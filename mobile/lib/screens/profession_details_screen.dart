import 'package:flutter/material.dart';
import '../core/api_service.dart';
import '../theme/app_theme.dart';

class ProfessionDetailsScreen extends StatefulWidget {
  final String slug;
  const ProfessionDetailsScreen({super.key, required this.slug});

  @override
  State<ProfessionDetailsScreen> createState() =>
      _ProfessionDetailsScreenState();
}

class _ProfessionDetailsScreenState extends State<ProfessionDetailsScreen> {
  final _api = ApiService();
  Map<String, dynamic>? _profession;
  List<dynamic> _universities = [];
  bool _loading = true;
  bool _isFavorite = false;
  bool _favLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final prof = await _api.getProfessionBySlug(widget.slug);
      final unis = await _api.getUniversitiesByProfession(
          prof['category_key'] ?? '');
      final isFav = await _api.checkFavorite(prof['id'] as int);
      if (!mounted) return;
      setState(() {
        _profession = prof;
        _universities = unis;
        _isFavorite = isFav;
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

  Future<void> _toggleFavorite() async {
    if (_profession == null) return;
    setState(() => _favLoading = true);
    try {
      final id = _profession!['id'] as int;
      if (_isFavorite) {
        await _api.removeFavorite(id);
        setState(() => _isFavorite = false);
        _snack('Таңдаулылардан жойылды', AppTheme.accentColor);
      } else {
        await _api.addFavorite(id);
        setState(() => _isFavorite = true);
        _snack('Таңдаулыларға қосылды ⭐', AppTheme.successColor);
      }
    } catch (e) {
      _snack('Сақтау сәтсіз аяқталды', AppTheme.accentColor);
    } finally {
      if (mounted) setState(() => _favLoading = false);
    }
  }

  void _snack(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_error != null || _profession == null) {
      return Scaffold(
        appBar: AppBar(leading: const BackButton()),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_error ?? 'Мамандық табылмады'),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _load, child: const Text('Қайталау')),
            ],
          ),
        ),
      );
    }

    final p = _profession!;
    final colorHex =
        (p['color_hex'] as String?)?.replaceAll('#', '0xFF') ?? '0xFF2E7D32';
    final color = Color(int.parse(colorHex));

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _sliverAppBar(p, color),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info cards row
                  _infoCards(p, color),
                  const SizedBox(height: 24),

                  // Favorite button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: _favLoading
                        ? const Center(child: CircularProgressIndicator())
                        : OutlinedButton.icon(
                            onPressed: _toggleFavorite,
                            icon: Icon(
                              _isFavorite
                                  ? Icons.bookmark
                                  : Icons.bookmark_border,
                              color: _isFavorite
                                  ? AppTheme.warningColor
                                  : AppTheme.primaryColor,
                            ),
                            label: Text(
                              _isFavorite
                                  ? 'Таңдаулылардан жою'
                                  : 'Таңдаулыларға қосу',
                              style: TextStyle(
                                color: _isFavorite
                                    ? AppTheme.warningColor
                                    : AppTheme.primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: _isFavorite
                                    ? AppTheme.warningColor
                                    : AppTheme.primaryColor,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                  ),
                  const SizedBox(height: 24),

                  // Description
                  _sectionTitle('📋 Сипаттама'),
                  const SizedBox(height: 10),
                  Text(p['description'] ?? '',
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(height: 1.6)),
                  const SizedBox(height: 24),

                  // Skills
                  _sectionTitle('💪 Қажетті дағдылар'),
                  const SizedBox(height: 12),
                  _skillChips(p['required_skills'], color),
                  const SizedBox(height: 24),

                  // Opportunities
                  if ((p['future_opportunities'] as List?)?.isNotEmpty ==
                      true) ...[
                    _sectionTitle('🌟 Болашақ мүмкіндіктері'),
                    const SizedBox(height: 12),
                    ...(p['future_opportunities'] as List).map((opp) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(top: 6),
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                    color: color, shape: BoxShape.circle),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(opp.toString(),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.copyWith(height: 1.4)),
                              ),
                            ],
                          ),
                        )),
                    const SizedBox(height: 24),
                  ],

                  // Universities
                  _sectionTitle(
                      '🏛️ Қазақстандағы университеттер (${_universities.length})'),
                  const SizedBox(height: 12),
                  _universities.isEmpty
                      ? Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                              'Бұл мамандық бойынша университет деректері жоқ'),
                        )
                      : Column(
                          children: _universities
                              .map((u) => _universityCard(u))
                              .toList(),
                        ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sliverAppBar(Map<String, dynamic> p, Color color) {
    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      backgroundColor: color,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color, color.withOpacity(0.7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(p['icon_emoji'] ?? '💼',
                      style: const TextStyle(fontSize: 52)),
                  const SizedBox(height: 6),
                  Text(p['title'] ?? '',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w800)),
                  Text(p['category'] ?? '',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 15)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoCards(Map<String, dynamic> p, Color color) {
    final salaryMin = p['salary_min'];
    final salaryMax = p['salary_max'];
    final salaryStr = salaryMin != null && salaryMax != null
        ? '${_fmt(salaryMin)}–${_fmt(salaryMax)} ₸'
        : 'Жоқ деректер';

    final demandLabels = {
      'very_high': 'Өте жоғары',
      'high': 'Жоғары',
      'medium': 'Орташа',
      'low': 'Төмен',
    };

    return Row(
      children: [
        Expanded(
          child: _infoTile('💰', 'Жалақы', salaryStr, AppTheme.successColor),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _infoTile(
            '📈',
            'Сұраныс',
            demandLabels[p['demand_level']] ?? p['demand_level'] ?? '',
            color,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _infoTile(
            '🚀',
            'Өсім',
            p['growth_rate'] ?? '—',
            AppTheme.warningColor,
          ),
        ),
      ],
    );
  }

  Widget _infoTile(String emoji, String label, String value, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)
        ],
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 4),
          Text(label,
              style:
                  Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11),
              textAlign: TextAlign.center),
          const SizedBox(height: 2),
          Text(value,
              style: TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w700, color: color),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(title, style: Theme.of(context).textTheme.headlineSmall);
  }

  Widget _skillChips(List? skills, Color color) {
    if (skills == null || skills.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: skills.map((skill) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Text(skill.toString(),
              style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 13)),
        );
      }).toList(),
    );
  }

  Widget _universityCard(Map<String, dynamic> uni) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isNational = uni['is_national'] == true;
    final rating = uni['rating'] as int? ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: isNational
            ? Border.all(
                color: AppTheme.warningColor.withOpacity(0.4), width: 1.5)
            : null,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isNational) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.warningColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          '🏆 Ұлттық университет',
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.warningColor),
                        ),
                      ),
                      const SizedBox(height: 6),
                    ],
                    Text(uni['name'] ?? '',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined,
                            size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(uni['city'] ?? '',
                            style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Row(
                    children: List.generate(
                      5,
                      (i) => Icon(
                        i < rating ? Icons.star_rounded : Icons.star_outline_rounded,
                        color: AppTheme.warningColor,
                        size: 14,
                      ),
                    ),
                  ),
                  if (uni['short_name'] != null)
                    Text(uni['short_name'],
                        style: const TextStyle(
                            fontSize: 11, fontWeight: FontWeight.w600,
                            color: AppTheme.primaryColor)),
                ],
              ),
            ],
          ),
          if (uni['description'] != null) ...[
            const SizedBox(height: 8),
            Text(uni['description'],
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(height: 1.4)),
          ],
          if (uni['website'] != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.language, size: 14,
                    color: AppTheme.primaryColor),
                const SizedBox(width: 4),
                Text(uni['website'],
                    style: const TextStyle(
                        color: AppTheme.primaryColor,
                        fontSize: 12,
                        decoration: TextDecoration.underline)),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _fmt(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}М';
    if (n >= 1000) return '${(n / 1000).toInt()}К';
    return n.toString();
  }
}