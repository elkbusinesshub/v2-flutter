part of 'review_cubit.dart';

enum ReviewStatus { initial, loading, loaded, submitting, submitted, error }

class ReviewState extends Equatable {
  const ReviewState({
    this.status = ReviewStatus.initial,
    this.target,
    this.rating = 0,
    this.selectedTags = const [],
    this.comment = '',
    this.errorMessage,
  });

  final ReviewStatus status;
  final ReviewTargetModel? target;
  final int rating;
  final List<String> selectedTags;
  final String comment;
  final String? errorMessage;

  bool get canSubmit => rating > 0;

  ReviewState copyWith({
    ReviewStatus? status,
    ReviewTargetModel? target,
    int? rating,
    List<String>? selectedTags,
    String? comment,
    String? errorMessage,
  }) {
    return ReviewState(
      status: status ?? this.status,
      target: target ?? this.target,
      rating: rating ?? this.rating,
      selectedTags: selectedTags ?? this.selectedTags,
      comment: comment ?? this.comment,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props =>
      [status, target, rating, selectedTags, comment, errorMessage];
}
