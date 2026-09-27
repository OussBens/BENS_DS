import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../../../core/constants/app_constants.dart';

// ==================== WIDGET D'ANIMATION DE TEXTE RÉVÉLATION ====================
class RevealText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final Duration duration;
  final double delay;
  final bool useTextColor; // 👈 NOUVEAU PARAMÈTRE

  const RevealText({
    super.key,
    required this.text,
    required this.style,
    this.duration = const Duration(milliseconds: 800),
    this.delay = 0.0,
    this.useTextColor = false, // 👈 DÉFAUT: false (dégradé)
  });

  @override
  State<RevealText> createState() => _RevealTextState();
}

class _RevealTextState extends State<RevealText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _clipAnimation;
  bool _hasAnimated = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _clipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key('reveal_${widget.text.hashCode}_${widget.delay}'),
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0.3 && !_hasAnimated && mounted) {
          setState(() {
            _hasAnimated = true;
          });
          Future.delayed(Duration(milliseconds: (widget.delay * 1000).toInt()), () {
            if (mounted) {
              _controller.forward();
            }
          });
        }
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return ClipRect(
            child: Stack(
              children: [
                // Texte original (gris)
                Text(
                  widget.text,
                  style: widget.style.copyWith(
                    color: AppConstants.accent,
                  ),
                ),
                // Effet de révélation
                Positioned.fill(
                  child: ClipRect(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      widthFactor: _clipAnimation.value,
                      child: widget.useTextColor
                          ? Text(
                        widget.text,
                        style: widget.style, // 👈 Garde la couleur originale
                      )
                          : ShaderMask(
                        shaderCallback: (bounds) {
                          return const LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              AppConstants.accentHover,
                              AppConstants.accent,
                            ],
                          ).createShader(bounds);
                        },
                        child: Text(
                          widget.text,
                          style: widget.style.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
// ==================== WIDGET D'ANIMATION DE TEXTE TYPEWRITER ====================
class TypewriterText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final Duration duration;
  final int delay;

  const TypewriterText({
    super.key,
    required this.text,
    required this.style,
    this.duration = const Duration(milliseconds: 50),
    this.delay = 0,
  });

  @override
  State<TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<TypewriterText> {
  String _displayText = '';
  bool _isComplete = false;

  @override
  void initState() {
    super.initState();
    _startTyping();
  }

  void _startTyping() async {
    await Future.delayed(Duration(milliseconds: widget.delay));
    for (int i = 0; i <= widget.text.length; i++) {
      if (mounted) {
        setState(() {
          _displayText = widget.text.substring(0, i);
        });
        await Future.delayed(widget.duration);
      }
    }
    if (mounted) {
      setState(() => _isComplete = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key('typewriter_${widget.text.hashCode}'),
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0.2 && _displayText.isEmpty) {
          _startTyping();
        }
      },
      child: Row(
        children: [
          Text(
            _displayText,
            style: widget.style,
          ),
          if (!_isComplete)
            SizedBox(
              width: 2,
              height: widget.style.fontSize ?? 24,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                color: AppConstants.accent,
              ),
            ),
        ],
      ),
    );
  }
}

// ==================== WIDGET D'ANIMATION DE TEXTE FADE ====================
// ==================== WIDGET D'ANIMATION DE TEXTE FADE ====================
// ==================== WIDGET D'ANIMATION DE TEXTE FADE ====================
class FadeText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final Duration duration;
  final double delay;
  final TextAlign textAlign;
  final Widget? child;

  const FadeText({
    super.key,
    required this.text,
    this.style,
    this.duration = const Duration(milliseconds: 600),
    this.delay = 0.0,
    this.textAlign = TextAlign.start,
    this.child,
  });

  @override
  State<FadeText> createState() => _FadeTextState();
}

class _FadeTextState extends State<FadeText> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isVisible = false;
  bool _hasAnimated = false; // 👈 AJOUTER pour éviter les répétitions

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 20), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key('fade_${widget.text.hashCode}_${widget.delay}'),
      onVisibilityChanged: (info) {
        // Déclencher l'animation uniquement si visible à plus de 30% et pas déjà animé
        if (info.visibleFraction > 0.3 && !_hasAnimated && mounted) {
          setState(() {
            _hasAnimated = true;
            _isVisible = true;
          });
          // Ajouter un délai si spécifié
          Future.delayed(Duration(milliseconds: (widget.delay * 1000).toInt()), () {
            if (mounted) {
              _controller.forward();
            }
          });
        }
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeAnimation.value,
            child: Transform.translate(
              offset: Offset(0, (1 - _fadeAnimation.value) * 20),
              child: widget.child ?? Text(
                widget.text,
                style: widget.style,
                textAlign: widget.textAlign,
              ),
            ),
          );
        },
      ),
    );
  }
}