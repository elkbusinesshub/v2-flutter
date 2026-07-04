import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/app_preferences.dart';
import 'data/datasources/api_client.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/booking_repository.dart';
import 'data/repositories/elkstay_repository.dart';
import 'data/repositories/chat_repository.dart';
import 'data/repositories/home_repository.dart';
import 'data/repositories/language_repository.dart';
import 'data/repositories/notifications_repository.dart';
import 'data/repositories/offers_repository.dart';
import 'data/repositories/payment_repository.dart';
import 'data/repositories/porter_repository.dart';
import 'data/repositories/profile_repository.dart';
import 'data/repositories/provider_repository.dart';
import 'data/repositories/rental_repository.dart';
import 'data/repositories/review_repository.dart';
import 'data/repositories/ride_repository.dart';
import 'data/repositories/services_repository.dart';
import 'data/repositories/tracking_repository.dart';
import 'data/repositories/wallet_repository.dart';

class App extends StatelessWidget {
  const App({super.key, required this.preferences, required this.apiClient});

  final AppPreferences preferences;
  final ApiClient apiClient;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: preferences),
        RepositoryProvider.value(value: apiClient),
        RepositoryProvider(create: (_) => AuthRepository(apiClient)),
        RepositoryProvider(create: (_) => LanguageRepository(apiClient)),
        RepositoryProvider(create: (_) => HomeRepository(apiClient)),
        RepositoryProvider(create: (_) => ServicesRepository(apiClient)),
        RepositoryProvider(create: (_) => BookingRepository(apiClient)),
        RepositoryProvider(create: (_) => PaymentRepository(apiClient)),
        RepositoryProvider(create: (_) => RideRepository(apiClient)),
        RepositoryProvider(create: (_) => TrackingRepository(apiClient)),
        RepositoryProvider(create: (_) => ChatRepository(apiClient)),
        RepositoryProvider(create: (_) => ReviewRepository(apiClient)),
        RepositoryProvider(create: (_) => WalletRepository(apiClient)),
        RepositoryProvider(create: (_) => OffersRepository(apiClient)),
        RepositoryProvider(create: (_) => NotificationsRepository(apiClient)),
        RepositoryProvider(create: (_) => RentalRepository(apiClient)),
        RepositoryProvider(create: (_) => PorterRepository(apiClient)),
        RepositoryProvider(create: (_) => ProfileRepository(apiClient)),
        RepositoryProvider(create: (_) => ProviderRepository(apiClient)),
        RepositoryProvider(create: (_) => ElkStayRepository(apiClient)),
      ],
      child: MaterialApp.router(
        title: 'ELK Business Hub',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        routerConfig: buildAppRouter(),
      ),
    );
  }
}
