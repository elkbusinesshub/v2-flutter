import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/push/push_service.dart';
import 'core/push/push_tokens.dart';
import 'core/api/api_client.dart';
import 'core/api/token_storage.dart';
import 'core/l10n/l10n.dart';
import 'core/l10n/locale_cubit.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/app_preferences.dart';
import 'l10n/app_localizations.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/locations_repository.dart';
import 'data/repositories/marketplace_repository.dart';
import 'data/repositories/places_repository.dart';
import 'data/repositories/booking_repository.dart';
import 'data/repositories/chat_repository.dart';
import 'data/repositories/home_repository.dart';
import 'data/repositories/language_repository.dart';
import 'data/repositories/notifications_repository.dart';
import 'data/repositories/offers_repository.dart';
import 'data/repositories/payment_repository.dart';
import 'data/repositories/porter_repository.dart';
import 'data/repositories/profile_repository.dart';
import 'data/repositories/provider_repository.dart';
import 'data/repositories/review_repository.dart';
import 'data/repositories/ride_repository.dart';
import 'data/repositories/tracking_repository.dart';
import 'data/repositories/wallet_repository.dart';

class App extends StatefulWidget {
  const App({
    super.key,
    required this.preferences,
    required this.apiClient,
    required this.tokenStorage,
  });

  final AppPreferences preferences;

  /// Backend client shared by every repository.
  final ApiClient apiClient;
  final TokenStorage tokenStorage;

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  /// Built once. Changing the language rebuilds `MaterialApp`, and rebuilding
  /// the router with it would throw away the navigation stack — the user would
  /// be bounced to the start route every time they switched language.
  late final _router = buildAppRouter();

  @override
  Widget build(BuildContext context) {
    final preferences = widget.preferences;
    final apiClient = widget.apiClient;
    final tokenStorage = widget.tokenStorage;

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: preferences),
        RepositoryProvider.value(value: apiClient),
        RepositoryProvider.value(value: tokenStorage),
        RepositoryProvider(create: (_) => AuthRepository(apiClient, tokenStorage)),
        RepositoryProvider(create: (_) => LanguageRepository(apiClient)),
        RepositoryProvider(create: (_) => HomeRepository(apiClient)),
        RepositoryProvider(create: (_) => BookingRepository(apiClient)),
        RepositoryProvider(create: (_) => PaymentRepository(apiClient)),
        RepositoryProvider(create: (_) => RideRepository(apiClient)),
        RepositoryProvider(create: (_) => TrackingRepository(apiClient)),
        RepositoryProvider(create: (_) => ChatRepository(apiClient)),
        RepositoryProvider(create: (_) => ReviewRepository(apiClient)),
        RepositoryProvider(create: (_) => WalletRepository(apiClient)),
        RepositoryProvider(create: (_) => OffersRepository(apiClient)),
        RepositoryProvider(create: (_) => NotificationsRepository(apiClient)),
        RepositoryProvider(
          create: (context) => PushService(
            context.read<NotificationsRepository>(),
            FirebasePushTokens(),
          ),
        ),
        RepositoryProvider(create: (_) => PorterRepository(apiClient)),
        RepositoryProvider(create: (_) => ProfileRepository(apiClient)),
        RepositoryProvider(create: (_) => ProviderRepository(apiClient)),
        RepositoryProvider(create: (_) => LocationsRepository(apiClient)),
        RepositoryProvider(create: (_) => PlacesRepository(apiClient)),
        RepositoryProvider(create: (_) => MarketplaceRepository(apiClient)),
      ],
      child: BlocProvider(
        create: (_) => LocaleCubit(preferences),
        // Rebuilding MaterialApp is what makes a language change take effect
        // everywhere at once, rather than only on screens opened afterwards.
        child: BlocBuilder<LocaleCubit, Locale>(
          builder: (context, locale) => MaterialApp.router(
            title: 'ELK Business Hub',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            locale: locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            // Runs below Localizations, so this is the first place the loaded
            // translations exist. Cubits and ApiException read them from here.
            builder: (context, child) {
              L10n.current = AppLocalizations.of(context);
              return child!;
            },
            routerConfig: _router,
          ),
        ),
      ),
    );
  }
}
