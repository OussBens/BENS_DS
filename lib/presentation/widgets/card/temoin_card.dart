// lib/presentation/widgets/card/temoin_card.dart
import 'package:chm_web/data/models/temoin_model.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_player/video_player.dart';

import '../../../core/theme/app_colors.dart';

class TemoinCard extends StatefulWidget {
  final Temoin temoin;
  final double width;
  final double height;

  const TemoinCard({
    super.key,
    required this.temoin,
    this.width = 340,
    this.height = 260,
  });

  @override
  State<TemoinCard> createState() => _TemoinCardState();
}

class _TemoinCardState extends State<TemoinCard> {
  bool _isHovered = false;

  void _openVideo() {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(24),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: _InlineVideoPlayer(url: widget.temoin.video!),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: Colors.white),
                style: IconButton.styleFrom(backgroundColor: Colors.black54),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStars() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < widget.temoin.note
              ? Icons.star_rounded
              : Icons.star_border_rounded,
          size: 16,
          color: const Color(0xFFFFC107),
        );
      }),
    );
  }

  Widget _buildAvatar() {
    const double size = 38;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient:
            LinearGradient(colors: [AppColors.tealDeep, AppColors.tealGlow]),
        border: Border.all(color: Colors.white.withOpacity(0.6), width: 1.5),
      ),
      alignment: Alignment.center,
      child: const Icon(Icons.person_rounded, color: Colors.white, size: 19),
    );
  }

  @override
  Widget build(BuildContext context) {
    final temoin = widget.temoin;
    final hasPhoto = temoin.hasPhoto;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        width: widget.width,
        height: widget.height,
        transform: Matrix4.identity()..translate(0.0, _isHovered ? -8.0 : 0.0),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: _isHovered
                ? AppColors.tealGlow.withOpacity(0.6)
                : Colors.white.withOpacity(0.08),
            width: 1.2,
          ),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: AppColors.tealGlow.withOpacity(0.25),
                    blurRadius: 28,
                    offset: const Offset(0, 14),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 14,
                    offset: const Offset(0, 8),
                  ),
                ],
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Photo en plein fond de la carte
            if (hasPhoto)
              _TemoinPhotoSlider(
                photos: temoin.photos,
              )
            else if (temoin.hasVideo)
              _TemoinVideoThumbnail(url: temoin.video!)
            else
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.tealDeep.withOpacity(0.5),
                      AppColors.bg.withOpacity(0.9),
                      AppColors.bg,
                    ],
                  ),
                ),
              ),
            // Dégradé pour garder le texte, les étoiles et le client lisibles sur la photo
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: hasPhoto
                      ? [
                          Colors.black.withOpacity(0.1),
                          Colors.black.withOpacity(0.05),
                          Colors.black.withOpacity(0.5),
                        ]
                      : [
                          Colors.transparent,
                          Colors.transparent,
                          Colors.black.withOpacity(0.45),
                        ],
                  stops: const [0.0, 0.35, 1.0],
                ),
              ),
            ),
            // Contenu superposé
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.format_quote_rounded,
                        color: Colors.white.withOpacity(0.9),
                        size: 26,
                      ),
                      const Spacer(),
                      if (temoin.hasVideo)
                        GestureDetector(
                          onTap: _openVideo,
                          child: Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.play_arrow_rounded,
                                color: Colors.white, size: 18),
                          ),
                        ),
                    ],
                  ),
                  const Spacer(),
                  IgnorePointer(
                    child: Text(
                      temoin.contenu,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.95),
                        fontSize: 13.5,
                        height: 1.5,
                        fontStyle: FontStyle.italic,
                        shadows: const [
                          Shadow(color: Colors.black54, blurRadius: 6)
                        ],
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildAvatar(),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              temoin.nomClient,
                              style: TextStyle(fontFamily: 'Inter', 
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (temoin.modeleVoiture != null &&
                                temoin.modeleVoiture!.isNotEmpty)
                              Text(
                                temoin.modeleVoiture!,
                                style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 11),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildStars(),
                          const SizedBox(height: 3),
                          Text(
                            temoin.formattedDate,
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.6),
                                fontSize: 10),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TemoinPhotoSlider extends StatefulWidget {
  final List<String> photos;

  const _TemoinPhotoSlider({
    required this.photos,
  });

  @override
  State<_TemoinPhotoSlider> createState() => _TemoinPhotoSliderState();
}

class _TemoinPhotoSliderState extends State<_TemoinPhotoSlider> {
  int _currentIndex = 0;

  // Changement piloté uniquement par tap (flèches / points), sans PageView :
  // ce carrousel est imbriqué dans le ListView horizontal des témoignages,
  // et deux scrollables horizontaux imbriqués se disputent le drag, ce qui
  // empêchait le swipe de changer la photo.
  void _goTo(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final photos = widget.photos;
    final hasMultiple = photos.length > 1;

    return Stack(
      fit: StackFit.expand,
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: CachedNetworkImage(
            key: ValueKey(photos[_currentIndex]),
            imageUrl: photos[_currentIndex],
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            memCacheWidth: 720,
            memCacheHeight: 480,
            placeholder: (context, url) =>
                Container(color: AppColors.bg),
            errorWidget: (context, url, error) => Container(
              color: AppColors.bg,
              child:
                  const Icon(Icons.broken_image_rounded, color: Colors.white54),
            ),
          ),
        ),
        if (hasMultiple)
          Positioned(
            top: 14,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(photos.length, (index) {
                final isActive = index == _currentIndex;
                return GestureDetector(
                  onTap: () => _goTo(index),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin:
                        const EdgeInsets.symmetric(horizontal: 3, vertical: 6),
                    width: isActive ? 16 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: isActive
                          ? Colors.white
                          : Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: const [
                        BoxShadow(color: Colors.black45, blurRadius: 3)
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        if (hasMultiple)
          Positioned.fill(
            child: Row(
              children: [
                if (_currentIndex > 0)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: _NavArrow(
                        icon: Icons.chevron_left,
                        onTap: () => _goTo(_currentIndex - 1)),
                  )
                else
                  const SizedBox(width: 36),
                const Spacer(),
                if (_currentIndex < photos.length - 1)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _NavArrow(
                        icon: Icons.chevron_right,
                        onTap: () => _goTo(_currentIndex + 1)),
                  )
                else
                  const SizedBox(width: 36),
              ],
            ),
          ),
      ],
    );
  }
}

class _NavArrow extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _NavArrow({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.72),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.5), width: 1),
          boxShadow: const [
            BoxShadow(
                color: Colors.black54, blurRadius: 8, offset: Offset(0, 2)),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }
}

// Affiche la première frame de la vidéo comme fond de carte (au lieu d'un
// simple dégradé noir) quand le témoignage n'a pas de photo, pour éviter
// que la carte paraisse vide/noire.
class _TemoinVideoThumbnail extends StatefulWidget {
  final String url;

  const _TemoinVideoThumbnail({required this.url});

  @override
  State<_TemoinVideoThumbnail> createState() => _TemoinVideoThumbnailState();
}

class _TemoinVideoThumbnailState extends State<_TemoinVideoThumbnail> {
  VideoPlayerController? _controller;
  bool _isReady = false;

  @override
  void initState() {
    super.initState();
    final controller = VideoPlayerController.networkUrl(Uri.parse(widget.url));
    _controller = controller;
    controller.initialize().then((_) {
      if (!mounted) return;
      controller
        ..setVolume(0)
        ..pause();
      setState(() => _isReady = true);
    }).catchError((_) {});
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (!_isReady || controller == null) {
      return DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.tealDeep.withOpacity(0.5),
              AppColors.bg.withOpacity(0.9),
              AppColors.bg,
            ],
          ),
        ),
      );
    }
    return FittedBox(
      fit: BoxFit.cover,
      child: SizedBox(
        width: controller.value.size.width,
        height: controller.value.size.height,
        child: VideoPlayer(controller),
      ),
    );
  }
}

class _InlineVideoPlayer extends StatefulWidget {
  final String url;

  const _InlineVideoPlayer({required this.url});

  @override
  State<_InlineVideoPlayer> createState() => _InlineVideoPlayerState();
}

class _InlineVideoPlayerState extends State<_InlineVideoPlayer> {
  VideoPlayerController? _controller;
  bool _isReady = false;

  @override
  void initState() {
    super.initState();
    final controller = VideoPlayerController.networkUrl(Uri.parse(widget.url));
    _controller = controller;
    controller.initialize().then((_) {
      if (!mounted) return;
      controller.play();
      setState(() => _isReady = true);
    }).catchError((_) {});
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isReady || _controller == null) {
      return const SizedBox(
        width: 320,
        height: 200,
        child: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }
    return AspectRatio(
      aspectRatio: _controller!.value.aspectRatio == 0
          ? 16 / 9
          : _controller!.value.aspectRatio,
      child: VideoPlayer(_controller!),
    );
  }
}
