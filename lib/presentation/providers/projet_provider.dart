import 'package:chm_web/data/datasources/projet_api.dart';
import 'package:chm_web/data/models/projet_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final projetProvider = StateNotifierProvider<ProjetNotifier, ProjetState>((ref) => ProjetNotifier());

class ProjetState {
  final List<Projet> projets;
  final List<Projet> filteredProjets;
  final bool isLoading;
  final String? errorMessage;
  final String selectedCategory;

  ProjetState({
    this.projets = const [],
    this.filteredProjets = const [],
    this.isLoading = false,
    this.errorMessage,
    this.selectedCategory = 'Tous',
  });

  ProjetState copyWith({
    List<Projet>? projets,
    List<Projet>? filteredProjets,
    bool? isLoading,
    String? errorMessage,
    String? selectedCategory,
  }) {
    return ProjetState(
      projets: projets ?? this.projets,
      filteredProjets: filteredProjets ?? this.filteredProjets,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      selectedCategory: selectedCategory ?? this.selectedCategory,
    );
  }
}

class ProjetNotifier extends StateNotifier<ProjetState> {
  ProjetNotifier() : super(ProjetState());

  Future<void> loadProjets({bool onlyPublished = true}) async {
    state = state.copyWith(isLoading: true);
    final response = await ProjetApi.getAllProjets(includeUnpublished: !onlyPublished);
    if (response.success && response.data != null) {
      state = state.copyWith(
        isLoading: false,
        projets: response.data!,
        filteredProjets: _applyCategory(response.data!, state.selectedCategory),
      );
    } else {
      state = state.copyWith(isLoading: false, errorMessage: response.message);
    }
  }

  Future<bool> addProjet(Projet projet) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final response = await ProjetApi.addProjet(projet);
    if (response.success) {
      await loadProjets(onlyPublished: false);
      return true;
    }
    state = state.copyWith(isLoading: false, errorMessage: response.message);
    return false;
  }

  Future<bool> updateProjet(Projet projet) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final response = await ProjetApi.updateProjet(projet);
    if (response.success) {
      await loadProjets(onlyPublished: false);
      return true;
    }
    state = state.copyWith(isLoading: false, errorMessage: response.message);
    return false;
  }

  Future<bool> deleteProjet(int id) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final response = await ProjetApi.deleteProjet(id: id);
    if (response.success) {
      await loadProjets(onlyPublished: false);
      return true;
    }
    state = state.copyWith(isLoading: false, errorMessage: response.message);
    return false;
  }

  List<Projet> _applyCategory(List<Projet> projets, String category) {
    if (category == 'Tous') return projets;
    return projets.where((p) => p.category == category).toList();
  }

  void filterByCategory(String category) {
    state = state.copyWith(
      selectedCategory: category,
      filteredProjets: _applyCategory(state.projets, category),
    );
  }
}
