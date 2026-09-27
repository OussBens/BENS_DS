import 'package:chm_web/data/models/temoin_model.dart';
import 'package:chm_web/presentation/providers/temoin_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../widgets/champ_saisie.dart';
import '../../widgets/image_upload.dart';
import '../../widgets/video_upload.dart';

class AddTemoinDialog extends ConsumerStatefulWidget {
  final VoidCallback onRefresh;

  const AddTemoinDialog({
    super.key,
    required this.onRefresh,
  });

  @override
  ConsumerState<AddTemoinDialog> createState() => _AddTemoinDialogState();
}

class _AddTemoinDialogState extends ConsumerState<AddTemoinDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nomClientController = TextEditingController();
  final _titreController = TextEditingController();
  final _modeleVoitureController = TextEditingController();
  final _contenuController = TextEditingController();

  List<String> _imageUrls = [];
  String? _videoUrl;
  int _note = 5;
  DateTime _selectedDate = DateTime.now();
  bool _isActive = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nomClientController.dispose();
    _titreController.dispose();
    _modeleVoitureController.dispose();
    _contenuController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2015),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final fullImageUrls = _imageUrls.map((url) {
        if (url.startsWith('http')) return url;
        if (url.startsWith('/uploads/')) return '${ApiConfig.baseUrl}$url';
        return '${ApiConfig.baseUrl}/uploads/$url';
      }).toList();

      final temoin = Temoin(
        id: 0,
        nomClient: _nomClientController.text,
        titre: _titreController.text.isNotEmpty ? _titreController.text : null,
        modeleVoiture: _modeleVoitureController.text.isNotEmpty ? _modeleVoitureController.text : null,
        contenu: _contenuController.text,
        note: _note,
        photos: fullImageUrls,
        video: _videoUrl,
        date: _selectedDate,
        isActive: _isActive,
        creePar: 'admin',
        creeLe: DateTime.now(),
      );

      final success = await ref.read(temoinProvider.notifier).addTemoin(temoin);

      if (mounted) Navigator.pop(context);

      if (success) {
        if (mounted) Navigator.pop(context);
        widget.onRefresh();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Témoignage ajouté avec succès'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        throw Exception(ref.read(temoinProvider).errorMessage ?? 'Erreur inconnue');
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Widget _buildStarSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Note *',
          style: TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey.shade800),
        ),
        const SizedBox(height: 8),
        Row(
          children: List.generate(5, (index) {
            final filled = index < _note;
            return GestureDetector(
              onTap: () => setState(() => _note = index + 1),
              child: Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Icon(
                  filled ? Icons.star_rounded : Icons.star_border_rounded,
                  color: const Color(0xFFFFC107),
                  size: 32,
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildDatePicker(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date du témoignage *',
          style: TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey.shade800),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _pickDate,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today_outlined, size: 18, color: Colors.grey.shade600),
                const SizedBox(width: 10),
                Text(
                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final isTablet = ResponsiveHelper.isTablette(context);
    final screenWidth = ResponsiveHelper.getWidth(context);
    final screenHeight = ResponsiveHelper.getHeight(context);

    double dialogWidth;
    double titleFontSize;
    double spacing;

    if (isMobile) {
      dialogWidth = screenWidth * 0.95;
      titleFontSize = 20;
      spacing = 16;
    } else if (isTablet) {
      dialogWidth = screenWidth * 0.6;
      titleFontSize = 22;
      spacing = 20;
    } else {
      dialogWidth = screenWidth * 0.42;
      titleFontSize = 24;
      spacing = 24;
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        width: dialogWidth,
        constraints: BoxConstraints(
          maxHeight: screenHeight * 0.88,
          minWidth: isMobile ? double.infinity : 450,
        ),
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Ajouter un témoignage',
                  style: TextStyle(fontFamily: 'Inter', fontSize: titleFontSize, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Renseignez les informations du témoignage client',
              style: TextStyle(fontSize: isMobile ? 12 : 13, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      CustomTextField(
                        label: 'Nom du client *',
                        hint: 'Ex: Karim Benali',
                        controller: _nomClientController,
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Le nom du client est requis';
                          if (value.length < 2) return 'Minimum 2 caractères';
                          return null;
                        },
                      ),
                      SizedBox(height: spacing),
                      CustomTextField(
                        label: 'Titre',
                        hint: 'Ex: Un service impeccable',
                        controller: _titreController,
                      ),
                      SizedBox(height: spacing),
                      CustomTextField(
                        label: 'Projet lié (optionnel)',
                        hint: 'Ex: Refonte site vitrine',
                        controller: _modeleVoitureController,
                      ),
                      SizedBox(height: spacing),
                      CustomTextField(
                        label: 'Témoignage *',
                        hint: 'Le contenu du témoignage client...',
                        controller: _contenuController,
                        maxLines: isMobile ? 4 : 5,
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Le contenu du témoignage est requis';
                          if (value.length < 10) return 'Minimum 10 caractères';
                          return null;
                        },
                      ),
                      SizedBox(height: spacing),
                      _buildStarSelector(),
                      SizedBox(height: spacing),
                      _buildDatePicker(isMobile),
                      SizedBox(height: spacing),
                      CustomImageUpload(
                        imageUrls: _imageUrls,
                        onImagesChanged: (images) => setState(() => _imageUrls = images),
                        uploadEndpoint: ApiConfig.uploadImage,
                      ),
                      SizedBox(height: spacing),
                      CustomVideoUpload(
                        videoUrl: _videoUrl,
                        onVideoChanged: (url) => setState(() => _videoUrl = url),
                        uploadEndpoint: ApiConfig.uploadVideo,

                      ),
                      SizedBox(height: spacing),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Publier immédiatement sur le site',
                              style: TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey.shade800),
                            ),
                          ),
                          Switch(
                            value: _isActive,
                            activeColor: AppConstants.accent,
                            onChanged: (value) => setState(() => _isActive = value),
                          ),
                        ],
                      ),
                      SizedBox(height: spacing * 2),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _isSubmitting ? null : () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: isMobile ? 12 : 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                side: BorderSide(color: Colors.grey.shade400),
                              ),
                              child: const Text('Annuler'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: StatefulBuilder(
                              builder: (context, setStateHover) {
                                bool isHovered = false;
                                bool isPressed = false;

                                return GestureDetector(
                                  onTapDown: (_) => setStateHover(() => isPressed = true),
                                  onTapUp: (_) => setStateHover(() => isPressed = false),
                                  onTapCancel: () => setStateHover(() => isPressed = false),
                                  child: MouseRegion(
                                    cursor: SystemMouseCursors.click,
                                    onEnter: (_) => setStateHover(() => isHovered = true),
                                    onExit: (_) => setStateHover(() {
                                      isHovered = false;
                                      isPressed = false;
                                    }),
                                    child: ElevatedButton(
                                      onPressed: _isSubmitting ? null : _submit,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: (isHovered || isPressed) ? AppConstants.accent : Colors.black,
                                        foregroundColor: Colors.white,
                                        padding: EdgeInsets.symmetric(vertical: isMobile ? 12 : 14),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        elevation: (isHovered || isPressed) ? 4 : 0,
                                      ),
                                      child: _isSubmitting
                                          ? const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                              ),
                                            )
                                          : const Text('Ajouter'),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
