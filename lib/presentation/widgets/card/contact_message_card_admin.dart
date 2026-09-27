import 'package:flutter/material.dart';
import '../../../data/models/contact_message_model.dart';

class ContactMessageCardAdmin extends StatelessWidget {
  final ContactMessage message;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const ContactMessageCardAdmin({super.key, required this.message, required this.onTap, required this.onDelete});

  Color get _statusColor {
    switch (message.status) {
      case ContactMessageStatus.nouveau:
        return Colors.blue;
      case ContactMessageStatus.lu:
        return Colors.orange;
      case ContactMessageStatus.repondu:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        onTap: onTap,
        leading: CircleAvatar(backgroundColor: _statusColor.withOpacity(0.12), child: Icon(Icons.mail_outline, color: _statusColor, size: 20)),
        title: Row(
          children: [
            Expanded(child: Text(message.subject, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: _statusColor.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
              child: Text(message.status.displayName, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: _statusColor)),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text('${message.name} · ${message.email}', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        ),
        trailing: IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red), onPressed: onDelete),
      ),
    );
  }
}
