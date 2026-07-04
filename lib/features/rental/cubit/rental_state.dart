part of 'rental_cubit.dart';

enum RentalStatus { initial, loading, loaded, error }

class RentalState extends Equatable {
  const RentalState({
    this.status = RentalStatus.initial,
    this.cars = const [],
    this.period = RentalPeriod.daily,
    this.typeFilter = 'All',
    this.errorMessage,
  });

  final RentalStatus status;
  final List<RentalCarModel> cars;
  final RentalPeriod period;
  final String typeFilter;
  final String? errorMessage;

  RentalState copyWith({
    RentalStatus? status,
    List<RentalCarModel>? cars,
    RentalPeriod? period,
    String? typeFilter,
    String? errorMessage,
  }) {
    return RentalState(
      status: status ?? this.status,
      cars: cars ?? this.cars,
      period: period ?? this.period,
      typeFilter: typeFilter ?? this.typeFilter,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, cars, period, typeFilter, errorMessage];
}
