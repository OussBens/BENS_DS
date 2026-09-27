import 'package:chm_web/data/models/temoin_model.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_player/video_player.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/responsive_helper.dart';

class TemoinDetailDialog extends StatefulWidget {
  final Temoin temoin;

  const TemoinDetailDialog({super.key, required this.temoin});

  @override
  State<TemoinDetailDialog> createState() => _TemoinDetailDialogState();
}

class _TemoinDetailDialogState extends State<TemoinDetailDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  bool _isHoveringClose = false;
  bool _isPressingClose = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(parent: _animationController, curve: Curves.elasticOut);
    _fadeAnimation = CurvedAnimation(parent: _animationController, curve: Curves.easeIn);
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} à ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final isTablet = ResponsiveHelper.isTablette(context);
    final screenWidth = ResponsiveHelper.getWidth(context);
    final screenHeight = ResponsiveHelper.getHeight(context);
    final temoin = widget.temoin;

    double dialogWidth;
    double titleFontSize;

    if (isMobile) {
      dialogWidth = screenWidth * 0.92;
      titleFontSize = 20;
    } else if (isTablet) {
      dialogWidth = screenWidth * 0.55;
      titleFontSize = 22;
    } else {
      dialogWidth = screenWidth * 0.42;
      titleFontSize = 24;
    }

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Container(
            width: dialogWidth,
            constraints: BoxConstraints(
              maxHeight: screenHeight * 0.88,
              minWidth: isMobile ? double.infinity : 450,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      SizedBox(
                        height: isMobile ? 220 : 260,
                        width: double.infinity,
                        child: temoin.hasPhoto
                            ? CachedNetworkImage(
                                imageUrl: temoin.photos.first,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                                placeholder: (context, url) => Container(
                                  color: Colors.grey.shade200,
                                  child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                                ),
                                errorWidget: (context, url, error) => _placeholderHeader(),
                              )
                            : _placeholderHeader(),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 110,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.transparent, Colors.black.withOpacity(0.75)],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 20,
                        left: 20,
                        right: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildStars(temoin.note, size: 18),
                            const SizedBox(height: 6),
                            Text(
                              temoin.nomClient,
                              style: TextStyle(fontFamily: 'Inter', 
                                fontSize: titleFontSize,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                shadows: [Shadow(color: Colors.black.withOpacity(0.5), blurRadius: 10)],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (temoin.titre != null && temoin.titre!.isNotEmpty)
                              Text(
                                temoin.titre!,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: 16,
                        right: 16,
                        child: IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close, color: Colors.white),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.black.withOpacity(0.5),
                            padding: const EdgeInsets.all(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildContenuCard(),
                          const SizedBox(height: 20),
                          _buildInfoCard(),
                          if (temoin.photos.length > 1) ...[
                            const SizedBox(height: 20),
                            _buildPhotosGallery(),
                          ],
                          if (temoin.hasVideo) ...[
                            const SizedBox(height: 20),
                            _buildVideoSection(),
                          ],
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                    child: SizedBox(
                      width: double.infinity,
                      child: Listener(
                        onPointerDown: (_) => setState(() => _isPressingClose = true),
                        onPointerUp: (_) => setState(() => _isPressingClose = false),
                        onPointerCancel: (_) => setState(() => _isPressingClose = false),
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          onEnter: (_) => setState(() => _isHoveringClose = true),
                          onExit: (_) => setState(() {
                            _isHoveringClose = false;
                            _isPressingClose = false;
                          }),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            child: ElevatedButton(
                              onPressed: () => Navigator.pop(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: (_isHoveringClose || _isPressingClose)
                                    ? AppConstants.accent
                                    : Colors.black,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                elevation: (_isHoveringClose || _isPressingClose) ? 4 : 2,
                              ),
                              child: const Text('Fermer', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _placeholderHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.grey.shade800, Colors.grey.shade900],
        ),
      ),
      child: const Center(
        child: Icon(Icons.format_quote_rounded, size: 70, color: Colors.white24),
      ),
    );
  }

  Widget _buildStars(int note, {double size = 16}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < note ? Icons.star_rounded : Icons.star_border_rounded,
          size: size,
          color: const Color(0xFFFFC107),
        );
      }),
    );
  }

  Widget _buildContenuCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.format_quote_rounded, color: AppConstants.accent.withOpacity(0.4), size: 28),
            const SizedBox(height: 8),
            Text(
              widget.temoin.contenu,
              style: TextStyle(
                fontSize: 14,
                height: 1.6,
                color: Colors.grey.shade800,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    final temoin = widget.temoin;
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (temoin.modeleVoiture != null && temoin.modeleVoiture!.isNotEmpty)
              _buildInfoRow(
                icon: Icons.work_outline,
                label: 'Projet lié',
                value: temoin.modeleVoiture!,
                color: Colors.blue,
              ),
            if (temoin.modeleVoiture != null && temoin.modeleVoiture!.isNotEmpty) const SizedBox(height: 12),
            _buildInfoRow(
              icon: Icons.calendar_today_outlined,
              label: 'Date',
              value: temoin.formattedDate,
              color: Colors.green,
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              icon: Icons.person_outline,
              label: 'Créé par',
              value: temoin.creePar,
              color: Colors.purple,
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              icon: Icons.event_outlined,
              label: 'Ajouté le',
              value: _formatDate(temoin.creeLe),
              color: Colors.teal,
            ),
            if (temoin.modifiePar != null) ...[
              const SizedBox(height: 12),
              _buildInfoRow(
                icon: Icons.edit_outlined,
                label: 'Modifié par',
                value: temoin.modifiePar!,
                color: Colors.orange,
              ),
            ],
            if (temoin.modifieLe != null) ...[
              const SizedBox(height: 12),
              _buildInfoRow(
                icon: Icons.update_outlined,
                label: 'Date modification',
                value: _formatDate(temoin.modifieLe!),
                color: Colors.orange,
              ),
            ],
            const SizedBox(height: 12),
            _buildInfoRow(
              icon: Icons.visibility_outlined,
              label: 'Statut',
              value: temoin.isActive ? 'Publié' : 'Masqué',
              color: temoin.isActive ? Colors.green : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotosGallery() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Photos (${widget.temoin.photos.length})',
          style: TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 80,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: widget.temoin.photos.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: widget.temoin.photos[index],
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(color: Colors.grey.shade200),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.broken_image_outlined, color: Colors.grey),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildVideoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Vidéo',
          style: TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: _TemoinVideoPreview(url: widget.temoin.video!),
        ),
      ],
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? color,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: (color ?? Colors.grey).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 20, color: color ?? Colors.grey.shade700),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 110,
          child: Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: color ?? Colors.black87),
          ),
        ),
      ],
    );
  }
}

class _TemoinVideoPreview extends StatefulWidget {
  final String url;

  const _TemoinVideoPreview({required this.url});

  @override
  State<_TemoinVideoPreview> createState() => _TemoinVideoPreviewState();
}

class _TemoinVideoPreviewState extends State<_TemoinVideoPreview> {
  VideoPlayerController? _controller;
  bool _isReady = false;

  @override
  void initState() {
    super.initState();
    final controller = VideoPlayerController.networkUrl(Uri.parse(widget.url));
    _controller = controller;
    controller.initialize().then((_) {
      if (mounted) setState(() => _isReady = true);
    }).catchError((_) {});
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _togglePlay() {
    final controller = _controller;
    if (controller == null) return;
    setState(() {
      controller.value.isPlaying ? controller.pause() : controller.play();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isReady || _controller == null) {
      return Container(
        height: 180,
        color: Colors.grey.shade200,
        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    return GestureDetector(
      onTap: _togglePlay,
      child: AspectRatio(
        aspectRatio: _controller!.value.aspectRatio == 0 ? 16 / 9 : _controller!.value.aspectRatio,
        child: Stack(
          alignment: Alignment.center,
          children: [
            VideoPlayer(_controller!),
            AnimatedOpacity(
              opacity: _controller!.value.isPlaying ? 0 : 1,
              duration: const Duration(milliseconds: 200),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 32),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
