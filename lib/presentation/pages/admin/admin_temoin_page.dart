// lib/presentation/pages/admin/admin_temoin_page.dart
import 'package:bens_ds/core/constants/app_constants.dart';
import 'package:bens_ds/data/models/temoin_model.dart';
import 'package:bens_ds/presentation/pages/admin/add_temoin_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../presentation/providers/temoin_provider.dart';
import '../../../presentation/widgets/card/temoin_card_admin.dart';
import 'modif_temoin_dialog.dart';

class AdminTemoinPage extends ConsumerStatefulWidget {
  const AdminTemoinPage({super.key});

  @override
  ConsumerState<AdminTemoinPage> createState() => _AdminTemoinPageState();
}

class _AdminTemoinPageState extends ConsumerState<AdminTemoinPage>
    with TickerProviderStateMixin {
  String _searchQuery = '';
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isFabHovered = false;
  bool _isFabPressed = false;
  bool _isRefreshButtonHovered = false;
  bool _isRefreshButtonPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTemoins();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadTemoins() async {
    await ref.read(temoinProvider.notifier).loadAllTemoins();
  }

  Future<void> _refreshTemoins() async {
    await _loadTemoins();
  }

  void _showAddTemoinDialog() {
    showDialog(
      context: context,
      builder: (context) => AddTemoinDialog(onRefresh: _refreshTemoins),
    );
  }

  void _showEditTemoinDialog(Temoin temoin) {
    showDialog(
      context: context,
      builder: (context) => EditTemoinDialog(temoin: temoin, onRefresh: _refreshTemoins),
    );
  }

  List<Temoin> _getFilteredTemoins(List<Temoin> all) {
    if (_searchQuery.isEmpty) return all;
    return all.where((t) {
      return t.nomClient.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (t.modeleVoiture ?? '').toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (t.titre ?? '').toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final temoinState = ref.watch(temoinProvider);
    final allTemoins = temoinState.temoins;
    final filteredTemoins = _getFilteredTemoins(allTemoins);
    final isMobile = ResponsiveHelper.isMobile(context);
    final isLoading = temoinState.isLoading;
    final isTablet = ResponsiveHelper.isTablette(context);
    final mainTitleFontSize = isMobile ? 22.0 : (isTablet ? 24.0 : 28.0);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Stack(
          children: [
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 80),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Témoignages',
                    style: TextStyle(fontFamily: 'Inter', fontSize: mainTitleFontSize, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Gérez les témoignages clients affichés sur le site',
                    style: TextStyle(fontSize: isMobile ? 12 : 14, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 24),
                  _buildSearchBar(isMobile),
                  const SizedBox(height: 16),
                  isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : filteredTemoins.isEmpty
                          ? _buildEmptyState(isMobile)
                          : RefreshIndicator(
                              onRefresh: _refreshTemoins,
                              child: ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                padding: EdgeInsets.all(isMobile ? 8 : 12),
                                itemCount: filteredTemoins.length,
                                itemBuilder: (context, index) {
                                  final temoin = filteredTemoins[index];
                                  return TweenAnimationBuilder(
                                    tween: Tween<double>(begin: 0, end: 1),
                                    duration: Duration(milliseconds: 300 + (index * 50)),
                                    builder: (_, opacity, child) => Opacity(opacity: opacity, child: child),
                                    child: TemoinCardAdmin(
                                      temoin: temoin,
                                      onEdit: () => _showEditTemoinDialog(temoin),
                                      onDelete: () async {
                                        final confirm = await showDialog<bool>(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text('Confirmation'),
                                            content: Text(
                                              'Voulez-vous vraiment supprimer le témoignage de "${temoin.nomClient}" ?',
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(context, false),
                                                child: const Text('Annuler'),
                                              ),
                                              TextButton(
                                                onPressed: () => Navigator.pop(context, true),
                                                style: TextButton.styleFrom(foregroundColor: Colors.red),
                                                child: const Text('Supprimer'),
                                              ),
                                            ],
                                          ),
                                        );

                                        if (confirm == true && mounted) {
                                          final success = await ref.read(temoinProvider.notifier).deleteTemoin(temoin.id);
                                          if (success && mounted) {
                                            await _refreshTemoins();
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text('Témoignage supprimé avec succès'),
                                                backgroundColor: Colors.green,
                                              ),
                                            );
                                          }
                                        }
                                      },
                                      onRefresh: _refreshTemoins,
                                    ),
                                  );
                                },
                              ),
                            ),
                ],
              ),
            ),
            Positioned(
              bottom: 16,
              right: 16,
              child: Listener(
                onPointerDown: (_) => setState(() => _isFabPressed = true),
                onPointerUp: (_) => setState(() => _isFabPressed = false),
                onPointerCancel: (_) => setState(() => _isFabPressed = false),
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  onEnter: (_) => setState(() => _isFabHovered = true),
                  onExit: (_) => setState(() {
                    _isFabHovered = false;
                    _isFabPressed = false;
                  }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    child: isMobile
                        ? FloatingActionButton(
                            onPressed: _showAddTemoinDialog,
                            backgroundColor: (_isFabHovered || _isFabPressed) ? AppConstants.accent : Colors.black,
                            child: const Icon(Icons.add),
                          )
                        : FloatingActionButton.extended(
                            onPressed: _showAddTemoinDialog,
                            icon: const Icon(Icons.add),
                            label: const Text('Ajouter un témoignage'),
                            backgroundColor: (_isFabHovered || _isFabPressed) ? AppConstants.accent : Colors.black,
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

  Widget _buildSearchBar(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.grey.shade200, blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: isMobile
          ? TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Rechercher un témoignage...',
                prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                filled: true,
                fillColor: Colors.grey.shade100,
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: Colors.grey.shade600),
                        onPressed: () => setState(() => _searchQuery = ''),
                      )
                    : null,
              ),
            )
          : Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (value) => setState(() => _searchQuery = value),
                    decoration: InputDecoration(
                      hintText: 'Rechercher par nom, modèle ou titre...',
                      prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear, color: Colors.grey.shade600),
                              onPressed: () => setState(() => _searchQuery = ''),
                            )
                          : null,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Listener(
                  onPointerDown: (_) => setState(() => _isRefreshButtonPressed = true),
                  onPointerUp: (_) => setState(() => _isRefreshButtonPressed = false),
                  onPointerCancel: (_) => setState(() => _isRefreshButtonPressed = false),
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    onEnter: (_) => setState(() => _isRefreshButtonHovered = true),
                    onExit: (_) => setState(() {
                      _isRefreshButtonHovered = false;
                      _isRefreshButtonPressed = false;
                    }),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      child: ElevatedButton.icon(
                        onPressed: _refreshTemoins,
                        icon: const Icon(Icons.refresh, size: 18),
                        label: const Text('Actualiser'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: (_isRefreshButtonHovered || _isRefreshButtonPressed) ? AppConstants.accent : Colors.black,
                          foregroundColor: Colors.white,
                          elevation: (_isRefreshButtonHovered || _isRefreshButtonPressed) ? 4 : 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildEmptyState(bool isMobile) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.reviews_outlined, size: isMobile ? 60 : 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'Aucun témoignage',
            style: TextStyle(fontSize: isMobile ? 16 : 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text('Aucun témoignage trouvé', style: TextStyle(color: Colors.grey.shade500)),
          const SizedBox(height: 16),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            onEnter: (_) => setState(() => _isFabHovered = true),
            onExit: (_) => setState(() => _isFabHovered = false),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: isMobile
                  ? FloatingActionButton(
                      onPressed: _showAddTemoinDialog,
                      backgroundColor: _isFabHovered ? AppConstants.accent : Colors.black,
                      child: const Icon(Icons.add),
                    )
                  : FloatingActionButton.extended(
                      onPressed: _showAddTemoinDialog,
                      icon: const Icon(Icons.add),
                      label: const Text('Ajouter un témoignage'),
                      backgroundColor: _isFabHovered ? AppConstants.accent : Colors.black,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
