import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../data/models/service_model.dart';
import '../../providers/service_provider.dart';
import '../../widgets/card/service_card_admin.dart';
import 'service_form_dialog.dart';

class AdminServicePage extends ConsumerStatefulWidget {
  const AdminServicePage({super.key});

  @override
  ConsumerState<AdminServicePage> createState() => _AdminServicePageState();
}

class _AdminServicePageState extends ConsumerState<AdminServicePage> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(serviceProvider.notifier).loadServices(onlyPublished: false);
    });
  }

  List<Service> _filtered(List<Service> all) {
    if (_searchQuery.isEmpty) return all;
    final q = _searchQuery.toLowerCase();
    return all.where((s) => s.title.toLowerCase().contains(q)).toList();
  }

  Future<void> _delete(Service service) async {
    final success = await ref.read(serviceProvider.notifier).deleteService(service.id);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Service supprimé'), backgroundColor: Colors.green));
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(serviceProvider);
    final items = _filtered(state.services);
    final isMobile = ResponsiveHelper.isMobile(context);

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Services', style: TextStyle(fontFamily: 'Inter', fontSize: isMobile ? 22 : 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Gérez les services proposés sur le site', style: TextStyle(fontSize: isMobile ? 12 : 14, color: Colors.grey.shade600)),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 8, offset: const Offset(0, 2))]),
                child: TextField(
                  onChanged: (v) => setState(() => _searchQuery = v),
                  decoration: InputDecoration(
                    hintText: 'Rechercher un service...',
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
                          child: Center(child: Text('Aucun service', style: TextStyle(color: Colors.grey.shade500))),
                        )
                      : Column(
                          children: items
                              .map((service) => ServiceCardAdmin(
                                    service: service,
                                    onEdit: () => showDialog(context: context, builder: (_) => ServiceFormDialog(service: service)),
                                    onDelete: () => _delete(service),
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
            onPressed: () => showDialog(context: context, builder: (_) => const ServiceFormDialog()),
            backgroundColor: AppConstants.primaryDark,
            icon: const Icon(Icons.add),
            label: const Text('Ajouter un service'),
          ),
        ),
      ],
    );
  }
}
