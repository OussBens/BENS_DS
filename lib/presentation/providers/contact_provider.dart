import 'package:chm_web/data/datasources/contact_api.dart';
import 'package:chm_web/data/models/contact_message_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final contactProvider = StateNotifierProvider<ContactNotifier, ContactState>((ref) => ContactNotifier());

class ContactState {
  final List<ContactMessage> messages;
  final bool isLoading;
  final bool isSubmitting;
  final String? errorMessage;

  ContactState({
    this.messages = const [],
    this.isLoading = false,
    this.isSubmitting = false,
    this.errorMessage,
  });

  ContactState copyWith({
    List<ContactMessage>? messages,
    bool? isLoading,
    bool? isSubmitting,
    String? errorMessage,
  }) {
    return ContactState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class ContactNotifier extends StateNotifier<ContactState> {
  ContactNotifier() : super(ContactState());

  Future<bool> submitMessage(ContactMessage message) async {
    state = state.copyWith(isSubmitting: true, errorMessage: null);
    final response = await ContactApi.submitMessage(message);
    state = state.copyWith(isSubmitting: false, errorMessage: response.success ? null : response.message);
    return response.success;
  }

  Future<void> loadMessages() async {
    state = state.copyWith(isLoading: true);
    final response = await ContactApi.getAllMessages();
    if (response.success && response.data != null) {
      state = state.copyWith(isLoading: false, messages: response.data!);
    } else {
      state = state.copyWith(isLoading: false, errorMessage: response.message);
    }
  }

  Future<bool> updateMessage({required int id, ContactMessageStatus? status, String? adminNote}) async {
    final response = await ContactApi.updateMessage(id: id, status: status, adminNote: adminNote);
    if (response.success) {
      await loadMessages();
      return true;
    }
    state = state.copyWith(errorMessage: response.message);
    return false;
  }

  Future<bool> deleteMessage(int id) async {
    final response = await ContactApi.deleteMessage(id: id);
    if (response.success) {
      await loadMessages();
      return true;
    }
    state = state.copyWith(errorMessage: response.message);
    return false;
  }
}
