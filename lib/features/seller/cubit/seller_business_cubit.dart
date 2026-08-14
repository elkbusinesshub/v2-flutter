import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/api_exception.dart';
import '../../../data/models/provider_models.dart';
import '../../../data/repositories/provider_repository.dart';

part 'seller_business_state.dart';

/// The seller's business side: whether they are accepting work, what they have
/// earned, and which days they work.
///
/// These lived on four screens under `/provider/*`, a second surface for the
/// same person — the owner's flow is that a seller *is* the service provider.
/// Merged here, they also stop the seller panel lying: its online toggle was
/// local state that never reached the backend, and its balance was hardcoded.
///
/// Job requests deliberately did not come across. `provider_requests` is a
/// stub whose customer and service are display strings not linked to any real
/// booking; a seller's actual work now arrives as ad orders, which the Orders
/// tab already shows.
class SellerBusinessCubit extends Cubit<SellerBusinessState> {
  SellerBusinessCubit(this._provider) : super(const SellerBusinessState());

  final ProviderRepository _provider;

  /// Loads everything the panel shows about the business.
  ///
  /// A seller who has never registered has no provider profile, so the
  /// backend 404s. That is not an error worth showing — it means "not set up
  /// yet", and the panel still works for listings and orders.
  Future<void> load() async {
    emit(state.copyWith(status: SellerBusinessStatus.loading));
    try {
      final dashboard = await _provider.getDashboard();
      final earnings = await _provider.getEarnings();
      emit(state.copyWith(
        status: SellerBusinessStatus.ready,
        businessName: dashboard.businessName,
        isAvailable: dashboard.isAvailable,
        earnings: earnings,
      ));
    } on ApiException catch (e) {
      if (e.statusCode == 404) {
        emit(state.copyWith(status: SellerBusinessStatus.notRegistered));
        return;
      }
      emit(state.copyWith(
        status: SellerBusinessStatus.error,
        errorMessage: friendlyErrorMessage(e),
      ));
    } catch (e) {
      emit(state.copyWith(
        status: SellerBusinessStatus.error,
        errorMessage: friendlyErrorMessage(e),
      ));
    }
  }

  /// Flips the online switch, optimistically.
  ///
  /// The toggle used to be local state, so a seller could believe they were
  /// offline while the backend kept them listed. It reverts on failure rather
  /// than leaving the switch showing something the server never accepted.
  Future<void> setAvailable(bool value) async {
    final previous = state.isAvailable;
    emit(state.copyWith(isAvailable: value, errorMessage: null));
    try {
      final applied = await _provider.setAvailability(value);
      if (applied != value) emit(state.copyWith(isAvailable: applied));
    } catch (e) {
      emit(state.copyWith(
        isAvailable: previous,
        errorMessage: friendlyErrorMessage(e),
      ));
    }
  }

  /// The working-week view, loaded when the sheet opens rather than up front.
  Future<void> loadSchedule() async {
    emit(state.copyWith(isLoadingSchedule: true));
    try {
      emit(state.copyWith(
        isLoadingSchedule: false,
        schedule: await _provider.getSchedule(),
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoadingSchedule: false,
        errorMessage: friendlyErrorMessage(e),
      ));
    }
  }
}
