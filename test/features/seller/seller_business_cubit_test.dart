import 'package:flutter_test/flutter_test.dart';

import 'package:elk/core/errors/api_exception.dart';
import 'package:elk/data/models/provider_models.dart';
import 'package:elk/data/repositories/provider_repository.dart';
import 'package:elk/features/seller/cubit/seller_business_cubit.dart';

const _dashboard = ProviderDashboardModel(
  businessName: 'Royal Shine Co.',
  modeLabel: 'Service Provider',
  isAvailable: true,
  stats: [],
  requests: [],
);

const _earnings = EarningsSummaryModel(
  totalEarnings: 4820,
  monthLabel: 'August',
  trendLabel: '+12%',
  completedJobs: 18,
  completedJobsTrend: '+3',
  avgPerJob: 268,
  avgPerJobTrend: '+5%',
  transactions: [],
);

const _schedule = ProviderScheduleModel(
  todaysBookingsCount: 2,
  days: [ScheduleDayModel(label: 'Mon', available: true, isToday: true)],
  slots: [ScheduleSlotModel(timeRange: '09:00 – 11:00', status: ScheduleSlotStatus.active)],
);

class _FakeProvider implements ProviderRepository {
  Object? dashboardError;
  Object? availabilityError;
  bool? lastAvailability;
  bool availabilityReturns = true;

  @override
  Future<ProviderDashboardModel> getDashboard() async {
    if (dashboardError != null) throw dashboardError!;
    return _dashboard;
  }

  @override
  Future<EarningsSummaryModel> getEarnings() async => _earnings;

  @override
  Future<ProviderScheduleModel> getSchedule() async => _schedule;

  @override
  Future<bool> setAvailability(bool isAvailable) async {
    lastAvailability = isAvailable;
    if (availabilityError != null) throw availabilityError!;
    return availabilityReturns;
  }

  @override
  noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

void main() {
  late _FakeProvider provider;
  late SellerBusinessCubit cubit;

  setUp(() {
    provider = _FakeProvider();
    cubit = SellerBusinessCubit(provider);
  });

  group('load', () {
    test('brings the business profile and earnings into the seller panel', () async {
      await cubit.load();

      expect(cubit.state.status, SellerBusinessStatus.ready);
      expect(cubit.state.businessName, 'Royal Shine Co.');
      expect(cubit.state.isAvailable, isTrue);
      expect(cubit.state.earnings!.totalEarnings, 4820);
    });

    test('a seller with no business profile is not an error', () async {
      // They can still list and sell; there is simply nothing to be available
      // for and nothing earned yet.
      provider.dashboardError = const ApiException(ApiErrorType.notFound, 'Not found', statusCode: 404);

      await cubit.load();

      expect(cubit.state.status, SellerBusinessStatus.notRegistered);
      expect(cubit.state.errorMessage, isNull);
    });

    test('surfaces a real failure', () async {
      provider.dashboardError = const ApiException(ApiErrorType.server, 'Boom', statusCode: 500);

      await cubit.load();

      expect(cubit.state.status, SellerBusinessStatus.error);
      expect(cubit.state.errorMessage, isNotNull);
    });
  });

  group('availability', () {
    test('writes the toggle through instead of keeping a local flag', () async {
      // The panel used to flip a bool that never left the device, so a seller
      // could believe they were offline while still taking work.
      await cubit.load();

      provider.availabilityReturns = false;
      await cubit.setAvailable(false);

      expect(provider.lastAvailability, isFalse);
      expect(cubit.state.isAvailable, isFalse);
    });

    test('reverts when the server refuses', () async {
      await cubit.load();
      provider.availabilityError = Exception('offline');

      await cubit.setAvailable(false);

      expect(cubit.state.isAvailable, isTrue);
      expect(cubit.state.errorMessage, isNotNull);
    });

    test('follows the server when it disagrees with what was asked', () async {
      await cubit.load();
      provider.availabilityReturns = true;

      await cubit.setAvailable(false);

      expect(cubit.state.isAvailable, isTrue);
    });
  });

  test('loads the schedule only when asked', () async {
    await cubit.load();
    expect(cubit.state.schedule, isNull);

    await cubit.loadSchedule();

    expect(cubit.state.schedule!.todaysBookingsCount, 2);
    expect(cubit.state.isLoadingSchedule, isFalse);
  });
}
