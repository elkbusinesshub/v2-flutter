/// Centralised path definitions for [GoRouter] so screens never hardcode
/// route strings.
class AppRoutes {
  AppRoutes._();

  static const splash = '/splash';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const language = '/language';

  static const home = '/home';
  static const bookingsTab = '/my-bookings';
  static const services = '/services';
  static const wallet = '/wallet';
  static const profile = '/profile';

  static const notifications = '/notifications';
  static const offers = '/offers';
  static const taxi = '/taxi';
  static const rental = '/rental';
  static const porter = '/porter';


  static String serviceDetail(String serviceId) => '/service/$serviceId';
  static String booking(String serviceId) => '/booking/$serviceId';
  static String bookingPayment(String serviceId) => '/booking/$serviceId/payment';
  static String bookingConfirmation(String serviceId) => '/booking/$serviceId/confirmation';

  static String tracking(String orderId) => '/tracking/$orderId';
  static String trackingChat(String orderId) => '/tracking/$orderId/chat';

  static String review(String bookingId) => '/review/$bookingId';

  static const addresses = '/addresses';
  static const bestSellers = '/best-sellers';
  static const sellerPanel = '/seller';
  static const elkRepairHome = '/elkrep';
  static const elkCleanHome = '/elkclean';

  static const elkStayHome = '/elkstay';
  static String elkStayDetail(String stayId) => '/elkstay/stay/$stayId';
}
