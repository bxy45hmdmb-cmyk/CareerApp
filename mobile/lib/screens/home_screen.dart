import 'package:flutter/material.dart';
import '../core/api_service.dart';
import '../core/lang_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/career_card.dart';
import '../widgets/progress_card.dart';
import 'career_test_screen.dart';
import 'profession_details_screen.dart';
import 'favorites_screen.dart';
import 'profile_screen.dart';
import 'test_result_screen.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  const HomeScreen({super.key, required this.onToggleTheme});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      _HomeTab(onToggleTheme: widget.onToggleTheme, onTabChange: _changeTab),
      CareerTestScreen(onToggleTheme: widget.onToggleTheme),
      FavoritesScreen(onToggleTheme: widget.onToggleTheme),
      ProfileScreen(onToggleTheme: widget.onToggleTheme),
    ];
  }

  void _changeTab(int i) => setState(() => _currentIndex = i);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, -4))
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navItem(0, Icons.home_rounded, LangScope.s(context).navHome),
                _navItem(1, Icons.quiz_rounded, LangScope.s(context).navTest),
                _navItem(2, Icons.bookmark_rounded, LangScope.s(context).navFavorites),
                _navItem(3, Icons.person_rounded, LangScope.s(context).navProfile),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData icon, String label) {
    final sel = _currentIndex == index;
    return GestureDetector(
      onTap: () => _changeTab(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: sel ? AppTheme.primaryColor.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                color: sel ? AppTheme.primaryColor : Colors.grey, size: 24),
            const SizedBox(height: 4),
            Text(label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: sel ? FontWeight.w700 : FontWeight.w400,
                  color: sel ? AppTheme.primaryColor : Colors.grey,
                )),
          ],
        ),
      ),
    );
  }
}

// ── Home Tab ─────────────────────────────────────────────────────────────────

class _HomeTab extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final ValueChanged<int> onTabChange;

  const _HomeTab(
      {required this.onToggleTheme, required this.onTabChange});

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  final _api = ApiService();

  Map<String, dynamic>? _user;
  Map<String, dynamic>? _progress;
  List<dynamic> _highDemand = [];
  List<dynamic> _recommendations = [];
  bool _loading = true;
  String? _error;

  final PageController _carouselCtrl = PageController(viewportFraction: 0.75);

  @override
  void initState() {
    super.initState();
    _loadData();
    LangController.instance.addListener(_onLangChanged);
  }

  void _onLangChanged() => _loadData();

  @override
  void dispose() {
    LangController.instance.removeListener(_onLangChanged);
    _carouselCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        _api.getMe(),
        _api.getProgress(),
        _api.getHighDemandProfessions(limit: 15),
        _api.getRecommendations().catchError((_) => <dynamic>[]),
      ]);
      if (!mounted) return;
      setState(() {
        _user = results[0] as Map<String, dynamic>;
        _progress = results[1] as Map<String, dynamic>;
        _highDemand = results[2] as List<dynamic>;
        _recommendations = results[3] as List<dynamic>;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = LangScope.s(context).dataLoadFailed;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                  child: _topBar(isDark),
                ),
              ),
              if (_error != null)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.accentColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline,
                              color: AppTheme.accentColor),
                          const SizedBox(width: 12),
                          Expanded(child: Text(_error!)),
                          TextButton(
                            onPressed: _loadData,
                            child: Text(LangScope.s(context).retry),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                  child: _welcomeCard(),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                  child: Text(LangScope.s(context).highDemand,
                      style: Theme.of(context).textTheme.headlineSmall),
                ),
              ),
              SliverToBoxAdapter(child: _carousel()),
              if (_progress != null) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                    child: Text(LangScope.s(context).progressSection,
                        style: Theme.of(context).textTheme.headlineSmall),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
                    child: _progressSection(),
                  ),
                ),
              ],
              if (_recommendations.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                    child: Text(LangScope.s(context).recommended,
                        style: Theme.of(context).textTheme.headlineSmall),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) {
                        final rec = _recommendations[i];
                        final prof = rec['profession'];
                        return _RecommendationCard(
                          profession: prof,
                          matchPct: (rec['match_percentage'] as num).toDouble(),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProfessionDetailsScreen(
                                slug: prof['slug'],
                              ),
                            ),
                          ),
                        );
                      },
                      childCount: _recommendations.length > 10
                          ? 10
                          : _recommendations.length,
                    ),
                  ),
                ),
              ] else ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: _testBanner(),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _topBar(bool isDark) {
    final s = LangScope.s(context);
    final name = _user?['full_name'] ?? (s.isKk ? 'Оқушы' : 'Ученик');
    final firstName = name.split(' ').first;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(s.greeting,
                style: Theme.of(context).textTheme.bodyMedium),
            Text(firstName,
                style: Theme.of(context).textTheme.headlineMedium),
          ],
        ),
        Row(
          children: [
            IconButton(
              onPressed: widget.onToggleTheme,
              icon: Icon(
                isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                color: isDark ? Colors.amber : const Color(0xFF6B7280),
              ),
            ),
            GestureDetector(
              onTap: () => widget.onTabChange(3),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [AppTheme.primaryColor, AppTheme.primaryLight]),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    firstName.isNotEmpty
                        ? firstName[0].toUpperCase()
                        : 'A',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 18),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _welcomeCard() {
    final s = LangScope.s(context);
    final grade = _user?['grade'] ?? 0;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryColor, AppTheme.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.findProfession,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Text(s.gradeStudent(grade as int),
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.85), fontSize: 13)),
                const SizedBox(height: 14),
                GestureDetector(
                  onTap: () => widget.onTabChange(1),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(s.takeTestBtn,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 13)),
                  ),
                ),
              ],
            ),
          ),
          const Text('🎓', style: TextStyle(fontSize: 64)),
        ],
      ),
    );
  }

  Widget _carousel() {
    if (_highDemand.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 180,
      child: PageView.builder(
        controller: _carouselCtrl,
        itemCount: _highDemand.length,
        itemBuilder: (_, i) {
          final prof = _highDemand[i];
          final color =
              Color(int.parse(prof['color_hex'].replaceAll('#', '0xFF')));
          return GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    ProfessionDetailsScreen(slug: prof['slug']),
              ),
            ),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(18),
                border:
                    Border.all(color: color.withOpacity(0.25)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(prof['icon_emoji'] ?? '💼',
                      style: const TextStyle(fontSize: 36)),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(prof['title'] ?? '',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: color)),
                      Text(prof['category'] ?? '',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: color.withOpacity(0.8))),
                      const SizedBox(height: 6),
                      _demandBadge(prof['demand_level'] ?? '', color),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _demandBadge(String level, Color color) {
    final s = LangScope.s(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        s.demandLevel(level),
        style: TextStyle(
            fontSize: 10, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }

  Widget _progressSection() {
    final s = LangScope.s(context);
    final p = _progress!;
    final testDone = p['test_completed'] == true;
    final testCount = p['test_count'] ?? 0;
    final favsCount = p['favorites_count'] ?? 0;

    return Column(
      children: [
        ProgressCard(
          title: s.testCompletion,
          subtitle: testDone ? s.testCount(testCount as int) : s.testNotDone,
          progress: testDone ? 1.0 : 0.0,
          color: AppTheme.primaryColor,
          emoji: '📝',
        ),
        const SizedBox(height: 12),
        ProgressCard(
          title: s.favoriteProfessions,
          subtitle: s.favSaved(favsCount as int),
          progress: favsCount > 0 ? (favsCount / 10).clamp(0.0, 1.0) : 0.0,
          color: AppTheme.successColor,
          emoji: '⭐',
        ),
      ],
    );
  }

  Widget _testBanner() {
    return GestureDetector(
      onTap: () => widget.onTabChange(1),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            const Text('🎯', style: TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(LangScope.s(context).takeTestBanner,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w700)),
                  Text(LangScope.s(context).takeTestBannerDesc,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: AppTheme.primaryColor)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios,
                size: 14, color: AppTheme.primaryColor),
          ],
        ),
      ),
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  final Map<String, dynamic> profession;
  final double matchPct;
  final VoidCallback onTap;

  const _RecommendationCard(
      {required this.profession,
      required this.matchPct,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorHex =
        (profession['color_hex'] as String?)?.replaceAll('#', '0xFF') ??
            '0xFF2E7D32';
    final color = Color(int.parse(colorHex));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF16213E) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4))
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
                child: Text(profession['icon_emoji'] ?? '💼',
                    style: const TextStyle(fontSize: 24)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(profession['title'] ?? '',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.w700)),
                  Text(profession['category'] ?? '',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: color)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${matchPct.toInt()}%',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: color),
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.arrow_forward_ios, size: 14, color: color),
          ],
        ),
      ),
    );
  }
}