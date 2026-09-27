import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../data/models/projet_model.dart';
import '../../animation/scroll_reveal.dart';
import '../../layouts/main_layout.dart';
import '../../providers/projet_provider.dart';
import '../../widgets/card/projet_card.dart';
import '../../widgets/responsive/responsive_grid_view.dart';
import 'projet_detail_dialog.dart';

class ProjetPage extends ConsumerStatefulWidget {
  const ProjetPage({super.key});

  @override
  ConsumerState<ProjetPage> createState() => _ProjetPageState();
}

class _ProjetPageState extends ConsumerState<ProjetPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(projetProvider.notifier).loadProjets();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(projetProvider);
    final isMobile = ResponsiveHelper.isMobile(context);
    final horizontalPadding = isMobile ? 20.0 : 80.0;

    return MainLayout(
      selectedIndex: 2,
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
                      Text('NOS RÉALISATIONS', style: AppText.eyebrow.copyWith(letterSpacing: 3, fontSize: 13)),
                      const SizedBox(height: 16),
                      Text(
                        'Des projets qui parlent d\'eux-mêmes',
                        style: AppText.h1.copyWith(fontSize: isMobile ? 28 : 42),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 32),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: AppConstants.projectCategories.map((category) {
                    final isSelected = state.selectedCategory == category;
                    return ChoiceChip(
                      label: Text(category),
                      selected: isSelected,
                      onSelected: (_) => ref.read(projetProvider.notifier).filterByCategory(category),
                      selectedColor: AppColors.tealDeep,
                      backgroundColor: AppColors.glass,
                      side: BorderSide(color: isSelected ? AppColors.tealGlow : AppColors.glassBorder),
                      labelStyle: TextStyle(
                        color: isSelected ? AppColors.white : AppColors.muted,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    );
                  }).toList(),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(horizontalPadding, 0, horizontalPadding, 80),
              child: state.isLoading
                  ? const Padding(padding: EdgeInsets.symmetric(vertical: 60), child: Center(child: CircularProgressIndicator(color: AppColors.tealGlow)))
                  : state.filteredProjets.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 60),
                          child: Center(
                            child: Text('Aucun projet dans cette catégorie pour le moment.', style: AppText.body),
                          ),
                        )
                      : ResponsiveGridView<Projet>(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          items: state.filteredProjets,
                          itemBuilder: (context, projet, index) => ScrollReveal(
                            delay: Duration(milliseconds: index * kStaggerStepMs),
                            child: ProjetCard(
                              projet: projet,
                              onTap: () => showDialog(
                                context: context,
                                builder: (_) => ProjetDetailDialog(projet: projet),
                              ),
                            ),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
