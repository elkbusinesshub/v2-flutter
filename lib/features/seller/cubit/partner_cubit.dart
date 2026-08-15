import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';

import '../../../core/api/dispatch_socket.dart';
import '../../../core/errors/api_exception.dart';
import '../../../data/models/dispatch_models.dart';
import '../../../data/repositories/dispatch_repository.dart';
import '../../../data/repositories/porter_repository.dart';
import '../../../data/repositories/ride_repository.dart';

part 'partner_state.dart';

/// How often a partner's position is sent while on duty.
///
/// Ten seconds is close enough that a rider's map does not visibly lag the
/// car, and far enough apart that a shift does not drain the battery. The
/// backend treats a partner as gone after ninety seconds of silence, so this
/// leaves room for several missed sends before that.
const _heartbeat = Duration(seconds: 10);

/// The partner persona inside the seller panel: a driver or delivery rider.
///
/// One cubit serves both products — the shapes are identical, and only the
/// endpoints differ — so a person who drives an auto and delivers parcels
/// works the same screen for either.
class PartnerCubit extends Cubit<PartnerState> {
  PartnerCubit(this._dispatch, this._rides, this._porter, this._socket)
      : super(const PartnerState());

  final DispatchRepository _dispatch;
  final RideRepository _rides;
  final PorterRepository _porter;
  final DispatchSocket _socket;

  Timer? _heartbeatTimer;
  StreamSubscription<JobOfferModel>? _offerSub;
  StreamSubscription<String>? _closedSub;

  /// Loads the partner's vehicles and whatever job they are already on.
  ///
  /// A partner who closed the app mid-trip must land back on it, not on an
  /// empty screen with a customer waiting.
  Future<void> load() async {
    emit(state.copyWith(status: PartnerStatus.loading));
    try {
      final profiles = await _dispatch.myProfiles();
      emit(state.copyWith(
        status: PartnerStatus.ready,
        profiles: profiles,
        service: state.service,
      ));
      await _listen();
      await refreshActiveJob();
      if (state.profile?.isOnline ?? false) _startHeartbeat();
    } catch (e) {
      emit(state.copyWith(
        status: PartnerStatus.error,
        errorMessage: friendlyErrorMessage(e),
      ));
    }
  }

  /// Switches between driving and delivering.
  Future<void> selectService(DriverService service) async {
    if (service == state.service) return;
    emit(state.copyWith(service: service, offers: const [], activeJob: null));
    await refreshActiveJob();
  }

  /// Registers, or re-registers, the vehicle for the selected product.
  Future<String?> register({
    required String vehicleSlug,
    required String vehicleLabel,
    required String plateNumber,
  }) async {
    try {
      final profile = await _dispatch.register(
        service: state.service,
        vehicleSlug: vehicleSlug,
        vehicleLabel: vehicleLabel,
        plateNumber: plateNumber,
      );
      emit(state.copyWith(profiles: [
        for (final p in state.profiles)
          if (p.service != profile.service) p,
        profile,
      ]));
      return null;
    } catch (e) {
      return friendlyErrorMessage(e);
    }
  }

  /// Goes on or off duty, carrying the current position so dispatch can reach
  /// them straight away rather than only after the first heartbeat.
  Future<String?> setOnline(bool online) async {
    final profile = state.profile;
    if (profile == null) return null;
    emit(state.copyWith(isTogglingDuty: true));
    try {
      final position = online ? await _position() : null;
      final updated = await _dispatch.setOnline(
        service: state.service,
        isOnline: online,
        lat: position?.latitude,
        lng: position?.longitude,
      );
      emit(state.copyWith(
        isTogglingDuty: false,
        profiles: [
          for (final p in state.profiles)
            if (p.service != updated.service) p,
          updated,
        ],
        // Offers are only meaningful while on duty.
        offers: online ? state.offers : const [],
      ));
      if (online) {
        _startHeartbeat();
      } else {
        _stopHeartbeat();
      }
      return null;
    } catch (e) {
      emit(state.copyWith(isTogglingDuty: false));
      return friendlyErrorMessage(e);
    }
  }

  /// Takes a job. Whoever gets there first wins, so this can legitimately fail.
  Future<String?> accept(JobOfferModel offer) async {
    emit(state.copyWith(acceptingId: offer.bookingId));
    try {
      offer.service == DriverService.ride
          ? await _rides.acceptRide(offer.bookingId)
          : await _porter.acceptJob(offer.bookingId);
      emit(state.copyWith(offers: const []).clearingAccepting());
      await refreshActiveJob();
      return null;
    } catch (e) {
      // Most often "somebody else took it" — drop it from the list so the
      // partner is not staring at a job that no longer exists.
      emit(state
          .copyWith(offers: [
            for (final o in state.offers)
              if (o.bookingId != offer.bookingId) o,
          ])
          .clearingAccepting());
      return friendlyErrorMessage(e);
    }
  }

  /// Declines an offer — locally only. The job stays on offer to everyone
  /// else, and there is nothing for the server to record about a partner who
  /// simply did not take it.
  void decline(String bookingId) => emit(state.copyWith(offers: [
        for (final o in state.offers)
          if (o.bookingId != bookingId) o,
      ]));

  Future<void> refreshActiveJob() async {
    try {
      final job = state.service == DriverService.ride
          ? await _rides.driverActiveTrip()
          : await _porter.driverActiveJob();
      emit(state.copyWith(activeJob: job, clearActiveJob: job == null));
    } catch (_) {
      // A partner with no profile for this product has no active job either.
      emit(state.copyWith(clearActiveJob: true));
    }
  }

  /// Collects the rider or the parcel, against the code they show.
  Future<String?> startJob(String otpCode) => _jobAction(
        (id) => state.service == DriverService.ride
            ? _rides.driverStart(id, otpCode)
            : _porter.driverPickUp(id, otpCode),
      );

  /// Ends the job, which frees the partner for the next one.
  Future<String?> finishJob() => _jobAction(
        (id) => state.service == DriverService.ride
            ? _rides.driverComplete(id)
            : _porter.driverDeliver(id),
      );

  Future<String?> _jobAction(Future<void> Function(String id) action) async {
    final job = state.activeJob;
    if (job == null) return null;
    emit(state.copyWith(isWorking: true));
    try {
      await action(job.id);
      emit(state.copyWith(isWorking: false));
      await refreshActiveJob();
      return null;
    } catch (e) {
      emit(state.copyWith(isWorking: false));
      return friendlyErrorMessage(e);
    }
  }

  // ─── realtime + heartbeat ──────────────────────────────────────────────

  Future<void> _listen() async {
    if (_offerSub != null) return;
    await _socket.connect();
    _offerSub = _socket.offers.listen((offer) {
      // Only for the product currently being worked, and never while already
      // on a job.
      if (offer.service != state.service || state.activeJob != null) return;
      emit(state.copyWith(offers: [
        offer,
        for (final o in state.offers)
          if (o.bookingId != offer.bookingId) o,
      ]));
    });
    _closedSub = _socket.closedOffers.listen(decline);
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    unawaited(_sendPosition());
    _heartbeatTimer = Timer.periodic(_heartbeat, (_) => unawaited(_sendPosition()));
  }

  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  Future<void> _sendPosition() async {
    try {
      final position = await _position();
      if (position == null) return;
      await _dispatch.sendLocation(
        service: state.service,
        lat: position.latitude,
        lng: position.longitude,
      );
      emit(state.copyWith(lastSentAt: DateTime.now()));
    } catch (_) {
      // A missed heartbeat is not worth surfacing: the next one is ten
      // seconds away, and the backend tolerates several before it drops the
      // partner from dispatch.
    }
  }

  Future<Position?> _position() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return null;
    }
    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
  }

  @override
  Future<void> close() {
    _stopHeartbeat();
    _offerSub?.cancel();
    _closedSub?.cancel();
    return super.close();
  }
}
