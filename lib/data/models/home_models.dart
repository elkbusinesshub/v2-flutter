import 'ad_models.dart';

import 'provider_models.dart';
import 'service_models.dart';

/// Home banner promo shown at the top of the Home feed.
class PromoBannerModel {
  const PromoBannerModel({
    required this.title,
    required this.subtitle,
    required this.ctaLabel,
    required this.tag,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final String ctaLabel;
  final String tag;
  final String icon;

  factory PromoBannerModel.fromJson(Map<String, dynamic> json) =>
      PromoBannerModel(
        title: json['title'] as String,
        subtitle: json['subtitle'] as String,
        ctaLabel: json['ctaLabel'] as String,
        tag: json['tag'] as String,
        icon: json['icon'] as String,
      );
}

/// Aggregated payload for the Home screen.
class HomeFeedModel {
  const HomeFeedModel({
    required this.userName,
    required this.location,
    this.locationAddress = '',
    required this.promo,
    required this.categories,
    required this.bestSellers,
    this.topSellers = const [],
  });

  final String userName;
  /// The default address's label, e.g. "Home".
  final String location;

  /// The default address's full text, e.g. "Koramangala, Bengaluru". Empty
  /// when the user has no saved address.
  final String locationAddress;

  /// What the header shows: the address when there is one, else the label.
  /// A bare "Home" does not tell the user which address is selected.
  String get locationDisplay =>
      locationAddress.isNotEmpty ? locationAddress : location;
  final PromoBannerModel promo;
  final List<ServiceCategoryModel> categories;
  final List<ProviderModel> bestSellers;

  /// Seller ads ranked by engagement — wishlists first, views breaking ties.
  /// Empty until sellers post ads.
  final List<AdModel> topSellers;

  factory HomeFeedModel.fromJson(Map<String, dynamic> json) => HomeFeedModel(
        userName: json['userName'] as String,
        location: json['location'] as String,
        locationAddress: (json['locationAddress'] as String?) ?? '',
        promo: PromoBannerModel.fromJson(json['promo'] as Map<String, dynamic>),
        categories: (json['categories'] as List)
            .map((e) => ServiceCategoryModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        bestSellers: (json['bestSellers'] as List)
            .map((e) => ProviderModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        topSellers: ((json['topSellers'] as List?) ?? const [])
            .map((e) => AdModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
