import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../core/api_service.dart';
import '../core/lang_controller.dart';
import '../core/token_storage.dart';
import '../theme/app_theme.dart';
import '../widgets/progress_card.dart';
import 'onboarding_screen.dart';
import 'setting_screen.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  const ProfileScreen({super.key, required this.onToggleTheme});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _api = ApiService();
  final _storage = TokenStorage();

  Map<String, dynamic>? _user;
  Map<String, dynamic>? _progress;
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
      final results = await Future.wait([_api.getMe(), _api.getProgress()]);
      if (!mounted) return;
      setState(() {
        _user = results[0] as Map<String, dynamic>;
        _progress = results[1] as Map<String, dynamic>;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = LangScope.s(context).profileLoadFailed;
        _loading = false;
      });
    }
  }

  Future<void> _pickAndUploadAvatar() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    try {
      final updated = await _api.uploadAvatar(File(picked.path));
      if (!mounted) return;
      setState(() => _user = updated);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(LangScope.s(context).photoUpdated),
          backgroundColor: AppTheme.successColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${LangScope.s(context).uploadFailed}: $e')),
      );
    }
  }

  Future<void> _showChangePasswordDialog() async {
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    bool obscureCurrent = true;
    bool obscureNew = true;
    bool obscureConfirm = true;

    bool pwHasLength = false;
    bool pwHasUpper = false;
    bool pwHasDigit = false;
    bool pwHasSpecial = false;

    void checkPw(String v, StateSetter setS) {
      setS(() {
        pwHasLength = v.length >= 7;
        pwHasUpper = v.contains(RegExp(r'[A-Z]'));
        pwHasDigit = v.contains(RegExp(r'\d'));
        pwHasSpecial = v.contains(RegExp(r'[!@#$%^&*()\-_=+\[\]{};:",.<>/?`~\\|]'));
      });
    }

    final s = LangScope.s(context);
    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(s.changePassword),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: currentCtrl,
                  obscureText: obscureCurrent,
                  autocorrect: false,
                  enableSuggestions: false,
                  decoration: InputDecoration(
                    labelText: s.currentPassword,
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(obscureCurrent
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined),
                      onPressed: () => setS(() => obscureCurrent = !obscureCurrent),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: newCtrl,
                  obscureText: obscureNew,
                  autocorrect: false,
                  enableSuggestions: false,
                  onChanged: (v) => checkPw(v, setS),
                  decoration: InputDecoration(
                    labelText: s.newPassword,
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(obscureNew
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined),
                      onPressed: () => setS(() => obscureNew = !obscureNew),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Password hints
                Column(
                  children: [
                    _hintRow(pwHasLength, s.pwLength),
                    _hintRow(pwHasUpper, s.pwUpper),
                    _hintRow(pwHasDigit, s.pwDigit),
                    _hintRow(pwHasSpecial, s.pwSpecialShort),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: confirmCtrl,
                  obscureText: obscureConfirm,
                  autocorrect: false,
                  enableSuggestions: false,
                  decoration: InputDecoration(
                    labelText: s.confirmNewPassword,
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(obscureConfirm
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined),
                      onPressed: () => setS(() => obscureConfirm = !obscureConfirm),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(s.cancel),
            ),
            ElevatedButton(
              onPressed: () async {
                if (currentCtrl.text.isEmpty || newCtrl.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(s.fillAllFields)),
                  );
                  return;
                }
                if (newCtrl.text != confirmCtrl.text) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(s.passwordsDoNotMatch)),
                  );
                  return;
                }
                if (!(pwHasLength && pwHasUpper && pwHasDigit && pwHasSpecial)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(s.passwordRequirementsNotMet)),
                  );
                  return;
                }
                Navigator.pop(ctx);
                try {
                  await _api.changePassword(
                    currentPassword: currentCtrl.text,
                    newPassword: newCtrl.text,
                  );
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(LangScope.s(context).passwordChanged),
                      backgroundColor: AppTheme.successColor,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                } on ApiException catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.message)),
                  );
                }
              },
              child: Text(s.save),
            ),
          ],
        ),
      ),
    );
  }

  Widget _hintRow(bool ok, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Row(
        children: [
          Icon(
            ok ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 14,
            color: ok ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 6),
          Text(text,
              style: TextStyle(fontSize: 11, color: ok ? Colors.green : Colors.grey)),
        ],
      ),
    );
  }

  Future<void> _showEditDialog() async {
    if (_user == null) return;
    final nameCtrl = TextEditingController(text: _user!['full_name']);
    final schoolCtrl = TextEditingController(text: _user!['school'] ?? '');
    final cityCtrl = TextEditingController(text: _user!['city'] ?? '');
    int grade = _user!['grade'] as int;

    final s = LangScope.s(context);
    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(s.editProfile),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                      labelText: s.fullName, prefixIcon: const Icon(Icons.person)),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: schoolCtrl,
                  decoration: InputDecoration(
                      labelText: s.schoolLabel, prefixIcon: const Icon(Icons.school)),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: cityCtrl,
                  decoration: InputDecoration(
                      labelText: s.cityLabel, prefixIcon: const Icon(Icons.location_city)),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(s.gradeField,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [7, 8, 9, 10, 11].map((g) {
                    final sel = grade == g;
                    return GestureDetector(
                      onTap: () => setS(() => grade = g),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(right: 8),
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: sel
                              ? AppTheme.primaryColor
                              : AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text('$g',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: sel
                                    ? Colors.white
                                    : AppTheme.primaryColor,
                              )),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(s.cancel),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                try {
                  final updated = await _api.updateMe({
                    'full_name': nameCtrl.text.trim(),
                    'grade': grade,
                    if (schoolCtrl.text.trim().isNotEmpty)
                      'school': schoolCtrl.text.trim(),
                    if (cityCtrl.text.trim().isNotEmpty)
                      'city': cityCtrl.text.trim(),
                  });
                  if (!mounted) return;
                  setState(() => _user = updated);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(LangScope.s(context).profileUpdated),
                      backgroundColor: AppTheme.successColor,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${LangScope.s(context).saveFailed}: $e')),
                  );
                }
              },
              child: Text(s.save),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_error != null || _user == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_error ?? LangScope.s(context).noData),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _load, child: Text(LangScope.s(context).retry)),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _load,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _header()),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _profileCard(),
                      const SizedBox(height: 24),
                      Text(LangScope.s(context).progressSection,
                          style: Theme.of(context).textTheme.headlineSmall),
                      const SizedBox(height: 12),
                      _progressSection(),
                      const SizedBox(height: 24),
                      Text('⚙️ ${LangScope.s(context).settings}',
                          style: Theme.of(context).textTheme.headlineSmall),
                      const SizedBox(height: 12),
                      _settingsCard(),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header() {
    final name = _user!['full_name'] ?? 'Оқушы';
    final grade = _user!['grade'];
    final avatarUrl = _user!['avatar_url'];
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryColor, AppTheme.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(LangScope.s(context).myProfile,
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(color: Colors.white)),
              Row(
                children: [
                  IconButton(
                    onPressed: widget.onToggleTheme,
                    icon: Icon(
                      isDark
                          ? Icons.light_mode_rounded
                          : Icons.dark_mode_rounded,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SettingsScreen(
                          onToggleTheme: widget.onToggleTheme,
                          onLogout: _logout,
                        ),
                      ),
                    ),
                    icon: const Icon(Icons.settings, color: Colors.white),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              GestureDetector(
                onTap: _pickAndUploadAvatar,
                child: Stack(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        color: Colors.white.withOpacity(0.2),
                      ),
                      child: avatarUrl != null
                          ? ClipOval(
                              child: Image.network(
                                '${ApiService.baseUrl.replaceAll('/api/v1', '')}$avatarUrl',
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Center(
                                  child: Text(
                                    name[0].toUpperCase(),
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 30,
                                        fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ),
                            )
                          : Center(
                              child: Text(
                                name.isNotEmpty ? name[0].toUpperCase() : 'A',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 30,
                                    fontWeight: FontWeight.w700),
                              ),
                            ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt,
                            size: 13, color: AppTheme.primaryColor),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(LangScope.s(context).gradeLabel(grade as int),
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: 14)),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _showEditDialog,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(LangScope.s(context).edit,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _profileCard() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
        ],
      ),
      child: Column(
        children: [
          _profileRow('📧', LangScope.s(context).emailLabel, _user!['email'] ?? ''),
          const Divider(height: 24),
          _profileRow('🏫', LangScope.s(context).schoolLabel, _user!['school'] ?? LangScope.s(context).notFilled),
          const Divider(height: 24),
          _profileRow('🏙️', LangScope.s(context).cityLabel, _user!['city'] ?? LangScope.s(context).notFilled),
          const Divider(height: 24),
          _profileRow('📅', LangScope.s(context).registrationDate, _formatDate(_user!['created_at'])),
        ],
      ),
    );
  }

  Widget _profileRow(String emoji, String label, String value) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodySmall),
            Text(value, style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ],
    );
  }

  Widget _progressSection() {
    final s = LangScope.s(context);
    final p = _progress!;
    return Column(
      children: [
        ProgressCard(
          title: s.testCompletion,
          subtitle: p['test_completed'] == true
              ? s.testCount((p['test_count'] as int?) ?? 0)
              : s.testNotDone,
          progress: p['test_completed'] == true ? 1.0 : 0.0,
          color: AppTheme.primaryColor,
          emoji: '📝',
        ),
        const SizedBox(height: 12),
        ProgressCard(
          title: s.favoriteProfessions,
          subtitle: s.favCount((p['favorites_count'] as int?) ?? 0),
          progress: ((p['favorites_count'] ?? 0) as int) > 0
              ? ((p['favorites_count'] as int) / 10).clamp(0.0, 1.0)
              : 0.0,
          color: AppTheme.successColor,
          emoji: '⭐',
        ),
      ],
    );
  }

  Widget _settingsCard() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final s = LangScope.s(context);
    final items = [
      (Icons.edit_outlined, s.editProfile, _showEditDialog),
      (Icons.lock_reset_outlined, s.changePassword, _showChangePasswordDialog),
      (Icons.camera_alt_outlined, s.changePhoto, _pickAndUploadAvatar),
      (
        Icons.settings_outlined,
        s.settings,
        () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SettingsScreen(
                  onToggleTheme: widget.onToggleTheme,
                  onLogout: _logout,
                ),
              ),
            )
      ),
      (Icons.logout_rounded, s.logout, _logout),
    ];

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
        ],
      ),
      child: Column(
        children: List.generate(items.length, (i) {
          final item = items[i];
          final isLogout = item.$1 == Icons.logout_rounded;
          final isLast = i == items.length - 1;
          return Column(
            children: [
              ListTile(
                leading: Icon(
                  item.$1,
                  color: isLogout ? AppTheme.accentColor : AppTheme.primaryColor,
                ),
                title: Text(
                  item.$2,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: isLogout ? AppTheme.accentColor : null,
                  ),
                ),
                trailing: Icon(Icons.arrow_forward_ios,
                    size: 14, color: Colors.grey.withOpacity(0.5)),
                onTap: item.$3,
              ),
              if (!isLast)
                Divider(
                    height: 1, indent: 56, color: Colors.grey.withOpacity(0.1)),
            ],
          );
        }),
      ),
    );
  }

  Future<void> _logout() async {
    await _api.logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => OnboardingScreen(onToggleTheme: widget.onToggleTheme),
      ),
      (_) => false,
    );
  }

  String _formatDate(dynamic dt) {
    if (dt == null) return '';
    try {
      final d = DateTime.parse(dt.toString());
      return '${d.day}.${d.month}.${d.year}';
    } catch (_) {
      return dt.toString();
    }
  }
}