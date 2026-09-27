import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../data/models/projet_model.dart';

class ProjetDetailDialog extends StatelessWidget {
  final Projet projet;

  const ProjetDetailDialog({super.key, required this.projet});

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final width = isMobile ? MediaQuery.of(context).size.width * 0.95 : 640.0;
    final images = [if (projet.hasImage) projet.imageUrl!, ...projet.gallery];

    return Dialog(
      backgroundColor: AppColors.bg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: AppColors.glassBorder),
      ),
      child: Container(
        width: width,
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  if (images.isNotEmpty)
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: CachedNetworkImage(imageUrl: images.first, fit: BoxFit.cover),
                      ),
                    )
                  else
                    Container(
                      height: 180,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(colors: [AppColors.tealDeep, AppColors.bg]),
                        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                      ),
                    ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: CircleAvatar(
                      backgroundColor: Colors.black.withOpacity(0.5),
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: AppColors.gold, borderRadius: BorderRadius.circular(20)),
                      child: Text(projet.category, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.bg)),
                    ),
                    const SizedBox(height: 16),
                    Text(projet.title, style: AppText.h2.copyWith(fontSize: 24)),
                    if (projet.clientName != null && projet.clientName!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text('Client : ${projet.clientName}', style: AppText.body.copyWith(fontSize: 13)),
                    ],
                    const SizedBox(height: 16),
                    Text(projet.description, style: AppText.body.copyWith(fontSize: 14.5)),
                    if (projet.technologies.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      Text('Technologies', style: AppText.h3.copyWith(fontSize: 15)),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: projet.technologies.map((t) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(color: AppColors.tealGlow.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
                            child: Text(t, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.tealGlow)),
                          );
                        }).toList(),
                      ),
                    ],
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          context.go('/contact');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.gold,
                          foregroundColor: AppColors.bg,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Un projet similaire ? Contactez-nous', style: TextStyle(fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
