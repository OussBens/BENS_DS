// lib/presentation/widgets/testimonial_section.dart
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../animation/scroll_reveal.dart';
import '../providers/temoin_provider.dart';
import 'card/temoin_card.dart';

class TestimonialSection extends ConsumerStatefulWidget {
  const TestimonialSection({super.key});

  @override
  ConsumerState<TestimonialSection> createState() => _TestimonialSectionState();
}

class _TestimonialSectionState extends ConsumerState<TestimonialSection> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Section plus bas dans la page : on laisse d'abord la priorité
      // réseau à la vidéo hero et aux sections au-dessus avant de charger
      // les avis clients.
      Future.delayed(const Duration(milliseconds: 400), () {
        if (!mounted) return;
        final state = ref.read(temoinProvider);
        if (state.temoins.isEmpty && !state.isLoading) {
          ref.read(temoinProvider.notifier).loadAllTemoins();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final temoinState = ref.watch(temoinProvider);
    final testimonials = temoinState.temoins.where((t) => t.isActive).toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    if (testimonials.isEmpty) {
      return const SizedBox.shrink();
    }
    const Color or = AppColors.gold;

    final isArabic = context.locale.languageCode == 'ar';
    final badgeText = isArabic ? 'آراء العملاء' : 'AVIS CLIENTS';
    final titleText = isArabic ? 'ماذا يقول عملاؤنا' : 'Ce que disent nos clients';
    final subtitleText = isArabic
        ? 'تجارب حقيقية عاشها عملاء BENS DIGITAL SOLUTIONS'
        : 'Des expériences réelles vécues par nos clients BENS DIGITAL SOLUTIONS';

    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final horizontalPadding =
        isMobile ? 16.0 : (screenWidth < 1200 ? 40.0 : 80.0);
    final titleFontSize = isMobile ? 28.0 : 36.0;
    final cardWidth = isMobile ? screenWidth * 0.8 : 360.0;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: ScrollReveal(
              child: Column(
                children: [
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          or.withOpacity(0.3),
                          or.withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: or.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      badgeText,
                      style: TextStyle(
                        color: or,
                        fontSize: isMobile ? 16 : 20,
                        letterSpacing: 3,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    titleText,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontFamily: 'Inter',
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    subtitleText,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: isMobile ? 14 : 16,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 48),
          SizedBox(
            height: 280,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final totalWidth =
                    testimonials.length * cardWidth + testimonials.length * 20;
                final cards = testimonials.asMap().entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: ScrollReveal(
                      delay: Duration(milliseconds: entry.key * kStaggerStepMs),
                      child: TemoinCard(
                        temoin: entry.value,
                        width: cardWidth,
                      ),
                    ),
                  );
                }).toList();

                // Quand les avis tiennent dans la largeur disponible, on les
                // centre plutôt que de les laisser collés à gauche dans une
                // ListView scrollable qui n'a pas besoin de scroller.
                if (totalWidth <= constraints.maxWidth) {
                  return Center(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const NeverScrollableScrollPhysics(),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: cards,
                      ),
                    ),
                  );
                }

                return ListView(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  children: cards,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
