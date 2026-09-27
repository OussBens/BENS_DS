import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import 'admin_dash_page.dart';
import 'admin_projet_page.dart';
import 'admin_service_page.dart';
import 'admin_temoin_page.dart';
import 'admin_contact_messages_page.dart';
import 'admin_settings_page.dart';

class AdminPage extends ConsumerStatefulWidget {
  const AdminPage({super.key});

  @override
  ConsumerState<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends ConsumerState<AdminPage> with TickerProviderStateMixin {
  late TabController _tabController;

  static const _tabs = [
    {'icon': Icons.dashboard_outlined, 'label': 'Dashboard'},
    {'icon': Icons.work_outline, 'label': 'Projets'},
    {'icon': Icons.design_services_outlined, 'label': 'Services'},
    {'icon': Icons.reviews_outlined, 'label': 'Témoignages'},
    {'icon': Icons.mail_outline, 'label': 'Messages'},
    {'icon': Icons.settings_outlined, 'label': 'Paramètres'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _logout() async {
    await ref.read(authProvider.notifier).logout();
    if (mounted) {
      context.go('/');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Déconnexion réussie'), backgroundColor: Colors.green, duration: Duration(seconds: 2)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final isMobile = ResponsiveHelper.isMobile(context);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 110,
        title: Column(
          children: [
            SizedBox(
              height: 46,
              child: Image.asset(
                'assets/images/logo/bens_ds_logo.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Text('BENS DS', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Tableau de bord Admin',
              style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold, color: Colors.black, fontSize: isMobile ? 14 : 18),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(children: [
              const Icon(Icons.admin_panel_settings, color: Colors.grey),
              const SizedBox(width: 8),
              if (!isMobile) Text(user?.name ?? 'Admin', style: const TextStyle(color: Colors.grey)),
            ]),
          ),
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout, tooltip: 'Déconnexion', color: Colors.grey),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: isMobile,
              indicator: BoxDecoration(color: AppConstants.primaryDark, borderRadius: BorderRadius.circular(12)),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey.shade600,
              dividerColor: Colors.transparent,
              indicatorSize: TabBarIndicatorSize.tab,
              padding: const EdgeInsets.all(6),
              tabs: _tabs.map((tab) => Tab(icon: Icon(tab['icon'] as IconData, size: 20), text: tab['label'] as String)).toList(),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 12.0 : 20.0, vertical: 10),
        child: TabBarView(
          controller: _tabController,
          children: const [
            AdminDashPage(),
            AdminProjetPage(),
            AdminServicePage(),
            AdminTemoinPage(),
            AdminContactMessagesPage(),
            AdminSettingsPage(),
          ],
        ),
      ),
    );
  }
}
