/// Payload for the Rating & Review screen — the completed booking being rated.
class ReviewTargetModel {
  const ReviewTargetModel({
    required this.providerName,
    required this.providerInitials,
    required this.serviceName,
    required this.durationLabel,
    required this.quickTags,
    required this.rewardPoints,
  });

  final String providerName;
  final String providerInitials;
  final String serviceName;
  final String durationLabel;
  final List<String> quickTags;
  final int rewardPoints;

  factory ReviewTargetModel.fromJson(Map<String, dynamic> json) =>
      ReviewTargetModel(
        providerName: json['providerName'] as String,
        providerInitials: json['providerInitials'] as String,
        serviceName: json['serviceName'] as String,
        durationLabel: json['durationLabel'] as String,
        quickTags: List<String>.from(json['quickTags'] as List),
        rewardPoints: json['rewardPoints'] as int,
      );
}

/// A submitted review payload sent to the API.
class ReviewSubmissionModel {
  const ReviewSubmissionModel({
    required this.bookingId,
    required this.rating,
    required this.selectedTags,
    required this.comment,
  });

  final String bookingId;
  final int rating;
  final List<String> selectedTags;
  final String comment;

  Map<String, dynamic> toJson() => {
        'bookingId': bookingId,
        'rating': rating,
        'selectedTags': selectedTags,
        'comment': comment,
      };
}
