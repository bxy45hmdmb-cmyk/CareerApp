import 'package:flutter/material.dart';
import '../core/api_service.dart';
import '../core/lang_controller.dart';
import '../theme/app_theme.dart';
import 'profession_details_screen.dart';

class FavoritesScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  const FavoritesScreen({super.key, required this.onToggleTheme});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final _api = ApiService();
  List<dynamic> _favorites = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
    LangController.instance.addListener(_onLangChanged);
  }

  void _onLangChanged() => _load();

  @override
  void dispose() {
    LangController.instance.removeListener(_onLangChanged);
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final favs = await _api.getFavorites();
      if (!mounted) return;
      setState(() {
        _favorites = favs;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Деректерді жүктеу сәтсіз';
        _loading = false;
      });
    }
  }

  Future<void> _remove(int profId) async {
    try {
      await _api.removeFavorite(profId);
      setState(() {
        _favorites.removeWhere((f) => f['profession_id'] == profId);
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Таңдаулылардан жойылды'),
          backgroundColor: AppTheme.accentColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Жою сәтсіз аяқталды')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _load,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                  child: Text('⭐ Таңдаулылар',
                      style: Theme.of(context).textTheme.displaySmall),
                ),
              ),
              if (_loading)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_error != null)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_error!),
                        const SizedBox(height: 16),
                        ElevatedButton(
                            onPressed: _load, child: const Text('Қайталау')),
                      ],
                    ),
                  ),
                )
              else if (_favorites.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🔖', style: TextStyle(fontSize: 64)),
                        const SizedBox(height: 16),
                        Text(
                          'Таңдаулы мамандықтар жоқ',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Мамандық бетінен «Таңдаулыларға қосу» батырмасын басыңыз',
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) {
                        final fav = _favorites[i];
                        final prof = fav['profession'] as Map<String, dynamic>;
                        final colorHex = (prof['color_hex'] as String?)
                                ?.replaceAll('#', '0xFF') ??
                            '0xFF2E7D32';
                        final color = Color(int.parse(colorHex));
                        final isDark =
                            Theme.of(context).brightness == Brightness.dark;

                        return Dismissible(
                          key: Key('fav_${fav['profession_id']}'),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: AppTheme.accentColor,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            child: const Icon(Icons.delete_outline,
                                color: Colors.white, size: 28),
                          ),
                          onDismissed: (_) =>
                              _remove(fav['profession_id'] as int),
                          child: GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ProfessionDetailsScreen(
                                    slug: prof['slug']),
                              ),
                            ).then((_) => _load()),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF1A1A2E)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black.withOpacity(0.04),
                                      blurRadius: 8)
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 52,
                                    height: 52,
                                    decoration: BoxDecoration(
                                      color: color.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Center(
                                      child: Text(
                                          prof['icon_emoji'] ?? '💼',
                                          style: const TextStyle(fontSize: 24)),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(prof['title'] ?? '',
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleLarge
                                                ?.copyWith(
                                                    fontWeight:
                                                        FontWeight.w700)),
                                        const SizedBox(height: 4),
                                        Text(prof['category'] ?? '',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(color: color)),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.bookmark,
                                        color: AppTheme.warningColor),
                                    onPressed: () =>
                                        _remove(fav['profession_id'] as int),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      childCount: _favorites.length,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}