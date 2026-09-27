// lib/presentation/widgets/testimonial_section.dart
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
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
    final isMobile = screenWidth < 700;
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
                    style: AppText.h2.copyWith(fontSize: titleFontSize),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    subtitleText,
                    textAlign: TextAlign.center,
                    style: AppText.body.copyWith(fontSize: isMobile ? 14 : 16),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 48),
          // Desktop / tablette : grille centrée (comme un site web).
          // Mobile : carrousel horizontal glissable au doigt ou à la souris.
          if (!isMobile)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 20,
                runSpacing: 24,
                children: testimonials.asMap().entries.map((entry) {
                  return ScrollReveal(
                    delay: Duration(milliseconds: entry.key * kStaggerStepMs),
                    child: TemoinCard(temoin: entry.value, width: cardWidth, height: 280),
                  );
                }).toList(),
              ),
            )
          else
            SizedBox(
              height: 300,
              child: ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(
                  dragDevices: PointerDeviceKind.values.toSet(),
                ),
                child: ListView.separated(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 10),
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: testimonials.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 16),
                  itemBuilder: (context, index) => ScrollReveal(
                    delay: Duration(milliseconds: index * kStaggerStepMs),
                    child: TemoinCard(temoin: testimonials[index], width: cardWidth, height: 280),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
