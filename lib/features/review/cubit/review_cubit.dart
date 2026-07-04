import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/review_model.dart';
import '../../../data/repositories/review_repository.dart';

part 'review_state.dart';

class ReviewCubit extends Cubit<ReviewState> {
  ReviewCubit(this._repository) : super(const ReviewState());

  final ReviewRepository _repository;

  Future<void> loadTarget(String bookingId) async {
    emit(state.copyWith(status: ReviewStatus.loading));
    try {
      final target = await _repository.getReviewTarget(bookingId);
      emit(state.copyWith(status: ReviewStatus.loaded, target: target));
    } catch (e) {
      emit(state.copyWith(status: ReviewStatus.error, errorMessage: e.toString()));
    }
  }

  void setRating(int rating) {
    emit(state.copyWith(rating: rating));
  }

  void toggleTag(String tag) {
    final tags = [...state.selectedTags];
    if (tags.contains(tag)) {
      tags.remove(tag);
    } else {
      tags.add(tag);
    }
    emit(state.copyWith(selectedTags: tags));
  }

  void commentChanged(String comment) {
    emit(state.copyWith(comment: comment));
  }

  Future<void> submit(String bookingId) async {
    if (!state.canSubmit) return;
    emit(state.copyWith(status: ReviewStatus.submitting));
    try {
      await _repository.submitReview(ReviewSubmissionModel(
        bookingId: bookingId,
        rating: state.rating,
        selectedTags: state.selectedTags,
        comment: state.comment,
      ));
      emit(state.copyWith(status: ReviewStatus.submitted));
    } catch (e) {
      emit(state.copyWith(status: ReviewStatus.error, errorMessage: e.toString()));
    }
  }
}
