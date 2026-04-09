import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/theme.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final success = await auth.login(
      _emailController.text.trim(),
      _passwordController.text,
    );
    if (!success && mounted) {
      // Error is shown via provider state
    }
  }

  Future<void> _quickLogin(String email, String password) async {
    _emailController.text = email;
    _passwordController.text = password;
    final auth = context.read<AuthProvider>();
    await auth.login(email, password);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg0,
      body: SafeArea(
        child: Consumer<AuthProvider>(
          builder: (context, auth, _) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 32),
                    // Logo / Title
                    Center(
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.home_work_rounded,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Center(
                      child: Text(
                        'EstateIQ',
                        style: TextStyle(
                          color: AppColors.text,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Center(
                      child: Text(
                        'AI-Powered Real Estate Intelligence',
                        style: TextStyle(color: AppColors.muted, fontSize: 14),
                      ),
                    ),
                    const SizedBox(height: 48),

                    // Email field
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(color: AppColors.text),
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        labelStyle: TextStyle(color: AppColors.muted),
                        prefixIcon: Icon(Icons.email_outlined, color: AppColors.muted),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Email is required';
                        if (!v.contains('@')) return 'Enter a valid email';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Password field
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      style: const TextStyle(color: AppColors.text),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: const TextStyle(color: AppColors.muted),
                        prefixIcon: const Icon(Icons.lock_outline, color: AppColors.muted),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off : Icons.visibility,
                            color: AppColors.muted,
                          ),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Password is required';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    // Error message
                    if (auth.error != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.bad.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.bad.withOpacity(0.4)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: AppColors.bad, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                auth.error!,
                                style: const TextStyle(color: AppColors.bad, fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 24),

                    // Sign In button
                    SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: auth.isLoading ? null : _signIn,
                        child: auth.isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Sign In',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Register link
                    Center(
                      child: TextButton(
                        onPressed: () {
                          auth.clearError();
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const RegisterScreen()),
                          );
                        },
                        child: const Text.rich(
                          TextSpan(
                            text: "Don't have an account? ",
                            style: TextStyle(color: AppColors.muted),
                            children: [
                              TextSpan(
                                text: 'Register',
                                style: TextStyle(
                                  color: AppColors.accent,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Quick demo logins
                    _buildDivider('Quick Demo Access'),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      alignment: WrapAlignment.center,
                      children: [
                        _demoButton('Try as Buyer', 'buyer@demo.com', AppColors.accent2, auth.isLoading),
                        _demoButton('Try as Investor', 'investor@demo.com', AppColors.good, auth.isLoading),
                        _demoButton('Try as Agent', 'agent@demo.com', AppColors.warn, auth.isLoading),
                        _demoButton('Try as Admin', 'admin@demo.com', AppColors.bad, auth.isLoading),
                      ],
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDivider(String label) {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.line)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            label,
            style: const TextStyle(color: AppColors.muted, fontSize: 12),
          ),
        ),
        const Expanded(child: Divider(color: AppColors.line)),
      ],
    );
  }

  Widget _demoButton(String label, String email, Color color, bool isLoading) {
    return OutlinedButton(
      onPressed: isLoading ? null : () => _quickLogin(email, 'demo123'),
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color.withOpacity(0.5)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(label, style: const TextStyle(fontSize: 13)),
    );
  }
}
