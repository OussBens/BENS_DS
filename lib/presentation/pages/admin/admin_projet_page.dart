import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../data/models/projet_model.dart';
import '../../providers/projet_provider.dart';
import '../../widgets/card/projet_card_admin.dart';
import 'projet_form_dialog.dart';

class AdminProjetPage extends ConsumerStatefulWidget {
  const AdminProjetPage({super.key});

  @override
  ConsumerState<AdminProjetPage> createState() => _AdminProjetPageState();
}

class _AdminProjetPageState extends ConsumerState<AdminProjetPage> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(projetProvider.notifier).loadProjets(onlyPublished: false);
    });
  }

  List<Projet> _filtered(List<Projet> all) {
    if (_searchQuery.isEmpty) return all;
    final q = _searchQuery.toLowerCase();
    return all.where((p) => p.title.toLowerCase().contains(q) || p.category.toLowerCase().contains(q)).toList();
  }

  Future<void> _delete(Projet projet) async {
    final success = await ref.read(projetProvider.notifier).deleteProjet(projet.id);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Projet supprimé'), backgroundColor: Colors.green));
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(projetProvider);
    final items = _filtered(state.projets);
    final isMobile = ResponsiveHelper.isMobile(context);

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Projets', style: TextStyle(fontFamily: 'Inter', fontSize: isMobile ? 22 : 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Gérez la galerie de projets affichée sur le site', style: TextStyle(fontSize: isMobile ? 12 : 14, color: Colors.grey.shade600)),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 8, offset: const Offset(0, 2))]),
                child: TextField(
                  onChanged: (v) => setState(() => _searchQuery = v),
                  decoration: InputDecoration(
                    hintText: 'Rechercher un projet...',
                    prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              state.isLoading
                  ? const Padding(padding: EdgeInsets.symmetric(vertical: 40), child: Center(child: CircularProgressIndicator()))
                  : items.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          child: Center(child: Text('Aucun projet', style: TextStyle(color: Colors.grey.shade500))),
                        )
                      : Column(
                          children: items
                              .map((projet) => ProjetCardAdmin(
                                    projet: projet,
                                    onEdit: () => showDialog(context: context, builder: (_) => ProjetFormDialog(projet: projet)),
                                    onDelete: () => _delete(projet),
                                  ))
                              .toList(),
                        ),
            ],
          ),
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton.extended(
            onPressed: () => showDialog(context: context, builder: (_) => const ProjetFormDialog()),
            backgroundColor: AppConstants.primaryDark,
            icon: const Icon(Icons.add),
            label: const Text('Ajouter un projet'),
          ),
        ),
      ],
    );
  }
}
