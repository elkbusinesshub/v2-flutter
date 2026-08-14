import 'package:flutter_test/flutter_test.dart';

import 'package:elk/data/models/ad_models.dart';

void main() {
  group('AdModel', () {
    test('parses the backend payload', () {
      final ad = AdModel.fromJson({
        'id': 'ad-1',
        'title': 'Deep Home Cleaning',
        'description': 'Full-home deep clean',
        'sellerName': 'Royal Shine Co.',
        'categorySlug': 'cleaning',
        'icon': '🧹',
        'price': 180,
        'priceUnit': '/ visit',
        'location': 'Koramangala, Bengaluru',
        'viewCount': 30,
        'wishlistCount': 4,
        'isWishlisted': true,
        'imageUrls': ['https://signed/a.jpg'],
      });

      expect(ad.sellerName, 'Royal Shine Co.');
      expect(ad.wishlistCount, 4);
      expect(ad.viewCount, 30);
      expect(ad.isWishlisted, isTrue);
      expect(ad.priceLabel, '₹180 / visit');
      expect(ad.imageUrls, hasLength(1));
    });

    test('survives a minimal payload', () {
      final ad = AdModel.fromJson({'id': 'ad-2', 'title': 'Plumbing'});

      expect(ad.price, 0);
      // No unit means no trailing space in the label.
      expect(ad.priceLabel, '₹0');
      expect(ad.icon, '🛍️');
      expect(ad.isWishlisted, isFalse);
      expect(ad.imageUrls, isEmpty);
      // Empty rather than null, so screens can index it without a guard.
      expect(ad.attributes, isEmpty);
    });

    group('category attributes', () {
      test('parses the details the vertical screens render', () {
        final ad = AdModel.fromJson({
          'id': 'ad-4',
          'title': 'Swift Dzire',
          'categorySlug': 'car_rental',
          'attributes': {'seats': 5, 'transmission': 'AUTOMATIC'},
        });

        expect(ad.attribute<int>('seats'), 5);
        expect(ad.attribute<String>('transmission'), 'AUTOMATIC');
      });

      test('reads an absent or wrongly typed attribute as null', () {
        // An older ad simply will not carry the key, and the screen must not
        // crash rendering it.
        final ad = AdModel.fromJson({
          'id': 'ad-5',
          'title': 'Deep Clean',
          'attributes': {'seats': 'five'},
        });

        expect(ad.attribute<int>('seats'), isNull);
        expect(ad.attribute<String>('roomType'), isNull);
      });

      test('null attributes read as empty', () {
        final ad = AdModel.fromJson({'id': 'ad-6', 'title': 'X', 'attributes': null});

        expect(ad.attributes, isEmpty);
      });
    });

    test('copyWith updates only the wishlist state', () {
      final ad = AdModel.fromJson({
        'id': 'ad-3',
        'title': 'AC Service',
        'price': 90,
        'wishlistCount': 2,
        'viewCount': 11,
      });

      final saved = ad.copyWith(isWishlisted: true, wishlistCount: 3);
      expect(saved.isWishlisted, isTrue);
      expect(saved.wishlistCount, 3);
      // Everything else is carried across untouched.
      expect(saved.viewCount, 11);
      expect(saved.title, 'AC Service');
    });
  });
}
