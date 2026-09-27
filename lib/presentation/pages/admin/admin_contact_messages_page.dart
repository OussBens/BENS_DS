import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../data/models/contact_message_model.dart';
import '../../providers/contact_provider.dart';
import '../../widgets/card/contact_message_card_admin.dart';
import 'contact_message_detail_dialog.dart';

class AdminContactMessagesPage extends ConsumerStatefulWidget {
  const AdminContactMessagesPage({super.key});

  @override
  ConsumerState<AdminContactMessagesPage> createState() => _AdminContactMessagesPageState();
}

class _AdminContactMessagesPageState extends ConsumerState<AdminContactMessagesPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(contactProvider.notifier).loadMessages();
    });
  }

  Future<void> _delete(ContactMessage message) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmation'),
        content: Text('Supprimer le message de "${message.name}" ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
          TextButton(onPressed: () => Navigator.pop(context, true), style: TextButton.styleFrom(foregroundColor: Colors.red), child: const Text('Supprimer')),
        ],
      ),
    );
    if (confirm == true) {
      final success = await ref.read(contactProvider.notifier).deleteMessage(message.id);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Message supprimé'), backgroundColor: Colors.green));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(contactProvider);
    final isMobile = ResponsiveHelper.isMobile(context);
    final messages = [...state.messages]..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Messages de contact', style: TextStyle(fontFamily: 'Inter', fontSize: isMobile ? 22 : 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Consultez et suivez les demandes reçues via le formulaire de contact', style: TextStyle(fontSize: isMobile ? 12 : 14, color: Colors.grey.shade600)),
          const SizedBox(height: 24),
          state.isLoading
              ? const Padding(padding: EdgeInsets.symmetric(vertical: 40), child: Center(child: CircularProgressIndicator()))
              : messages.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Center(child: Text('Aucun message', style: TextStyle(color: Colors.grey.shade500))),
                    )
                  : Column(
                      children: messages
                          .map((message) => ContactMessageCardAdmin(
                                message: message,
                                onTap: () => showDialog(context: context, builder: (_) => ContactMessageDetailDialog(message: message)),
                                onDelete: () => _delete(message),
                              ))
                          .toList(),
                    ),
        ],
      ),
    );
  }
}
