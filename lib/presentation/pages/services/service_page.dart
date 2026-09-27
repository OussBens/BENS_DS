import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../animation/scroll_reveal.dart';
import '../../layouts/main_layout.dart';
import '../../../data/models/service_model.dart';
import '../../providers/service_provider.dart';
import '../../widgets/card/service_card.dart';
import '../../widgets/responsive/responsive_grid_view.dart';

class ServicePage extends ConsumerStatefulWidget {
  const ServicePage({super.key});

  @override
  ConsumerState<ServicePage> createState() => _ServicePageState();
}

class _ServicePageState extends ConsumerState<ServicePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(serviceProvider.notifier).loadServices();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(serviceProvider);
    final isMobile = ResponsiveHelper.isMobile(context);
    final horizontalPadding = isMobile ? 20.0 : 80.0;

    return MainLayout(
      selectedIndex: 1,
      child: Container(
        color: AppColors.bg,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: isMobile ? 60 : 100),
              child: Stack(
                children: [
                  Positioned(top: -60, right: -40, child: const GlowBlob(size: 280, color: AppColors.tealGlow)),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('NOS SERVICES', style: AppText.eyebrow.copyWith(letterSpacing: 3, fontSize: 13)),
                      const SizedBox(height: 16),
                      Text(
                        'Des solutions digitales sur mesure',
                        style: AppText.h1.copyWith(fontSize: isMobile ? 28 : 42),
                      ),
                      const SizedBox(height: 16),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 560),
                        child: Text(
                          'Du développement web au mobile, en passant par les applications desktop : notre équipe conçoit des produits digitaux robustes et évolutifs.',
                          style: AppText.body.copyWith(fontSize: 15),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 60),
              child: state.isLoading
                  ? const Padding(padding: EdgeInsets.symmetric(vertical: 60), child: Center(child: CircularProgressIndicator(color: AppColors.tealGlow)))
                  : state.services.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 60),
                          child: Center(
                            child: Text('Aucun service disponible pour le moment.', style: AppText.body),
                          ),
                        )
                      : ResponsiveGridView<Service>(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          items: state.services,
                          itemBuilder: (context, service, index) => ScrollReveal(
                            delay: Duration(milliseconds: index * kStaggerStepMs),
                            child: ServiceCard(service: service),
                          ),
                        ),
            ),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 60),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.glassBorder)),
              ),
              child: Column(
                children: [
                  Text('Un projet en tête ?', style: AppText.h2.copyWith(fontSize: 24)),
                  const SizedBox(height: 12),
                  Text('Parlons de vos besoins et obtenez un devis gratuit sous 48h.', style: AppText.body),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => context.go('/contact'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.gold,
                      foregroundColor: AppColors.bg,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Demander un devis', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
