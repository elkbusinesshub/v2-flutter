import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:elk/core/api/api_client.dart';
import 'package:elk/core/api/token_storage.dart';
import 'package:elk/core/errors/api_exception.dart';
import 'package:elk/core/utils/app_preferences.dart';
import 'package:elk/data/models/home_models.dart';
import 'package:elk/data/repositories/home_repository.dart';
import 'package:elk/features/home/cubit/home_cubit.dart';

const _feed = HomeFeedModel(
  userName: 'Rafseena K',
  location: 'Indiranagar',
  promo: PromoBannerModel(
    title: 't',
    subtitle: 's',
    ctaLabel: 'c',
    tag: 'NEW',
    icon: '🎁',
  ),
  categories: [],
  bestSellers: [],
);

class _FakeHomeRepository implements HomeRepository {
  Object? error;
  bool apiCalled = false;

  @override
  Future<HomeFeedModel> getHomeFeed() async {
    apiCalled = true;
    if (error != null) throw error!;
    return _feed;
  }

  // guestFeed is pure static config — delegate to the real implementation
  // (constructing the client makes no network or platform calls).
  @override
  HomeFeedModel guestFeed() =>
      HomeRepository(ApiClient(tokenStorage: TokenStorage())).guestFeed();
}

void main() {
  late _FakeHomeRepository repository;

  Future<HomeCubit> buildCubit({Map<String, Object> prefs = const {}}) async {
    SharedPreferences.setMockInitialValues(prefs);
    final preferences = AppPreferences(await SharedPreferences.getInstance());
    return HomeCubit(repository, preferences);
  }

  setUp(() => repository = _FakeHomeRepository());

  test('loads the feed from the backend', () async {
    final cubit = await buildCubit();
    await cubit.loadHome();
    expect(cubit.state.status, HomeStatus.loaded);
    expect(cubit.state.feed, _feed);
  });

  test('serves the local guest feed without calling the API', () async {
    final cubit = await buildCubit(prefs: {'is_guest': true});
    await cubit.loadHome();
    expect(repository.apiCalled, isFalse);
    expect(cubit.state.status, HomeStatus.loaded);
    expect(cubit.state.feed!.categories, hasLength(6));
    expect(cubit.state.feed!.userName, 'Guest');
  });

  test('surfaces a friendly error on failure', () async {
    repository.error = const ApiException(
      ApiErrorType.timeout,
      'The request timed out. Please try again.',
    );
    final cubit = await buildCubit();
    await cubit.loadHome();
    expect(cubit.state.status, HomeStatus.error);
    expect(cubit.state.errorMessage, contains('timed out'));
  });
}
