import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/icon_mapper.dart';
import '../../../data/models/service_model.dart';

class ServiceCard extends StatefulWidget {
  final Service service;
  final VoidCallback? onTap;

  const ServiceCard({super.key, required this.service, this.onTap});

  @override
  State<ServiceCard> createState() => _ServiceCardState();
}

class _ServiceCardState extends State<ServiceCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final service = widget.service;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.identity()..translate(0.0, _isHovered ? -6.0 : 0.0),
          padding: const EdgeInsets.all(24),
          decoration: glassDecoration(radius: 20, borderColor: _isHovered ? AppColors.tealGlow : AppColors.glassBorder),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [AppColors.tealGlow, AppColors.tealDeep]),
                  shape: BoxShape.circle,
                ),
                child: Icon(IconMapper.resolve(service.icon), color: AppColors.white, size: 26),
              ),
              const SizedBox(height: 20),
              Text(
                service.title,
                style: AppText.h3.copyWith(fontSize: 18),
              ),
              const SizedBox(height: 10),
              Text(
                service.description,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: AppText.body.copyWith(fontSize: 13.5),
              ),
              if (service.technologies.isNotEmpty) ...[
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: service.technologies.take(4).map((tech) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.tealGlow.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(tech, style: const TextStyle(fontSize: 11, color: AppColors.tealGlow, fontWeight: FontWeight.w600)),
                    );
                  }).toList(),
                ),
              ],
              if (service.priceFrom != null) ...[
                const SizedBox(height: 16),
                Text(
                  'À partir de ${service.priceFrom!.toStringAsFixed(0)} DA',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.gold),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
