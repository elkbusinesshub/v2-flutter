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
    required this.promo,
    required this.categories,
    required this.bestSellers,
  });

  final String userName;
  final String location;
  final PromoBannerModel promo;
  final List<ServiceCategoryModel> categories;
  final List<ProviderModel> bestSellers;
}
