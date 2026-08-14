/// A step in the Order Tracking timeline.
class TrackingStepModel {
  const TrackingStepModel({
    required this.name,
    required this.time,
    required this.status,
  });

  final String name;
  final String time;
  final TrackingStepStatus status;

  factory TrackingStepModel.fromJson(Map<String, dynamic> json) =>
      TrackingStepModel(
        name: json['name'] as String,
        time: json['time'] as String,
        status: TrackingStepStatus.values.byName(json['status'] as String),
      );
}

enum TrackingStepStatus { done, active, pending }

/// Full order tracking payload.
class OrderTrackingModel {
  const OrderTrackingModel({
    required this.orderId,
    required this.serviceName,
    required this.serviceIcon,
    required this.providerName,
    required this.statusLabel,
    required this.steps,
    this.addressText = '',
    this.lat,
    this.lng,
  });

  final String orderId;
  final String serviceName;
  final String serviceIcon;
  final String providerName;
  final String statusLabel;
  final List<TrackingStepModel> steps;

  /// Where the job is. Empty for bookings taken before it was recorded.
  final String addressText;

  /// Coordinate of [addressText]. Null for a hand-typed address and for
  /// bookings made before coordinates were captured; the map is hidden then.
  final double? lat;
  final double? lng;

  factory OrderTrackingModel.fromJson(Map<String, dynamic> json) =>
      OrderTrackingModel(
        orderId: json['orderId'] as String,
        serviceName: json['serviceName'] as String,
        serviceIcon: json['serviceIcon'] as String,
        providerName: json['providerName'] as String,
        statusLabel: json['statusLabel'] as String,
        addressText: (json['addressText'] as String?) ?? '',
        lat: (json['lat'] as num?)?.toDouble(),
        lng: (json['lng'] as num?)?.toDouble(),
        steps: (json['steps'] as List)
            .map((e) => TrackingStepModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
