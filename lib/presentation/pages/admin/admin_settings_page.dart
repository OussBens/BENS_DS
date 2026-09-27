// Dans AdminSettingsPage, remplacez le contenu par :

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/cordonne.dart';
import '../../../presentation/providers/cordonne_provider.dart';

class AdminSettingsPage extends ConsumerStatefulWidget {
  const AdminSettingsPage({super.key});

  @override
  ConsumerState<AdminSettingsPage> createState() => _AdminSettingsPageState();
}

class _AdminSettingsPageState extends ConsumerState<AdminSettingsPage> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Controllers pour les coordonnées
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _hoursController;
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 500), vsync: this);
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();

    // Initialiser les contrôleurs
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _addressController = TextEditingController();
    _hoursController = TextEditingController();

    // Charger les coordonnées
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(cordonneProvider.notifier).loadCordonne();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _hoursController.dispose();
    super.dispose();
  }

  void _updateControllers(Cordonne? cordonne) {
    if (cordonne != null) {
      _emailController.text = cordonne.email;
      _phoneController.text = cordonne.telephone;
      _addressController.text = cordonne.adresse;
      _hoursController.text = cordonne.horraire;
    }
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;

    final cordonneState = ref.read(cordonneProvider);
    if (cordonneState.cordonne == null) return;

    final updatedCordonne = cordonneState.cordonne!.copyWith(
      email: _emailController.text,
      telephone: _phoneController.text,
      adresse: _addressController.text,
      horraire: _hoursController.text,
    );

    setState(() => _isSaving = true);
    final success = await ref.read(cordonneProvider.notifier).updateCordonne(updatedCordonne);
    setState(() => _isSaving = false);

    if (mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Paramètres enregistrés avec succès !'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cordonneState = ref.watch(cordonneProvider);

    // Mettre à jour les contrôleurs quand les données sont chargées
    if (cordonneState.cordonne != null) {
      _updateControllers(cordonneState.cordonne);
    }

    if (cordonneState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Coordonnées de contact', style: TextStyle(fontFamily: 'Inter', fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Configurez les informations de contact de BENS DIGITAL SOLUTIONS', style: TextStyle(color: Colors.grey.shade600)),
                const SizedBox(height: 20),

                _buildTextField(
                  label: 'Email de contact',
                  icon: Icons.email,
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 20),

                _buildTextField(
                  label: 'Téléphone de contact',
                  icon: Icons.phone,
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 20),

                _buildTextField(
                  label: 'Adresse',
                  icon: Icons.location_on,
                  controller: _addressController,
                  maxLines: 2,
                ),
                const SizedBox(height: 20),

                _buildTextField(
                  label: "Horaires d'ouverture",
                  icon: Icons.access_time,
                  controller: _hoursController,
                  maxLines: 3,
                ),
                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: StatefulBuilder(
                    builder: (context, setStateHover) {

                      return Listener(
                        onPointerDown: (_) => setStateHover(() => _isPressed = true),
                        onPointerUp: (_) => setStateHover(() => _isPressed = false),
                        onPointerCancel: (_) => setStateHover(() => _isPressed = false),
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          onEnter: (_) => setStateHover(() => _isHovered = true),
                          onExit: (_) => setStateHover(() {
                            _isHovered = false;
                            _isPressed = false;
                          }),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            transform: Matrix4.identity()..scale(_isPressed ? 0.97 : 1.0),
                            child: ElevatedButton(
                              onPressed: _isSaving ? null : _saveSettings,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: (_isHovered || _isPressed)
                                    ? AppConstants.accent
                                    : Colors.black,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: (_isHovered || _isPressed) ? 6 : 2,
                              ),
                              child: _isSaving
                                  ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white
                                  )
                              )
                                  : const Text('Enregistrer les paramètres'),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, fontSize: 14)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            prefixIcon: Icon(icon),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: (val) => (val == null || val.isEmpty) ? 'Veuillez saisir $label' : null,
        ),
      ],
    );
  }
}