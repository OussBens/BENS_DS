import 'package:bens_ds/data/datasources/temoin_api.dart';
import 'package:bens_ds/data/models/temoin_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final temoinProvider = StateNotifierProvider<TemoinNotifier, TemoinState>((ref) => TemoinNotifier());

class TemoinState {
  final List<Temoin> temoins;
  final List<Temoin> filteredTemoins;
  final bool isLoading;
  final String? errorMessage;
  final Temoin? selectedTemoin;

  TemoinState({
    this.temoins = const [],
    this.filteredTemoins = const [],
    this.isLoading = false,
    this.errorMessage,
    this.selectedTemoin,
  });

  TemoinState copyWith({
    List<Temoin>? temoins,
    List<Temoin>? filteredTemoins,
    bool? isLoading,
    String? errorMessage,
    Temoin? selectedTemoin,
  }) {
    return TemoinState(
      temoins: temoins ?? this.temoins,
      filteredTemoins: filteredTemoins ?? this.filteredTemoins,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      selectedTemoin: selectedTemoin ?? this.selectedTemoin,
    );
  }
}

class TemoinNotifier extends StateNotifier<TemoinState> {
  TemoinNotifier() : super(TemoinState());

  Future<void> loadAllTemoins() async {
    state = state.copyWith(isLoading: true);
    final response = await TemoinApi.getAllTemoins();
    if (response.success && response.data != null) {
      state = state.copyWith(
        isLoading: false,
        temoins: response.data!,
        filteredTemoins: response.data!,
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: response.message,
      );
    }
  }

  Future<Temoin?> loadTemoinById(int id) async {
    state = state.copyWith(isLoading: true);
    try {
      final response = await TemoinApi.getTemoinById(id: id);
      if (response.success && response.data != null) {
        state = state.copyWith(
          selectedTemoin: response.data,
          isLoading: false,
        );
        return response.data;
      }
      state = state.copyWith(isLoading: false);
      return null;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return null;
    }
  }

  Future<bool> addTemoin(Temoin temoin) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final response = await TemoinApi.addTemoin(temoin);
    if (response.success) {
      await loadAllTemoins();
      return true;
    } else {
      state = state.copyWith(isLoading: false, errorMessage: response.message);
      return false;
    }
  }

  Future<bool> updateTemoin(Temoin temoin) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final response = await TemoinApi.updateTemoin(temoin);
    if (response.success) {
      await loadAllTemoins();
      state = state.copyWith(isLoading: false);
      return true;
    } else {
      state = state.copyWith(isLoading: false, errorMessage: response.message);
      return false;
    }
  }

  Future<bool> deleteTemoin(int id) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final response = await TemoinApi.deleteTemoin(id: id);
    if (response.success) {
      await loadAllTemoins();
      return true;
    } else {
      state = state.copyWith(isLoading: false, errorMessage: response.message);
      return false;
    }
  }

  void searchTemoins(String query) {
    if (query.isEmpty) {
      state = state.copyWith(filteredTemoins: state.temoins);
    } else {
      final filtered = state.temoins.where((temoin) {
        return temoin.nomClient.toLowerCase().contains(query.toLowerCase()) ||
            (temoin.modeleVoiture ?? '').toLowerCase().contains(query.toLowerCase()) ||
            (temoin.titre ?? '').toLowerCase().contains(query.toLowerCase());
      }).toList();
      state = state.copyWith(filteredTemoins: filtered);
    }
  }

  void resetFilters() {
    state = state.copyWith(filteredTemoins: state.temoins);
  }
}
