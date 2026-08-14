import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/widgets/state_views.dart';
import '../../../data/models/ride_models.dart';
import '../cubit/ride_booking_cubit.dart';

import '../../../core/widgets/location_picker_sheet.dart';
import '../../../core/widgets/live_map_view.dart';
import '../../../core/location/current_location.dart';
import '../../../core/location/trip_point.dart';
import '../../../data/repositories/places_repository.dart';
import '../../../l10n/app_localizations.dart';

// ─── Design tokens (from elk-ride-booking-flow HTML) ──────────────────────────
const _teal = Color(0xFF14B8A6);
const _tealDark = Color(0xFF0D9488);
const _tealDeep = Color(0xFF0B6F64);
const _tealTint = Color(0xFFE7FAF7);
const _yellowDark = Color(0xFFE6A800);
const _yellowTint = Color(0xFFFFF7E0);
const _ink = Color(0xFF16212B);
const _inkSoft = Color(0xFF64737C);
const _inkFaint = Color(0xFF9AA6AB);
const _line = Color(0xFFE8EDEF);
const _red = Color(0xFFEF4B41);
const _grayBg = Color(0xFFF3F5F6);

TextStyle _o({double sz = 14, FontWeight w = FontWeight.w600, Color c = _ink, double h = 1.3}) =>
    GoogleFonts.outfit(fontSize: sz, fontWeight: w, color: c, height: h);

String _money(double n) => '₹${n.toStringAsFixed(2)}';

// ─── Ride presentation ────────────────────────────────────────────────────────
/// Marketing copy per ride class — presentation only (the backend's
/// RideType carries fares, seats, ETA and badges but no description).
String _rideBlurb(RideTypeModel r, AppLocalizations l10n) => switch (r.id) {
      'auto' => l10n.rideBlurbAutoShort,
      'economy' => l10n.rideBlurbEconomyShort,
      'premium' => l10n.rideBlurbPremiumShort,
      'xl' => l10n.rideBlurbXl,
      _ => l10n.rideSeats(r.seats),
    };

/// Fare breakdown lines derived from the server's base fare — the backend
/// bills a single `totalAmount`, so the split is illustrative only.
List<(String, double)> _fareLines(
  RideTypeModel r,
  double distanceKm,
  int etaMinutes,
  AppLocalizations l10n,
) => [
      (l10n.fareBase, (r.price * 0.3)),
      (l10n.fareDistance(distanceKm.toStringAsFixed(1)), (r.price * 0.5)),
      (l10n.fareTime(etaMinutes), (r.price * 0.13)),
      (l10n.fareBookingFee, (r.price * 0.07)),
    ];

Map<String, String> _payLabelsFor(AppLocalizations l10n) => {
  'cash': l10n.payCash,
  'card': l10n.payCard,
  'wallet': l10n.payElkWallet,
  'applepay': l10n.payApplePay,
};

// Screens: 0 book · 1 finding · 2 assigned · 3 payment · 4 card · 5 processing
//          6 confirmed · 7 pickup(OTP) · 8 trip · 9 completed · 10 receipt

// ─── Flow ─────────────────────────────────────────────────────────────────────
class RideBookingFlow extends StatefulWidget {
  const RideBookingFlow({super.key});

  @override
  State<RideBookingFlow> createState() => _RideBookingFlowState();
}

class _RideBookingFlowState extends State<RideBookingFlow>
    with SingleTickerProviderStateMixin {
  int _screen = 0;

  AppLocalizations get l10n => AppLocalizations.of(context);

  /// Empty until picked or GPS-filled — a default that names a real place the
  /// user has never been to gets submitted with the booking.
  TripPoint _pickup = const TripPoint.empty();
  TripPoint _dropoff = const TripPoint.empty();

  int _pill = 0;
  String _pay = 'card';

  // card form
  final _numCtrl = TextEditingController();
  final _expCtrl = TextEditingController();
  final _cvvCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  bool _saveCard = true;

  RideBookingCubit get _cubit => context.read<RideBookingCubit>();

  // payment state — the code and timestamp come from the created booking
  String _txnTime = '';

  // completed
  int _stars = 0;
  double _tip = 0;

  // timers / eta
  Timer? _timer;
  Timer? _etaTimer;
  int _etaSecs = 0;

  late final AnimationController _radarCtrl =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 2200))..repeat();

  /// The selected ride class from the live catalogue.
  RideTypeModel? get _ride => _cubit.state.selectedRideType;

  double get _distanceKm => _cubit.state.estimate?.distanceKm ?? 0;
  int get _routeEta => _cubit.state.estimate?.etaMinutes ?? 0;
  double get _farePaid => _cubit.state.booking?.fare ?? _ride?.price ?? 0;

  // The assigned driver, from the server. No rating/trip-count is returned, so
  // the plate and vehicle stand in rather than an invented "4.9 · 2,340 trips".
  String get _driverName => _cubit.state.driverName ?? l10n.assigningDriver;
  String get _vehicleLabel {
    final vehicle = _cubit.state.vehicle;
    final plate = _cubit.state.plateNumber;
    if (vehicle == null && plate == null) return l10n.detailsOnTheWay;
    return [vehicle, plate].where((v) => v != null && v.isNotEmpty).join(' · ');
  }

  String get _driverInitials {
    final parts = _driverName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '–';
    final first = parts.first[0];
    final last = parts.length > 1 && parts.last.isNotEmpty ? parts.last[0] : '';
    return (first + last).toUpperCase();
  }
  String get _txnId => _cubit.state.booking?.code ?? '';

  @override
  void initState() {
    super.initState();
    _prefillPickupFromGps();
    _cubit.loadOptions();
  }

  /// Best-effort: names the device's position as the pickup so the common case
  /// needs no typing. Silent on failure — the user picks manually, which beats
  /// showing an address we did not measure.
  Future<void> _prefillPickupFromGps() async {
    if (_pickup.isNotEmpty) return;
    try {
      final place = await resolveCurrentLocation(context.read<PlacesRepository>());
      if (!mounted || _pickup.isNotEmpty) return;
      setState(() => _pickup = TripPoint(
            address: place.formattedAddress,
            lat: place.lat,
            lng: place.lng,
          ));
    } catch (_) {
      // No permission, no signal, or guest — leave it for the picker.
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _etaTimer?.cancel();
    _radarCtrl.dispose();
    _numCtrl.dispose();
    _expCtrl.dispose();
    _cvvCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  // ─── navigation & timers ──────────────────────────────────────────────────
  void _goTo(int i) {
    _timer?.cancel();
    _etaTimer?.cancel();
    setState(() => _screen = i.clamp(0, 10));

    // 1 = searching: ask the backend for a driver-match preview.
    if (i == 1) {
      _cubit.previewDriver().then((ok) {
        if (mounted && ok) _goTo(2);
      });
    }
    if (i == 2) _startEta(180, 45);
    // 5 = processing: create the real booking, then show confirmation.
    if (i == 5) {
      _confirmPayment().then((ok) {
        if (!mounted) return;
        _goTo(ok ? 6 : 3);
      });
    }
    if (i == 6) {
      _timer = Timer(const Duration(milliseconds: 1600), () => _goTo(7));
    }
    if (i == 7) _startEta(75, 20);
  }

  void _startEta(int start, int floor) {
    _etaSecs = start;
    _etaTimer = Timer.periodic(const Duration(milliseconds: 700), (t) {
      setState(() {
        _etaSecs -= 15;
        if (_etaSecs <= floor) {
          _etaSecs = floor;
          t.cancel();
        }
      });
    });
  }

  String get _etaText {
    final m = _etaSecs ~/ 60, s = _etaSecs % 60;
    return '$m:${s.toString().padLeft(2, '0')} away';
  }

  /// Creates the ride server-side — this is what assigns the driver, issues
  /// the pickup OTP and returns the tracking code shown on the receipt.
  Future<bool> _confirmPayment() async {
    if (_cubit.state.booking != null) return true;
    final messenger = ScaffoldMessenger.of(context);
    // Booking with a blank route would store an empty pickup on a real ride.
    if (_pickup.isEmpty || _dropoff.isEmpty) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.setPickupAndDrop)));
      return false;
    }
    final ok = await _cubit.confirmBooking(
      pickupAddress: _pickup.address,
      dropAddress: _dropoff.address,
    );
    if (!mounted) return false;
    if (!ok) {
      messenger.showSnackBar(SnackBar(
        content: Text(_cubit.state.actionError ?? l10n.couldNotBookRide),
      ));
      return false;
    }
    final now = DateTime.now();
    _txnTime =
        DateFormat('dd MMM yyyy, HH:mm', l10n.localeName).format(now);
    return true;
  }

  void _restart() {
    setState(() {
      _tip = 0;
      _stars = 0;
      _pay = 'card';
      _txnTime = '';
      _numCtrl.clear();
      _expCtrl.clear();
      _cvvCtrl.clear();
      _nameCtrl.clear();
    });
    _goTo(0);
  }

  void _back() {
    switch (_screen) {
      case 0:
        Navigator.pop(context);
      case 1 || 2:
        _goTo(0);
      case 3:
        _goTo(2);
      case 4:
        _goTo(3);
      default:
        break; // no back from processing onwards
    }
  }

  Future<void> _pickLocation(bool isPickup) async {
    final picked = await showLocationPicker(
      context,
      title: isPickup ? l10n.choosePickupLocation : l10n.chooseDropoffLocation,
    );
    if (picked == null) return;
    final point = TripPoint(
      address: picked.address,
      lat: picked.lat,
      lng: picked.lng,
    );
    setState(() {
      if (isPickup) {
        _pickup = point;
      } else {
        _dropoff = point;
      }
    });
  }

  // ─── build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    // BlocBuilder is load-bearing: every screen below reads `_cubit.state`
    // directly, so without a rebuild trigger the flow renders once with the
    // initial loading state and never updates when loadOptions() returns.
    return BlocBuilder<RideBookingCubit, RideBookingState>(
      bloc: _cubit,
      builder: (context, _) => PopScope(
      canPop: false,
      onPopInvokedWithResult: (_, _) => _back(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          bottom: false,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, anim) => FadeTransition(
              opacity: anim,
              child: SlideTransition(
                position: Tween(begin: const Offset(0, 0.02), end: Offset.zero).animate(anim),
                child: child,
              ),
            ),
            child: KeyedSubtree(
              key: ValueKey(_screen),
              child: switch (_screen) {
                0 => _s0Book(),
                1 => _s1Finding(),
                2 => _s2Assigned(),
                3 => _s3Payment(),
                4 => _s4Card(),
                5 => _s5Processing(),
                6 => _s6Confirmed(),
                7 => _s7Pickup(),
                8 => _s8Trip(),
                9 => _s9Completed(),
                _ => _s10Receipt(),
              },
            ),
          ),
        ),
      ),
      ),
    );
  }

  // ─── shared bits ──────────────────────────────────────────────────────────
  Widget _sTop({String? title, Widget? left, Widget? right}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 6),
      child: Row(children: [
        left ?? const SizedBox(width: 34),
        Expanded(
          child: Center(child: Text(title ?? '', style: _o(sz: 16, w: FontWeight.w700))),
        ),
        right ?? const SizedBox(width: 34),
      ]),
    );
  }

  Widget _backCircle({VoidCallback? onTap, IconData icon = Icons.chevron_left_rounded}) {
    return GestureDetector(
      onTap: onTap ?? _back,
      child: Container(
        width: 34, height: 34,
        decoration: const BoxDecoration(color: _grayBg, shape: BoxShape.circle),
        child: Icon(icon, size: 20, color: _ink),
      ),
    );
  }

  Widget _bottomBar(Widget child) {
    final pad = MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(18, 14, 18, pad + 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: _line)),
      ),
      child: child,
    );
  }

  Widget _primaryBtn(String label, VoidCallback onTap, {Widget? trailing}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 18),
        decoration: BoxDecoration(
          color: _teal,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(color: Color(0x8C14B8A6), blurRadius: 22, offset: Offset(0, 12), spreadRadius: -8)],
        ),
        child: Row(
          mainAxisAlignment: trailing == null ? MainAxisAlignment.center : MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: _o(sz: 14.5, w: FontWeight.w700, c: Colors.white)),
            ?trailing,
          ],
        ),
      ),
    );
  }

  // ═══ Screen 0 — Book a Ride ═══════════════════════════════════════════════
  Widget _s0Book() {
    final state = _cubit.state;
    if (state.optionsStatus == RideOptionsStatus.error) {
      return SafeArea(
        child: ErrorRetryView(
          message: state.optionsError ?? l10n.errorGeneric,
          onRetry: _cubit.loadOptions,
        ),
      );
    }
    final r = _ride;
    if (r == null) return const LoadingView();
    return Column(children: [
      _sTop(title: l10n.taxiBookARide, left: _backCircle()),
      _RideMap(
        height: 176,
        kind: _MapKind.book,
        pickup: _pickup,
        dropoff: _dropoff,
        chip: '$_routeEta min · ${_distanceKm.toStringAsFixed(1)} km',
        locateBtn: true,
      ),
      Expanded(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // trip card
            Container(
              margin: const EdgeInsets.only(top: 14, bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: _line),
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [BoxShadow(color: Color(0x0D141E1E), blurRadius: 18, offset: Offset(0, 6))],
              ),
              child: Stack(children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  GestureDetector(
                    onTap: () => _pickLocation(true),
                    behavior: HitTestBehavior.opaque,
                    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Container(
                        width: 10, height: 10,
                        margin: const EdgeInsets.only(top: 4),
                        decoration: const BoxDecoration(color: _teal, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(l10n.taxiPickup, style: _o(sz: 10.5, w: FontWeight.w700, c: _inkSoft).copyWith(letterSpacing: 0.4)),
                          const SizedBox(height: 1),
                          Text(_pickup.isEmpty ? l10n.setPickupLocation : _pickup.address, maxLines: 2, overflow: TextOverflow.ellipsis,
                              style: _o(sz: 14, w: FontWeight.w700)),
                        ]),
                      ),
                      const SizedBox(width: 40),
                    ]),
                  ),
                  Container(width: 1, height: 16, color: _line, margin: const EdgeInsets.only(left: 5)),
                  GestureDetector(
                    onTap: () => _pickLocation(false),
                    behavior: HitTestBehavior.opaque,
                    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Container(
                        width: 10, height: 10,
                        margin: const EdgeInsets.only(top: 4),
                        decoration: const BoxDecoration(color: _red, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(l10n.taxiDropoff, style: _o(sz: 10.5, w: FontWeight.w700, c: _inkSoft).copyWith(letterSpacing: 0.4)),
                          const SizedBox(height: 1),
                          Text(_dropoff.isEmpty ? l10n.setDropLocation : _dropoff.address, maxLines: 2, overflow: TextOverflow.ellipsis,
                              style: _o(sz: 14, w: FontWeight.w700)),
                        ]),
                      ),
                      const SizedBox(width: 40),
                    ]),
                  ),
                ]),
                Positioned(
                  right: 0, top: 0, bottom: 0,
                  child: Center(
                    child: GestureDetector(
                      onTap: () => setState(() {
                        final t = _pickup;
                        _pickup = _dropoff;
                        _dropoff = t;
                      }),
                      child: Container(
                        width: 34, height: 34,
                        decoration: const BoxDecoration(color: _tealTint, shape: BoxShape.circle),
                        child: const Icon(Icons.swap_vert_rounded, size: 17, color: _tealDark),
                      ),
                    ),
                  ),
                ),
              ]),
            ),
            // filter pills
            Row(children: [
              _filterPill(0, '★ Recommended'),
              const SizedBox(width: 8),
              _filterPill(1, '⏱ Faster'),
              const SizedBox(width: 8),
              _filterPill(2, r'$ Cheaper'),
            ]),
            const SizedBox(height: 16),
            Text(l10n.taxiChooseRide, style: _o(sz: 14.5, w: FontWeight.w800)),
            const SizedBox(height: 10),
            for (final ride in _sortedRides()) ...[
              _rideCard(ride),
              const SizedBox(height: 10),
            ],
          ]),
        ),
      ),
      _bottomBar(
        Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(color: _grayBg, borderRadius: BorderRadius.circular(14)),
            child: Row(children: [
              Icon(Icons.payments_outlined, size: 14, color: _ink),
              const SizedBox(width: 6),
              Text(l10n.payCash, style: _o(sz: 13, w: FontWeight.w700)),
            ]),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _primaryBtn(
              'Book ${r.name}',
              () => _goTo(1),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(_money(r.price), style: _o(sz: 13, w: FontWeight.w600, c: Colors.white)),
              ),
            ),
          ),
        ]),
      ),
    ]);
  }

  List<RideTypeModel> _sortedRides() {
    final list = [..._cubit.state.rideTypes];
    if (_pill == 1) list.sort((a, b) => a.etaMinutes.compareTo(b.etaMinutes));
    if (_pill == 2) list.sort((a, b) => a.price.compareTo(b.price));
    return list;
  }

  Widget _filterPill(int i, String label) {
    final on = _pill == i;
    return GestureDetector(
      onTap: () => setState(() => _pill = i),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: on ? _tealTint : Colors.white,
          border: Border.all(color: on ? _teal : _line, width: 1.5),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(label, style: _o(sz: 12, w: FontWeight.w700, c: on ? _tealDark : _inkSoft)),
      ),
    );
  }

  Widget _rideCard(RideTypeModel r) {
    final on = _cubit.state.selectedRideTypeId == r.id;
    return GestureDetector(
      onTap: () => _cubit.selectRideType(r.id),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: on ? _tealTint : Colors.white,
          border: Border.all(color: on ? _teal : _line, width: 2),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(children: [
          SizedBox(width: 42, child: Text(r.emoji, textAlign: TextAlign.center, style: const TextStyle(fontSize: 27))),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text(r.name, style: _o(sz: 14.5, w: FontWeight.w800)),
                if (r.badge != null) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: _teal),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(r.badge!, style: _o(sz: 9.5, w: FontWeight.w800, c: _tealDark)),
                  ),
                ],
              ]),
              const SizedBox(height: 2),
              Text('⏱ ${r.etaMinutes} min · 👤 ${r.seats}', style: _o(sz: 11.5, w: FontWeight.w600, c: _inkSoft)),
              const SizedBox(height: 2),
              Text(_rideBlurb(r, l10n), style: _o(sz: 11.5, w: FontWeight.w500, c: _inkSoft)),
            ]),
          ),
          Text('₹${r.price.toStringAsFixed(0)}', style: _o(sz: 15, w: FontWeight.w800)),
        ]),
      ),
    );
  }

  // ═══ Screen 1 — Finding Driver ════════════════════════════════════════════
  Widget _s1Finding() {
    return Column(children: [
      _sTop(
        title: l10n.findingDriver,
        right: _backCircle(onTap: () => _goTo(0), icon: Icons.close_rounded),
      ),
      _RideMap(
        height: 208,
        kind: _MapKind.finding,
        pickup: _pickup,
        dropoff: _dropoff,
        emoji: _ride?.emoji ?? '🚗',
        radarCtrl: _radarCtrl,
      ),
      Expanded(
        child: Padding(
          padding: const EdgeInsets.only(top: 18),
          child: Column(children: [
            _BlinkDots(text: l10n.lookingForDrivers),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 28),
              child: Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                children: [
                  Text(_pickup.isEmpty ? l10n.setPickupLocation : _pickup.address, style: _o(sz: 12, w: FontWeight.w600, c: _inkSoft)),
                  Text('→', style: _o(sz: 12, w: FontWeight.w700, c: _teal)),
                  Text(_dropoff.address, style: _o(sz: 12, w: FontWeight.w600, c: _inkSoft)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(color: _tealTint, borderRadius: BorderRadius.circular(24)),
              child: Text('${_ride?.name ?? ''} · ${_money(_ride?.price ?? 0)}',
                  style: _o(sz: 13, w: FontWeight.w800, c: _tealDark)),
            ),
          ]),
        ),
      ),
    ]);
  }

  // ═══ Screen 2 — Driver Assigned ═══════════════════════════════════════════
  Widget _s2Assigned() {
    final r = _ride;
    if (r == null) return const LoadingView();
    return Column(children: [
      _sTop(title: l10n.driverAssigned, left: _backCircle(onTap: () => _goTo(0))),
      _RideMap(
        height: 176,
        kind: _MapKind.assigned,
        pickup: _pickup,
        dropoff: _dropoff,
        eta: _etaText,
      ),
      Expanded(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
          child: Column(children: [
            _driverCard(r),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                l10n.completePaymentNote,
                textAlign: TextAlign.center,
                style: _o(sz: 12.5, w: FontWeight.w600, c: _inkSoft, h: 1.6),
              ),
            ),
          ]),
        ),
      ),
      _bottomBar(_primaryBtn(l10n.proceedToPayment, () => _goTo(3))),
    ]);
  }

  Widget _driverCard(RideTypeModel r) {
    return Container(
      margin: const EdgeInsets.only(top: 14, bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: _line),
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [BoxShadow(color: Color(0x0D141E1E), blurRadius: 18, offset: Offset(0, 6))],
      ),
      child: Column(children: [
        Row(children: [
          Container(
            width: 46, height: 46,
            decoration: const BoxDecoration(color: _tealTint, shape: BoxShape.circle),
            child: Center(child: Text(_driverInitials, style: _o(sz: 15, w: FontWeight.w800, c: _tealDark))),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(_driverName, style: _o(sz: 14.5, w: FontWeight.w800)),
              const SizedBox(height: 1),
              Text(_vehicleLabel, style: _o(sz: 12, w: FontWeight.w600, c: _inkSoft)),
            ]),
          ),
          _iconCircle(Icons.phone_outlined),
          const SizedBox(width: 8),
          _iconCircle(Icons.chat_bubble_outline_rounded),
        ]),
        Container(
          margin: const EdgeInsets.only(top: 12),
          padding: const EdgeInsets.only(top: 12),
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: _line, style: BorderStyle.solid)),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Flexible(
              child: Text.rich(
                TextSpan(children: [
                  TextSpan(text: '${r.emoji} ', style: const TextStyle(fontSize: 13)),
                  TextSpan(text: _cubit.state.vehicle ?? '', style: _o(sz: 13, w: FontWeight.w700)),
                ]),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: _grayBg, borderRadius: BorderRadius.circular(6)),
              child: Text(_cubit.state.plateNumber ?? '', style: _o(sz: 11.5, w: FontWeight.w800).copyWith(letterSpacing: 0.4)),
            ),
          ]),
        ),
      ]),
    );
  }

  Widget _iconCircle(IconData icon, {double size = 36}) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: _line),
        color: Colors.white,
      ),
      child: Icon(icon, size: size * 0.42, color: _tealDark),
    );
  }

  // ═══ Screen 3 — Payment Method ════════════════════════════════════════════
  Widget _s3Payment() {
    final r = _ride;
    if (r == null) return const LoadingView();
    return Column(children: [
      _sTop(title: l10n.sectionPayment, left: _backCircle()),
      Expanded(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 18, 0, 4),
              child: Center(
                child: Column(children: [
                  Text(l10n.amountDue, style: _o(sz: 12, w: FontWeight.w700, c: _inkSoft).copyWith(letterSpacing: 0.4)),
                  const SizedBox(height: 4),
                  Text(_money(r.price), style: _o(sz: 34, w: FontWeight.w800)),
                ]),
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(color: _grayBg, borderRadius: BorderRadius.circular(16)),
              child: Column(children: [
                for (final (label, amt) in _fareLines(r, _distanceKm, _routeEta, l10n))
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text(label, style: _o(sz: 13, w: FontWeight.w600, c: _inkSoft)),
                      Text(_money(amt), style: _o(sz: 13, w: FontWeight.w600, c: _inkSoft)),
                    ]),
                  ),
                Container(
                  margin: const EdgeInsets.only(top: 6),
                  padding: const EdgeInsets.only(top: 10),
                  decoration: const BoxDecoration(border: Border(top: BorderSide(color: _line))),
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text(l10n.total, style: _o(sz: 15, w: FontWeight.w800)),
                    Text(_money(r.price), style: _o(sz: 15, w: FontWeight.w800)),
                  ]),
                ),
              ]),
            ),
            const SizedBox(height: 18),
            Text(l10n.selectPaymentMethod, style: _o(sz: 14.5, w: FontWeight.w800)),
            const SizedBox(height: 10),
            _payOption('cash', Icons.payments_outlined, l10n.payCash, l10n.payCashSub),
            const SizedBox(height: 10),
            _payOption('card', Icons.credit_card, l10n.payCard, l10n.payCardSub),
            const SizedBox(height: 10),
            _payOption('wallet', Icons.account_balance_wallet_outlined, l10n.payElkWallet, l10n.payWalletSub),
            const SizedBox(height: 10),
            _payOption('applepay', Icons.smartphone_rounded, l10n.payApplePayGooglePay, l10n.payApplePaySub),
            const SizedBox(height: 14),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.lock_outline_rounded, size: 12, color: _inkSoft),
              const SizedBox(width: 6),
              Text(l10n.paymentsSecured,
                  style: _o(sz: 11.5, w: FontWeight.w600, c: _inkSoft)),
            ]),
          ]),
        ),
      ),
      _bottomBar(_primaryBtn(
        'Pay ${_money(r.price)}',
        () => _pay == 'card' ? _goTo(4) : _goTo(5),
      )),
    ]);
  }

  Widget _payOption(String id, IconData icon, String title, String sub) {
    final on = _pay == id;
    return GestureDetector(
      onTap: () => setState(() => _pay = id),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: on ? _tealTint : Colors.white,
          border: Border.all(color: on ? _teal : _line, width: 2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [BoxShadow(color: Color(0x0F000000), blurRadius: 6, offset: Offset(0, 2))],
            ),
            child: Icon(icon, size: 18, color: _tealDark),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: _o(sz: 13.5, w: FontWeight.w700)),
              Text(sub, style: _o(sz: 11.5, w: FontWeight.w600, c: _inkSoft)),
            ]),
          ),
          Container(
            width: 20, height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: on ? _teal : Colors.transparent,
              border: Border.all(color: on ? _teal : _line, width: 2),
            ),
            child: on ? const Icon(Icons.check, size: 12, color: Colors.white) : null,
          ),
        ]),
      ),
    );
  }

  // ═══ Screen 4 — Card Details ══════════════════════════════════════════════
  Widget _s4Card() {
    final digits = _numCtrl.text.replaceAll(RegExp(r'\D'), '');
    final groups = <String>[];
    for (var i = 0; i < 16; i += 4) {
      var seg = digits.length > i ? digits.substring(i, math.min(i + 4, digits.length)) : '';
      seg = seg.padRight(4, '•');
      groups.add(seg);
    }
    final cpName = _nameCtrl.text.trim().isEmpty ? l10n.cardYourName : _nameCtrl.text.toUpperCase();
    final cpExp = _expCtrl.text.isEmpty ? 'MM/YY' : _expCtrl.text;

    return Column(children: [
      _sTop(title: l10n.cardDetails, left: _backCircle()),
      Expanded(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // card preview
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                  colors: [_tealDark, _tealDeep],
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Stack(children: [
                Positioned(
                  right: -60, top: -60,
                  child: Container(
                    width: 180, height: 180,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('ELK Pay', style: _o(sz: 13, w: FontWeight.w800, c: Colors.white).copyWith(letterSpacing: 0.5)),
                    const Text('💳', style: TextStyle(fontSize: 14)),
                  ]),
                  const SizedBox(height: 22),
                  Text(groups.join(' '),
                      style: _o(sz: 19, w: FontWeight.w700, c: Colors.white).copyWith(letterSpacing: 2)),
                  const SizedBox(height: 18),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(l10n.cardHolder,
                          style: _o(sz: 9, w: FontWeight.w700, c: Colors.white.withValues(alpha: 0.7))
                              .copyWith(letterSpacing: 0.5)),
                      const SizedBox(height: 3),
                      Text(cpName, style: _o(sz: 12.5, w: FontWeight.w700, c: Colors.white)),
                    ]),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(l10n.cardExpires,
                          style: _o(sz: 9, w: FontWeight.w700, c: Colors.white.withValues(alpha: 0.7))
                              .copyWith(letterSpacing: 0.5)),
                      const SizedBox(height: 3),
                      Text(cpExp, style: _o(sz: 12.5, w: FontWeight.w700, c: Colors.white)),
                    ]),
                  ]),
                ]),
              ]),
            ),
            const SizedBox(height: 18),
            _field(l10n.cardNumber, _numCtrl, '1234 5678 9012 3456'),
            Row(children: [
              Expanded(child: _field(l10n.cardExpiry, _expCtrl, 'MM/YY')),
              const SizedBox(width: 10),
              Expanded(child: _field(l10n.cardCvv, _cvvCtrl, '•••', obscure: true)),
            ]),
            _field(l10n.cardholderName, _nameCtrl, l10n.cardAsShown),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(l10n.saveCardForFuture, style: _o(sz: 13, w: FontWeight.w600)),
              Switch(
                value: _saveCard,
                onChanged: (v) => setState(() => _saveCard = v),
                activeTrackColor: _teal,
                thumbColor: const WidgetStatePropertyAll(Colors.white),
              ),
            ]),
          ]),
        ),
      ),
      _bottomBar(_primaryBtn('Pay ${_money(_farePaid)}', () {
        final d = _numCtrl.text.replaceAll(RegExp(r'\D'), '');
        if (d.length < 16 || _expCtrl.text.length < 5 || _cvvCtrl.text.length < 3 || _nameCtrl.text.trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.completeCardDetails)),
          );
          return;
        }
        _goTo(5);
      })),
    ]);
  }

  Widget _field(String label, TextEditingController ctrl, String hint, {bool obscure = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: _o(sz: 12, w: FontWeight.w700, c: _inkSoft)),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          obscureText: obscure,
          onChanged: (_) => setState(() {}),
          style: _o(sz: 14, w: FontWeight.w600),
          cursorColor: _teal,
          decoration: InputDecoration(
            isDense: true,
            hintText: hint,
            hintStyle: _o(sz: 14, w: FontWeight.w500, c: _inkFaint),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _line, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _teal, width: 1.5),
            ),
          ),
        ),
      ]),
    );
  }

  // ═══ Screen 5 — Processing ════════════════════════════════════════════════
  Widget _s5Processing() {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const SizedBox(
          width: 52, height: 52,
          child: CircularProgressIndicator(strokeWidth: 4, color: _teal, backgroundColor: _tealTint),
        ),
        const SizedBox(height: 16),
        Text(l10n.processingYourPayment, style: _o(sz: 15.5, w: FontWeight.w800)),
        const SizedBox(height: 6),
        Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.lock_outline_rounded, size: 12, color: _inkSoft),
          const SizedBox(width: 5),
          Text("Please don't close or refresh", style: _o(sz: 12, w: FontWeight.w600, c: _inkSoft)),
        ]),
      ]),
    );
  }

  // ═══ Screen 6 — Payment Confirmed ═════════════════════════════════════════
  Widget _s6Confirmed() {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.5, end: 1),
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutBack,
          builder: (_, v, child) => Transform.scale(scale: v, child: child),
          child: const Icon(Icons.check_circle_outline_rounded, size: 52, color: _teal),
        ),
        const SizedBox(height: 10),
        Text(l10n.paymentConfirmed, style: _o(sz: 17, w: FontWeight.w800)),
        const SizedBox(height: 6),
        Text(_money(_farePaid), style: _o(sz: 24, w: FontWeight.w800, c: _tealDark)),
        const SizedBox(height: 4),
        Text(l10n.otpBeingPrepared, style: _o(sz: 12, w: FontWeight.w600, c: _inkSoft)),
      ]),
    );
  }

  // ═══ Screen 7 — Driver On The Way (OTP) ═══════════════════════════════════
  Widget _s7Pickup() {
    final r = _ride;
    if (r == null) return const LoadingView();
    return Column(children: [
      _sTop(title: l10n.driverOnTheWay),
      _RideMap(
        height: 176,
        kind: _MapKind.pickup,
        pickup: _pickup,
        dropoff: _dropoff,
        eta: _etaText,
      ),
      Expanded(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
          child: Column(children: [
            _driverStrip(r),
            const SizedBox(height: 12),
            // OTP card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: _tealTint, borderRadius: BorderRadius.circular(16)),
              child: Column(children: [
                Text(l10n.shareOtpToStart, style: _o(sz: 12, w: FontWeight.w700, c: _tealDeep)),
                const SizedBox(height: 8),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  for (final d in (_cubit.state.booking?.otpCode ?? '----').split(''))
                    Container(
                      width: 34, height: 40,
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 8, offset: Offset(0, 3))],
                      ),
                      child: Center(child: Text(d, style: _o(sz: 18, w: FontWeight.w800))),
                    ),
                ]),
              ]),
            ),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: _safetyBtn(Icons.shield_outlined, l10n.safety)),
              const SizedBox(width: 10),
              Expanded(child: _safetyBtn(Icons.share_outlined, l10n.shareTrip)),
            ]),
          ]),
        ),
      ),
      _bottomBar(_primaryBtn(l10n.driverArrivedStartTrip, () async {
        final otp = _cubit.state.booking?.otpCode;
        if (otp == null) return;
        final messenger = ScaffoldMessenger.of(context);
        final ok = await _cubit.startRide(otp);
        if (!mounted) return;
        if (ok) {
          _goTo(8);
        } else {
          messenger.showSnackBar(SnackBar(
            content: Text(_cubit.state.actionError ?? l10n.couldNotStartTrip),
          ));
        }
      })),
    ]);
  }

  Widget _driverStrip(RideTypeModel r) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(color: _grayBg, borderRadius: BorderRadius.circular(14)),
      child: Row(children: [
        Container(
          width: 34, height: 34,
          decoration: const BoxDecoration(color: _tealTint, shape: BoxShape.circle),
          child: Center(child: Text('FA', style: _o(sz: 12, w: FontWeight.w800, c: _tealDark))),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text('${_cubit.state.driverName ?? ''} · ${_cubit.state.plateNumber ?? ''}',
              style: _o(sz: 12.5, w: FontWeight.w700), overflow: TextOverflow.ellipsis),
        ),
        _iconCircle(Icons.phone_outlined, size: 32),
      ]),
    );
  }

  Widget _safetyBtn(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 11),
      decoration: BoxDecoration(
        border: Border.all(color: _line),
        borderRadius: BorderRadius.circular(14),
        color: Colors.white,
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, size: 14, color: _ink),
        const SizedBox(width: 6),
        Text(label, style: _o(sz: 12.5, w: FontWeight.w700)),
      ]),
    );
  }

  // ═══ Screen 8 — Trip in Progress ══════════════════════════════════════════
  Widget _s8Trip() {
    final r = _ride;
    if (r == null) return const LoadingView();
    return Column(children: [
      _sTop(
        title: l10n.tripInProgress,
        right: _iconCircle(Icons.shield_outlined, size: 32),
      ),
      _RideMap(
        height: 208,
        kind: _MapKind.trip,
        pickup: _pickup,
        dropoff: _dropoff,
        // Was hardcoded to "9 min · 5.4 km" for every trip; these come from
        // the backend's fare estimate.
        eta: '$_routeEta min · ${_distanceKm.toStringAsFixed(1)} km',
      ),
      Expanded(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(l10n.headingTo, style: _o(sz: 10.5, w: FontWeight.w700, c: _inkSoft).copyWith(letterSpacing: 0.4)),
            const SizedBox(height: 1),
            Text(_dropoff.address, style: _o(sz: 14, w: FontWeight.w700)),
            const SizedBox(height: 12),
            _driverStrip(r),
          ]),
        ),
      ),
      _bottomBar(_primaryBtn(l10n.completeTrip, () async {
        final messenger = ScaffoldMessenger.of(context);
        final ok = await _cubit.completeRide();
        if (!mounted) return;
        if (ok) {
          _goTo(9);
        } else {
          messenger.showSnackBar(SnackBar(
            content: Text(_cubit.state.actionError ?? l10n.couldNotCompleteTrip),
          ));
        }
      })),
    ]);
  }

  // ═══ Screen 9 — Trip Completed ════════════════════════════════════════════
  Widget _s9Completed() {
    return Column(children: [
      _sTop(title: 'Trip Completed 🎉'),
      Expanded(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
          child: Column(children: [
            Text('You arrived at ${_dropoff.address}',
                textAlign: TextAlign.center, style: _o(sz: 13, w: FontWeight.w600, c: _inkSoft)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
              decoration: BoxDecoration(color: _grayBg, borderRadius: BorderRadius.circular(16)),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                _stat('8.2 km', l10n.distance),
                _stat('14 min', l10n.duration),
                _stat(_money(_farePaid), l10n.farePaid),
              ]),
            ),
            const SizedBox(height: 16),
            Container(
              width: 46, height: 46,
              decoration: const BoxDecoration(color: _tealTint, shape: BoxShape.circle),
              child: Center(child: Text('FA', style: _o(sz: 15, w: FontWeight.w800, c: _tealDark))),
            ),
            const SizedBox(height: 8),
            Text(l10n.rateDriver(_driverName), style: _o(sz: 14, w: FontWeight.w800)),
            const SizedBox(height: 8),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              for (int i = 1; i <= 5; i++)
                GestureDetector(
                  onTap: () => setState(() => _stars = i),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(
                      Icons.star_rounded,
                      size: 32,
                      color: i <= _stars ? _yellowDark : _line,
                    ),
                  ),
                ),
            ]),
            const SizedBox(height: 18),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(l10n.addATip, style: _o(sz: 14.5, w: FontWeight.w800)),
            ),
            const SizedBox(height: 8),
            Row(children: [
              _tipChip(0, l10n.noTip),
              const SizedBox(width: 8),
              _tipChip(2, '₹2'),
              const SizedBox(width: 8),
              _tipChip(5, '₹5'),
              const SizedBox(width: 8),
              _tipChip(10, '₹10'),
            ]),
            const SizedBox(height: 10),
            SizedBox(
              height: 16,
              child: _tip > 0
                  ? Text(
                      l10n.tipWillBeCharged(_money(_tip), _payLabelsFor(l10n)[_pay]!),
                      style: _o(sz: 12, w: FontWeight.w700, c: _tealDark),
                    )
                  : null,
            ),
          ]),
        ),
      ),
      _bottomBar(_primaryBtn(l10n.finishTrip, () async {
        final messenger = ScaffoldMessenger.of(context);
        // Rating is optional; only post when the rider picked stars.
        if (_stars > 0) {
          final ok = await _cubit.rateRide(stars: _stars, tip: _tip.round());
          if (!mounted) return;
          if (!ok) {
            messenger.showSnackBar(SnackBar(
              content: Text(_cubit.state.actionError ?? l10n.couldNotSubmitRating),
            ));
            return;
          }
        }
        if (mounted) _goTo(10);
      })),
    ]);
  }

  Widget _stat(String value, String label) {
    return Column(children: [
      Text(value, style: _o(sz: 14.5, w: FontWeight.w800)),
      const SizedBox(height: 3),
      Text(label, style: _o(sz: 11, w: FontWeight.w600, c: _inkSoft)),
    ]);
  }

  Widget _tipChip(double amt, String label) {
    final on = _tip == amt;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tip = amt),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: on ? _yellowTint : Colors.white,
            border: Border.all(color: on ? _yellowDark : _line, width: 1.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(label,
                style: _o(sz: 12.5, w: FontWeight.w700, c: on ? const Color(0xFF8A6100) : _inkSoft)),
          ),
        ),
      ),
    );
  }

  // ═══ Screen 10 — Trip Receipt ═════════════════════════════════════════════
  Widget _s10Receipt() {
    final total = _farePaid + _tip;
    return Column(children: [
      Expanded(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 30, 18, 16),
          child: Column(children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.5, end: 1),
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutBack,
              builder: (_, v, child) => Transform.scale(scale: v, child: child),
              child: const Icon(Icons.check_circle_outline_rounded, size: 58, color: _teal),
            ),
            const SizedBox(height: 10),
            Text(l10n.allDoneThanks, style: _o(sz: 18, w: FontWeight.w800)),
            const SizedBox(height: 6),
            Text(_money(total), style: _o(sz: 30, w: FontWeight.w800, c: _tealDark)),
            const SizedBox(height: 2),
            Text(l10n.totalVia(_payLabelsFor(l10n)[_pay]!), style: _o(sz: 12.5, w: FontWeight.w600, c: _inkSoft)),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(color: _grayBg, borderRadius: BorderRadius.circular(16)),
              child: Column(children: [
                _rcRow(l10n.trip, '${_pickup.address} → ${_dropoff.address}'),
                _rcRow(l10n.driver, _driverName),
                _rcRow(l10n.fare, _money(_farePaid)),
                if (_tip > 0) _rcRow(l10n.tip, _money(_tip)),
                _rcRow(l10n.transactionId, _txnId),
                _rcRow(l10n.labelDateTime, _txnTime),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  height: 1,
                  color: _line,
                ),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text(l10n.total, style: _o(sz: 14.5, w: FontWeight.w800)),
                  Text(_money(total), style: _o(sz: 14.5, w: FontWeight.w800)),
                ]),
              ]),
            ),
          ]),
        ),
      ),
      _bottomBar(
        Row(children: [
          Expanded(
            child: GestureDetector(
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.receiptDownloaded)),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: _line, width: 1.5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(child: Text(l10n.download, style: _o(sz: 14, w: FontWeight.w700))),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(flex: 2, child: _primaryBtn(l10n.bookAnotherTrip, _restart)),
        ]),
      ),
    ]);
  }

  Widget _rcRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: _o(sz: 12.5, w: FontWeight.w600, c: _inkSoft)),
        Flexible(
          child: Text(value,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              style: _o(sz: 12.5, w: FontWeight.w600, c: _inkSoft)),
        ),
      ]),
    );
  }
}

// ─── Blinking dots "Looking for nearby drivers..." ────────────────────────────
class _BlinkDots extends StatefulWidget {
  const _BlinkDots({required this.text});
  final String text;

  @override
  State<_BlinkDots> createState() => _BlinkDotsState();
}

class _BlinkDotsState extends State<_BlinkDots> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..repeat();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        double dotOpacity(double delay) {
          final t = (_ctrl.value - delay) % 1.0;
          if (t < 0 || t > 0.8) return 0;
          return t < 0.4 ? t / 0.4 : (0.8 - t) / 0.4;
        }

        return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(widget.text, style: _o(sz: 15, w: FontWeight.w700)),
          for (int i = 0; i < 3; i++)
            Opacity(
              opacity: dotOpacity(i * 0.14).clamp(0, 1),
              child: Text('.', style: _o(sz: 15, w: FontWeight.w700)),
            ),
        ]);
      },
    );
  }
}

// ─── Stylized map ─────────────────────────────────────────────────────────────
enum _MapKind { book, finding, assigned, pickup, trip }

class _RideMap extends StatelessWidget {
  const _RideMap({
    required this.height,
    required this.kind,
    required this.pickup,
    required this.dropoff,
    this.chip,
    this.eta,
    this.locateBtn = false,
    this.radarCtrl,
    this.emoji = '🚗',
  });

  final double height;
  final _MapKind kind;

  /// Both ends of the trip. Each may have no coordinate, in which case it
  /// simply is not pinned.
  final TripPoint pickup;
  final TripPoint dropoff;

  final String? chip;
  final String? eta;
  final bool locateBtn;
  final AnimationController? radarCtrl;

  /// Vehicle glyph for the radar ping while a driver is being found.
  final String emoji;

  @override
  Widget build(BuildContext context) {
    // The drop is hidden until the ride is actually going there: while a driver
    // is being found or is on the way, the leg that matters is to the pickup.
    final showDrop = kind == _MapKind.book || kind == _MapKind.trip;
    final points = [
      ?pickup.toMapPoint(MapPointKind.pickup),
      if (showDrop) ?dropoff.toMapPoint(MapPointKind.drop),
    ];

    return SizedBox(
      height: height,
      child: ClipRect(
        child: Stack(children: [
          if (points.isEmpty)
            const Positioned.fill(child: ColoredBox(color: Color(0xFFE9EEEA)))
          else
            LiveMapView(
              points: points,
              height: height,
              showRoute: points.length > 1,
              // These sit inside a scrolling column; a pannable map would
              // fight the scroll.
              interactive: false,
            ),
          // radar ping over the pickup, while a driver is being found
          if (kind == _MapKind.finding && radarCtrl != null)
            Positioned(
              left: 0, right: 0, top: 0, bottom: 0,
              child: Center(child: _Radar(ctrl: radarCtrl!, emoji: emoji)),
            ),
          // trip chip
          if (chip != null)
            Positioned(
              left: 14, bottom: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: const [BoxShadow(color: Color(0x1F000000), blurRadius: 16, offset: Offset(0, 6))],
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Container(width: 8, height: 8, decoration: const BoxDecoration(color: _teal, shape: BoxShape.circle)),
                  const SizedBox(width: 6),
                  Text(chip!, style: _o(sz: 12.5, w: FontWeight.w700)),
                ]),
              ),
            ),
          // eta chip
          if (eta != null)
            Positioned(
              top: 12, left: 0, right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                  decoration: BoxDecoration(color: _ink, borderRadius: BorderRadius.circular(24)),
                  child: Text(eta!, style: _o(sz: 12.5, w: FontWeight.w700, c: Colors.white)),
                ),
              ),
            ),
          // locate button
          if (locateBtn)
            Positioned(
              right: 14, bottom: 14,
              child: Container(
                width: 38, height: 38,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Color(0x26000000), blurRadius: 16, offset: Offset(0, 6))],
                ),
                child: const Icon(Icons.my_location_rounded, size: 16, color: _tealDark),
              ),
            ),
        ]),
      ),
    );
  }
}

// ─── Radar ping (finding driver) ──────────────────────────────────────────────
class _Radar extends StatelessWidget {
  const _Radar({required this.ctrl, required this.emoji});
  final AnimationController ctrl;
  final String emoji;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 0, height: 0,
      child: Stack(clipBehavior: Clip.none, alignment: Alignment.center, children: [
        AnimatedBuilder(
          animation: ctrl,
          builder: (context, _) {
            Widget ring(double phase) {
              final t = (ctrl.value + phase) % 1.0;
              return Transform.scale(
                scale: 1 + t * 8,
                child: Container(
                  width: 14, height: 14,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _teal.withValues(alpha: 0.55 * (1 - t)),
                  ),
                ),
              );
            }

            return Stack(clipBehavior: Clip.none, alignment: Alignment.center, children: [
              ring(0), ring(0.23), ring(0.46),
            ]);
          },
        ),
        Container(
          width: 34, height: 34,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: Color(0x33000000), blurRadius: 10, offset: Offset(0, 4))],
          ),
          child: Center(child: Text(emoji, style: const TextStyle(fontSize: 16))),
        ),
      ]),
    );
  }
}

