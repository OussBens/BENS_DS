import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/responsive_helper.dart';
import '../providers/cordonne_provider.dart';

class MainLayout extends ConsumerStatefulWidget {
  final Widget child;
  final int selectedIndex;
  final Widget? floatingActionButton;
  final ScrollController? scrollController;

  const MainLayout({
    super.key,
    required this.child,
    this.selectedIndex = 0,
    this.floatingActionButton,
    this.scrollController,
  });

  @override
  ConsumerState<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends ConsumerState<MainLayout> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  static const _navItems = [
    {'title': 'Accueil', 'route': '/'},
    {'title': 'Services', 'route': '/services'},
    {'title': 'Projets', 'route': '/projets'},
    {'title': 'Contact', 'route': '/contact'},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ref.read(cordonneProvider).cordonne == null) {
        ref.read(cordonneProvider.notifier).loadCordonne();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveHelper(
      mobile: _buildMobileLayout(),
      tablette: _buildTabletLayout(),
      desktop: _buildDesktopLayout(),
    );
  }

  Widget _buildGlassAppBarBackground({required Widget child}) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.bg.withOpacity(0.82),
            border: const Border(bottom: BorderSide(color: AppColors.glassBorder)),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          CustomScrollView(
            controller: widget.scrollController,
            slivers: [
              SliverAppBar(
                expandedHeight: 84,
                floating: true,
                pinned: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                centerTitle: false,
                flexibleSpace: FlexibleSpaceBar(
                  background: _buildGlassAppBarBackground(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 80),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildLogo(48),
                          _buildNav(fontSize: 14, spacing: 28),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(child: widget.child),
              SliverToBoxAdapter(child: _buildFooter(columns: 2)),
            ],
          ),
          if (widget.floatingActionButton != null)
            Positioned(bottom: 20, right: 20, child: widget.floatingActionButton!),
        ],
      ),
    );
  }

  Widget _buildTabletLayout() {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          CustomScrollView(
            controller: widget.scrollController,
            slivers: [
              SliverAppBar(
                expandedHeight: 74,
                floating: true,
                pinned: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                centerTitle: false,
                flexibleSpace: FlexibleSpaceBar(
                  background: _buildGlassAppBarBackground(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildLogo(38),
                          _buildNav(fontSize: 13, spacing: 16),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(child: widget.child),
              SliverToBoxAdapter(child: _buildFooter(columns: 1)),
            ],
          ),
          if (widget.floatingActionButton != null)
            Positioned(bottom: 20, right: 20, child: widget.floatingActionButton!),
        ],
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.bg,
      endDrawer: _buildDrawer(),
      body: Stack(
        children: [
          CustomScrollView(
            controller: widget.scrollController,
            slivers: [
              SliverAppBar(
                expandedHeight: 60,
                floating: true,
                pinned: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                centerTitle: false,
                automaticallyImplyLeading: false,
                flexibleSpace: FlexibleSpaceBar(
                  background: _buildGlassAppBarBackground(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildLogo(32),
                          IconButton(
                            icon: const Icon(Icons.menu, color: AppColors.white),
                            onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(child: widget.child),
              SliverToBoxAdapter(child: _buildFooter(columns: 1)),
            ],
          ),
          if (widget.floatingActionButton != null)
            Positioned(bottom: 20, right: 20, child: widget.floatingActionButton!),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: AppColors.bg,
      child: Column(
        children: [
          Container(padding: const EdgeInsets.all(24), child: _buildLogo(36)),
          Expanded(
            child: ListView(
              children: _navItems
                  .map((item) => ListTile(
                        title: Text(item['title']!, style: const TextStyle(color: AppColors.white)),
                        onTap: () {
                          Navigator.pop(context);
                          context.go(item['route']!);
                        },
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNav({required double fontSize, required double spacing}) {
    return Row(
      children: [
        ..._navItems.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isSelected = widget.selectedIndex == index;
          return MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => context.go(item['route']!),
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: spacing / 2),
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  border: isSelected
                      ? const Border(bottom: BorderSide(color: AppColors.gold, width: 2))
                      : null,
                ),
                child: Text(
                  item['title']!,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    fontSize: fontSize,
                    color: isSelected ? AppColors.white : AppColors.muted,
                  ),
                ),
              ),
            ),
          );
        }),
        SizedBox(width: spacing),
        ElevatedButton(
          onPressed: () => context.go('/contact'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.gold,
            foregroundColor: AppColors.bg,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text('Demander un devis', style: TextStyle(fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }

  Widget _buildLogo(double height) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          final currentRoute = GoRouterState.of(context).uri.toString();
          if (currentRoute != '/') context.go('/');
        },
        child: Image.asset(
          'assets/images/logo/bens_ds_logo.png',
          height: height,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => Text(
            'BENS DS',
            style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: height * 0.4),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter({required int columns}) {
    final cordonne = ref.watch(cordonneProvider).cordonne;
    final phone = cordonne?.telephone ?? '';
    final address = cordonne?.adresse ?? '';
    final email = cordonne?.email ?? '';
    final horraire = cordonne?.horraire ?? '';

    final contactColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Image.asset('assets/images/logo/bens_ds_logo.png', height: 50, fit: BoxFit.contain),
        const SizedBox(height: 20),
        const Text(
          'Votre partenaire digital de confiance.',
          style: TextStyle(color: AppColors.muted, fontSize: 14),
        ),
        const SizedBox(height: 20),
        if (phone.isNotEmpty) _footerInfoLine(Icons.phone_outlined, phone),
        if (email.isNotEmpty) _footerInfoLine(Icons.email_outlined, email),
        if (address.isNotEmpty) _footerInfoLine(Icons.location_on_outlined, address),
        if (horraire.isNotEmpty) _footerInfoLine(Icons.schedule_outlined, horraire),
      ],
    );

    final linksColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Navigation', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 16),
        ..._navItems.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GestureDetector(
                onTap: () => context.go(item['route']!),
                child: Text(item['title']!, style: const TextStyle(color: AppColors.muted)),
              ),
            )),
      ],
    );

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.bg,
        border: Border(top: BorderSide(color: AppColors.glassBorder)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 50),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 56),
            child: columns == 2
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 3, child: contactColumn),
                      const SizedBox(width: 60),
                      Expanded(flex: 2, child: linksColumn),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [contactColumn, const SizedBox(height: 36), linksColumn],
                  ),
          ),
          const SizedBox(height: 40),
          const Divider(color: AppColors.glassBorder),
          const SizedBox(height: 20),
          const Text(
            '© 2026 BENS DIGITAL SOLUTIONS. Tous droits réservés.',
            style: TextStyle(color: AppColors.muted, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _footerInfoLine(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppColors.tealGlow),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(color: AppColors.muted, fontSize: 13))),
        ],
      ),
    );
  }
}

class SocialIconButton extends StatefulWidget {
  final IconData icon;
  final String url;
  final String name;

  const SocialIconButton({super.key, required this.icon, required this.url, required this.name});

  @override
  State<SocialIconButton> createState() => _SocialIconButtonState();
}

class _SocialIconButtonState extends State<SocialIconButton> {
  bool _isHovered = false;

  Future<void> _launchURL() async {
    final uri = Uri.parse(widget.url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: _launchURL,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _isHovered ? AppColors.gold : AppColors.glass,
            shape: BoxShape.circle,
          ),
          child: Icon(widget.icon, size: 18, color: _isHovered ? AppColors.bg : AppColors.white),
        ),
      ),
    );
  }
}
