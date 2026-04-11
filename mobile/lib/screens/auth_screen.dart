import 'package:flutter/material.dart';
import '../core/api_service.dart';
import '../core/lang_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_button.dart';
import 'home_screen.dart';
import 'verification_screen.dart';
import 'forgot_password_screen.dart';

class AuthScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  const AuthScreen({super.key, required this.onToggleTheme});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  bool _isLogin = true;
  bool _obscurePassword = true;
  bool _isLoading = false;
  int _selectedGrade = 9;

  final _api = ApiService();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _schoolCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  // Password strength state
  bool _pwHasLength = false;
  bool _pwHasUpper = false;
  bool _pwHasDigit = false;
  bool _pwHasSpecial = false;
  bool _showPwHints = false;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        duration: const Duration(milliseconds: 400), vsync: this);
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(_animCtrl);
    _animCtrl.forward();
    _passwordCtrl.addListener(_onPasswordChanged);
  }

  void _onPasswordChanged() {
    final v = _passwordCtrl.text;
    setState(() {
      _pwHasLength = v.length >= 7;
      _pwHasUpper = v.contains(RegExp(r'[A-Z]'));
      _pwHasDigit = v.contains(RegExp(r'\d'));
      _pwHasSpecial =
          v.contains(RegExp(r'[!@#$%^&*()\-_=+\[\]{};:",.<>/?`~\\|]'));
    });
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _nameCtrl.dispose();
    _schoolCtrl.dispose();
    _cityCtrl.dispose();
    super.dispose();
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppTheme.accentColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _submit() async {
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;

    final s = LangScope.s(context);
    if (email.isEmpty || password.isEmpty) {
      _showError(s.enterEmailAndPw);
      return;
    }
    if (!_isLogin && _nameCtrl.text.trim().isEmpty) {
      _showError(s.enterNameError);
      return;
    }

    setState(() => _isLoading = true);
    try {
      if (_isLogin) {
        await _api.login(email: email, password: password);
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) =>
                HomeScreen(onToggleTheme: widget.onToggleTheme),
            transitionsBuilder: (_, anim, __, child) =>
                FadeTransition(opacity: anim, child: child),
            transitionDuration: const Duration(milliseconds: 400),
          ),
        );
      } else {
        await _api.register(
          email: email,
          password: password,
          fullName: _nameCtrl.text.trim(),
          grade: _selectedGrade,
          school:
              _schoolCtrl.text.trim().isEmpty ? null : _schoolCtrl.text.trim(),
          city: _cityCtrl.text.trim().isEmpty ? null : _cityCtrl.text.trim(),
        );
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => VerificationScreen(
              email: email,
              onToggleTheme: widget.onToggleTheme,
            ),
          ),
        );
      }
    } on ApiException catch (e) {
      _showError(e.message);
    } catch (_) {
      _showError(LangScope.s(context).serverError);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _toggleMode() {
    _animCtrl.reset();
    setState(() {
      _isLogin = !_isLogin;
      _showPwHints = false;
    });
    _animCtrl.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: FadeTransition(
            opacity: _fadeAnim,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                _buildHeader(),
                const SizedBox(height: 32),
                _buildForm(),
                const SizedBox(height: 24),
                CustomButton(
                  text: _isLogin ? LangScope.s(context).loginButton : LangScope.s(context).registerButton,
                  onPressed: _submit,
                  isLoading: _isLoading,
                ),
                if (_isLogin) ...[
                  const SizedBox(height: 8),
                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const ForgotPasswordScreen()),
                      ),
                      child: Text(
                        LangScope.s(context).forgotPassword,
                        style: TextStyle(color: AppTheme.primaryColor),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _isLogin ? LangScope.s(context).noAccount : LangScope.s(context).alreadyHaveAccount,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: _toggleMode,
                      child: Text(
                        _isLogin ? LangScope.s(context).toRegister : LangScope.s(context).toLogin,
                        style: const TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [AppTheme.primaryColor, AppTheme.primaryLight]),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Center(child: Text('🎯', style: TextStyle(fontSize: 28))),
        ),
        const SizedBox(height: 24),
        Text(
          _isLogin ? LangScope.s(context).loginTitle : LangScope.s(context).registerTitle,
          style: Theme.of(context).textTheme.displaySmall,
        ),
        const SizedBox(height: 8),
        Text(
          _isLogin ? LangScope.s(context).loginSubtitle : LangScope.s(context).registerSubtitle,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Column(
      children: [
        if (!_isLogin) ...[
          _field(_nameCtrl, LangScope.s(context).nameFieldLabel, LangScope.s(context).nameFieldHint,
              Icons.person_outline),
          const SizedBox(height: 14),
          _field(_schoolCtrl, LangScope.s(context).schoolFieldLabel, LangScope.s(context).schoolFieldHint,
              Icons.school_outlined),
          const SizedBox(height: 14),
          _field(_cityCtrl, LangScope.s(context).cityFieldLabel, LangScope.s(context).cityFieldHint,
              Icons.location_city_outlined),
          const SizedBox(height: 14),
          _gradeSelector(),
          const SizedBox(height: 14),
        ],
        _field(_emailCtrl, LangScope.s(context).emailFieldLabel, 'name@example.com',
            Icons.email_outlined,
            type: TextInputType.emailAddress,
            isEmail: true),
        const SizedBox(height: 14),
        _passwordField(),
        if (!_isLogin && _showPwHints) ...[
          const SizedBox(height: 10),
          _buildPasswordHints(),
        ],
      ],
    );
  }

  Widget _field(
    TextEditingController ctrl,
    String label,
    String hint,
    IconData icon, {
    TextInputType type = TextInputType.text,
    bool isEmail = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: ctrl,
          keyboardType: type,
          autocorrect: false,
          enableSuggestions: !isEmail,
          textCapitalization:
              isEmail ? TextCapitalization.none : TextCapitalization.words,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, size: 20),
          ),
        ),
      ],
    );
  }

  Widget _passwordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(LangScope.s(context).passwordFieldLabel,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: _passwordCtrl,
          obscureText: _obscurePassword,
          autocorrect: false,
          enableSuggestions: false,
          onTap: () {
            if (!_isLogin) setState(() => _showPwHints = true);
          },
          decoration: InputDecoration(
            hintText: '••••••••',
            prefixIcon: const Icon(Icons.lock_outline, size: 20),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                size: 20,
              ),
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordHints() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(LangScope.s(context).pwRequirements,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodySmall?.color,
              )),
          const SizedBox(height: 6),
          _hintRow(_pwHasLength, LangScope.s(context).pwLength),
          _hintRow(_pwHasUpper, LangScope.s(context).pwUpper),
          _hintRow(_pwHasDigit, LangScope.s(context).pwDigit),
          _hintRow(_pwHasSpecial, LangScope.s(context).pwSpecial),
        ],
      ),
    );
  }

  Widget _hintRow(bool ok, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Icon(
            ok ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 16,
            color: ok ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: ok ? Colors.green : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _gradeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(LangScope.s(context).gradeSelector,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Row(
          children: [7, 8, 9, 10, 11].map((g) {
            final sel = _selectedGrade == g;
            return GestureDetector(
              onTap: () => setState(() => _selectedGrade = g),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 8),
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: sel
                      ? AppTheme.primaryColor
                      : AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    '$g',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: sel ? Colors.white : AppTheme.primaryColor,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
