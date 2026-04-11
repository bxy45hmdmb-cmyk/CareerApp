import 'package:flutter/material.dart';
import '../core/api_service.dart';
import '../theme/app_theme.dart';
import 'test_result_screen.dart';

class TestHistoryScreen extends StatefulWidget {
  const TestHistoryScreen({super.key});

  @override
  State<TestHistoryScreen> createState() => _TestHistoryScreenState();
}

class _TestHistoryScreenState extends State<TestHistoryScreen> {
  final _api = ApiService();
  List<dynamic> _results = [];
  bool _loading = true;
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
      final results = await _api.getMyResults();
      if (!mounted) return;
      setState(() {
        _results = results;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Тарихты жүктеу сәтсіз аяқталды';
        _loading = false;
      });
    }
  }

  String _formatDate(dynamic dt) {
    if (dt == null) return '';
    try {
      final d = DateTime.parse(dt.toString()).toLocal();
      final months = [
        '', 'қаң', 'ақп', 'нау', 'сәу', 'мам', 'мау',
        'шіл', 'там', 'қыр', 'қаз', 'қар', 'жел'
      ];
      return '${d.day} ${months[d.month]} ${d.year}, ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return dt.toString();
    }
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 24, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text('Тест тарихы',
                      style: Theme.of(context).textTheme.headlineSmall),
                ],
              ),
            ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? _buildError()
                      : _results.isEmpty
                          ? _buildEmpty()
                          : RefreshIndicator(
                              onRefresh: _load,
                              child: ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: _results.length,
                                itemBuilder: (_, i) =>
                                    _buildCard(_results[i], isDark, i),
                              ),
                            ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48, color: AppTheme.accentColor),
          const SizedBox(height: 12),
          Text(_error!),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _load, child: const Text('Қайталау')),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('📋', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          Text('Тест тарихы жоқ',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text('Алдымен тест тапсырыңыз',
              style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildCard(Map<String, dynamic> result, bool isDark, int index) {
    final recs = (result['recommendations'] as List<dynamic>?) ?? [];
    final topRec = recs.isNotEmpty ? recs[0] : null;
    final topProf = topRec?['profession'] as Map<String, dynamic>?;
    final scores = (result['category_scores'] as Map<String, dynamic>?) ?? {};
    final topCategory = scores.isNotEmpty
        ? (scores.entries.toList()
              ..sort((a, b) =>
                  (b.value as num).compareTo(a.value as num)))
            .first
            .key
        : null;

    final colorHex =
        (topProf?['color_hex'] as String?)?.replaceAll('#', '0xFF') ??
            '0xFF2E7D32';
    final color = Color(int.parse(colorHex));
    final matchPct = topRec != null
        ? (topRec['match_percentage'] as num).toInt()
        : 0;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => TestResultScreen(result: result),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: attempt number + date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${index + 1}-тест',
                    style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w700),
                  ),
                ),
                Text(
                  _formatDate(result['completed_at']),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Top profession
            if (topProf != null) ...[
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(topProf['icon_emoji'] ?? '💼',
                          style: const TextStyle(fontSize: 22)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          topProf['title'] ?? '',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        Text(
                          'Ең сай мамандық',
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
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$matchPct%',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: color),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
            // Category bars (top 3)
            if (topCategory != null) ...[
              const Divider(height: 1),
              const SizedBox(height: 10),
              ...((scores.entries.toList()
                        ..sort((a, b) =>
                            (b.value as num).compareTo(a.value as num)))
                      .take(3)
                      .map((e) {
                    final barColor = _categoryColor(e.key);
                    final val = (e.value as num).toDouble();
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 90,
                            child: Text(
                              _categoryLabel(e.key),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(fontWeight: FontWeight.w500),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: val / 100,
                                backgroundColor:
                                    barColor.withOpacity(0.15),
                                valueColor:
                                    AlwaysStoppedAnimation(barColor),
                                minHeight: 6,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${val.toInt()}%',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: barColor),
                          ),
                        ],
                      ),
                    );
                  })),
            ],
            // Footer
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${result['total_questions'] ?? 0} сұраққа жауап берілді',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Row(
                  children: [
                    Text('Толығырақ',
                        style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_forward_ios,
                        size: 11, color: AppTheme.primaryColor),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
