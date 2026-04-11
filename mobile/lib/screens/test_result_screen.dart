import 'package:flutter/material.dart';
import '../core/api_service.dart';
import '../theme/app_theme.dart';
import 'profession_details_screen.dart';

class TestResultScreen extends StatefulWidget {
  final Map<String, dynamic> result;
  const TestResultScreen({super.key, required this.result});

  @override
  State<TestResultScreen> createState() => _TestResultScreenState();
}

class _TestResultScreenState extends State<TestResultScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  final _api = ApiService();
  List<dynamic> _universities = [];

  List<dynamic> get _recommendations =>
      (widget.result['recommendations'] as List<dynamic>?) ?? [];

  Map<String, dynamic> get _scores =>
      (widget.result['category_scores'] as Map<String, dynamic>?) ?? {};

  String? get _topCategoryKey {
    if (_scores.isEmpty) return null;
    return (_scores.entries.toList()
          ..sort((a, b) => (b.value as num).compareTo(a.value as num)))
        .first
        .key;
  }

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        duration: const Duration(milliseconds: 800), vsync: this);
    _scaleAnim = Tween<double>(begin: 0.5, end: 1).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut),
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
          parent: _ctrl, curve: const Interval(0.3, 1, curve: Curves.easeIn)),
    );
    _ctrl.forward();
    _loadUniversities();
  }

  Future<void> _loadUniversities() async {
    final catKey = _topCategoryKey;
    if (catKey == null) return;
    try {
      final unis = await _api.getUniversitiesByProfession(catKey);
      if (!mounted) return;
      setState(() => _universities = unis);
    } catch (_) {}
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  String _categoryLabel(String key) {
    const map = {
      'technology': 'Технология',
      'engineering': 'Инженерия',
      'medicine': 'Медицина',
      'art': 'Өнер / Дизайн',
      'law': 'Заң',
      'business': 'Бизнес',
    };
    return map[key] ?? key;
  }

  Color _categoryColor(String key) {
    const map = {
      'technology': AppTheme.primaryColor,
      'engineering': AppTheme.warningColor,
      'medicine': AppTheme.secondaryColor,
      'art': AppTheme.accentColor,
      'law': AppTheme.successColor,
      'business': Color(0xFF9C27B0),
    };
    return map[key] ?? AppTheme.primaryColor;
  }

  @override
  Widget build(BuildContext context) {
    final topRec = _recommendations.isNotEmpty ? _recommendations[0] : null;
    final topProf = topRec?['profession'];

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Back button bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 24, 0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_rounded),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text('Тест нәтижесі',
                        style: Theme.of(context).textTheme.headlineSmall),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    _buildTrophy(),
                    const SizedBox(height: 24),
                    if (topProf != null) _buildTopCard(topProf, topRec),
                    const SizedBox(height: 24),
                    _buildScores(),
                    const SizedBox(height: 24),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('🎯 Ұсынылған мамандықтар (${_recommendations.length})',
                          style: Theme.of(context).textTheme.headlineSmall),
                    ),
                    const SizedBox(height: 16),
                    if (_universities.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      _buildUniversities(),
                      const SizedBox(height: 16),
                    ],
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) {
                    final rec = _recommendations[i];
                    final prof = rec['profession'];
                    final colorHex = (prof['color_hex'] as String?)
                            ?.replaceAll('#', '0xFF') ??
                        '0xFF2E7D32';
                    final color = Color(int.parse(colorHex));
                    final match =
                        (rec['match_percentage'] as num).toDouble();
                    return GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ProfessionDetailsScreen(slug: prof['slug']),
                        ),
                      ),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness ==
                                  Brightness.dark
                              ? const Color(0xFF1A1A2E)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 3))
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(prof['icon_emoji'] ?? '💼',
                                    style: const TextStyle(fontSize: 22)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(prof['title'] ?? '',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                              fontWeight: FontWeight.w700)),
                                  Text(
                                    '${rec['rank']}-орын • ${prof['category']}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(color: color),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${match.toInt()}%',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: color),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Icon(Icons.arrow_forward_ios,
                                size: 13, color: color),
                          ],
                        ),
                      ),
                    );
                  },
                  childCount: _recommendations.length,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }

  Widget _buildTrophy() {
    return ScaleTransition(
      scale: _scaleAnim,
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [AppTheme.primaryColor, AppTheme.primaryLight]),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8))
              ],
            ),
            child: const Center(
                child: Text('🏆', style: TextStyle(fontSize: 48))),
          ),
          const SizedBox(height: 16),
          Text('Тест аяқталды!',
              style: Theme.of(context).textTheme.displaySmall),
          Text('Нәтижелеріңді қарап шық',
              style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildTopCard(Map<String, dynamic> prof, dynamic rec) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppTheme.primaryColor, AppTheme.primaryLight],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Text(prof['icon_emoji'] ?? '💼',
                style: const TextStyle(fontSize: 40)),
            const SizedBox(height: 8),
            const Text('🎯 Саған ең сай мамандық',
                style: TextStyle(color: Colors.white, fontSize: 13)),
            const SizedBox(height: 6),
            Text(
              prof['title'] ?? '',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${(rec['match_percentage'] as num).toInt()}% сәйкестік',
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUniversities() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return FadeTransition(
      opacity: _fadeAnim,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('🏛️ Ұсынылған университеттер',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.05), blurRadius: 10)
              ],
            ),
            child: Column(
              children: List.generate(_universities.length > 5 ? 5 : _universities.length, (i) {
                final uni = _universities[i] as Map<String, dynamic>;
                final rating = (uni['rating'] as int?) ?? 0;
                final isNational = uni['is_national'] == true;
                final isLast = i == (_universities.length > 5 ? 4 : _universities.length - 1);
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Center(
                              child: Text('🏛️',
                                  style: TextStyle(fontSize: 20)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        uni['short_name'] ?? uni['name'] ?? '',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall
                                            ?.copyWith(
                                                fontWeight: FontWeight.w700),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (isNational)
                                      Container(
                                        margin: const EdgeInsets.only(left: 6),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppTheme.successColor
                                              .withOpacity(0.15),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: const Text('Мемлекеттік',
                                            style: TextStyle(
                                                fontSize: 9,
                                                fontWeight: FontWeight.w600,
                                                color: AppTheme.successColor)),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '📍 ${uni['city'] ?? ''}',
                                  style:
                                      Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: List.generate(
                              5,
                              (s) => Icon(
                                s < rating
                                    ? Icons.star_rounded
                                    : Icons.star_outline_rounded,
                                size: 14,
                                color: s < rating
                                    ? AppTheme.warningColor
                                    : Colors.grey.withOpacity(0.3),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!isLast)
                      Divider(
                          height: 1,
                          indent: 72,
                          color: Colors.grey.withOpacity(0.1)),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScores() {
    if (_scores.isEmpty) return const SizedBox.shrink();
    final sorted = _scores.entries.toList()
      ..sort((a, b) =>
          (b.value as num).compareTo(a.value as num));

    return FadeTransition(
      opacity: _fadeAnim,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF1A1A2E)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('📊 Категория нәтижелері',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            ...sorted.map((entry) {
              final label = _categoryLabel(entry.key);
              final val = (entry.value as num).toDouble();
              final color = _categoryColor(entry.key);
              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(label,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w500)),
                        Text('${val.toInt()}%',
                            style: TextStyle(
                                color: color, fontWeight: FontWeight.w700)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: val / 100,
                        backgroundColor: color.withOpacity(0.15),
                        valueColor: AlwaysStoppedAnimation(color),
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}