import 'package:flutter/material.dart';
import '../../../core/utils/icon_mapper.dart';
import '../../../data/models/service_model.dart';

class ServiceCardAdmin extends StatelessWidget {
  final Service service;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ServiceCardAdmin({super.key, required this.service, required this.onEdit, required this.onDelete});

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Confirmation'),
        content: Text('Supprimer le service "${service.title}" ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onDelete();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
            child: Icon(IconMapper.resolve(service.icon), color: Colors.grey.shade700),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(service.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: service.isPublished ? Colors.green.shade50 : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        service.isPublished ? 'Publié' : 'Masqué',
                        style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: service.isPublished ? Colors.green.shade700 : Colors.grey.shade600),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(service.description, style: TextStyle(fontSize: 12, color: Colors.grey.shade500), maxLines: 2, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            children: [
              IconButton(icon: const Icon(Icons.edit, size: 20, color: Colors.blue), onPressed: onEdit),
              IconButton(icon: const Icon(Icons.delete, size: 20, color: Colors.red), onPressed: () => _confirmDelete(context)),
            ],
          ),
        ],
      ),
    );
  }
}
