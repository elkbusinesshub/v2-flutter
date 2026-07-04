part of 'profile_cubit.dart';

enum ProfileStatus { initial, loading, loaded, error }

class ProfileState extends Equatable {
  const ProfileState({
    this.status = ProfileStatus.initial,
    this.user,
    this.isSigningOut = false,
    this.errorMessage,
  });

  final ProfileStatus status;
  final UserModel? user;
  final bool isSigningOut;
  final String? errorMessage;

  ProfileState copyWith({
    ProfileStatus? status,
    UserModel? user,
    bool? isSigningOut,
    String? errorMessage,
  }) {
    return ProfileState(
      status: status ?? this.status,
      user: user ?? this.user,
      isSigningOut: isSigningOut ?? this.isSigningOut,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, user, isSigningOut, errorMessage];
}
