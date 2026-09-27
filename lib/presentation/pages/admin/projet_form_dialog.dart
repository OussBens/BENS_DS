import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../data/models/projet_model.dart';
import '../../providers/projet_provider.dart';
import '../../widgets/champ_saisie.dart';
import '../../widgets/drop_down.dart';
import '../../widgets/image_upload.dart';

class ProjetFormDialog extends ConsumerStatefulWidget {
  final Projet? projet;

  const ProjetFormDialog({super.key, this.projet});

  @override
  ConsumerState<ProjetFormDialog> createState() => _ProjetFormDialogState();
}

class _ProjetFormDialogState extends ConsumerState<ProjetFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _clientController;
  late TextEditingController _urlController;
  late TextEditingController _technologiesController;
  String _category = 'Web';
  late List<String> _images;
  bool _isFeatured = false;
  bool _isPublished = true;
  bool _isSubmitting = false;

  bool get _isEditing => widget.projet != null;

  @override
  void initState() {
    super.initState();
    final projet = widget.projet;
    _titleController = TextEditingController(text: projet?.title ?? '');
    _descriptionController = TextEditingController(text: projet?.description ?? '');
    _clientController = TextEditingController(text: projet?.clientName ?? '');
    _urlController = TextEditingController(text: projet?.projectUrl ?? '');
    _technologiesController = TextEditingController(text: projet?.technologies.join(', ') ?? '');
    _category = projet?.category ?? 'Web';
    _images = projet != null ? [if (projet.hasImage) projet.imageUrl!, ...projet.gallery] : [];
    _isFeatured = projet?.isFeatured ?? false;
    _isPublished = projet?.isPublished ?? true;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _clientController.dispose();
    _urlController.dispose();
    _technologiesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final technologies = _technologiesController.text
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    final projet = Projet(
      id: widget.projet?.id ?? 0,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      category: _category,
      imageUrl: _images.isNotEmpty ? _images.first : null,
      gallery: _images.length > 1 ? _images.sublist(1) : [],
      technologies: technologies,
      clientName: _clientController.text.trim().isNotEmpty ? _clientController.text.trim() : null,
      projectUrl: _urlController.text.trim().isNotEmpty ? _urlController.text.trim() : null,
      isFeatured: _isFeatured,
      isPublished: _isPublished,
      order: widget.projet?.order ?? 0,
      createdAt: widget.projet?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final notifier = ref.read(projetProvider.notifier);
    final success = _isEditing ? await notifier.updateProjet(projet) : await notifier.addProjet(projet);

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_isEditing ? 'Projet modifié' : 'Projet ajouté'), backgroundColor: Colors.green),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ref.read(projetProvider).errorMessage ?? 'Erreur'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final width = isMobile ? MediaQuery.of(context).size.width * 0.95 : 560.0;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        width: width,
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.88),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_isEditing ? 'Modifier le projet' : 'Ajouter un projet', style: const TextStyle(fontFamily: 'Inter', fontSize: 22, fontWeight: FontWeight.bold)),
                    IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                  ],
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  label: 'Titre *',
                  controller: _titleController,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Titre requis' : null,
                ),
                const SizedBox(height: 16),
                CustomDropdown(
                  label: 'Catégorie',
                  value: _category,
                  items: AppConstants.projectCategories.where((c) => c != 'Tous').toList(),
                  hint: 'Choisir une catégorie',
                  onChanged: (v) => setState(() => _category = v ?? _category),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Description *',
                  controller: _descriptionController,
                  maxLines: 4,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Description requise' : null,
                ),
                const SizedBox(height: 16),
                CustomTextField(label: 'Client (optionnel)', controller: _clientController),
                const SizedBox(height: 16),
                CustomTextField(label: 'Lien du projet (optionnel)', controller: _urlController),
                const SizedBox(height: 16),
                CustomTextField(label: 'Technologies (séparées par des virgules)', hint: 'Ex: Flutter, NestJS, PostgreSQL', controller: _technologiesController),
                const SizedBox(height: 16),
                CustomImageUpload(
                  label: 'Photos du projet',
                  imageUrls: _images,
                  onImagesChanged: (images) => setState(() => _images = images),
                  uploadEndpoint: ApiConfig.uploadImage,
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Projet mis en avant'),
                  value: _isFeatured,
                  onChanged: (v) => setState(() => _isFeatured = v),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Publié sur le site'),
                  value: _isPublished,
                  onChanged: (v) => setState(() => _isPublished = v),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.yellow,
                      foregroundColor: AppConstants.primaryDark,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : Text(_isEditing ? 'Enregistrer' : 'Ajouter', style: const TextStyle(fontWeight: FontWeight.w700)),
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
