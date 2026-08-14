import 'package:elk/data/models/ad_models.dart';
import 'package:elk/data/repositories/marketplace_repository.dart';
import 'package:elk/features/best_sellers/view/best_sellers_screen.dart';
import 'package:elk/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_marketplace_repository.dart';

AdModel _ad(
  String id,
  String title, {
  bool isWishlisted = false,
  int wishlistCount = 4,
}) =>
    AdModel.fromJson({
      'id': id,
      'title': title,
      'sellerName': 'Bright Spark Services',
      'categorySlug': 'cleaning',
      'price': 180,
      'priceUnit': '/ visit',
      'isWishlisted': isWishlisted,
      'wishlistCount': wishlistCount,
    });

class _FakeMarketplaceRepository extends FakeMarketplaceRepositoryBase {
  /// Every `q` the screen actually sent, in order.
  final List<String?> searches = [];
  List<AdModel> searchResults = [_ad('ad-9', 'Sofa Shampoo')];
  Object? searchError;

  List<AdModel> topSellerResults = [_ad('ad-1', 'Deep Home Cleaning')];

  @override
  Future<List<AdModel>> topSellers({int? limit, String? category}) async {
    return topSellerResults;
  }

  @override
  Future<List<AdModel>> listAds({
    String? query,
    String? category,
    int? limit,
  }) async {
    searches.add(query);
    if (searchError != null) throw searchError!;
    return searchResults;
  }

  /// Opening a card refetches the ad, so this has to agree with the list or
  /// the detail screen would render stale state the real backend never sends.
  @override
  Future<AdModel> getAd(String id) async =>
      topSellerResults.firstWhere((a) => a.id == id);

  /// Every (adId, wishlisted) pair the screen sent.
  final List<(String, bool)> wishlistCalls = [];
  Object? wishlistError;

  @override
  Future<({bool isWishlisted, int wishlistCount})> setWishlisted(
    String adId, {
    required bool wishlisted,
  }) async {
    wishlistCalls.add((adId, wishlisted));
    if (wishlistError != null) throw wishlistError!;
    return (isWishlisted: wishlisted, wishlistCount: wishlisted ? 5 : 4);
  }
}

void main() {
  late _FakeMarketplaceRepository repository;

  Future<void> pumpScreen(WidgetTester tester, {List<AdModel>? rails}) async {
    repository = _FakeMarketplaceRepository();
    if (rails != null) repository.topSellerResults = rails;
    await tester.pumpWidget(
      RepositoryProvider<MarketplaceRepository>.value(
        value: repository,
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: BestSellersScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('searches the catalogue, not just the loaded rails',
      (tester) async {
    // The rails hold the top 30 sellers. Before this was wired, the box
    // filtered that slice, so an ad outside it could not be found at all.
    await pumpScreen(tester);

    await tester.enterText(find.byType(TextField), 'sofa');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();

    expect(repository.searches, ['sofa']);
    expect(find.text('Sofa Shampoo'), findsOneWidget);
  });

  testWidgets('debounces typing into a single request', (tester) async {
    await pumpScreen(tester);

    // Four keystrokes in quick succession must not be four round trips.
    for (final q in ['s', 'so', 'sof', 'sofa']) {
      await tester.enterText(find.byType(TextField), q);
      await tester.pump(const Duration(milliseconds: 80));
    }
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();

    expect(repository.searches, ['sofa']);
  });

  testWidgets('does not query for a single character', (tester) async {
    // The backend rejects q shorter than 2 characters with a 400.
    await pumpScreen(tester);

    await tester.enterText(find.byType(TextField), 's');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();

    expect(repository.searches, isEmpty);
  });

  testWidgets('shows the failure instead of an empty result', (tester) async {
    // "No vendors found" would be a lie when the request never succeeded.
    await pumpScreen(tester);
    repository.searchError = Exception('offline');

    await tester.enterText(find.byType(TextField), 'sofa');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();

    expect(find.textContaining('No vendors found'), findsNothing);
  });

  group('wishlist', () {
    /// Opens the first rail card's detail page, where the heart lives.
    Future<void> openDetail(WidgetTester tester) async {
      await tester.tap(find.text('Deep Home Cleaning').first);
      await tester.pumpAndSettle();
    }

    /// The hero's save button, by its size — the card's engagement counter
    /// uses the same filled-heart icon at 13px.
    Finder heart({required bool filled}) => find.byWidgetPredicate(
          (w) =>
              w is Icon &&
              w.size == 20 &&
              w.icon ==
                  (filled
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded),
        );

    testWidgets('saving an unsaved ad calls the endpoint and fills the heart',
        (tester) async {
      await pumpScreen(tester);
      await openDetail(tester);

      expect(heart(filled: false), findsOneWidget);

      await tester.tap(heart(filled: false));
      await tester.pumpAndSettle();

      expect(repository.wishlistCalls, [('ad-1', true)]);
      expect(heart(filled: true), findsOneWidget);
    });

    testWidgets('an ad the backend says is saved opens with a filled heart',
        (tester) async {
      // isWishlisted is per-user state the list already carries; the screen
      // must render it rather than assuming every ad starts unsaved.
      await pumpScreen(tester, rails: [
        _ad('ad-1', 'Deep Home Cleaning', isWishlisted: true, wishlistCount: 5),
      ]);
      await openDetail(tester);

      expect(heart(filled: true), findsOneWidget);

      await tester.tap(heart(filled: true));
      await tester.pumpAndSettle();

      expect(repository.wishlistCalls, [('ad-1', false)]);
      expect(heart(filled: false), findsOneWidget);
    });

    testWidgets('rolls the heart back when the call fails', (tester) async {
      // An optimistic flip that silently stuck would tell the user their save
      // was recorded when it was not.
      await pumpScreen(tester);
      await openDetail(tester);
      repository.wishlistError = Exception('offline');

      await tester.tap(heart(filled: false));
      await tester.pumpAndSettle();

      expect(repository.wishlistCalls, [('ad-1', true)]);
      expect(heart(filled: false), findsOneWidget);
    });
  });

  testWidgets('clearing the box returns to the rails', (tester) async {
    await pumpScreen(tester);

    await tester.enterText(find.byType(TextField), 'sofa');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '');
    await tester.pumpAndSettle();

    expect(find.text('Deep Home Cleaning'), findsWidgets);
  });
}
