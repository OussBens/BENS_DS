import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/icon_mapper.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../data/models/service_model.dart';
import '../../providers/service_provider.dart';
import '../../widgets/champ_saisie.dart';

class ServiceFormDialog extends ConsumerStatefulWidget {
  final Service? service;

  const ServiceFormDialog({super.key, this.service});

  @override
  ConsumerState<ServiceFormDialog> createState() => _ServiceFormDialogState();
}

class _ServiceFormDialogState extends ConsumerState<ServiceFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _technologiesController;
  late TextEditingController _priceController;
  String _icon = 'web';
  bool _isPublished = true;
  bool _isSubmitting = false;

  bool get _isEditing => widget.service != null;

  @override
  void initState() {
    super.initState();
    final service = widget.service;
    _titleController = TextEditingController(text: service?.title ?? '');
    _descriptionController = TextEditingController(text: service?.description ?? '');
    _technologiesController = TextEditingController(text: service?.technologies.join(', ') ?? '');
    _priceController = TextEditingController(text: service?.priceFrom?.toStringAsFixed(0) ?? '');
    _icon = service?.icon ?? 'web';
    _isPublished = service?.isPublished ?? true;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _technologiesController.dispose();
    _priceController.dispose();
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

    final service = Service(
      id: widget.service?.id ?? 0,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      icon: _icon,
      technologies: technologies,
      priceFrom: _priceController.text.trim().isNotEmpty ? double.tryParse(_priceController.text.trim()) : null,
      order: widget.service?.order ?? 0,
      isPublished: _isPublished,
      createdAt: widget.service?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final notifier = ref.read(serviceProvider.notifier);
    final success = _isEditing ? await notifier.updateService(service) : await notifier.addService(service);

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_isEditing ? 'Service modifié' : 'Service ajouté'), backgroundColor: Colors.green),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ref.read(serviceProvider).errorMessage ?? 'Erreur'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final width = isMobile ? MediaQuery.of(context).size.width * 0.95 : 520.0;

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
                    Text(_isEditing ? 'Modifier le service' : 'Ajouter un service', style: const TextStyle(fontFamily: 'Inter', fontSize: 22, fontWeight: FontWeight.bold)),
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
                CustomTextField(
                  label: 'Description *',
                  controller: _descriptionController,
                  maxLines: 4,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Description requise' : null,
                ),
                const SizedBox(height: 16),
                Text('Icône', style: TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey.shade800)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: IconMapper.selectable.map((entry) {
                    final isSelected = _icon == entry.key;
                    return GestureDetector(
                      onTap: () => setState(() => _icon = entry.key),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: isSelected ? AppConstants.primaryDark : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(entry.value, color: isSelected ? Colors.white : Colors.grey.shade700),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                CustomTextField(label: 'Technologies (séparées par des virgules)', hint: 'Ex: Flutter, NestJS', controller: _technologiesController),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Tarif de départ en DA (optionnel)',
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
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
