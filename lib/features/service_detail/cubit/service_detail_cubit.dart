import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/service_models.dart';
import '../../../data/repositories/services_repository.dart';

part 'service_detail_state.dart';

class ServiceDetailCubit extends Cubit<ServiceDetailState> {
  ServiceDetailCubit(this._repository) : super(const ServiceDetailState());

  final ServicesRepository _repository;

  Future<void> loadDetail(String serviceId) async {
    emit(state.copyWith(status: ServiceDetailStatus.loading));
    try {
      final detail = await _repository.getServiceDetail(serviceId);
      emit(state.copyWith(status: ServiceDetailStatus.loaded, detail: detail));
    } catch (e) {
      emit(state.copyWith(
        status: ServiceDetailStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }
}
