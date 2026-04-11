import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/api_service.dart';
import '../core/lang_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_button.dart';
import 'home_screen.dart';

class VerificationScreen extends StatefulWidget {
  final String email;
  final VoidCallback onToggleTheme;

  const VerificationScreen({
    super.key,
    required this.email,
    required this.onToggleTheme,
  });

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final _api = ApiService();
  final List<TextEditingController> _ctrls =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  bool _isLoading = false;
  bool _isResending = false;

  @override
  void dispose() {
    for (final c in _ctrls) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _code => _ctrls.map((c) => c.text).join();

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

  void _showSuccess(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _verify() async {
    if (_code.length < 6) {
      _showError(LangScope.s(context).enterFullCode);
      return;
    }
    setState(() => _isLoading = true);
    try {
      await _api.verifyEmail(email: widget.email, code: _code);
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) =>
              HomeScreen(onToggleTheme: widget.onToggleTheme),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 400),
        ),
        (_) => false,
      );
    } on ApiException catch (e) {
      _showError(e.message);
    } catch (_) {
      _showError(LangScope.s(context).serverError);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resend() async {
    setState(() => _isResending = true);
    try {
      await _api.resendVerification(widget.email);
      _showSuccess(LangScope.s(context).codeSentAgain);
      for (final c in _ctrls) {
        c.clear();
      }
      _focusNodes[0].requestFocus();
    } on ApiException catch (e) {
      _showError(e.message);
    } catch (_) {
      _showError(LangScope.s(context).serverError);
    } finally {
      if (mounted) setState(() => _isResending = false);
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
          child: Column(
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
                    const Center(child: Text('✉️', style: TextStyle(fontSize: 28))),
              ),
              const SizedBox(height: 24),
              Text(
                LangScope.s(context).verifyEmail,
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const SizedBox(height: 8),
              Text(
                LangScope.s(context).verifyCodeSent,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 4),
              Text(
                widget.email,
                style: const TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 32),
              _buildOtpFields(),
              const SizedBox(height: 32),
              CustomButton(
                text: LangScope.s(context).verify,
                onPressed: _verify,
                isLoading: _isLoading,
              ),
              const SizedBox(height: 16),
              Center(
                child: _isResending
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : TextButton(
                        onPressed: _resend,
                        child: Text(
                          LangScope.s(context).resendCode,
                          style: TextStyle(color: AppTheme.primaryColor),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
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
            controller: _ctrls[i],
            focusNode: _focusNodes[i],
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
                _focusNodes[i + 1].requestFocus();
              } else if (v.isEmpty && i > 0) {
                _focusNodes[i - 1].requestFocus();
              }
              setState(() {});
            },
          ),
        );
      }),
    );
  }
}
