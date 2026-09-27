import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:visibility_detector/visibility_detector.dart';

/// Vocabulaire d'animation partagé pour les entrées au scroll de la home page.
const kStaggerStepMs = 80;
const kRevealDuration = Duration(milliseconds: 450);
const kRevealCurve = Curves.easeOutCubic;

/// Fait apparaître [child] (fondu + glissement + léger zoom) la première fois
/// qu'il devient visible à l'écran, une seule fois.
class ScrollReveal extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  final double slideY;
  final double beginScale;
  final double visibleThreshold;
  final Curve curve;
  final VoidCallback? onBecomeVisible;

  const ScrollReveal({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = kRevealDuration,
    this.slideY = 30,
    this.beginScale = 0.92,
    this.visibleThreshold = 0.1,
    this.curve = kRevealCurve,
    this.onBecomeVisible,
  });

  @override
  State<ScrollReveal> createState() => _ScrollRevealState();
}

class _ScrollRevealState extends State<ScrollReveal> {
  bool _visible = false;

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: ValueKey(this),
      onVisibilityChanged: (info) {
        if (info.visibleFraction > widget.visibleThreshold && !_visible && mounted) {
          setState(() => _visible = true);
          widget.onBecomeVisible?.call();
        }
      },
      child: widget.child
          .animate(target: _visible ? 1 : 0)
          .fadeIn(duration: widget.duration, delay: widget.delay, curve: widget.curve)
          .slideY(
            begin: widget.slideY / 100,
            end: 0,
            duration: widget.duration,
            delay: widget.delay,
            curve: widget.curve,
          )
          .scaleXY(
            begin: widget.beginScale,
            end: 1.0,
            duration: widget.duration,
            delay: widget.delay,
            curve: widget.curve,
          ),
    );
  }
}
