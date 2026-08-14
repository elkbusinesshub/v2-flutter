import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:elk/core/errors/api_exception.dart';
import 'package:elk/core/utils/app_preferences.dart';
import 'package:elk/data/models/review_model.dart';
import 'package:elk/data/repositories/review_repository.dart';
import 'package:elk/features/review/cubit/review_cubit.dart';

const _target = ReviewTargetModel(
  providerName: 'Royal Shine',
  providerInitials: 'RS',
  serviceName: 'Home Cleaning',
  durationLabel: '2-3 hrs',
  quickTags: ['On Time', 'Professional', 'Thorough Job'],
  rewardPoints: 15,
);

class _FakeReviewRepository implements ReviewRepository {
  Object? loadError;
  Object? submitError;
  ReviewSubmissionModel? submitted;

  @override
  Future<ReviewTargetModel> getReviewTarget(String bookingId) async {
    if (loadError != null) throw loadError!;
    return _target;
  }

  @override
  Future<void> submitReview(ReviewSubmissionModel submission) async {
    submitted = submission;
    if (submitError != null) throw submitError!;
  }
}

void main() {
  late _FakeReviewRepository repository;

  Future<ReviewCubit> buildCubit({Map<String, Object> values = const {}}) async {
    SharedPreferences.setMockInitialValues(values);
    final preferences = AppPreferences(await SharedPreferences.getInstance());
    return ReviewCubit(repository, preferences);
  }

  setUp(() => repository = _FakeReviewRepository());

  test('loads the rating target', () async {
    final cubit = await buildCubit();
    await cubit.loadTarget('b1');
    expect(cubit.state.status, ReviewStatus.loaded);
    expect(cubit.state.target!.quickTags, hasLength(3));
    expect(cubit.state.target!.rewardPoints, 15);
  });

  test('guest mode short-circuits', () async {
    repository.loadError = StateError('must not be called');
    final cubit = await buildCubit(values: {'is_guest': true});
    await cubit.loadTarget('b1');
    expect(cubit.state.status, ReviewStatus.guest);
  });

  test('cannot submit without a star rating', () async {
    final cubit = await buildCubit();
    await cubit.loadTarget('b1');
    expect(cubit.state.canSubmit, isFalse);

    await cubit.submit('b1');
    expect(repository.submitted, isNull);

    cubit.setRating(4);
    expect(cubit.state.canSubmit, isTrue);
  });

  test('submits the rating, tags and comment', () async {
    final cubit = await buildCubit();
    await cubit.loadTarget('b1');
    cubit.setRating(5);
    cubit.toggleTag('On Time');
    cubit.toggleTag('Friendly');
    cubit.toggleTag('Friendly'); // toggles back off
    cubit.commentChanged('Great job!');

    await cubit.submit('b1');
    expect(cubit.state.status, ReviewStatus.submitted);
    expect(repository.submitted!.rating, 5);
    expect(repository.submitted!.selectedTags, ['On Time']);
    expect(repository.submitted!.comment, 'Great job!');
  });

  test('the wire payload uses `tags` and omits bookingId', () {
    const submission = ReviewSubmissionModel(
      bookingId: 'b1',
      rating: 5,
      selectedTags: ['On Time'],
      comment: 'Great job!',
    );
    expect(submission.toJson(), {
      'rating': 5,
      'tags': ['On Time'],
      'comment': 'Great job!',
    });
  });

  test('a rejected submit keeps the form filled in for a retry', () async {
    repository.submitError = const ApiException(
      ApiErrorType.unknown,
      'This booking has already been reviewed',
    );
    final cubit = await buildCubit();
    await cubit.loadTarget('b1');
    cubit.setRating(5);

    await cubit.submit('b1');
    expect(cubit.state.status, ReviewStatus.loaded);
    expect(cubit.state.errorMessage, contains('already been reviewed'));
    expect(cubit.state.rating, 5);
  });

  test('surfaces the backend message when the target is not reviewable',
      () async {
    repository.loadError = const ApiException(
      ApiErrorType.unknown,
      'Only completed bookings can be reviewed',
    );
    final cubit = await buildCubit();
    await cubit.loadTarget('b1');
    expect(cubit.state.status, ReviewStatus.error);
    expect(cubit.state.errorMessage, 'Only completed bookings can be reviewed');
  });
}
