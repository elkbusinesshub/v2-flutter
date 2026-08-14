part of 'language_cubit.dart';

enum LanguageStatus { initial, loading, loaded, error }

class LanguageState extends Equatable {
  const LanguageState({
    this.status = LanguageStatus.initial,
    this.languages = const [],
    this.selectedCode = 'en',
    this.isSaving = false,
    this.errorMessage,
  });

  final LanguageStatus status;
  final List<LanguageModel> languages;
  final String selectedCode;

  /// True while the selection is being persisted on the backend.
  final bool isSaving;
  final String? errorMessage;

  LanguageState copyWith({
    LanguageStatus? status,
    List<LanguageModel>? languages,
    String? selectedCode,
    bool? isSaving,
    String? errorMessage,
  }) {
    return LanguageState(
      status: status ?? this.status,
      languages: languages ?? this.languages,
      selectedCode: selectedCode ?? this.selectedCode,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props =>
      [status, languages, selectedCode, isSaving, errorMessage];
}
