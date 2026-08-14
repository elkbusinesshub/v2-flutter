part of 'elkclean_cubit.dart';

enum CleanViewStatus { initial, loading, loaded, error, guest }

class ElkCleanState extends Equatable {
  const ElkCleanState({
    this.feedStatus = CleanViewStatus.initial,
    this.feed,
    this.feedError,
    this.servicesStatus = CleanViewStatus.initial,
    this.services = const [],
    this.servicesError,
    this.category,
    this.optionsStatus = CleanViewStatus.initial,
    this.options,
    this.optionsError,
    this.cart = const [],
    this.dateIndex = 0,
    this.timeSlot,
    this.addressId,
    this.paymentMethod = 'card',
    this.isBooking = false,
    this.bookingError,
    this.confirmation,
  });

  final CleanViewStatus feedStatus;
  final CleanHomeFeedModel? feed;
  final String? feedError;

  final CleanViewStatus servicesStatus;
  final List<CleanServiceModel> services;
  final String? servicesError;

  /// The category the user is browsing.
  final CleanCategoryModel? category;

  final CleanViewStatus optionsStatus;
  final CleanBookingOptionsModel? options;
  final String? optionsError;

  final List<CleanCartLine> cart;
  final int dateIndex;
  final String? timeSlot;
  final String? addressId;
  final String paymentMethod;

  final bool isBooking;
  final String? bookingError;
  final CleanBookingModel? confirmation;

  int get cartCount => cart.length;

  int get subtotal => cart.fold(0, (sum, l) => sum + l.lineTotal);

  int get supplyFee => options?.supplyFee ?? 10;

  int get total => cart.isEmpty ? 0 : subtotal + supplyFee;

  int qtyOf(String serviceId) =>
      cart.where((l) => l.service.id == serviceId).firstOrNull?.quantity ?? 0;

  CleanDateOptionModel? get selectedDate =>
      options != null && dateIndex < options!.dates.length
          ? options!.dates[dateIndex]
          : null;

  CleanAddressModel? get selectedAddress =>
      options?.addresses.where((a) => a.id == addressId).firstOrNull;

  /// Arrival windows bookable on the selected date — today's shrink as the day
  /// passes. Falls back to the full catalogue for a backend that predates
  /// per-date slots.
  List<String> get availableTimeSlots {
    final all = options?.timeSlots ?? const <String>[];
    final slots = selectedDate?.slots ?? const <String>[];
    return slots.isEmpty ? all : slots;
  }

  ElkCleanState copyWith({
    CleanViewStatus? feedStatus,
    CleanHomeFeedModel? feed,
    String? feedError,
    CleanViewStatus? servicesStatus,
    List<CleanServiceModel>? services,
    String? servicesError,
    CleanCategoryModel? category,
    CleanViewStatus? optionsStatus,
    CleanBookingOptionsModel? options,
    String? optionsError,
    List<CleanCartLine>? cart,
    int? dateIndex,
    String? timeSlot,
    String? addressId,
    String? paymentMethod,
    bool? isBooking,
    String? bookingError,
    CleanBookingModel? confirmation,
  }) {
    return ElkCleanState(
      feedStatus: feedStatus ?? this.feedStatus,
      feed: feed ?? this.feed,
      feedError: feedError,
      servicesStatus: servicesStatus ?? this.servicesStatus,
      services: services ?? this.services,
      servicesError: servicesError,
      category: category ?? this.category,
      optionsStatus: optionsStatus ?? this.optionsStatus,
      options: options ?? this.options,
      optionsError: optionsError,
      cart: cart ?? this.cart,
      dateIndex: dateIndex ?? this.dateIndex,
      timeSlot: timeSlot ?? this.timeSlot,
      addressId: addressId ?? this.addressId,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      isBooking: isBooking ?? this.isBooking,
      bookingError: bookingError,
      confirmation: confirmation ?? this.confirmation,
    );
  }

  @override
  List<Object?> get props => [
        feedStatus,
        feed,
        feedError,
        servicesStatus,
        services,
        servicesError,
        category,
        optionsStatus,
        options,
        optionsError,
        cart,
        dateIndex,
        timeSlot,
        addressId,
        paymentMethod,
        isBooking,
        bookingError,
        confirmation,
      ];
}
