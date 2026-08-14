import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:elk/core/errors/api_exception.dart';
import 'package:elk/core/utils/app_preferences.dart';
import 'package:elk/data/models/order_models.dart';
import 'package:elk/data/repositories/tracking_repository.dart';
import 'package:elk/features/tracking/cubit/tracking_cubit.dart';

const _stepNames = [
  'Booking Confirmed',
  'Provider Accepted',
  'On The Way',
  'In Progress',
  'Completed',
];

/// Mirrors `TRACKING_STEP_STATES` in the backend's orders.constants.ts.
OrderTrackingModel _tracking({
  required String statusLabel,
  required List<TrackingStepStatus> states,
}) =>
    OrderTrackingModel(
      orderId: 'ELK-2026-63882',
      serviceName: 'Home Cleaning',
      serviceIcon: '🏠',
      providerName: 'Royal Shine Cleaning Co.',
      statusLabel: statusLabel,
      steps: [
        for (var i = 0; i < _stepNames.length; i++)
          TrackingStepModel(
            name: _stepNames[i],
            time: states[i] == TrackingStepStatus.pending
                ? '—'
                : states[i] == TrackingStepStatus.active
                    ? 'ETA: soon'
                    : 'Today, 9:15 AM',
            status: states[i],
          ),
      ],
    );

final _confirmed = _tracking(
  statusLabel: 'Arriving soon',
  states: const [
    TrackingStepStatus.done,
    TrackingStepStatus.done,
    TrackingStepStatus.active,
    TrackingStepStatus.pending,
    TrackingStepStatus.pending,
  ],
);

final _cancelled = _tracking(
  statusLabel: 'Booking cancelled',
  states: const [
    TrackingStepStatus.done,
    TrackingStepStatus.pending,
    TrackingStepStatus.pending,
    TrackingStepStatus.pending,
    TrackingStepStatus.pending,
  ],
);

class _FakeTrackingRepository implements TrackingRepository {
  OrderTrackingModel tracking = _confirmed;
  Object? loadError;
  Object? cancelError;
  final List<String> calls = [];

  @override
  Future<OrderTrackingModel> getOrderTracking(String orderId) async {
    calls.add('tracking:$orderId');
    if (loadError != null) throw loadError!;
    return tracking;
  }

  @override
  Future<void> cancelOrder(String orderId) async {
    calls.add('cancel:$orderId');
    if (cancelError != null) throw cancelError!;
    tracking = _cancelled;
  }
}

void main() {
  late _FakeTrackingRepository repository;

  Future<TrackingCubit> buildCubit({Map<String, Object> values = const {}}) async {
    SharedPreferences.setMockInitialValues(values);
    final preferences = AppPreferences(await SharedPreferences.getInstance());
    return TrackingCubit(repository, preferences);
  }

  setUp(() => repository = _FakeTrackingRepository());

  test('loads the timeline for a confirmed order', () async {
    final cubit = await buildCubit();
    await cubit.loadTracking('b1');

    expect(cubit.state.status, TrackingStatus.loaded);
    expect(cubit.state.tracking!.statusLabel, 'Arriving soon');
    expect(cubit.state.tracking!.steps, hasLength(5));
    expect(cubit.state.tracking!.steps[2].status, TrackingStepStatus.active);
    expect(cubit.state.tracking!.steps[2].time, 'ETA: soon');
    expect(cubit.state.tracking!.steps.last.time, '—');
  });

  test('guest mode short-circuits before hitting the API', () async {
    repository.loadError = StateError('must not be called');
    final cubit = await buildCubit(values: {'is_guest': true});
    await cubit.loadTracking('b1');

    expect(cubit.state.status, TrackingStatus.guest);
    expect(repository.calls, isEmpty);
  });

  test('cancelling reloads so the timeline shows the cancelled state', () async {
    final cubit = await buildCubit();
    await cubit.loadTracking('b1');

    final result = await cubit.cancelOrder('b1');
    expect(result.ok, isTrue);
    expect(result.message, 'Order cancelled');
    expect(repository.calls, ['tracking:b1', 'cancel:b1', 'tracking:b1']);
    expect(cubit.state.tracking!.statusLabel, 'Booking cancelled');
    expect(cubit.state.isCancelling, isFalse);
  });

  test('a rejected cancel reports failure so the screen stays put', () async {
    final cubit = await buildCubit();
    await cubit.loadTracking('b1');
    repository.cancelError = const ApiException(
      ApiErrorType.unknown,
      'Only upcoming confirmed orders can be cancelled',
    );

    final result = await cubit.cancelOrder('b1');
    // The screen navigates away only on ok — previously it always did.
    expect(result.ok, isFalse);
    expect(result.message, contains('confirmed orders can be cancelled'));
    expect(cubit.state.tracking!.statusLabel, 'Arriving soon');
    expect(cubit.state.isCancelling, isFalse);
  });

  test('surfaces the backend message for an unknown order', () async {
    repository.loadError =
        const ApiException(ApiErrorType.notFound, 'Order not found');
    final cubit = await buildCubit();
    await cubit.loadTracking('nope');

    expect(cubit.state.status, TrackingStatus.error);
    expect(cubit.state.errorMessage, 'Order not found');
  });

  test('OrderTrackingModel parses the backend payload', () {
    final model = OrderTrackingModel.fromJson({
      'orderId': 'ELK-2026-63882',
      'serviceName': 'Home Cleaning',
      'serviceIcon': '🏠',
      'providerName': 'Royal Shine Cleaning Co.',
      'statusLabel': 'Service completed',
      'steps': [
        {'name': 'Booking Confirmed', 'time': 'Today, 9:15 AM', 'status': 'done'},
        {'name': 'On The Way', 'time': 'ETA: soon', 'status': 'active'},
        {'name': 'Completed', 'time': '—', 'status': 'pending'},
      ],
    });

    expect(model.statusLabel, 'Service completed');
    expect(model.steps.map((s) => s.status), [
      TrackingStepStatus.done,
      TrackingStepStatus.active,
      TrackingStepStatus.pending,
    ]);
  });
}
