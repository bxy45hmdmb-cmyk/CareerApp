import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/api_service.dart';
import '../core/lang_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_button.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _api = ApiService();

  // Step 1 — enter email
  final _emailCtrl = TextEditingController();
  // Step 2 — enter OTP + new password
  final List<TextEditingController> _otpCtrls =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpFocus = List.generate(6, (_) => FocusNode());
  final _newPwCtrl = TextEditingController();
  final _confirmPwCtrl = TextEditingController();

  bool _step2 = false;
  bool _isLoading = false;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  // Password hint state
  bool _pwHasLength = false;
  bool _pwHasUpper = false;
  bool _pwHasDigit = false;
  bool _pwHasSpecial = false;
  bool _showPwHints = false;

  @override
  void initState() {
    super.initState();
    _newPwCtrl.addListener(_onPasswordChanged);
  }

  void _onPasswordChanged() {
    final v = _newPwCtrl.text;
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
    _emailCtrl.dispose();
    _newPwCtrl.dispose();
    _confirmPwCtrl.dispose();
    for (final c in _otpCtrls) {
      c.dispose();
    }
    for (final f in _otpFocus) {
      f.dispose();
    }
    super.dispose();
  }

  String get _otpCode => _otpCtrls.map((c) => c.text).join();

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

  Future<void> _sendCode() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      _showError(LangScope.s(context).enterEmailError);
      return;
    }
    setState(() => _isLoading = true);
    try {
      await _api.forgotPassword(email);
      setState(() => _step2 = true);
    } on ApiException catch (e) {
      _showError(e.message);
    } catch (_) {
      _showError(LangScope.s(context).serverError);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resetPassword() async {
    final s = LangScope.s(context);
    if (_otpCode.length < 6) {
      _showError(s.enterFullCode);
      return;
    }
    final newPw = _newPwCtrl.text;
    final confirmPw = _confirmPwCtrl.text;
    if (newPw != confirmPw) {
      _showError(s.passwordMismatch);
      return;
    }
    if (!(_pwHasLength && _pwHasUpper && _pwHasDigit && _pwHasSpecial)) {
      _showError(s.passwordRequirementsFailed);
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _api.resetPassword(
        email: _emailCtrl.text.trim(),
        code: _otpCode,
        newPassword: newPw,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(LangScope.s(context).passwordResetSuccess),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      Navigator.pop(context);
    } on ApiException catch (e) {
      _showError(e.message);
    } catch (_) {
      _showError(LangScope.s(context).serverError);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: _step2 ? _buildStep2() : _buildStep1(),
        ),
      ),
    );
  }

  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [AppTheme.primaryColor, AppTheme.primaryLight]),
            borderRadius: BorderRadius.circular(16),
          ),
          child:
              const Center(child: Text('🔐', style: TextStyle(fontSize: 28))),
        ),
        const SizedBox(height: 24),
        Text(
          LangScope.s(context).resetPasswordTitle,
          style: Theme.of(context).textTheme.displaySmall,
        ),
        const SizedBox(height: 8),
        Text(
          LangScope.s(context).resetPasswordDesc,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 32),
        Text(LangScope.s(context).emailFieldLabel,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: _emailCtrl,
          keyboardType: TextInputType.emailAddress,
          autocorrect: false,
          enableSuggestions: false,
          textCapitalization: TextCapitalization.none,
          decoration: const InputDecoration(
            hintText: 'name@example.com',
            prefixIcon: Icon(Icons.email_outlined, size: 20),
          ),
        ),
        const SizedBox(height: 32),
        CustomButton(
          text: LangScope.s(context).sendCode,
          onPressed: _sendCode,
          isLoading: _isLoading,
        ),
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [AppTheme.primaryColor, AppTheme.primaryLight]),
            borderRadius: BorderRadius.circular(16),
          ),
          child:
              const Center(child: Text('🔑', style: TextStyle(fontSize: 28))),
        ),
        const SizedBox(height: 24),
        Text(
          LangScope.s(context).newPasswordTitle,
          style: Theme.of(context).textTheme.displaySmall,
        ),
        const SizedBox(height: 8),
        Text(
          LangScope.s(context).codeSentTo(_emailCtrl.text.trim()),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 24),
        _buildOtpFields(),
        const SizedBox(height: 24),
        Text(LangScope.s(context).newPassword,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: _newPwCtrl,
          obscureText: _obscureNew,
          autocorrect: false,
          enableSuggestions: false,
          onTap: () => setState(() => _showPwHints = true),
          decoration: InputDecoration(
            hintText: '••••••••',
            prefixIcon: const Icon(Icons.lock_outline, size: 20),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureNew
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                size: 20,
              ),
              onPressed: () => setState(() => _obscureNew = !_obscureNew),
            ),
          ),
        ),
        if (_showPwHints) ...[
          const SizedBox(height: 10),
          _buildPasswordHints(),
        ],
        const SizedBox(height: 14),
        Text(LangScope.s(context).confirmNewPassword,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: _confirmPwCtrl,
          obscureText: _obscureConfirm,
          autocorrect: false,
          enableSuggestions: false,
          decoration: InputDecoration(
            hintText: '••••••••',
            prefixIcon: const Icon(Icons.lock_outline, size: 20),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirm
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                size: 20,
              ),
              onPressed: () =>
                  setState(() => _obscureConfirm = !_obscureConfirm),
            ),
          ),
        ),
        const SizedBox(height: 32),
        CustomButton(
          text: LangScope.s(context).save,
          onPressed: _resetPassword,
          isLoading: _isLoading,
        ),
        const SizedBox(height: 12),
        Center(
          child: TextButton(
            onPressed: () => setState(() {
              _step2 = false;
              for (final c in _otpCtrls) {
                c.clear();
              }
            }),
            child: Text(
              LangScope.s(context).resendCode,
              style: TextStyle(color: AppTheme.primaryColor),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOtpFields() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(6, (i) {
        return SizedBox(
          width: 48,
          height: 56,
          child: TextField(
            controller: _otpCtrls[i],
            focusNode: _otpFocus[i],
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 1,
            autocorrect: false,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            decoration: InputDecoration(
              counterText: '',
              contentPadding: EdgeInsets.zero,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: AppTheme.primaryColor, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: AppTheme.primaryColor, width: 2),
              ),
            ),
            onChanged: (v) {
              if (v.isNotEmpty && i < 5) {
                _otpFocus[i + 1].requestFocus();
              } else if (v.isEmpty && i > 0) {
                _otpFocus[i - 1].requestFocus();
              }
              setState(() {});
            },
          ),
        );
      }),
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
}
