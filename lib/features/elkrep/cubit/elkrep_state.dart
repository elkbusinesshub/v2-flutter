part of 'elkrep_cubit.dart';

enum RepairViewStatus { initial, loading, loaded, error, guest }

class ElkRepState extends Equatable {
  const ElkRepState({
    this.feedStatus = RepairViewStatus.initial,
    this.feed,
    this.feedError,
    this.servicesStatus = RepairViewStatus.initial,
    this.services = const [],
    this.servicesError,
    this.category,
    this.optionsStatus = RepairViewStatus.initial,
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

  final RepairViewStatus feedStatus;
  final RepairHomeFeedModel? feed;
  final String? feedError;

  final RepairViewStatus servicesStatus;
  final List<RepairServiceModel> services;
  final String? servicesError;

  /// The trade the user is browsing.
  final RepairCategoryModel? category;

  final RepairViewStatus optionsStatus;
  final RepairBookingOptionsModel? options;
  final String? optionsError;

  final List<RepairCartLine> cart;
  final int dateIndex;
  final String? timeSlot;
  final String? addressId;
  final String paymentMethod;

  final bool isBooking;
  final String? bookingError;
  final RepairBookingModel? confirmation;

  int get cartCount => cart.length;

  int get subtotal => cart.fold(0, (sum, l) => sum + l.lineTotal);

  int get visitFee => options?.visitFee ?? 15;

  int get total => cart.isEmpty ? 0 : subtotal + visitFee;

  int qtyOf(String serviceId) =>
      cart.where((l) => l.service.id == serviceId).firstOrNull?.quantity ?? 0;

  RepairDateOptionModel? get selectedDate =>
      options != null && dateIndex < options!.dates.length
          ? options!.dates[dateIndex]
          : null;

  /// Arrival windows bookable on the selected date — today's shrink as the day
  /// passes. Falls back to the full catalogue for a backend that predates
  /// per-date slots.
  List<String> get availableTimeSlots {
    final all = options?.timeSlots ?? const <String>[];
    final slots = selectedDate?.slots ?? const <String>[];
    return slots.isEmpty ? all : slots;
  }

  RepairAddressModel? get selectedAddress =>
      options?.addresses.where((a) => a.id == addressId).firstOrNull;

  ElkRepState copyWith({
    RepairViewStatus? feedStatus,
    RepairHomeFeedModel? feed,
    String? feedError,
    RepairViewStatus? servicesStatus,
    List<RepairServiceModel>? services,
    String? servicesError,
    RepairCategoryModel? category,
    RepairViewStatus? optionsStatus,
    RepairBookingOptionsModel? options,
    String? optionsError,
    List<RepairCartLine>? cart,
    int? dateIndex,
    String? timeSlot,
    String? addressId,
    String? paymentMethod,
    bool? isBooking,
    String? bookingError,
    RepairBookingModel? confirmation,
  }) {
    return ElkRepState(
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
