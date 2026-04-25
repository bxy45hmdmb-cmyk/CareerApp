import 'package:flutter/material.dart';
import '../core/lang_controller.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final VoidCallback onLogout;

  const SettingsScreen({
    super.key,
    required this.onToggleTheme,
    required this.onLogout,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notifications = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final s = LangScope.s(context);
    final lang = LangScope.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(s.settingsTitle),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // Appearance
            _sectionLabel(s.appearance),
            const SizedBox(height: 8),
            _card([
              _tile(
                icon: isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                label: isDark ? s.lightMode : s.darkMode,
                trailing: Switch.adaptive(
                  value: isDark,
                  activeColor: AppTheme.primaryColor,
                  onChanged: (_) => widget.onToggleTheme(),
                ),
              ),
            ]),
            const SizedBox(height: 20),

            // Language
            _sectionLabel(s.languageSection),
            const SizedBox(height: 8),
            _card([
              _tile(
                icon: Icons.language_rounded,
                label: s.kazakh,
                trailing: lang.locale == 'kk'
                    ? const Icon(Icons.check_circle, color: AppTheme.primaryColor, size: 20)
                    : null,
                onTap: () => lang.setLocale('kk'),
              ),
              _divider(),
              _tile(
                icon: Icons.language_rounded,
                label: s.russian,
                trailing: lang.locale == 'ru'
                    ? const Icon(Icons.check_circle, color: AppTheme.primaryColor, size: 20)
                    : null,
                onTap: () => lang.setLocale('ru'),
              ),
              _divider(),
              _tile(
                icon: Icons.language_rounded,
                label: s.english,
                trailing: lang.locale == 'en'
                    ? const Icon(Icons.check_circle, color: AppTheme.primaryColor, size: 20)
                    : null,
                onTap: () => lang.setLocale('en'),
              ),
            ]),
            const SizedBox(height: 20),

            // Notifications
            _sectionLabel(s.notificationsSection),
            const SizedBox(height: 8),
            _card([
              _tile(
                icon: Icons.notifications_outlined,
                label: s.pushNotifications,
                trailing: Switch.adaptive(
                  value: _notifications,
                  activeColor: AppTheme.primaryColor,
                  onChanged: (v) => setState(() => _notifications = v),
                ),
              ),
            ]),
            const SizedBox(height: 20),

            // About
            _sectionLabel(s.aboutApp),
            const SizedBox(height: 8),
            _card([
              _tile(
                icon: Icons.info_outline,
                label: s.version,
                trailing: const Text('1.0.0',
                    style: TextStyle(color: Colors.grey, fontSize: 13)),
              ),
              _divider(),
              _tile(
                icon: Icons.privacy_tip_outlined,
                label: s.privacyPolicy,
                onTap: () => _showInfo(s.privacyPolicy, s.privacyPolicyContent),
              ),
              _divider(),
              _tile(
                icon: Icons.description_outlined,
                label: s.termsOfUse,
                onTap: () => _showInfo(s.termsOfUse, s.termsContent),
              ),
            ]),
            const SizedBox(height: 20),

            // Account
            _sectionLabel(s.accountSection),
            const SizedBox(height: 8),
            _card([
              _tile(
                icon: Icons.logout_rounded,
                label: s.logout,
                color: AppTheme.accentColor,
                onTap: _confirmLogout,
              ),
            ]),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Text(label,
        style: Theme.of(context)
            .textTheme
            .titleLarge
            ?.copyWith(fontWeight: FontWeight.w700));
  }

  Widget _card(List<Widget> children) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _tile({
    required IconData icon,
    required String label,
    Widget? trailing,
    VoidCallback? onTap,
    Color? color,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? AppTheme.primaryColor),
      title: Text(label,
          style: TextStyle(fontWeight: FontWeight.w500, color: color)),
      trailing: trailing ??
          (onTap != null
              ? Icon(Icons.arrow_forward_ios,
                  size: 14, color: Colors.grey.withOpacity(0.5))
              : null),
      onTap: onTap,
    );
  }

  Widget _divider() =>
      Divider(height: 1, indent: 56, color: Colors.grey.withOpacity(0.1));

  void _showInfo(String title, String msg) {
    final s = LangScope.s(context);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title),
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(s.close),
          ),
        ],
      ),
    );
  }

  void _confirmLogout() {
    final s = LangScope.s(context);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(s.logout),
        content: Text(s.logoutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(s.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onLogout();
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentColor),
            child: Text(s.logout),
          ),
        ],
      ),
    );
  }
}
