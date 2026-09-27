import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../providers/contact_provider.dart';
import '../../providers/projet_provider.dart';
import '../../providers/service_provider.dart';
import '../../providers/temoin_provider.dart';
import '../../../data/models/contact_message_model.dart';

class AdminDashPage extends ConsumerStatefulWidget {
  const AdminDashPage({super.key});

  @override
  ConsumerState<AdminDashPage> createState() => _AdminDashPageState();
}

class _AdminDashPageState extends ConsumerState<AdminDashPage> {
  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final isTablet = ResponsiveHelper.isTablette(context);

    final projets = ref.watch(projetProvider).projets;
    final services = ref.watch(serviceProvider).services;
    final temoins = ref.watch(temoinProvider).temoins;
    final messages = ref.watch(contactProvider).messages;
    final newMessages = messages.where((m) => m.status == ContactMessageStatus.nouveau).length;

    int crossAxisCount = isMobile ? 2 : (isTablet ? 3 : 4);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tableau de bord', style: TextStyle(fontFamily: 'Inter', fontSize: isMobile ? 22 : 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Vue d\'ensemble du contenu du site', style: TextStyle(fontSize: isMobile ? 12 : 14, color: Colors.grey.shade600)),
          const SizedBox(height: 24),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: isMobile ? 12 : 16,
            mainAxisSpacing: isMobile ? 12 : 16,
            childAspectRatio: isMobile ? 1.2 : 1.4,
            children: [
              _statCard('Projets publiés', projets.where((p) => p.isPublished).length.toString(), Icons.work_outline, Colors.blue, isMobile),
              _statCard('Services actifs', services.where((s) => s.isPublished).length.toString(), Icons.design_services_outlined, Colors.teal, isMobile),
              _statCard('Témoignages', temoins.where((t) => t.isActive).length.toString(), Icons.reviews_outlined, Colors.purple, isMobile),
              _statCard('Nouveaux messages', newMessages.toString(), Icons.mail_outline, Colors.orange, isMobile),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statCard(String title, String value, IconData icon, Color color, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(isMobile ? 8 : 10),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: isMobile ? 24 : 28),
          ),
          const SizedBox(height: 10),
          Text(title, style: TextStyle(fontSize: isMobile ? 11 : 12, color: Colors.grey.shade600), textAlign: TextAlign.center),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: isMobile ? 22 : 26, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}
