import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../data/models/projet_model.dart';

class ProjetCardAdmin extends StatelessWidget {
  final Projet projet;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ProjetCardAdmin({super.key, required this.projet, required this.onEdit, required this.onDelete});

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Confirmation'),
        content: Text('Supprimer le projet "${projet.title}" ?'),
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
    final isMobile = MediaQuery.of(context).size.width < 600;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 64,
              height: 64,
              child: projet.hasImage
                  ? CachedNetworkImage(imageUrl: projet.imageUrl!, fit: BoxFit.cover)
                  : Container(color: Colors.grey.shade200, child: const Icon(Icons.image_outlined, color: Colors.grey)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(projet.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: projet.isPublished ? Colors.green.shade50 : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        projet.isPublished ? 'Publié' : 'Masqué',
                        style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: projet.isPublished ? Colors.green.shade700 : Colors.grey.shade600),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(projet.category, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                const SizedBox(height: 4),
                Text(projet.description, style: TextStyle(fontSize: 12, color: Colors.grey.shade500), maxLines: 2, overflow: TextOverflow.ellipsis),
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
