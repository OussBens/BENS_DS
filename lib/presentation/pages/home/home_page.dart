import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../animation/fade_text.dart';
import '../../animation/scroll_reveal.dart';
import '../../layouts/main_layout.dart';
import '../../providers/projet_provider.dart';
import '../../providers/service_provider.dart';
import '../../widgets/card/projet_card.dart';
import '../../widgets/card/service_card.dart';
import '../../widgets/testimonial_section.dart';
import '../projets/projet_detail_dialog.dart';
import '../../../data/models/projet_model.dart';
import '../../../data/models/service_model.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  static const _expertise = [
    {'icon': Icons.language_outlined, 'label': 'Développement Web'},
    {'icon': Icons.phone_iphone_outlined, 'label': 'Applications Mobile'},
    {'icon': Icons.desktop_windows_outlined, 'label': 'Logiciels Desktop'},
    {'icon': Icons.cloud_outlined, 'label': 'Cloud & API'},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(serviceProvider.notifier).loadServices();
      ref.read(projetProvider.notifier).loadProjets();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final horizontalPadding = isMobile ? 20.0 : 80.0;
    final services = ref.watch(serviceProvider).services.take(4).toList();
    final projets = ref.watch(projetProvider).projets.take(3).toList();

    return MainLayout(
      selectedIndex: 0,
      child: Container(
        color: AppColors.bg,
        child: Column(
          children: [
            _buildHero(isMobile, horizontalPadding),
            _buildExpertise(isMobile, horizontalPadding),
            if (services.isNotEmpty) _buildServicesTeaser(isMobile, horizontalPadding, services),
            if (projets.isNotEmpty) _buildProjetsTeaser(isMobile, horizontalPadding, projets),
            const TestimonialSection(),
            _buildFinalCta(isMobile, horizontalPadding),
          ],
        ),
      ),
    );
  }

  Widget _buildHero(bool isMobile, double horizontalPadding) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: isMobile ? 80 : 140),
      color: AppColors.bg,
      child: Stack(
        children: [
          Positioned(top: -80, right: -60, child: const GlowBlob(size: 340, color: AppColors.tealGlow)),
          Positioned(bottom: -100, left: -80, child: const GlowBlob(size: 300, color: AppColors.tealDeep)),
          Column(
            crossAxisAlignment: isMobile ? CrossAxisAlignment.start : CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.gold.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.gold.withOpacity(0.4)),
                ),
                child: Text('AGENCE DE DÉVELOPPEMENT DIGITAL', style: AppText.eyebrow.copyWith(color: AppColors.gold)),
              ),
              const SizedBox(height: 28),
              RevealText(
                text: 'Votre partenaire digital de confiance',
                useTextColor: true,
                style: AppText.h1.copyWith(fontSize: isMobile ? 32 : 52),
              ),
              const SizedBox(height: 24),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 620),
                child: FadeText(
                  text: "BENS DIGITAL SOLUTIONS conçoit des sites web, applications mobiles et logiciels sur mesure qui font grandir votre entreprise.",
                  delay: 0.3,
                  textAlign: isMobile ? TextAlign.start : TextAlign.center,
                  style: AppText.body.copyWith(fontSize: 16),
                ),
              ),
              const SizedBox(height: 36),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 16,
                runSpacing: 16,
                children: [
                  ElevatedButton(
                    onPressed: () => context.go('/projets'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.gold,
                      foregroundColor: AppColors.bg,
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Découvrir nos projets', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                  OutlinedButton(
                    onPressed: () => context.go('/contact'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.white,
                      side: const BorderSide(color: AppColors.glassBorder),
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Demander un devis', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExpertise(bool isMobile, double horizontalPadding) {
    return Container(
      color: AppColors.bg,
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 60),
      child: LayoutBuilder(
        builder: (context, constraints) => Wrap(
        alignment: WrapAlignment.center,
        spacing: 24,
        runSpacing: 24,
        children: _expertise.asMap().entries.map((entry) {
          final item = entry.value;
          return ScrollReveal(
            delay: Duration(milliseconds: entry.key * kStaggerStepMs),
            child: Container(
              width: isMobile ? constraints.maxWidth : 240,
              padding: const EdgeInsets.all(24),
              decoration: glassDecoration(radius: 16),
              child: Column(
                children: [
                  Icon(item['icon'] as IconData, color: AppColors.tealGlow, size: 32),
                  const SizedBox(height: 14),
                  Text(
                    item['label'] as String,
                    textAlign: TextAlign.center,
                    style: AppText.h3.copyWith(fontSize: 15),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
        ),
      ),
    );
  }

  Widget _buildServicesTeaser(bool isMobile, double horizontalPadding, List<Service> services) {
    return Container(
      width: double.infinity,
      color: AppColors.bg,
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 70),
      child: Column(
        children: [
          Text('CE QUE NOUS FAISONS', style: AppText.eyebrow),
          const SizedBox(height: 12),
          Text('Nos services clés', style: AppText.h2.copyWith(fontSize: 28)),
          const SizedBox(height: 40),
          LayoutBuilder(
            builder: (context, constraints) => Wrap(
              spacing: 20,
              runSpacing: 20,
              children: services.asMap().entries.map((entry) {
                return SizedBox(
                  width: isMobile ? constraints.maxWidth : 270,
                  child: ScrollReveal(
                    delay: Duration(milliseconds: entry.key * kStaggerStepMs),
                    child: ServiceCard(service: entry.value),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 36),
          TextButton(
            onPressed: () => context.go('/services'),
            child: Text('Voir tous nos services →', style: AppText.button.copyWith(color: AppColors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildProjetsTeaser(bool isMobile, double horizontalPadding, List<Projet> projets) {
    return Container(
      width: double.infinity,
      color: AppColors.bg,
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 70),
      child: Column(
        children: [
          Text('NOTRE PORTFOLIO', style: AppText.eyebrow),
          const SizedBox(height: 12),
          Text('Projets récents', style: AppText.h2.copyWith(fontSize: 28)),
          const SizedBox(height: 40),
          LayoutBuilder(
            builder: (context, constraints) => Wrap(
              spacing: 20,
              runSpacing: 20,
              children: projets.asMap().entries.map((entry) {
                return SizedBox(
                  width: isMobile ? constraints.maxWidth : 340,
                  child: ScrollReveal(
                    delay: Duration(milliseconds: entry.key * kStaggerStepMs),
                    child: ProjetCard(
                      projet: entry.value,
                      onTap: () => showDialog(context: context, builder: (_) => ProjetDetailDialog(projet: entry.value)),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 36),
          TextButton(
            onPressed: () => context.go('/projets'),
            child: Text('Voir tous nos projets →', style: AppText.button.copyWith(color: AppColors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildFinalCta(bool isMobile, double horizontalPadding) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 80),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.bg, AppColors.tealDeep],
        ),
      ),
      child: Column(
        children: [
          Text(
            'Prêt à lancer votre projet ?',
            textAlign: TextAlign.center,
            style: AppText.h2.copyWith(fontSize: isMobile ? 24 : 34),
          ),
          const SizedBox(height: 16),
          Text(
            'Discutons de vos objectifs et construisons ensemble la solution digitale qu\'il vous faut.',
            textAlign: TextAlign.center,
            style: AppText.body,
          ),
          const SizedBox(height: 28),
          ElevatedButton(
            onPressed: () => context.go('/contact'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.gold,
              foregroundColor: AppColors.bg,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Contactez-nous', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }
}
