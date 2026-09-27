import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/projet_model.dart';

class ProjetCard extends StatefulWidget {
  final Projet projet;
  final VoidCallback? onTap;

  const ProjetCard({super.key, required this.projet, this.onTap});

  @override
  State<ProjetCard> createState() => _ProjetCardState();
}

class _ProjetCardState extends State<ProjetCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final projet = widget.projet;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.identity()..translate(0.0, _isHovered ? -6.0 : 0.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: _isHovered ? AppColors.tealGlow.withOpacity(0.25) : Colors.black.withOpacity(0.3),
                blurRadius: _isHovered ? 26 : 12,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                AspectRatio(
                  aspectRatio: 4 / 3,
                  child: projet.hasImage
                      ? CachedNetworkImage(
                          imageUrl: projet.imageUrl!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(color: AppColors.tealDeep.withOpacity(0.3)),
                          errorWidget: (context, url, error) => Container(
                            color: AppColors.bg,
                            child: const Icon(Icons.image_outlined, color: Colors.white38, size: 40),
                          ),
                        )
                      : Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(colors: [AppColors.tealDeep, AppColors.bg]),
                          ),
                          child: const Icon(Icons.code_rounded, color: Colors.white38, size: 48),
                        ),
                ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black.withOpacity(0.75)],
                        stops: const [0.4, 1.0],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 14,
                  left: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.gold,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      projet.category,
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.bg),
                    ),
                  ),
                ),
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        projet.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontFamily: 'Inter', color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                      if (projet.technologies.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: projet.technologies.take(3).map((tech) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(tech, style: const TextStyle(fontSize: 10, color: Colors.white)),
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
