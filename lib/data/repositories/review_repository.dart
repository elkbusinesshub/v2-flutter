import '../datasources/api_client.dart';
import '../datasources/dummy_data.dart';
import '../models/review_model.dart';

class ReviewRepository {
  ReviewRepository(this._client);

  final ApiClient _client;

  Future<ReviewTargetModel> getReviewTarget(String bookingId) {
    return _client.simulate(
      '/bookings/$bookingId/review-target',
      () => ReviewTargetModel.fromJson(dummyReviewTargetJson),
    );
  }

  Future<void> submitReview(ReviewSubmissionModel submission) {
    return _client.simulateMutation(
      '/bookings/${submission.bookingId}/reviews',
      submission.toJson(),
      () {},
      delay: const Duration(milliseconds: 800),
    );
  }
}
