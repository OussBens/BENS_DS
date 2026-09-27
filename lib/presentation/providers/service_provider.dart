import 'package:chm_web/data/datasources/service_api.dart';
import 'package:chm_web/data/models/service_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final serviceProvider = StateNotifierProvider<ServiceNotifier, ServiceState>((ref) => ServiceNotifier());

class ServiceState {
  final List<Service> services;
  final bool isLoading;
  final String? errorMessage;

  ServiceState({this.services = const [], this.isLoading = false, this.errorMessage});

  ServiceState copyWith({List<Service>? services, bool? isLoading, String? errorMessage}) {
    return ServiceState(
      services: services ?? this.services,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class ServiceNotifier extends StateNotifier<ServiceState> {
  ServiceNotifier() : super(ServiceState());

  Future<void> loadServices({bool onlyPublished = true}) async {
    state = state.copyWith(isLoading: true);
    final response = await ServiceApi.getAllServices(includeUnpublished: !onlyPublished);
    if (response.success && response.data != null) {
      state = state.copyWith(isLoading: false, services: response.data!);
    } else {
      state = state.copyWith(isLoading: false, errorMessage: response.message);
    }
  }

  Future<bool> addService(Service service) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final response = await ServiceApi.addService(service);
    if (response.success) {
      await loadServices(onlyPublished: false);
      return true;
    }
    state = state.copyWith(isLoading: false, errorMessage: response.message);
    return false;
  }

  Future<bool> updateService(Service service) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final response = await ServiceApi.updateService(service);
    if (response.success) {
      await loadServices(onlyPublished: false);
      return true;
    }
    state = state.copyWith(isLoading: false, errorMessage: response.message);
    return false;
  }

  Future<bool> deleteService(int id) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final response = await ServiceApi.deleteService(id: id);
    if (response.success) {
      await loadServices(onlyPublished: false);
      return true;
    }
    state = state.copyWith(isLoading: false, errorMessage: response.message);
    return false;
  }
}
