import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:elk/core/errors/api_exception.dart';
import 'package:elk/core/utils/app_preferences.dart';
import 'package:elk/data/models/provider_models.dart';
import 'package:elk/data/repositories/provider_repository.dart';
import 'package:elk/features/provider_dashboard/cubit/provider_dashboard_cubit.dart';
import 'package:elk/features/provider_earnings/cubit/provider_earnings_cubit.dart';
import 'package:elk/features/provider_registration/cubit/provider_registration_cubit.dart';
import 'package:elk/features/provider_schedule/cubit/provider_schedule_cubit.dart';

/// The backend's `assertProfile` refuses every provider read with 403 until a
/// profile exists.
const _notRegistered = ApiException(
  ApiErrorType.forbidden,
  'No provider profile — register first',
);

ProviderRequestModel _request(String id, ProviderRequestStatus status) =>
    ProviderRequestModel(
      id: id,
      serviceName: 'Deep Cleaning',
      customerName: 'Aisha K.',
      location: 'Koramangala',
      time: 'Today, 2:00 PM',
      amount: 180,
      status: status,
    );

ProviderDashboardModel _dashboard({
  bool isAvailable = true,
  List<ProviderRequestModel>? requests,
}) =>
    ProviderDashboardModel(
      businessName: 'Royal Shine Cleaning Co.',
      modeLabel: 'Verified Provider',
      isAvailable: isAvailable,
      stats: const [
        ProviderStatModel(label: 'Active Orders', value: '2', trend: '+1 today'),
      ],
      requests: requests ?? [_request('r1', ProviderRequestStatus.pending)],
    );

class _FakeProviderRepository implements ProviderRepository {
  Object? readError;
  Object? availabilityError;
  Object? respondError;
  Object? registerError;

  bool availability = true;
  bool? lastAvailabilitySent;
  ProviderRegistrationModel? submitted;

  @override
  Future<ProviderDashboardModel> getDashboard() async {
    if (readError != null) throw readError!;
    return _dashboard(isAvailable: availability);
  }

  @override
  Future<bool> setAvailability(bool isAvailable) async {
    lastAvailabilitySent = isAvailable;
    if (availabilityError != null) throw availabilityError!;
    availability = isAvailable;
    return isAvailable;
  }

  @override
  Future<ProviderRequestModel> respondToRequest({
    required ProviderRequestModel request,
    required bool accept,
  }) async {
    if (respondError != null) throw respondError!;
    return _request(
      request.id,
      accept ? ProviderRequestStatus.accepted : ProviderRequestStatus.declined,
    );
  }

  @override
  Future<ProviderScheduleModel> getSchedule() async {
    if (readError != null) throw readError!;
    return const ProviderScheduleModel(
      todaysBookingsCount: 3,
      days: [ScheduleDayModel(label: 'Mon', available: true, isToday: true)],
      slots: [
        ScheduleSlotModel(timeRange: '9:00 - 11:00', status: ScheduleSlotStatus.active),
      ],
    );
  }

  @override
  Future<EarningsSummaryModel> getEarnings() async {
    if (readError != null) throw readError!;
    return const EarningsSummaryModel(
      totalEarnings: 2840,
      monthLabel: 'July 2026',
      trendLabel: '+12%',
      completedJobs: 18,
      completedJobsTrend: '+3',
      avgPerJob: 158,
      avgPerJobTrend: '+5%',
      transactions: [],
    );
  }

  @override
  Future<void> submitRegistration(ProviderRegistrationModel registration) async {
    submitted = registration;
    if (registerError != null) throw registerError!;
  }
}

void main() {
  late _FakeProviderRepository repository;

  Future<AppPreferences> prefs({Map<String, Object> values = const {}}) async {
    SharedPreferences.setMockInitialValues(values);
    return AppPreferences(await SharedPreferences.getInstance());
  }

  setUp(() => repository = _FakeProviderRepository());

  group('dashboard', () {
    test('loads stats and requests', () async {
      final cubit = ProviderDashboardCubit(repository, await prefs());
      await cubit.loadDashboard();

      expect(cubit.state.status, ProviderDashboardStatus.loaded);
      expect(cubit.state.dashboard!.businessName, 'Royal Shine Cleaning Co.');
      expect(cubit.state.dashboard!.requests, hasLength(1));
    });

    test('a 403 becomes "register first", not an error', () async {
      repository.readError = _notRegistered;
      final cubit = ProviderDashboardCubit(repository, await prefs());
      await cubit.loadDashboard();

      expect(cubit.state.status, ProviderDashboardStatus.notRegistered);
    });

    test('guest mode short-circuits', () async {
      repository.readError = StateError('must not be called');
      final cubit = ProviderDashboardCubit(
        repository,
        await prefs(values: {'is_guest': true}),
      );
      await cubit.loadDashboard();

      expect(cubit.state.status, ProviderDashboardStatus.guest);
    });

    test('toggling availability takes the value the server confirms', () async {
      final cubit = ProviderDashboardCubit(repository, await prefs());
      await cubit.loadDashboard();

      final error = await cubit.toggleAvailability();
      expect(error, isNull);
      expect(repository.lastAvailabilitySent, isFalse);
      expect(cubit.state.dashboard!.isAvailable, isFalse);
    });

    test('a failed toggle leaves the switch where it was', () async {
      final cubit = ProviderDashboardCubit(repository, await prefs());
      await cubit.loadDashboard();
      repository.availabilityError =
          const ApiException(ApiErrorType.network, 'No internet connection.');

      final error = await cubit.toggleAvailability();
      expect(error, contains('internet'));
      expect(cubit.state.dashboard!.isAvailable, isTrue);
    });

    test('accepting a request replaces it with the server copy', () async {
      final cubit = ProviderDashboardCubit(repository, await prefs());
      await cubit.loadDashboard();

      final error = await cubit.respondToRequest(
        cubit.state.dashboard!.requests.first,
        accept: true,
      );
      expect(error, isNull);
      expect(cubit.state.dashboard!.requests.single.status,
          ProviderRequestStatus.accepted);
      expect(cubit.state.respondingRequestId, isNull);
    });

    test('an already-handled request returns the backend message and keeps the dashboard',
        () async {
      final cubit = ProviderDashboardCubit(repository, await prefs());
      await cubit.loadDashboard();
      repository.respondError = const ApiException(
        ApiErrorType.unknown,
        'This request has already been accepted or declined',
      );

      final error = await cubit.respondToRequest(
        cubit.state.dashboard!.requests.first,
        accept: true,
      );
      expect(error, contains('already been accepted'));
      expect(cubit.state.status, ProviderDashboardStatus.loaded);
      expect(cubit.state.dashboard, isNotNull);
      expect(cubit.state.respondingRequestId, isNull);
    });
  });

  group('schedule', () {
    test('loads days and slots', () async {
      final cubit = ProviderScheduleCubit(repository, await prefs());
      await cubit.loadSchedule();

      expect(cubit.state.status, ProviderScheduleStatus.loaded);
      expect(cubit.state.schedule!.todaysBookingsCount, 3);
    });

    test('a 403 becomes "register first"', () async {
      repository.readError = _notRegistered;
      final cubit = ProviderScheduleCubit(repository, await prefs());
      await cubit.loadSchedule();

      expect(cubit.state.status, ProviderScheduleStatus.notRegistered);
    });
  });

  group('earnings', () {
    test('loads the summary', () async {
      final cubit = ProviderEarningsCubit(repository, await prefs());
      await cubit.loadEarnings();

      expect(cubit.state.status, ProviderEarningsStatus.loaded);
      expect(cubit.state.summary!.totalEarnings, 2840);
      expect(cubit.state.summary!.completedJobs, 18);
    });

    test('a 403 becomes "register first"', () async {
      repository.readError = _notRegistered;
      final cubit = ProviderEarningsCubit(repository, await prefs());
      await cubit.loadEarnings();

      expect(cubit.state.status, ProviderEarningsStatus.notRegistered);
    });

    test('a genuine failure is still an error', () async {
      repository.readError =
          const ApiException(ApiErrorType.network, 'No internet connection.');
      final cubit = ProviderEarningsCubit(repository, await prefs());
      await cubit.loadEarnings();

      expect(cubit.state.status, ProviderEarningsStatus.error);
      expect(cubit.state.errorMessage, contains('internet'));
    });
  });

  group('registration', () {
    Future<ProviderRegistrationCubit> filledForm() async {
      final cubit = ProviderRegistrationCubit(repository);
      cubit.businessNameChanged('Royal Shine');
      cubit.contactNumberChanged('+971501234567');
      cubit.serviceAreaChanged('Koramangala');
      cubit.goToDocumentsStep();
      cubit.uploadTradeLicense();
      cubit.uploadIdDocument();
      return cubit;
    }

    test('gates the documents step until the details are filled in', () async {
      final cubit = ProviderRegistrationCubit(repository);
      cubit.goToDocumentsStep();
      expect(cubit.state.step, 0);

      cubit.businessNameChanged('Royal Shine');
      cubit.contactNumberChanged('+971501234567');
      cubit.serviceAreaChanged('Koramangala');
      cubit.goToDocumentsStep();
      expect(cubit.state.step, 1);
    });

    test('will not submit without both documents', () async {
      final cubit = ProviderRegistrationCubit(repository);
      cubit.businessNameChanged('Royal Shine');
      cubit.contactNumberChanged('+971501234567');
      cubit.serviceAreaChanged('Koramangala');
      cubit.goToDocumentsStep();
      cubit.uploadTradeLicense();

      await cubit.submit();
      expect(repository.submitted, isNull);
    });

    test('submits the form the backend DTO expects', () async {
      final cubit = await filledForm();
      await cubit.submit();

      expect(cubit.state.status, ProviderRegistrationStatus.submitted);
      expect(repository.submitted!.toJson(), {
        'businessName': 'Royal Shine',
        'serviceCategory': 'Cleaning',
        'contactNumber': '+971501234567',
        'serviceArea': 'Koramangala',
        'tradeLicenseUploaded': true,
        'idDocumentUploaded': true,
      });
    });

    test('surfaces the duplicate-profile message', () async {
      repository.registerError = const ApiException(
        ApiErrorType.unknown,
        'You already have a provider profile',
      );
      final cubit = await filledForm();
      await cubit.submit();

      expect(cubit.state.status, ProviderRegistrationStatus.error);
      expect(cubit.state.errorMessage, 'You already have a provider profile');
    });
  });
}
