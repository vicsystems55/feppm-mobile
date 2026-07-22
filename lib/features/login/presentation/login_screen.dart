import 'package:flutter/material.dart';

import '../../../core/auth/auth_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.authController});

  final AuthController authController;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = true;
  bool _passwordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    widget.authController.clearError();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    await widget.authController.login(
      email: _emailController.text,
      password: _passwordController.text,
      rememberMe: _rememberMe,
    );
  }

  void _comingSoon(String name) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$name is not configured yet.')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 920;
          if (isWide) {
            return Row(
              children: [
                const Expanded(flex: 9, child: _StoryPanel()),
                Expanded(
                  flex: 11,
                  child: _FormPanel(
                    content: _buildForm(maxWidth: 500),
                    showBrand: false,
                  ),
                ),
              ],
            );
          }

          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF073E75), Color(0xFF0B5A9F)],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(22, 22, 22, 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _BrandLogo(inverse: true, compact: true),
                        _LanguageButton(inverse: true),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(30),
                        ),
                      ),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(22, 34, 22, 30),
                        child: Center(child: _buildForm(maxWidth: 500)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildForm({required double maxWidth}) {
    final auth = widget.authController;
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Welcome back!',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: const Color(0xFF101828),
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Sign in to continue to your FEPPM account',
              style: TextStyle(color: Color(0xFF475467), fontSize: 15),
            ),
            const SizedBox(height: 28),
            if (auth.errorMessage != null) ...[
              _ErrorBanner(message: auth.errorMessage!),
              const SizedBox(height: 18),
            ],
            const _FieldLabel('Email address'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _emailController,
              enabled: !auth.isLoading,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
              decoration: const InputDecoration(
                hintText: 'Enter your email address',
                prefixIcon: Icon(Icons.mail_outline_rounded),
              ),
              validator: (value) {
                final email = value?.trim() ?? '';
                if (email.isEmpty) return 'Email address is required.';
                if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
                  return 'Enter a valid email address.';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            const _FieldLabel('Password'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _passwordController,
              enabled: !auth.isLoading,
              obscureText: !_passwordVisible,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.password],
              onFieldSubmitted: (_) => _submit(),
              decoration: InputDecoration(
                hintText: 'Enter your password',
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                suffixIcon: IconButton(
                  tooltip: _passwordVisible ? 'Hide password' : 'Show password',
                  onPressed: () =>
                      setState(() => _passwordVisible = !_passwordVisible),
                  icon: Icon(
                    _passwordVisible
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                ),
              ),
              validator: (value) => (value == null || value.isEmpty)
                  ? 'Password is required.'
                  : null,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Checkbox(
                    value: _rememberMe,
                    onChanged: auth.isLoading
                        ? null
                        : (value) =>
                              setState(() => _rememberMe = value ?? false),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Remember me',
                  style: TextStyle(color: Color(0xFF344054), fontSize: 14),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => _comingSoon('Password recovery'),
                  child: const Text('Forgot password?'),
                ),
              ],
            ),
            const SizedBox(height: 18),
            SizedBox(
              height: 52,
              child: FilledButton.icon(
                onPressed: auth.isLoading ? null : _submit,
                icon: auth.isLoading
                    ? const SizedBox.square(
                        dimension: 19,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.lock_outline_rounded, size: 20),
                label: Text(auth.isLoading ? 'Signing in…' : 'Sign in'),
              ),
            ),
            const SizedBox(height: 25),
            const _DividerLabel('or continue with'),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: _ProviderButton(
                    label: 'Google',
                    mark: const Text(
                      'G',
                      style: TextStyle(
                        color: Color(0xFF4285F4),
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    onPressed: () => _comingSoon('Google login'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ProviderButton(
                    label: 'Microsoft',
                    mark: const _MicrosoftMark(),
                    onPressed: () => _comingSoon('Microsoft login'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => _comingSoon('SSO login'),
              icon: const Icon(Icons.verified_user_outlined, size: 20),
              label: const Text('SSO login'),
            ),
            const SizedBox(height: 28),
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const Text(
                  "Don't have an account? ",
                  style: TextStyle(color: Color(0xFF475467), fontSize: 14),
                ),
                TextButton(
                  onPressed: () => _comingSoon('Administrator contact'),
                  child: const Text('Contact administrator'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FormPanel extends StatelessWidget {
  const _FormPanel({required this.content, required this.showBrand});
  final Widget content;
  final bool showBrand;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(48, 30, 48, 24),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (showBrand) const _BrandLogo(compact: true),
                const _LanguageButton(),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 28),
                child: Center(child: content),
              ),
            ),
            const Text(
              '© 2026 FEPPM. All rights reserved.',
              style: TextStyle(color: Color(0xFF667085), fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _StoryPanel extends StatelessWidget {
  const _StoryPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF073E75), Color(0xFF075499), Color(0xFF042E58)],
        ),
      ),
      child: SafeArea(
        child: Stack(
          children: [
            Positioned(
              right: -100,
              bottom: -80,
              child: Icon(
                Icons.settings_outlined,
                size: 520,
                color: Colors.white.withValues(alpha: 0.055),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(54, 42, 48, 44),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _BrandLogo(inverse: true),
                  const Spacer(),
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        height: 1.32,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.7,
                      ),
                      children: [
                        TextSpan(text: 'Smart '),
                        TextSpan(
                          text: 'Maintenance.\n',
                          style: TextStyle(color: Color(0xFF31BA70)),
                        ),
                        TextSpan(text: 'Stronger '),
                        TextSpan(
                          text: 'Facilities.\n',
                          style: TextStyle(color: Color(0xFF5BA5FF)),
                        ),
                        TextSpan(text: 'Better '),
                        TextSpan(
                          text: 'Performance.',
                          style: TextStyle(color: Color(0xFFFFA62B)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: 62,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFF32BD70),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'Plan, track and optimize preventive maintenance across all your facilities and equipment.',
                    style: TextStyle(
                      color: Color(0xFFEAF4FF),
                      height: 1.65,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 34),
                  const _Benefit(
                    icon: Icons.verified_user_outlined,
                    color: Color(0xFF13AC60),
                    title: 'Improve equipment reliability',
                  ),
                  const _Benefit(
                    icon: Icons.fact_check_outlined,
                    color: Color(0xFF1670DC),
                    title: 'Plan preventive maintenance',
                  ),
                  const _Benefit(
                    icon: Icons.bar_chart_rounded,
                    color: Color(0xFFF48A0A),
                    title: 'Real-time insights & reports',
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BrandLogo extends StatelessWidget {
  const _BrandLogo({this.inverse = false, this.compact = false});
  final bool inverse;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final secondary = inverse ? Colors.white : const Color(0xFF344054);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: compact ? 43 : 52,
          height: compact ? 43 : 52,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(4),
          child: Image.asset('assets/images/icon.png'),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: compact ? 23 : 28,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
                children: const [
                  TextSpan(
                    text: 'FE',
                    style: TextStyle(color: Color(0xFF3A8AF0)),
                  ),
                  TextSpan(
                    text: 'PPM',
                    style: TextStyle(color: Color(0xFF31BA70)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Facility Equipment',
              style: TextStyle(
                color: secondary,
                fontSize: compact ? 9 : 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _LanguageButton extends StatelessWidget {
  const _LanguageButton({this.inverse = false});
  final bool inverse;

  @override
  Widget build(BuildContext context) {
    final color = inverse ? Colors.white : const Color(0xFF344054);
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 11),
      decoration: BoxDecoration(
        color: inverse ? Colors.white.withValues(alpha: 0.1) : Colors.white,
        border: Border.all(
          color: inverse
              ? Colors.white.withValues(alpha: 0.3)
              : const Color(0xFFD8E0EA),
        ),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.language_rounded, size: 18, color: color),
          const SizedBox(width: 7),
          Text('English', style: TextStyle(color: color, fontSize: 13)),
          const SizedBox(width: 3),
          Icon(Icons.keyboard_arrow_down_rounded, size: 17, color: color),
        ],
      ),
    );
  }
}

class _Benefit extends StatelessWidget {
  const _Benefit({
    required this.icon,
    required this.color,
    required this.title,
  });
  final IconData icon;
  final Color color;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 23),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.label);
  final String label;

  @override
  Widget build(BuildContext context) => Text(
    label,
    style: const TextStyle(
      color: Color(0xFF101828),
      fontSize: 14,
      fontWeight: FontWeight.w600,
    ),
  );
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: const Color(0xFFFFF1F0),
      border: Border.all(color: const Color(0xFFF4B4AD)),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.error_outline, color: Color(0xFFB42318), size: 20),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            message,
            style: const TextStyle(color: Color(0xFFB42318), height: 1.4),
          ),
        ),
      ],
    ),
  );
}

class _DividerLabel extends StatelessWidget {
  const _DividerLabel(this.label);
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      const Expanded(child: Divider()),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 13),
        child: Text(
          label,
          style: const TextStyle(color: Color(0xFF667085), fontSize: 13),
        ),
      ),
      const Expanded(child: Divider()),
    ],
  );
}

class _ProviderButton extends StatelessWidget {
  const _ProviderButton({
    required this.label,
    required this.mark,
    required this.onPressed,
  });
  final String label;
  final Widget mark;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 50,
    child: OutlinedButton(
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          mark,
          const SizedBox(width: 10),
          Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
        ],
      ),
    ),
  );
}

class _MicrosoftMark extends StatelessWidget {
  const _MicrosoftMark();

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: 18,
    child: GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 2,
      mainAxisSpacing: 2,
      physics: const NeverScrollableScrollPhysics(),
      children: const [
        ColoredBox(color: Color(0xFFF25022)),
        ColoredBox(color: Color(0xFF7FBA00)),
        ColoredBox(color: Color(0xFF00A4EF)),
        ColoredBox(color: Color(0xFFFFB900)),
      ],
    ),
  );
}
