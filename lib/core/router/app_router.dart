import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/booking_repository.dart';
import '../../data/repositories/elkstay_repository.dart';
import '../../features/elkstay/shell/elkstay_shell.dart';
import '../../features/elkrep/elkrep_shell.dart';
import '../../features/elkclean/elkclean_shell.dart';
import '../../features/seller/seller_shell.dart';
import '../../features/best_sellers/view/best_sellers_screen.dart';
import '../../features/bookings/view/my_bookings_screen.dart';
import '../../features/elkstay/stay_detail/cubit/stay_detail_cubit.dart';
import '../../features/elkstay/stay_detail/view/stay_detail_screen.dart';
import '../../data/repositories/chat_repository.dart';
import '../../data/repositories/home_repository.dart';
import '../../data/repositories/language_repository.dart';
import '../../data/repositories/notifications_repository.dart';
import '../../data/repositories/offers_repository.dart';
import '../../data/repositories/payment_repository.dart';
import '../../data/repositories/porter_repository.dart';
import '../../data/repositories/profile_repository.dart';
import '../../data/repositories/provider_repository.dart';
import '../../data/repositories/rental_repository.dart';
import '../../data/repositories/review_repository.dart';
import '../../data/repositories/ride_repository.dart';
import '../../data/repositories/services_repository.dart';
import '../../data/repositories/tracking_repository.dart';
import '../../data/repositories/wallet_repository.dart';
import '../../features/auth/bloc/auth_bloc.dart';
import '../../features/auth/view/login_screen.dart';
import '../../features/booking/bloc/booking_bloc.dart';
import '../../features/booking/view/booking_screen.dart';
import '../../features/booking/view/confirmation_screen.dart';
import '../../features/booking/view/payment_screen.dart';
import '../../features/chat/cubit/chat_cubit.dart';
import '../../features/chat/view/chat_screen.dart';
import '../../features/home/cubit/home_cubit.dart';
import '../../features/home/view/home_screen.dart';
import '../../features/language/cubit/language_cubit.dart';
import '../../features/language/view/language_screen.dart';
import '../../features/notifications/cubit/notifications_cubit.dart';
import '../../features/notifications/view/notifications_screen.dart';
import '../../features/offers/cubit/offers_cubit.dart';
import '../../features/offers/view/offers_screen.dart';
import '../../features/onboarding/cubit/onboarding_cubit.dart';
import '../../features/onboarding/view/onboarding_screen.dart';
import '../../features/porter/cubit/porter_cubit.dart';
import '../../features/porter/view/porter_screen.dart';
import '../../features/profile/cubit/profile_cubit.dart';
import '../../features/profile/view/profile_screen.dart';
import '../../features/provider_dashboard/cubit/provider_dashboard_cubit.dart';
import '../../features/provider_dashboard/view/provider_dashboard_screen.dart';
import '../../features/provider_earnings/cubit/provider_earnings_cubit.dart';
import '../../features/provider_earnings/view/provider_earnings_screen.dart';
import '../../features/provider_registration/cubit/provider_registration_cubit.dart';
import '../../features/provider_registration/view/provider_registration_screen.dart';
import '../../features/provider_schedule/cubit/provider_schedule_cubit.dart';
import '../../features/provider_schedule/view/provider_schedule_screen.dart';
import '../../features/rental/cubit/rental_cubit.dart';
import '../../features/rental/view/rental_screen.dart';
import '../../features/review/cubit/review_cubit.dart';
import '../../features/review/view/review_screen.dart';
import '../../features/service_detail/cubit/service_detail_cubit.dart';
import '../../features/service_detail/view/service_detail_screen.dart';
import '../../features/services/view/services_screen.dart';
import '../../features/splash/cubit/splash_cubit.dart';
import '../../features/splash/view/splash_screen.dart';
import '../../features/taxi/cubit/taxi_cubit.dart';
import '../../features/taxi/view/taxi_screen.dart';
import '../../features/tracking/cubit/tracking_cubit.dart';
import '../../features/tracking/view/tracking_screen.dart';
import '../../features/wallet/cubit/wallet_cubit.dart';
import '../../features/wallet/view/wallet_screen.dart';
import '../utils/app_preferences.dart';
import '../widgets/main_shell.dart';
import 'app_routes.dart';

/// The placeholder order/booking id used for screens whose dummy repositories
/// return a fixed payload regardless of the id passed in.
const _demoOrderId = 'ELK-2025-04921';
const _demoBookingId = 'b_1001';

// Root navigator key ensures routes pushed over the StatefulShellRoute use
// the top-level navigator and aren't trapped inside a branch's sub-navigator.
final _rootKey = GlobalKey<NavigatorState>();

GoRouter buildAppRouter() {
  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: AppRoutes.splash,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => BlocProvider(
          create: (context) => SplashCubit(context.read<AppPreferences>()),
          child: SplashScreen(
            onResolved: (destination) {
              switch (destination) {
                case SplashDestination.onboarding:
                  context.go(AppRoutes.onboarding);
                case SplashDestination.login:
                  context.go(AppRoutes.login);
                case SplashDestination.home:
                  context.go(AppRoutes.home);
              }
            },
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => BlocProvider(
          create: (context) => OnboardingCubit(context.read<AppPreferences>()),
          child: OnboardingScreen(
            onFinished: () => context.go(AppRoutes.login),
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => BlocProvider(
          create: (context) => AuthBloc(
            context.read<AuthRepository>(),
            context.read<AppPreferences>(),
          ),
          child: AuthScreen(
            onAuthenticated: () => context.go(AppRoutes.home),
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.language,
        builder: (context, state) => BlocProvider(
          create: (context) => LanguageCubit(
            context.read<LanguageRepository>(),
            context.read<AppPreferences>(),
          ),
          child: LanguageScreen(
            onContinue: () => context.pop(),
          ),
        ),
      ),

      // Bottom navigation shell: Home / Wallet / Profile.
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => MainShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.home,
              builder: (context, state) => BlocProvider(
                create: (context) => HomeCubit(context.read<HomeRepository>()),
                child: HomeScreen(
                  onPartnerTap: () => context.push(AppRoutes.sellerPanel),
                  onSearchTap: () => context.push(AppRoutes.services),
                  onNotificationsTap: () => context.push(AppRoutes.notifications),
                  onPromoTap: () => context.push(AppRoutes.offers),
                  onSeeAllServices: () => context.push(AppRoutes.services),
                  onSeeAllBestSellers: () => context.push(AppRoutes.bestSellers),
                  onCategoryTap: (category) {
                    switch (category.id) {
                      case 'taxi':
                        context.push(AppRoutes.taxi);
                      case 'car_rental':
                        context.push(AppRoutes.rental);
                      case 'porter':
                        context.push(AppRoutes.porter);
                      case 'cleaning':
                        context.push(AppRoutes.elkCleanHome);
                      case 'repair':
                        context.push(AppRoutes.elkRepairHome);
                      case 'elkstay':
                        context.push(AppRoutes.elkStayHome);
                      default:
                        context.push(AppRoutes.services);
                    }
                  },
                  onProviderTap: (provider) {
                    if (provider.category.startsWith('Taxi')) {
                      context.push(AppRoutes.taxi);
                    } else if (provider.category.startsWith('Rental')) {
                      context.push(AppRoutes.rental);
                    } else {
                      context.push(AppRoutes.serviceDetail(provider.id));
                    }
                  },
                ),
              ),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.bookingsTab,
              builder: (context, state) => const MyBookingsScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.wallet,
              builder: (context, state) => BlocProvider(
                create: (context) => WalletCubit(context.read<WalletRepository>()),
                child: const WalletScreen(),
              ),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.profile,
              builder: (context, state) => BlocProvider(
                create: (context) => ProfileCubit(
                  context.read<ProfileRepository>(),
                  context.read<AppPreferences>(),
                ),
                child: ProfileScreen(
                  onSignedOut: () => context.go(AppRoutes.login),
                  onWalletTap: () => context.go(AppRoutes.wallet),
                  onOffersTap: () => context.push(AppRoutes.offers),
                  onNotificationsTap: () => context.push(AppRoutes.notifications),
                  onLanguageTap: () => context.push(AppRoutes.language),
                  onRateServiceTap: () => context.push(AppRoutes.review(_demoBookingId)),
                  onBecomeProviderTap: () => context.push(AppRoutes.providerRegister),
                  onProviderDashboardTap: () => context.push(AppRoutes.providerDashboard),
                ),
              ),
            ),
          ]),
        ],
      ),

      GoRoute(
        path: AppRoutes.bestSellers,
        builder: (context, state) => const BestSellersScreen(),
      ),
      GoRoute(
        path: AppRoutes.services,
        builder: (context, state) => ServicesScreen(
          onCategoryTap: (id) {
            switch (id) {
              case 'taxi':
                context.push(AppRoutes.taxi);
              case 'car_rental':
                context.push(AppRoutes.rental);
              case 'porter':
                context.push(AppRoutes.porter);
              case 'cleaning':
                context.push(AppRoutes.elkCleanHome);
              case 'repair':
                context.push(AppRoutes.elkRepairHome);
              case 'elkstay':
                context.push(AppRoutes.elkStayHome);
            }
          },
        ),
      ),
      GoRoute(
        path: AppRoutes.sellerPanel,
        parentNavigatorKey: _rootKey,
        builder: (context, state) => SellerShell(onBack: () => context.pop()),
      ),
      GoRoute(
        path: AppRoutes.notifications,
        builder: (context, state) => BlocProvider(
          create: (context) => NotificationsCubit(context.read<NotificationsRepository>()),
          child: const NotificationsScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.offers,
        builder: (context, state) => BlocProvider(
          create: (context) => OffersCubit(context.read<OffersRepository>()),
          child: const OffersScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.taxi,
        builder: (context, state) => BlocProvider(
          create: (context) => TaxiCubit(context.read<RideRepository>()),
          child: TaxiScreen(
            onTrackRide: () => context.push(AppRoutes.tracking(_demoOrderId)),
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.rental,
        builder: (context, state) => BlocProvider(
          create: (context) => RentalCubit(context.read<RentalRepository>()),
          child: const RentalScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.porter,
        builder: (context, state) => BlocProvider(
          create: (context) => PorterCubit(context.read<PorterRepository>()),
          child: PorterScreen(
            onDone: () => context.pop(),
            onTrack: () => context.push(AppRoutes.tracking(_demoOrderId)),
          ),
        ),
      ),

      GoRoute(
        path: AppRoutes.serviceDetail(':serviceId'),
        builder: (context, state) {
          final serviceId = state.pathParameters['serviceId']!;
          return BlocProvider(
            create: (context) => ServiceDetailCubit(context.read<ServicesRepository>()),
            child: ServiceDetailScreen(
              serviceId: serviceId,
              onBookNow: () => context.push(AppRoutes.booking(serviceId)),
            ),
          );
        },
      ),

      // Booking flow shares a single BookingBloc across all three steps.
      ShellRoute(
        builder: (context, state, child) => BlocProvider(
          create: (context) => BookingBloc(
            context.read<BookingRepository>(),
            context.read<PaymentRepository>(),
          ),
          child: child,
        ),
        routes: [
          GoRoute(
            path: AppRoutes.booking(':serviceId'),
            builder: (context, state) {
              final serviceId = state.pathParameters['serviceId']!;
              return BookingScreen(
                serviceId: serviceId,
                onProceedToPayment: () => context.push(AppRoutes.bookingPayment(serviceId)),
              );
            },
          ),
          GoRoute(
            path: AppRoutes.bookingPayment(':serviceId'),
            builder: (context, state) {
              final serviceId = state.pathParameters['serviceId']!;
              return PaymentScreen(
                onPaymentSuccess: () => context.go(AppRoutes.bookingConfirmation(serviceId)),
              );
            },
          ),
          GoRoute(
            path: AppRoutes.bookingConfirmation(':serviceId'),
            builder: (context, state) => ConfirmationScreen(
              onDone: () => context.go(AppRoutes.home),
            ),
          ),
        ],
      ),

      GoRoute(
        path: AppRoutes.tracking(':orderId'),
        builder: (context, state) {
          final orderId = state.pathParameters['orderId']!;
          return BlocProvider(
            create: (context) => TrackingCubit(context.read<TrackingRepository>()),
            child: TrackingScreen(
              orderId: orderId,
              onChatTap: () => context.push(AppRoutes.trackingChat(orderId)),
              onCancelled: () => context.go(AppRoutes.home),
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.trackingChat(':orderId'),
        builder: (context, state) {
          final orderId = state.pathParameters['orderId']!;
          return BlocProvider(
            create: (context) => ChatCubit(context.read<ChatRepository>()),
            child: ChatScreen(orderId: orderId),
          );
        },
      ),

      GoRoute(
        path: AppRoutes.review(':bookingId'),
        builder: (context, state) {
          final bookingId = state.pathParameters['bookingId']!;
          return BlocProvider(
            create: (context) => ReviewCubit(context.read<ReviewRepository>()),
            child: ReviewScreen(
              bookingId: bookingId,
              onDone: () => context.pop(),
            ),
          );
        },
      ),

      GoRoute(
        path: AppRoutes.providerRegister,
        builder: (context, state) => BlocProvider(
          create: (context) => ProviderRegistrationCubit(context.read<ProviderRepository>()),
          child: ProviderRegistrationScreen(
            onDone: () => context.go(AppRoutes.providerDashboard),
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.providerDashboard,
        builder: (context, state) => BlocProvider(
          create: (context) => ProviderDashboardCubit(context.read<ProviderRepository>()),
          child: ProviderDashboardScreen(
            onScheduleTap: () => context.push(AppRoutes.providerSchedule),
            onEarningsTap: () => context.push(AppRoutes.providerEarnings),
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.providerSchedule,
        builder: (context, state) => BlocProvider(
          create: (context) => ProviderScheduleCubit(context.read<ProviderRepository>()),
          child: const ProviderScheduleScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.providerEarnings,
        builder: (context, state) => BlocProvider(
          create: (context) => ProviderEarningsCubit(context.read<ProviderRepository>()),
          child: const ProviderEarningsScreen(),
        ),
      ),

      GoRoute(
        path: AppRoutes.elkCleanHome,
        builder: (context, state) => ElkCleanShell(onBack: () => context.pop()),
      ),
      GoRoute(
        path: AppRoutes.elkRepairHome,
        builder: (context, state) => ElkRepairShell(onBack: () => context.pop()),
      ),

      GoRoute(
        path: AppRoutes.elkStayHome,
        builder: (context, state) => ElkStayShell(
          onStayTap: (stayId) => context.push(AppRoutes.elkStayDetail(stayId)),
          onBack: () => context.pop(),
        ),
      ),
      GoRoute(
        path: '/elkstay/stay/:stayId',
        builder: (context, state) {
          final stayId = state.pathParameters['stayId']!;
          return BlocProvider(
            create: (context) => StayDetailCubit(context.read<ElkStayRepository>()),
            child: StayDetailScreen(stayId: stayId),
          );
        },
      ),
    ],
  );
}
