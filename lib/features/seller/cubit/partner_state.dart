part of 'partner_cubit.dart';

enum PartnerStatus { initial, loading, ready, error }

/// One job in hand, whichever product it came from.
///
/// Rides and deliveries carry different fields, but the partner screen only
/// ever shows these — so both are narrowed to one shape at the repository
/// boundary rather than the screen branching on product everywhere.
class PartnerJob extends Equatable {
  const PartnerJob({
    required this.id,
    required this.code,
    required this.status,
    required this.pickupAddress,
    required this.dropAddress,
    required this.fare,
    this.otpCode,
  });

  final String id;
  final String code;

  /// `confirmed` → on the way; `in_progress` / `picked_up` → carrying.
  final String status;
  final String pickupAddress;
  final String dropAddress;
  final double fare;

  /// The code the customer reads out, which the partner types to prove they
  /// are really there. Null once the job is under way.
  final String? otpCode;

  /// Whether the partner has collected the rider or the parcel yet.
  bool get isUnderWay => status == 'in_progress' || status == 'picked_up';

  factory PartnerJob.fromJson(Map<String, dynamic> json) => PartnerJob(
        id: json['id'] as String,
        code: (json['code'] as String?) ?? '',
        status: (json['status'] as String?) ?? '',
        pickupAddress: (json['pickupAddress'] as String?) ?? '',
        dropAddress: (json['dropAddress'] as String?) ?? '',
        // Rides call it a fare; deliveries put it in the breakdown.
        fare: (json['fare'] as num?)?.toDouble() ??
            ((json['breakdown'] as Map?)?['totalAmount'] as num?)?.toDouble() ??
            0,
        otpCode: json['otpCode'] as String?,
      );

  @override
  List<Object?> get props => [id, code, status, pickupAddress, dropAddress, fare, otpCode];
}

class PartnerState extends Equatable {
  const PartnerState({
    this.status = PartnerStatus.initial,
    this.service = DriverService.ride,
    this.profiles = const [],
    this.offers = const [],
    this.activeJob,
    this.isTogglingDuty = false,
    this.isWorking = false,
    this.acceptingId,
    this.lastSentAt,
    this.errorMessage,
  });

  final PartnerStatus status;

  /// Which product the partner is working right now.
  final DriverService service;

  /// One per product they have registered a vehicle for.
  final List<DriverProfileModel> profiles;

  /// Jobs currently on offer — every nearby partner sees the same ones, and
  /// the first to accept takes it.
  final List<JobOfferModel> offers;

  final PartnerJob? activeJob;
  final bool isTogglingDuty;
  final bool isWorking;

  /// The offer being accepted, so only that card shows a spinner.
  final String? acceptingId;

  /// When the last position went up — the panel shows it as proof the
  /// heartbeat is alive, since a silent partner stops being offered work.
  final DateTime? lastSentAt;
  final String? errorMessage;

  /// The registered vehicle for the selected product, if there is one.
  DriverProfileModel? get profile =>
      profiles.where((p) => p.service == service).firstOrNull;

  bool get isRegistered => profile != null;
  bool get isOnline => profile?.isOnline ?? false;

  PartnerState copyWith({
    PartnerStatus? status,
    DriverService? service,
    List<DriverProfileModel>? profiles,
    List<JobOfferModel>? offers,
    PartnerJob? activeJob,
    bool clearActiveJob = false,
    bool? isTogglingDuty,
    bool? isWorking,
    String? acceptingId,
    DateTime? lastSentAt,
    String? errorMessage,
  }) =>
      PartnerState(
        status: status ?? this.status,
        service: service ?? this.service,
        profiles: profiles ?? this.profiles,
        offers: offers ?? this.offers,
        activeJob: clearActiveJob ? null : (activeJob ?? this.activeJob),
        isTogglingDuty: isTogglingDuty ?? this.isTogglingDuty,
        isWorking: isWorking ?? this.isWorking,
        acceptingId: acceptingId ?? this.acceptingId,
        lastSentAt: lastSentAt ?? this.lastSentAt,
        errorMessage: errorMessage,
      );

  PartnerState clearingAccepting() => PartnerState(
        status: status,
        service: service,
        profiles: profiles,
        offers: offers,
        activeJob: activeJob,
        isTogglingDuty: isTogglingDuty,
        isWorking: isWorking,
        lastSentAt: lastSentAt,
      );

  @override
  List<Object?> get props => [
        status,
        service,
        profiles,
        offers,
        activeJob,
        isTogglingDuty,
        isWorking,
        acceptingId,
        lastSentAt,
        errorMessage,
      ];
}
