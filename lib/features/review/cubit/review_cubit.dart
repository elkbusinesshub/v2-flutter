import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/api_exception.dart';
import '../../../core/utils/app_preferences.dart';
import '../../../data/models/review_model.dart';
import '../../../data/repositories/review_repository.dart';

part 'review_state.dart';

class ReviewCubit extends Cubit<ReviewState> {
  ReviewCubit(this._repository, this._preferences) : super(const ReviewState());

  final ReviewRepository _repository;
  final AppPreferences _preferences;

  Future<void> loadTarget(String bookingId) async {
    if (_preferences.isGuest) {
      emit(state.copyWith(status: ReviewStatus.guest));
      return;
    }
    emit(state.copyWith(status: ReviewStatus.loading));
    try {
      final target = await _repository.getReviewTarget(bookingId);
      emit(state.copyWith(status: ReviewStatus.loaded, target: target));
    } catch (e) {
      // Covers "already reviewed" and "not completed" too — the backend's
      // message is the clearest thing to show.
      emit(state.copyWith(
        status: ReviewStatus.error,
        errorMessage: friendlyErrorMessage(e),
      ));
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
      // Back to the filled-in form so the rating isn't lost on a retry.
      emit(state.copyWith(
        status: ReviewStatus.loaded,
        errorMessage: friendlyErrorMessage(e),
      ));
    }
  }
}
