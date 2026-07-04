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
  });

  final String orderId;
  final String serviceName;
  final String serviceIcon;
  final String providerName;
  final String statusLabel;
  final List<TrackingStepModel> steps;

  factory OrderTrackingModel.fromJson(Map<String, dynamic> json) =>
      OrderTrackingModel(
        orderId: json['orderId'] as String,
        serviceName: json['serviceName'] as String,
        serviceIcon: json['serviceIcon'] as String,
        providerName: json['providerName'] as String,
        statusLabel: json['statusLabel'] as String,
        steps: (json['steps'] as List)
            .map((e) => TrackingStepModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
