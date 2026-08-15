/// Backend endpoint paths, relative to [ApiConfig.apiBaseUrl].
///
/// Grouped per module; add constants here as features are integrated.
class ApiEndpoints {
  ApiEndpoints._();

  // ── auth ──────────────────────────────────────────────────────────────
  static const String requestOtp = '/auth/otp/request';
  static const String verifyOtp = '/auth/otp/verify';
  static const String refreshToken = '/auth/refresh';
  static const String logout = '/auth/logout';

  // ── users ─────────────────────────────────────────────────────────────
  static const String profile = '/users/me';
  static const String profileLanguage = '/users/me/language';

  // ── config ────────────────────────────────────────────────────────────
  static const String languages = '/config/languages';

  // ── home ──────────────────────────────────────────────────────────────
  static const String homeFeed = '/home/feed';

  // ── bookings ──────────────────────────────────────────────────────────
  /// Every booking the user has, whichever system holds it. Read-only —
  /// cancelling is routed per vertical; see [BookingRepository.cancelBooking].
  static const String bookings = '/bookings';

  // ── reviews ───────────────────────────────────────────────────────────
  static String reviewTarget(String bookingId) => '/bookings/$bookingId/review-target';
  static String submitReview(String bookingId) => '/bookings/$bookingId/reviews';

  // ── payments ──────────────────────────────────────────────────────────
  static const String paymentMethods = '/payments/methods';
  static const String paymentCharge = '/payments/charge';

  // ── wallet ────────────────────────────────────────────────────────────
  static const String wallet = '/wallet';
  static const String walletTopUp = '/wallet/top-up';
  static const String walletWithdraw = '/wallet/withdraw';

  // ── notifications ─────────────────────────────────────────────────────
  static const String notifications = '/notifications';
  static const String notificationsMarkAllRead = '/notifications/mark-all-read';
  static const String notificationDevices = '/notifications/devices';

  // ── offers ────────────────────────────────────────────────────────────
  static const String offers = '/offers';

  // ── orders (tracking + chat) ──────────────────────────────────────────
  // An "order" is a home-services booking, addressed by its booking id.
  static String orderTracking(String id) => '/orders/$id/tracking';
  static String orderCancel(String id) => '/orders/$id/cancel';
  static String orderChat(String id) => '/orders/$id/chat';

  // ── dispatch (drivers & delivery partners) ────────────────────────────
  static const String dispatchProfiles = '/dispatch/me';
  static const String dispatchRegister = '/dispatch/register';
  static const String dispatchOnline = '/dispatch/online';
  static const String dispatchLocation = '/dispatch/location';
  static const String dispatchNearbyRides = '/dispatch/nearby/rides';
  static const String dispatchNearbyPorter = '/dispatch/nearby/porter';

  // ── elkclean ──────────────────────────────────────────────────────────
  static const String elkCleanHome = '/elkclean/home';
  static const String elkCleanCategories = '/elkclean/categories';
  static String elkCleanCategoryServices(String slug) => '/elkclean/categories/$slug/services';
  static const String elkCleanBookingOptions = '/elkclean/booking-options';
  static const String elkCleanQuote = '/elkclean/quote';
  static const String elkCleanBookings = '/elkclean/bookings';

  // ── elkrep (repair) ───────────────────────────────────────────────────
  static const String elkRepHome = '/elkrep/home';
  static String elkRepCategoryServices(String slug) => '/elkrep/categories/$slug/services';
  static const String elkRepBookingOptions = '/elkrep/booking-options';
  static const String elkRepQuote = '/elkrep/quote';
  static const String elkRepBookings = '/elkrep/bookings';

  // ── elkstay ───────────────────────────────────────────────────────────
  static const String elkStayHome = '/elkstay/home';
  static const String elkStays = '/elkstay/stays';
  static String elkStayDetail(String id) => '/elkstay/stay/$id';
  static String elkStayFavorite(String id) => '/elkstay/stay/$id/favorite';
  static const String elkStayFavorites = '/elkstay/favorites';
  static const String elkStayBookings = '/elkstay/bookings';
  static const String elkStayVisits = '/elkstay/visits';

  // ── rentals ───────────────────────────────────────────────────────────
  static const String rentalCars = '/rentals/cars';
  static String rentalCarAvailability(String id) => '/rentals/cars/$id/availability';
  static const String rentalBranches = '/rentals/branches';
  static const String rentalExtras = '/rentals/extras';
  static const String rentalQuote = '/rentals/quote';
  static const String rentalBookings = '/rentals/bookings';

  // ── rides (taxi) ──────────────────────────────────────────────────────
  static const String rideTypes = '/rides/types';
  static const String rideCurrentEstimate = '/rides/current-estimate';
  static const String rideRequest = '/rides/request';
  static const String rideBookings = '/rides/bookings';
  static String rideBooking(String id) => '/rides/bookings/$id';
  static String rideStart(String id) => '/rides/bookings/$id/start';
  static String rideComplete(String id) => '/rides/bookings/$id/complete';
  static String rideAccept(String id) => '/rides/bookings/$id/accept';
  static String rideDriverStart(String id) => '/rides/bookings/$id/driver-start';
  static String rideDriverComplete(String id) => '/rides/bookings/$id/driver-complete';
  static const String rideDriverActive = '/rides/driver/active';
  static String rideCancel(String id) => '/rides/bookings/$id/cancel';
  static String rideRate(String id) => '/rides/bookings/$id/rate';

  // ── porter ────────────────────────────────────────────────────────────
  static const String porterOptions = '/porter/options';
  static const String porterQuote = '/porter/quote';
  static const String porterBookings = '/porter/bookings';
  static String porterAccept(String id) => '/porter/bookings/$id/accept';
  static String porterDriverPickup(String id) => '/porter/bookings/$id/driver-pickup';
  static String porterDriverDeliver(String id) => '/porter/bookings/$id/driver-deliver';
  static const String porterDriverActive = '/porter/driver/active';
  static String porterCancel(String id) => '/porter/bookings/$id/cancel';

  // ── provider ──────────────────────────────────────────────────────────
  static const String providerRegistration = '/provider/registration';
  static const String providerDashboard = '/provider/dashboard';
  static const String providerSchedule = '/provider/schedule';
  static const String providerEarnings = '/provider/earnings';
  static const String providerAvailability = '/provider/availability';

  // ── locations ─────────────────────────────────────────────────────────
  static const String locations = '/locations';
  static String location(String id) => '/locations/$id';

  // ── marketplace (seller ads) ──────────────────────────────────────────
  static const String marketplaceTopSellers = '/marketplace/top-sellers';
  static const String marketplaceAds = '/marketplace/ads';
  static String marketplaceAd(String id) => '/marketplace/ads/$id';
  static String marketplaceAdWishlist(String id) => '/marketplace/ads/$id/wishlist';
  static const String marketplaceMyAds = '/marketplace/my-ads';
  static String marketplaceAdOrders(String adId) => '/marketplace/ads/$adId/orders';
  static const String marketplaceSellerOrders = '/marketplace/seller-orders';
  static const String marketplaceSellerOrderCounts = '/marketplace/seller-orders/counts';
  static const String marketplaceMyOrders = '/marketplace/orders';
  static String marketplaceOrderStatus(String id) => '/marketplace/orders/$id/status';

  // ── uploads ───────────────────────────────────────────────────────────
  static const String uploadImage = '/uploads/image';

  // ── places (geocoding) ────────────────────────────────────────────────
  static const String placeSearch = '/places/search';
  static const String placeReverse = '/places/reverse';
  static const String placeStaticMap = '/places/static-map';
  static const String placeRoute = '/places/route';
  static String placeDetails(String placeId) => '/places/$placeId';
}
