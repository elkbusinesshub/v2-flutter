import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/api_exception.dart';
import '../../../core/utils/app_preferences.dart';
import '../../../data/adapters/ad_location.dart';
import '../../../data/adapters/clean_ads_adapter.dart';
import '../../../data/models/ad_models.dart';
import '../../../data/models/elkclean_models.dart';
import '../../../data/repositories/locations_repository.dart';
import '../../../data/repositories/marketplace_repository.dart';

part 'elkclean_state.dart';

/// Drives the whole ELK Clean shell: home feed, category services, the
/// cart, scheduling options (dates/slots/addresses), and booking creation.
/// Navigation between the shell's screens stays inside the shell widget.
///
/// What is bookable here is now whatever sellers have listed under the
/// `cleaning` category — the seeded catalogue is gone. The shell and its
/// models are unchanged; [CleanAdsAdapter] does the whole translation, and
/// this cubit's API is deliberately identical to what it was.
class ElkCleanCubit extends Cubit<ElkCleanState> {
  ElkCleanCubit(this._marketplace, this._locations, this._preferences)
      : super(const ElkCleanState());

  final MarketplaceRepository _marketplace;
  final LocationsRepository _locations;
  final AppPreferences _preferences;

  /// Every cleaning listing from the last load.
  ///
  /// The grid and the per-tile lists are two views of one fetch, so switching
  /// tiles costs no round trip and the tile counts always match the rows
  /// behind them.
  List<AdModel> _ads = const [];

  /// Arrival windows. Generated here rather than fetched: they were the
  /// seeded `clean_bookings` module's, and an order carries only an instant.
  static const _timeSlots = ['09:00', '11:00', '13:00', '15:00', '17:00', '19:00'];

  /// Flat fee the screen has always added on top of the cart.
  static const _supplyFee = 10;

  /// How many days ahead the date strip offers.
  static const _bookableDays = 7;

  /// City-center fallback: the location picker has no device geolocation yet
  /// and the backend requires coordinates on new addresses.
  static const _fallbackLat = 12.9716;
  static const _fallbackLng = 77.5946;

  Future<void> loadHome() async {
    if (_preferences.isGuest) {
      emit(state.copyWith(feedStatus: CleanViewStatus.guest));
      return;
    }
    emit(state.copyWith(feedStatus: CleanViewStatus.loading));
    try {
      _ads = await _marketplace.listAds(category: CleanAdsAdapter.categorySlug);
      final feed = CleanHomeFeedModel(
        userName: _preferences.userName ?? '',
        // The header showed the city the seeded catalogue served. Listings
        // carry their own locality, so the most common one is the honest
        // answer to "where is this".
        location: commonestAdLocation(_ads),
        categories: CleanAdsAdapter.categories(_ads),
        // Offer cards came from `clean_offers`, which no seller can write to.
        offers: const [],
      );
      emit(state.copyWith(feedStatus: CleanViewStatus.loaded, feed: feed));
    } catch (e) {
      emit(state.copyWith(
        feedStatus: CleanViewStatus.error,
        feedError: friendlyErrorMessage(e),
      ));
    }
  }

  /// Opens a tile. The listings are already loaded, so this filters rather
  /// than fetches — the tile counts and the rows behind them cannot disagree.
  Future<void> openCategory(CleanCategoryModel category) async {
    emit(state.copyWith(
      category: category,
      servicesStatus: CleanViewStatus.loaded,
      services: CleanAdsAdapter.servicesIn(_ads, category.slug),
    ));
  }

  // ─── cart ─────────────────────────────────────────────────────────────

  void addService(CleanServiceModel service) {
    final index = state.cart.indexWhere((l) => l.service.id == service.id);
    final cart = [...state.cart];
    if (index >= 0) {
      cart[index] = cart[index].copyWith(quantity: cart[index].quantity + 1);
    } else {
      cart.add(CleanCartLine(service: service, quantity: 1));
    }
    emit(state.copyWith(cart: cart));
  }

  void incrementLine(String serviceId) {
    final index = state.cart.indexWhere((l) => l.service.id == serviceId);
    if (index < 0) return;
    final cart = [...state.cart];
    cart[index] = cart[index].copyWith(quantity: cart[index].quantity + 1);
    emit(state.copyWith(cart: cart));
  }

  void decrementLine(String serviceId) {
    final index = state.cart.indexWhere((l) => l.service.id == serviceId);
    if (index < 0) return;
    final cart = [...state.cart];
    if (cart[index].quantity > 1) {
      cart[index] = cart[index].copyWith(quantity: cart[index].quantity - 1);
    } else {
      cart.removeAt(index);
    }
    emit(state.copyWith(cart: cart));
  }

  void removeLine(String serviceId) {
    emit(state.copyWith(
      cart: state.cart.where((l) => l.service.id != serviceId).toList(),
    ));
  }

  // ─── scheduling ───────────────────────────────────────────────────────

  Future<void> loadBookingOptions() async {
    emit(state.copyWith(optionsStatus: CleanViewStatus.loading));
    try {
      final options = CleanBookingOptionsModel(
        dates: _upcomingDates(),
        timeSlots: _timeSlots,
        supplyFee: _supplyFee,
        addresses: [
          for (final a in await _locations.getAddresses())
            CleanAddressModel(
              id: a.id,
              label: a.label,
              line: a.formattedAddress,
              isDefault: a.isDefault,
              lat: a.lat,
              lng: a.lng,
            ),
        ],
      );
      // Keep valid selections; default the rest.
      final dateIndex = state.dateIndex < options.dates.length ? state.dateIndex : 0;
      // Slots must come from the chosen date, not the full catalogue: today's
      // earlier windows have passed, and the backend rejects them.
      final slots = _slotsFor(options, dateIndex);
      final timeSlot =
          slots.contains(state.timeSlot) ? state.timeSlot : slots.firstOrNull;
      final addresses = options.addresses;
      final currentAddressValid = addresses.any((a) => a.id == state.addressId);
      final addressId = currentAddressValid
          ? state.addressId
          : (addresses.where((a) => a.isDefault).firstOrNull ?? addresses.firstOrNull)?.id;
      emit(state.copyWith(
        optionsStatus: CleanViewStatus.loaded,
        options: options,
        dateIndex: dateIndex,
        timeSlot: timeSlot,
        addressId: addressId,
      ));
    } catch (e) {
      emit(state.copyWith(
        optionsStatus: CleanViewStatus.error,
        optionsError: friendlyErrorMessage(e),
      ));
    }
  }

  /// Switching date re-picks the slot: the windows left today are a subset of
  /// a future day's, so a selection carried over could be one that has passed.
  void selectDate(int index) {
    final options = state.options;
    if (options == null) {
      emit(state.copyWith(dateIndex: index));
      return;
    }
    final slots = _slotsFor(options, index);
    emit(state.copyWith(
      dateIndex: index,
      timeSlot: slots.contains(state.timeSlot) ? state.timeSlot : slots.firstOrNull,
    ));
  }

  void selectTimeSlot(String slot) => emit(state.copyWith(timeSlot: slot));

  /// The date strip: today plus the next few days.
  ///
  /// Today only offers windows that have not already passed, which is what the
  /// backend used to enforce — an order for 09:00 placed at noon was rejected.
  /// A day with nothing left is dropped rather than shown empty.
  static List<CleanDateOptionModel> _upcomingDates() {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final now = DateTime.now();
    final dates = <CleanDateOptionModel>[];

    for (var i = 0; i < _bookableDays; i++) {
      final day = DateTime(now.year, now.month, now.day).add(Duration(days: i));
      final slots = i == 0
          ? _timeSlots.where((s) => int.parse(s.split(':')[0]) > now.hour).toList()
          : _timeSlots;
      if (slots.isEmpty) continue;
      dates.add(CleanDateOptionModel(
        date: '${day.year.toString().padLeft(4, '0')}-'
            '${day.month.toString().padLeft(2, '0')}-'
            '${day.day.toString().padLeft(2, '0')}',
        day: day.day,
        weekday: weekdays[day.weekday - 1],
        slots: slots,
      ));
    }
    return dates;
  }

  /// Bookable windows for the date at [index].
  ///
  /// Falls back to the full catalogue for a backend that predates per-date
  /// slots, so an older server still yields a usable (if unfiltered) list.
  static List<String> _slotsFor(CleanBookingOptionsModel options, int index) {
    if (index < 0 || index >= options.dates.length) return options.timeSlots;
    final slots = options.dates[index].slots;
    return slots.isEmpty ? options.timeSlots : slots;
  }

  void selectAddress(String id) => emit(state.copyWith(addressId: id));

  void selectPaymentMethod(String method) =>
      emit(state.copyWith(paymentMethod: method));

  /// Saves a new address and selects it. Returns an error message, or null
  /// on success.
  Future<String?> addAddress({
    required String label,
    required String line,
  }) async {
    try {
      final created = await _locations.addAddress(
        label: label,
        formattedAddress: line,
        lat: _fallbackLat,
        lng: _fallbackLng,
      );
      await loadBookingOptions();
      emit(state.copyWith(addressId: created.id));
      return null;
    } catch (e) {
      return friendlyErrorMessage(e);
    }
  }

  // ─── booking ──────────────────────────────────────────────────────────

  /// Creates the booking from the current cart + selections.
  /// Returns true on success (cart cleared, [ElkCleanState.confirmation] set).
  Future<bool> confirmBooking() async {
    final date = state.selectedDate;
    final timeSlot = state.timeSlot;
    final addressId = state.addressId;
    if (state.cart.isEmpty || date == null || timeSlot == null || addressId == null) {
      emit(state.copyWith(bookingError: 'Please pick a slot and address first.'));
      return false;
    }

    final address = state.selectedAddress;
    if (address == null) {
      emit(state.copyWith(bookingError: 'Please pick a slot and address first.'));
      return false;
    }

    emit(state.copyWith(isBooking: true, bookingError: null));
    try {
      final scheduledAt = DateTime.parse('${date.date}T$timeSlot:00');

      // One order per line, not one per cart: two listings may belong to two
      // different sellers, and each has to reach the person who will do the
      // work. They are placed in sequence so a failure halfway leaves the
      // rest unplaced rather than half-charged.
      // The supply fee is charged once for the visit, not once per line, so
      // it rides on the first order and the batch totals what the screen said.
      final placed = <AdOrderModel>[];
      for (final line in state.cart) {
        placed.add(await _marketplace.placeOrder(
          line.service.id,
          addressText: address.line,
          contactPhone: _preferences.userPhone ?? '',
          quantity: line.quantity,
          scheduledAt: scheduledAt,
          feesAmount: placed.isEmpty ? state.supplyFee.toDouble() : null,
        ));
      }

      emit(state.copyWith(
        isBooking: false,
        // The done screen shows one reference. With several orders the first
        // stands for the batch, and its code is what the seller sees too.
        confirmation: CleanBookingModel(
          id: placed.first.id,
          code: placed.first.code,
          status: 'CONFIRMED',
          scheduledDate: date.date,
          timeSlot: timeSlot,
          addressLabel: address.label,
          addressLine: address.line,
          subtotal: state.subtotal,
          supplyFee: state.supplyFee,
          discountAmount: 0,
          totalAmount: state.total,
          paymentMethod: state.paymentMethod,
        ),
        cart: const [],
      ));
      return true;
    } catch (e) {
      emit(state.copyWith(
        isBooking: false,
        bookingError: friendlyErrorMessage(e),
      ));
      return false;
    }
  }
}
