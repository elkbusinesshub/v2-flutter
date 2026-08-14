import '../../core/api/api_client.dart';
import '../../core/api/api_endpoints.dart';
import '../models/review_model.dart';

/// Ratings for completed service bookings.
///
/// Backend contract:
///  * `GET  /bookings/:id/review-target` → provider/service context plus the
///    fixed quick-tag vocabulary the chips are built from
///  * `POST /bookings/:id/reviews { rating, tags, comment }`
///
/// Both endpoints reject a booking that is not the caller's, not COMPLETED,
/// or already reviewed — the message is surfaced as-is.
class ReviewRepository {
  ReviewRepository(this._client);

  final ApiClient _client;

  Future<ReviewTargetModel> getReviewTarget(String bookingId) async {
    final data = await _client.get(ApiEndpoints.reviewTarget(bookingId));
    return ReviewTargetModel.fromJson(data as Map<String, dynamic>);
  }

  Future<void> submitReview(ReviewSubmissionModel submission) async {
    await _client.post(
      ApiEndpoints.submitReview(submission.bookingId),
      data: submission.toJson(),
    );
  }
}
