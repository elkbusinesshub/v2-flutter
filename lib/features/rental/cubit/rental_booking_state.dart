part of 'rental_booking_cubit.dart';

enum RentalOptionsStatus { initial, loading, loaded, error }

class RentalBookingState extends Equatable {
  const RentalBookingState({
    this.optionsStatus = RentalOptionsStatus.initial,
    this.branches = const [],
    this.extras = const [],
    this.optionsError,
    this.selectedBranchId,
    this.selectedExtraKeys = const {},
    this.isQuoting = false,
    this.quote,
    this.quoteError,
    this.appliedPromoCode,
    this.isSubmitting = false,
    this.booking,
    this.bookingError,
  });

  final RentalOptionsStatus optionsStatus;
  final List<RentalBranchModel> branches;
  final List<RentalExtraModel> extras;
  final String? optionsError;

  final String? selectedBranchId;
  final Set<String> selectedExtraKeys;

  final bool isQuoting;

  /// Latest server-side pricing for the trip.
  final RentalQuoteModel? quote;
  final String? quoteError;

  /// Promo accepted by the backend (null when none is applied).
  final String? appliedPromoCode;

  final bool isSubmitting;
  final RentalBookingModel? booking;
  final String? bookingError;

  RentalBranchModel? get selectedBranch =>
      branches.where((b) => b.id == selectedBranchId).firstOrNull;

  RentalBookingState copyWith({
    RentalOptionsStatus? optionsStatus,
    List<RentalBranchModel>? branches,
    List<RentalExtraModel>? extras,
    String? optionsError,
    String? selectedBranchId,
    Set<String>? selectedExtraKeys,
    bool? isQuoting,
    RentalQuoteModel? quote,
    String? quoteError,
    String? appliedPromoCode,
    bool? isSubmitting,
    RentalBookingModel? booking,
    String? bookingError,
  }) {
    return RentalBookingState(
      optionsStatus: optionsStatus ?? this.optionsStatus,
      branches: branches ?? this.branches,
      extras: extras ?? this.extras,
      optionsError: optionsError,
      selectedBranchId: selectedBranchId ?? this.selectedBranchId,
      selectedExtraKeys: selectedExtraKeys ?? this.selectedExtraKeys,
      isQuoting: isQuoting ?? this.isQuoting,
      quote: quote ?? this.quote,
      quoteError: quoteError,
      appliedPromoCode: appliedPromoCode ?? this.appliedPromoCode,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      booking: booking ?? this.booking,
      bookingError: bookingError,
    );
  }

  @override
  List<Object?> get props => [
        optionsStatus,
        branches,
        extras,
        optionsError,
        selectedBranchId,
        selectedExtraKeys,
        isQuoting,
        quote,
        quoteError,
        appliedPromoCode,
        isSubmitting,
        booking,
        bookingError,
      ];
}
