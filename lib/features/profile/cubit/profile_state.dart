part of 'profile_cubit.dart';

enum ProfileStatus { initial, loading, loaded, error, guest }

class ProfileState extends Equatable {
  const ProfileState({
    this.status = ProfileStatus.initial,
    this.user,
    this.isSigningOut = false,
    this.isSaving = false,
    this.errorMessage,
  });

  final ProfileStatus status;
  final UserModel? user;
  final bool isSigningOut;

  /// True while a profile edit is being saved.
  final bool isSaving;
  final String? errorMessage;

  ProfileState copyWith({
    ProfileStatus? status,
    UserModel? user,
    bool? isSigningOut,
    bool? isSaving,
    String? errorMessage,
  }) {
    return ProfileState(
      status: status ?? this.status,
      user: user ?? this.user,
      isSigningOut: isSigningOut ?? this.isSigningOut,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, user, isSigningOut, isSaving, errorMessage];
}
