import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../data/models/contact_message_model.dart';
import '../../providers/contact_provider.dart';

class ContactMessageDetailDialog extends ConsumerStatefulWidget {
  final ContactMessage message;

  const ContactMessageDetailDialog({super.key, required this.message});

  @override
  ConsumerState<ContactMessageDetailDialog> createState() => _ContactMessageDetailDialogState();
}

class _ContactMessageDetailDialogState extends ConsumerState<ContactMessageDetailDialog> {
  late TextEditingController _noteController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController(text: widget.message.adminNote ?? '');
    if (widget.message.status == ContactMessageStatus.nouveau) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(contactProvider.notifier).updateMessage(id: widget.message.id, status: ContactMessageStatus.lu);
      });
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _markResponded() async {
    setState(() => _isSaving = true);
    await ref.read(contactProvider.notifier).updateMessage(
          id: widget.message.id,
          status: ContactMessageStatus.repondu,
          adminNote: _noteController.text.trim().isNotEmpty ? _noteController.text.trim() : null,
        );
    if (mounted) {
      setState(() => _isSaving = false);
      Navigator.pop(context);
    }
  }

  Future<void> _saveNote() async {
    setState(() => _isSaving = true);
    await ref.read(contactProvider.notifier).updateMessage(id: widget.message.id, adminNote: _noteController.text.trim());
    if (mounted) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Note enregistrée'), backgroundColor: Colors.green));
    }
  }

  @override
  Widget build(BuildContext context) {
    final message = widget.message;
    final isMobile = ResponsiveHelper.isMobile(context);
    final width = isMobile ? MediaQuery.of(context).size.width * 0.95 : 520.0;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        width: width,
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text(message.subject, style: const TextStyle(fontFamily: 'Inter', fontSize: 20, fontWeight: FontWeight.bold))),
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                ],
              ),
              const SizedBox(height: 8),
              Text('${message.name} · ${message.email}${message.phone != null ? ' · ${message.phone}' : ''}', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12)),
                child: Text(message.message, style: const TextStyle(height: 1.6)),
              ),
              const SizedBox(height: 20),
              const Text('Note interne', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextField(
                controller: _noteController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Ajouter une note (visible uniquement en interne)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isSaving ? null : _saveNote,
                      child: const Text('Enregistrer la note'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSaving || message.status == ContactMessageStatus.repondu ? null : _markResponded,
                      style: ElevatedButton.styleFrom(backgroundColor: AppConstants.yellow, foregroundColor: AppConstants.primaryDark),
                      child: Text(message.status == ContactMessageStatus.repondu ? 'Déjà répondu' : 'Marquer répondu'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
