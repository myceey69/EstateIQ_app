import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/user.dart';
import '../../theme/theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  UserRole _selectedRole = UserRole.buyer;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _createAccount() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    await auth.register(
      _nameController.text.trim(),
      _emailController.text.trim(),
      _passwordController.text,
      _selectedRole,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg0,
      appBar: AppBar(
        backgroundColor: AppColors.bg0,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.muted),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Consumer<AuthProvider>(
          builder: (context, auth, _) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Create Account',
                      style: TextStyle(
                        color: AppColors.text,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Join EstateIQ and start exploring smarter.',
                      style: TextStyle(color: AppColors.muted, fontSize: 14),
                    ),
                    const SizedBox(height: 32),

                    // Name field
                    TextFormField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      style: const TextStyle(color: AppColors.text),
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        labelStyle: TextStyle(color: AppColors.muted),
                        prefixIcon: Icon(Icons.person_outline, color: AppColors.muted),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Name is required';
                        if (v.trim().length < 2) return 'Name is too short';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

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
                        if (!v.contains('@') || !v.contains('.')) return 'Enter a valid email';
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
                        if (v.length < 6) return 'Password must be at least 6 characters';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Confirm password field
                    TextFormField(
                      controller: _confirmController,
                      obscureText: _obscureConfirm,
                      style: const TextStyle(color: AppColors.text),
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        labelStyle: const TextStyle(color: AppColors.muted),
                        prefixIcon: const Icon(Icons.lock_outline, color: AppColors.muted),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirm ? Icons.visibility_off : Icons.visibility,
                            color: AppColors.muted,
                          ),
                          onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Please confirm your password';
                        if (v != _passwordController.text) return 'Passwords do not match';
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Role selector
                    const Text(
                      'I am a...',
                      style: TextStyle(
                        color: AppColors.muted,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _roleChip(UserRole.buyer, 'Buyer', Icons.home_outlined),
                        const SizedBox(width: 10),
                        _roleChip(UserRole.investor, 'Investor', Icons.trending_up),
                        const SizedBox(width: 10),
                        _roleChip(UserRole.agent, 'Agent', Icons.badge_outlined),
                      ],
                    ),
                    const SizedBox(height: 16),

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
                    if (auth.error != null) const SizedBox(height: 16),

                    // Create Account button
                    SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: auth.isLoading ? null : _createAccount,
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
                                'Create Account',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Sign in link
                    Center(
                      child: TextButton(
                        onPressed: () {
                          auth.clearError();
                          Navigator.pop(context);
                        },
                        child: const Text.rich(
                          TextSpan(
                            text: 'Already have an account? ',
                            style: TextStyle(color: AppColors.muted),
                            children: [
                              TextSpan(
                                text: 'Sign In',
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
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _roleChip(UserRole role, String label, IconData icon) {
    final isSelected = _selectedRole == role;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedRole = role),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.accent.withOpacity(0.15) : AppColors.bg1,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.accent : AppColors.line,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? AppColors.accent : AppColors.muted,
                size: 22,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? AppColors.accent : AppColors.muted,
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
