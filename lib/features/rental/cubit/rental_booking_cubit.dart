import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/api_exception.dart';
import '../../../core/utils/app_preferences.dart';
import '../../../data/adapters/rental_ads_adapter.dart';
import '../../../data/models/rental_models.dart';
import '../../../data/repositories/marketplace_repository.dart';

part 'rental_booking_state.dart';

/// Backs the 5-step rental booking flow: the pickup point, the priced trip,
/// and the booking itself. Trip dates, addresses and card fields stay local to
/// the flow widget.
///
/// A car is now a seller's listing rather than a fleet vehicle, which changes
/// where three things come from:
///
///  * **Pickup point** — the seller's own locality, one per listing, instead
///    of a company branch list.
///  * **Price** — computed here from the listing's daily rate. There is no
///    server-side quote endpoint any more; the order is priced by the backend
///    from the same listing when it is placed, so this is a preview rather
///    than the authority.
///  * **Extras and promo codes** — gone. They were rows in `rental_extras`
///    and `rental_promos`, and no seller can write to either.
class RentalBookingCubit extends Cubit<RentalBookingState> {
  RentalBookingCubit(this._marketplace, this._preferences)
      : super(const RentalBookingState());

  final MarketplaceRepository _marketplace;
  final AppPreferences _preferences;

  /// VAT the screen has always shown, as a percentage of the subtotal.
  static const _vatPercent = 5;

  /// Charged when the car is brought to the renter rather than collected.
  static const _deliveryFee = 25;

  /// The listing being booked, held for pricing.
  RentalCarModel? _car;

  /// Loads the pickup point for [carId].
  ///
  /// One "branch" — where the seller is. The flow renders the same list it
  /// always did; it simply has a single entry.
  Future<void> loadOptions(String carId) async {
    emit(state.copyWith(optionsStatus: RentalOptionsStatus.loading));
    try {
      final ad = await _marketplace.getAd(carId);
      _car = RentalAdsAdapter.car(ad);
      final branch = RentalBranchModel(
        id: ad.id,
        slug: ad.id,
        name: ad.sellerName,
        address: ad.location.isEmpty ? 'Collect from the owner' : ad.location,
        // The seeded branches showed a hand-written distance; nothing computes
        // one, so the card shows none rather than a made-up figure.
        distance: '',
        lat: ad.lat,
        lng: ad.lng,
      );
      emit(state.copyWith(
        optionsStatus: RentalOptionsStatus.loaded,
        branches: [branch],
        // `rental_extras` had no seller equivalent, so the extras step has
        // nothing to offer rather than offering something nobody supplies.
        extras: const [],
        selectedBranchId: branch.id,
      ));
    } catch (e) {
      emit(state.copyWith(
        optionsStatus: RentalOptionsStatus.error,
        optionsError: friendlyErrorMessage(e),
      ));
    }
  }

  void selectBranch(String id) => emit(state.copyWith(selectedBranchId: id));

  void toggleExtra(String key) {
    final keys = {...state.selectedExtraKeys};
    if (!keys.remove(key)) keys.add(key);
    emit(state.copyWith(selectedExtraKeys: keys));
  }

  /// Prices the trip from the listing's daily rate.
  ///
  /// Synchronous work behind an async signature, because the flow calls it
  /// where a network round trip used to happen.
  Future<void> refreshQuote(Map<String, dynamic> request) async {
    final car = _car;
    if (car == null) {
      emit(state.copyWith(quoteError: 'Pick a car first.'));
      return;
    }
    final days = _daysBetween(request);
    if (days == null) {
      emit(state.copyWith(quoteError: 'Pick a return date after the pickup date.'));
      return;
    }

    final dailyRate = car.pricePerDay.round();
    final rentalTotal = dailyRate * days;
    final deliveryFee = request['fulfilment'] == 'delivery' ? _deliveryFee : 0;
    final subtotal = rentalTotal + deliveryFee;
    final vat = (subtotal * _vatPercent / 100).round();

    emit(state.copyWith(
      isQuoting: false,
      quoteError: null,
      quote: RentalQuoteModel(
        car: car,
        rentalType: (request['rentalType'] as String?) ?? 'daily',
        breakdown: RentalBreakdown(
          days: days,
          dailyRate: dailyRate,
          rentalTotal: rentalTotal,
          deliveryFee: deliveryFee,
          extrasTotal: 0,
          subtotal: subtotal,
          promoDiscount: 0,
          vatAmount: vat,
          totalAmount: subtotal + vat,
        ),
      ),
    ));
  }

  /// Promo codes were rows in `rental_promos`, which sellers cannot write to.
  /// Every code is refused rather than silently accepted and ignored.
  Future<String?> applyPromo(String code, Map<String, dynamic> request) async {
    const message = 'Promo codes are not available on this booking.';
    emit(state.copyWith(isQuoting: false, quoteError: message));
    return message;
  }

  /// Places the booking as an order against the listing. Returns true on
  /// success — the confirmation is in [RentalBookingState.booking].
  Future<bool> confirmBooking(Map<String, dynamic> request) async {
    final car = _car;
    final quote = state.quote;
    if (car == null || quote == null) {
      emit(state.copyWith(bookingError: 'Please price the trip first.'));
      return false;
    }

    emit(state.copyWith(isSubmitting: true, bookingError: null));
    try {
      final isDelivery = request['fulfilment'] == 'delivery';
      final pickupAt = DateTime.parse(request['pickupAt'] as String);
      final returnAt = DateTime.parse(request['returnAt'] as String);
      final branch = state.branches.firstOrNull;

      final order = await _marketplace.placeOrder(
        car.id,
        addressText: isDelivery
            ? (request['deliveryAddress'] as String? ?? '')
            : (branch?.address ?? ''),
        contactPhone: _preferences.userPhone ?? '',
        // Only a branch pickup has a pin — that is the seller's own location.
        // A delivery address is typed, so it carries none.
        lat: isDelivery ? null : branch?.lat,
        lng: isDelivery ? null : branch?.lng,
        // Days, not cars: the backend charges `price × quantity`, and a
        // listing is priced per day. Sending 1 would record a three-day hire
        // at one day's rate.
        quantity: quote.breakdown.days,
        // The trip window, which is what makes this a rental rather than a
        // one-off job.
        scheduledAt: pickupAt,
        endAt: returnAt,
        // The delivery fee and VAT the quote showed, so the order and the
        // receipt agree rather than differing by both.
        feesAmount: quote.breakdown.deliveryFee.toDouble(),
        taxAmount: quote.breakdown.vatAmount.toDouble(),
        note: isDelivery ? (request['deliveryNotes'] as String?) : null,
      );

      emit(state.copyWith(
        isSubmitting: false,
        booking: RentalBookingModel(
          id: order.id,
          code: order.code,
          status: 'CONFIRMED',
          rentalType: quote.rentalType,
          car: car,
          fulfilment: isDelivery ? 'delivery' : 'pickup',
          pickupAt: pickupAt,
          returnAt: returnAt,
          breakdown: quote.breakdown,
          branchName: isDelivery ? null : branch?.name,
          deliveryAddress: isDelivery ? request['deliveryAddress'] as String? : null,
        ),
      ));
      return true;
    } catch (e) {
      emit(state.copyWith(
        isSubmitting: false,
        bookingError: friendlyErrorMessage(e),
      ));
      return false;
    }
  }

  /// Whole days between pickup and return, minimum one. Null when the window
  /// is backwards or unparseable.
  static int? _daysBetween(Map<String, dynamic> request) {
    final pickup = DateTime.tryParse(request['pickupAt'] as String? ?? '');
    final ret = DateTime.tryParse(request['returnAt'] as String? ?? '');
    if (pickup == null || ret == null) return null;
    if (!ret.isAfter(pickup)) return null;
    // A part-day still costs a day, which is how the seeded pricing worked.
    return ret.difference(pickup).inHours ~/ 24 + (ret.difference(pickup).inHours % 24 > 0 ? 1 : 0);
  }
}
