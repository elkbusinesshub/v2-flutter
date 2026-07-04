part of 'language_cubit.dart';

enum LanguageStatus { initial, loading, loaded, error }

class LanguageState extends Equatable {
  const LanguageState({
    this.status = LanguageStatus.initial,
    this.languages = const [],
    this.selectedCode = 'en',
    this.errorMessage,
  });

  final LanguageStatus status;
  final List<LanguageModel> languages;
  final String selectedCode;
  final String? errorMessage;

  LanguageState copyWith({
    LanguageStatus? status,
    List<LanguageModel>? languages,
    String? selectedCode,
    String? errorMessage,
  }) {
    return LanguageState(
      status: status ?? this.status,
      languages: languages ?? this.languages,
      selectedCode: selectedCode ?? this.selectedCode,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, languages, selectedCode, errorMessage];
}
