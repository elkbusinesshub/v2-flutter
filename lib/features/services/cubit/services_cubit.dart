import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/service_models.dart';
import '../../../data/repositories/services_repository.dart';

part 'services_state.dart';

class ServicesCubit extends Cubit<ServicesState> {
  ServicesCubit(this._repository) : super(const ServicesState());

  final ServicesRepository _repository;

  Future<void> loadServices() async {
    emit(state.copyWith(status: ServicesStatus.loading));
    try {
      final groups = await _repository.getServiceGroups();
      emit(state.copyWith(status: ServicesStatus.loaded, groups: groups));
    } catch (e) {
      emit(state.copyWith(
        status: ServicesStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }
}
