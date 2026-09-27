import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

// glassDecoration() et GlowBlob sont définis dans app_colors.dart : on les
// ré-exporte ici pour qu'un seul import suffise dans les sections publiques.
export '../../core/theme/app_colors.dart' show AppColors, AppText, glassDecoration, GlowBlob;

/// Bouton principal (fond or) des pages publiques.
class GoldButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final EdgeInsetsGeometry padding;

  const GoldButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.padding = const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.gold,
        foregroundColor: AppColors.bg,
        padding: padding,
        textStyle: AppText.button.copyWith(fontWeight: FontWeight.w700),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(label),
    );
  }
}

/// Bouton secondaire (contour verre) des pages publiques.
class GhostButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final EdgeInsetsGeometry padding;

  const GhostButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.padding = const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.white,
        backgroundColor: AppColors.glass,
        side: const BorderSide(color: AppColors.glassBorder),
        padding: padding,
        textStyle: AppText.button.copyWith(fontWeight: FontWeight.w700),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(label),
    );
  }
}

/// Petit libellé en capitales au-dessus d'un titre de section.
class Eyebrow extends StatelessWidget {
  final String text;
  final Color color;

  const Eyebrow(this.text, {super.key, this.color = AppColors.tealGlow});

  @override
  Widget build(BuildContext context) {
    return Text(text.toUpperCase(), style: AppText.eyebrow.copyWith(color: color, letterSpacing: 2));
  }
}

/// En-tête de section standard : eyebrow + titre + sous-titre optionnel.
class SectionHeader extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String? subtitle;
  final CrossAxisAlignment alignment;

  const SectionHeader({
    super.key,
    required this.eyebrow,
    required this.title,
    this.subtitle,
    this.alignment = CrossAxisAlignment.center,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;
    final textAlign = alignment == CrossAxisAlignment.center ? TextAlign.center : TextAlign.start;
    return Column(
      crossAxisAlignment: alignment,
      children: [
        Eyebrow(eyebrow),
        const SizedBox(height: 12),
        Text(title, textAlign: textAlign, style: AppText.h2.copyWith(fontSize: isMobile ? 24 : 32)),
        if (subtitle != null) ...[
          const SizedBox(height: 14),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: Text(subtitle!, textAlign: textAlign, style: AppText.body.copyWith(fontSize: 15)),
          ),
        ],
      ],
    );
  }
}
