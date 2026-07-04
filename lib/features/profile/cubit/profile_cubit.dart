import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/app_preferences.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/profile_repository.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit(this._repository, this._preferences) : super(const ProfileState());

  final ProfileRepository _repository;
  final AppPreferences _preferences;

  Future<void> loadProfile() async {
    emit(state.copyWith(status: ProfileStatus.loading));
    try {
      final user = await _repository.getProfile();
      emit(state.copyWith(status: ProfileStatus.loaded, user: user));
    } catch (e) {
      emit(state.copyWith(status: ProfileStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> signOut() async {
    emit(state.copyWith(isSigningOut: true));
    try {
      await _repository.signOut();
      await _preferences.setAuthenticated(false);
    } finally {
      emit(state.copyWith(isSigningOut: false));
    }
  }
}
