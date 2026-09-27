// lib/presentation/widgets/card/temoin_card_admin.dart
import 'package:bens_ds/data/models/temoin_model.dart';
import 'package:bens_ds/presentation/pages/admin/temoin_detail.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class TemoinCardAdmin extends StatelessWidget {
  final Temoin temoin;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onRefresh;

  const TemoinCardAdmin({
    super.key,
    required this.temoin,
    required this.onEdit,
    required this.onDelete,
    required this.onRefresh,
  });

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Confirmation'),
          content: Text(
            'Voulez-vous vraiment supprimer le témoignage de "${temoin.nomClient}" ?',
            style: const TextStyle(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                onDelete();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );
  }

  void _showTemoinDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => TemoinDetailDialog(temoin: temoin),
    );
  }

  Widget _buildStars(double size) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < temoin.note ? Icons.star_rounded : Icons.star_border_rounded,
          size: size,
          color: const Color(0xFFFFC107),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final isTablet = MediaQuery.of(context).size.width >= 600 && MediaQuery.of(context).size.width < 1200;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => _showTemoinDetails(context),
                child: Container(
                  width: isMobile ? 56 : 64,
                  height: isMobile ? 56 : 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade200, width: 2),
                  ),
                  child: ClipOval(
                    child: temoin.hasPhoto
                        ? CachedNetworkImage(
                            imageUrl: temoin.displayPhoto,
                            fit: BoxFit.cover,
                            width: isMobile ? 56 : 64,
                            height: isMobile ? 56 : 64,
                            placeholder: (context, url) => Container(
                              color: Colors.grey.shade200,
                              child: const Center(
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: Colors.grey.shade200,
                              child: Icon(Icons.person, size: isMobile ? 24 : 30, color: Colors.grey),
                            ),
                          )
                        : Container(
                            color: Colors.grey.shade200,
                            child: Icon(Icons.person, size: isMobile ? 24 : 30, color: Colors.grey),
                          ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () => _showTemoinDetails(context),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              temoin.nomClient,
                              style: TextStyle(
                                fontSize: isMobile ? 14 : 16,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (temoin.hasVideo)
                            const Padding(
                              padding: EdgeInsets.only(left: 4),
                              child: Icon(Icons.videocam, size: 16, color: Colors.blueGrey),
                            ),
                          Container(
                            margin: const EdgeInsets.only(left: 6),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: temoin.isActive ? Colors.green.shade50 : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              temoin.isActive ? 'Publié' : 'Masqué',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                color: temoin.isActive ? Colors.green.shade700 : Colors.grey.shade600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      _buildStars(isMobile ? 13 : 15),
                      const SizedBox(height: 4),
                      if (temoin.modeleVoiture != null && temoin.modeleVoiture!.isNotEmpty)
                        Text(
                          temoin.modeleVoiture!,
                          style: TextStyle(fontSize: isMobile ? 11 : 12, color: Colors.grey.shade600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      const SizedBox(height: 4),
                      Text(
                        temoin.contenu,
                        style: TextStyle(fontSize: isMobile ? 11 : 12, color: Colors.grey.shade500),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (isMobile || isTablet) _buildMobileButtons(context) else _buildDesktopButtons(context),
        ],
      ),
    );
  }

  Widget _buildMobileButtons(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            icon: Icons.visibility,
            label: isMobile ? '' : 'Détails',
            color: Colors.grey.shade700,
            backgroundColor: Colors.grey.shade100,
            onPressed: () => _showTemoinDetails(context),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildActionButton(
            icon: Icons.edit,
            label: isMobile ? '' : 'Modifier',
            color: Colors.blue.shade700,
            backgroundColor: Colors.blue.shade50,
            onPressed: onEdit,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildActionButton(
            icon: Icons.delete,
            label: isMobile ? '' : 'Supprimer',
            color: Colors.red.shade700,
            backgroundColor: Colors.red.shade50,
            onPressed: () => _showDeleteConfirmationDialog(context),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        OutlinedButton.icon(
          onPressed: () => _showTemoinDetails(context),
          icon: const Icon(Icons.visibility, size: 16),
          label: const Text('Détails', style: TextStyle(fontSize: 12)),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            side: BorderSide(color: Colors.grey.shade400),
          ),
        ),
        const SizedBox(width: 8),
        OutlinedButton.icon(
          onPressed: onEdit,
          icon: const Icon(Icons.edit, size: 16),
          label: const Text('Modifier', style: TextStyle(fontSize: 12)),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            side: BorderSide(color: Colors.blue.shade400),
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton.icon(
          onPressed: () => _showDeleteConfirmationDialog(context),
          icon: const Icon(Icons.delete, size: 16),
          label: const Text('Supprimer', style: TextStyle(fontSize: 12)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required Color backgroundColor,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: color),
              if (label.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w500),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
