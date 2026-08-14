import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:elk/core/errors/api_exception.dart';
import 'package:elk/core/utils/app_preferences.dart';
import 'package:elk/data/models/offer_models.dart';
import 'package:elk/data/repositories/offers_repository.dart';
import 'package:elk/features/offers/cubit/offers_cubit.dart';

const _welcome = OfferModel(
  id: 'o1',
  tagLabel: 'FOR NEW USERS',
  title: 'Welcome Offer',
  description: 'Get 20% off your first booking on any service category',
  code: 'ELK20',
  expiry: 'Expires 31 May 2026',
  discountLabel: '20%',
  discountSubLabel: 'OFF',
  gradientStartHex: 0xff0d3d35,
  gradientEndHex: 0xff4bbfb0,
);

class _FakeOffersRepository implements OffersRepository {
  OffersPageModel page = const OffersPageModel(
    rewardPoints: 150,
    rewardDiscountLabel: '≈ ₹15 discount available',
    offers: [_welcome],
  );
  Object? error;
  int calls = 0;

  @override
  Future<OffersPageModel> getOffers() async {
    calls += 1;
    if (error != null) throw error!;
    return page;
  }
}

void main() {
  late _FakeOffersRepository repository;

  Future<OffersCubit> buildCubit({Map<String, Object> values = const {}}) async {
    SharedPreferences.setMockInitialValues(values);
    final preferences = AppPreferences(await SharedPreferences.getInstance());
    return OffersCubit(repository, preferences);
  }

  setUp(() => repository = _FakeOffersRepository());

  test('loads reward points and offer banners', () async {
    final cubit = await buildCubit();
    await cubit.loadOffers();

    expect(cubit.state.status, OffersStatus.loaded);
    expect(cubit.state.page!.rewardPoints, 150);
    expect(cubit.state.page!.rewardDiscountLabel, contains('₹15'));
    expect(cubit.state.page!.offers.single.code, 'ELK20');
  });

  test('guest mode short-circuits — the page is per-user', () async {
    repository.error = StateError('must not be called');
    final cubit = await buildCubit(values: {'is_guest': true});
    await cubit.loadOffers();

    expect(cubit.state.status, OffersStatus.guest);
    expect(repository.calls, 0);
  });

  test('an empty banner list still loads', () async {
    repository.page = const OffersPageModel(
      rewardPoints: 0,
      rewardDiscountLabel: '≈ ₹0 discount available',
      offers: [],
    );
    final cubit = await buildCubit();
    await cubit.loadOffers();

    expect(cubit.state.status, OffersStatus.loaded);
    expect(cubit.state.page!.offers, isEmpty);
  });

  test('surfaces a friendly error', () async {
    repository.error =
        const ApiException(ApiErrorType.network, 'No internet connection.');
    final cubit = await buildCubit();
    await cubit.loadOffers();

    expect(cubit.state.status, OffersStatus.error);
    expect(cubit.state.errorMessage, contains('internet'));
  });

  test('OffersPageModel parses the backend payload', () {
    final model = OffersPageModel.fromJson({
      'rewardPoints': 150,
      'rewardDiscountLabel': '≈ ₹15 discount available',
      'offers': [
        {
          'id': 'o1',
          'tagLabel': 'CLEANING SPECIAL',
          'title': 'Flat ₹30 Off',
          'description': 'On deep cleaning or AC services booked this weekend',
          'code': 'CLEAN30',
          'expiry': 'Valid: Fri-Sun only',
          'discountLabel': '₹',
          'discountSubLabel': '30',
          'gradientStartHex': 0xff1a2e3d,
          'gradientEndHex': 0xff4f46e5,
        },
      ],
    });

    expect(model.rewardPoints, 150);
    expect(model.offers.single.code, 'CLEAN30');
    // The gradient ints go straight into Color().
    expect(model.offers.single.gradientStartHex, 0xff1a2e3d);
  });
}
