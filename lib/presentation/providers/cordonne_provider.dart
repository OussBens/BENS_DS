// lib/presentation/providers/cordonne_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/cordonne_api.dart';
import '../../data/models/cordonne.dart';

final cordonneProvider = StateNotifierProvider<CordonneNotifier, CordonneState>((ref) {
  return CordonneNotifier();
});

class CordonneState {
  final Cordonne? cordonne;
  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;

  CordonneState({
    this.cordonne,
    this.isLoading = false,
    this.isSaving = false,
    this.errorMessage,
  });

  CordonneState copyWith({
    Cordonne? cordonne,
    bool? isLoading,
    bool? isSaving,
    String? errorMessage,
  }) {
    return CordonneState(
      cordonne: cordonne ?? this.cordonne,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class CordonneNotifier extends StateNotifier<CordonneState> {
  CordonneNotifier() : super(CordonneState());

  Future<void> loadCordonne() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await CordonneApi.getCordonne();

      if (response.success && response.data != null) {
        state = state.copyWith(
          cordonne: response.data,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: response.message ?? 'Erreur de chargement',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erreur: $e',
      );
    }
  }

  Future<bool> updateCordonne(Cordonne cordonne) async {
    state = state.copyWith(isSaving: true, errorMessage: null);

    try {
      final response = await CordonneApi.updateCordonne(cordonne);

      if (response.success) {
        await loadCordonne(); // Recharger après mise à jour
        return true;
      } else {
        state = state.copyWith(
          isSaving: false,
          errorMessage: response.message,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: 'Erreur: $e',
      );
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}