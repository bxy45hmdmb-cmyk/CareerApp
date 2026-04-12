import 'package:flutter/material.dart';
import '../core/api_service.dart';
import '../core/lang_controller.dart';
import '../theme/app_theme.dart';
import 'test_result_screen.dart';
import 'test_history_screen.dart';

class CareerTestScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  const CareerTestScreen({super.key, required this.onToggleTheme});

  @override
  State<CareerTestScreen> createState() => _CareerTestScreenState();
}

class _CareerTestScreenState extends State<CareerTestScreen>
    with TickerProviderStateMixin {
  final _api = ApiService();

  List<dynamic> _questions = [];
  final Map<int, int> _answers = {}; // questionId → selectedIndex
  int _currentIdx = 0;
  bool _loading = true;
  bool _submitting = false;
  bool _testStarted = false;
  bool _hasHistory = false;
  String? _error;

  late AnimationController _cardCtrl;
  late Animation<Offset> _slideAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _cardCtrl = AnimationController(
        duration: const Duration(milliseconds: 350), vsync: this);
    _slideAnim = Tween<Offset>(
            begin: const Offset(0.25, 0), end: Offset.zero)
        .animate(CurvedAnimation(parent: _cardCtrl, curve: Curves.easeOutCubic));
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(_cardCtrl);
    _loadQuestions();
    LangController.instance.addListener(_onLangChanged);
  }

  void _onLangChanged() {
    setState(() {
      _answers.clear();
      _currentIdx = 0;
      _testStarted = false;
    });
    _loadQuestions();
  }

  @override
  void dispose() {
    LangController.instance.removeListener(_onLangChanged);
    _cardCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadQuestions() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        _api.getQuestions(),
        _api.getMyResults().catchError((_) => <dynamic>[]),
      ]);
      if (!mounted) return;
      setState(() {
        _questions = results[0] as List<dynamic>;
        _hasHistory = (results[1] as List<dynamic>).isNotEmpty;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = LangScope.s(context).questionLoadFailed;
        _loading = false;
      });
    }
  }

  void _selectAnswer(int optionIdx) async {
    final qId = _questions[_currentIdx]['id'] as int;
    setState(() => _answers[qId] = optionIdx);

    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;

    if (_currentIdx < _questions.length - 1) {
      _cardCtrl.reset();
      setState(() => _currentIdx++);
      _cardCtrl.forward();
    } else {
      _submitTest();
    }
  }

  Future<void> _submitTest() async {
    setState(() => _submitting = true);
    try {
      final answersList = _answers.entries
          .map((e) => {
                'question_id': e.key,
                'selected_option_index': e.value,
              })
          .toList();

      final result = await _api.submitTest(answersList);
      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => TestResultScreen(result: result),
        ),
      ).then((_) {
        // Reset test when user comes back
        setState(() {
          _answers.clear();
          _currentIdx = 0;
          _testStarted = false;
        });
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: AppTheme.accentColor),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(LangScope.s(context).testSubmitFailed),
          backgroundColor: AppTheme.accentColor,
        ),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_error!),
              const SizedBox(height: 16),
              ElevatedButton(
                  onPressed: _loadQuestions, child: Text(LangScope.s(context).retry)),
            ],
          ),
        ),
      );
    }
    if (!_testStarted) return _buildIntro();
    return _buildTest();
  }

  Widget _buildIntro() {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(LangScope.s(context).testIntroTitle,
                  style: Theme.of(context).textTheme.displayMedium),
              const SizedBox(height: 16),
              Text(
                LangScope.s(context).testIntroDesc,
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(height: 1.6),
              ),
              const SizedBox(height: 32),
              _infoTile('📝', LangScope.s(context).questionCountLabel, LangScope.s(context).questionCountValue(_questions.length)),
              const SizedBox(height: 12),
              _infoTile('⏱️', LangScope.s(context).estimatedTimeLabel, '5-10 мин'),
              const SizedBox(height: 12),
              _infoTile('🎯', LangScope.s(context).resultLabel, LangScope.s(context).resultDesc),
              const Spacer(),
              if (_hasHistory)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const TestHistoryScreen(),
                        ),
                      ),
                      icon: const Icon(Icons.history_rounded),
                      label: Text(LangScope.s(context).testHistoryBtn),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.primaryColor,
                        side: const BorderSide(color: AppTheme.primaryColor),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                ),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _testStarted = true;
                      _currentIdx = 0;
                      _answers.clear();
                    });
                    _cardCtrl.forward();
                  },
                  child: Text('${LangScope.s(context).startTest} 🚀'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoTile(String emoji, String title, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)
        ],
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.bodySmall),
              Text(value,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTest() {
    if (_submitting) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(LangScope.s(context).computing),
            ],
          ),
        ),
      );
    }

    final q = _questions[_currentIdx];
    final progress = (_currentIdx + 1) / _questions.length;
    final options = (q['options'] as List<dynamic>).cast<String>();
    final selectedIdx = _answers[q['id'] as int];

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Header
              Row(
                children: [
                  if (_currentIdx > 0)
                    IconButton(
                      onPressed: () {
                        _cardCtrl.reset();
                        setState(() => _currentIdx--);
                        _cardCtrl.forward();
                      },
                      icon: const Icon(Icons.arrow_back_ios_rounded),
                      padding: EdgeInsets.zero,
                    )
                  else
                    const SizedBox(width: 40),
                  Expanded(
                    child: Text(
                      LangScope.s(context).questionCounter(_currentIdx + 1, _questions.length),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      q['category'] ?? '',
                      style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: AppTheme.primaryColor.withOpacity(0.15),
                  valueColor: const AlwaysStoppedAnimation(AppTheme.primaryColor),
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: SlideTransition(
                  position: _slideAnim,
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          // Question card
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  AppTheme.primaryColor,
                                  AppTheme.primaryLight
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              q['text'] ?? '',
                              style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  height: 1.4),
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Options
                          ...List.generate(
                            options.length,
                            (i) => _optionBtn(options[i], i, selectedIdx),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _optionBtn(String text, int idx, int? selected) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSel = selected == idx;

    return GestureDetector(
      onTap: () => _selectAnswer(idx),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSel
              ? AppTheme.primaryColor
              : isDark
                  ? const Color(0xFF1A1A2E)
                  : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSel
                ? AppTheme.primaryColor
                : AppTheme.primaryColor.withOpacity(0.2),
            width: isSel ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSel
                  ? AppTheme.primaryColor.withOpacity(0.3)
                  : Colors.black.withOpacity(0.04),
              blurRadius: isSel ? 12 : 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: isSel ? Colors.white : null,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}