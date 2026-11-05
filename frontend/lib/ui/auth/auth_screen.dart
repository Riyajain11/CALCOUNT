import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants.dart';
import '../../providers/app_providers.dart';

class AuthScreen extends ConsumerStatefulWidget {
  final bool initialIsSignUp;

  const AuthScreen({
    super.key,
    this.initialIsSignUp = false,
  });

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  late bool _isSignUp;
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController(text: 'user@example.com');
  final _passwordController = TextEditingController(text: 'password123');

  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _isSignUp = widget.initialIsSignUp;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (_isSignUp) {
        await ref.read(authRepositoryProvider).signUp(
              name: _nameController.text.trim().isNotEmpty
                  ? _nameController.text.trim()
                  : 'User',
              email: _emailController.text.trim(),
              password: _passwordController.text,
            );
        if (mounted) {
          context.go('/onboarding');
        }
      } else {
        await ref.read(authRepositoryProvider).logIn(
              email: _emailController.text.trim(),
              password: _passwordController.text,
            );
        if (mounted) {
          context.go('/home');
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.pagePadding,
              vertical: 24,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // App Reticle Icon
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDark
                          ? AppColors.accentLime
                          : AppColors.primaryGreen,
                      boxShadow: [
                        BoxShadow(
                          color: (isDark
                                  ? AppColors.accentLime
                                  : AppColors.primaryGreen)
                              .withValues(alpha: 0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.center_focus_strong,
                      size: 38,
                      color: isDark ? Colors.black : Colors.white,
                    ),
                  ),
                  const SizedBox(height: 18),

                  Text(
                    'CalCount',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : AppColors.textLight,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Click your thali. Get your macros in seconds.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Segmented Switcher (Log In / Sign Up)
                  Container(
                    height: 52,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.cardDark
                          : const Color(0xFFE5EEDF),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              if (_isSignUp) {
                                setState(() {
                                  _isSignUp = false;
                                  _errorMessage = null;
                                });
                              }
                            },
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: !_isSignUp
                                    ? (isDark
                                        ? AppColors.accentLime
                                        : AppColors.primaryGreen)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Text(
                                'Log In',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: !_isSignUp
                                      ? (isDark ? Colors.black : Colors.white)
                                      : (isDark
                                          ? Colors.white70
                                          : AppColors.textLight),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              if (!_isSignUp) {
                                setState(() {
                                  _isSignUp = true;
                                  _errorMessage = null;
                                });
                              }
                            },
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: _isSignUp
                                    ? (isDark
                                        ? AppColors.accentLime
                                        : AppColors.primaryGreen)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Text(
                                'Sign Up',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: _isSignUp
                                      ? (isDark ? Colors.black : Colors.white)
                                      : (isDark
                                          ? Colors.white70
                                          : AppColors.textLight),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Error Banner if any
                  if (_errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.over.withValues(alpha: 0.15)
                            : AppColors.overBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.over),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline,
                              color: AppColors.over, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(
                                color: AppColors.over,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                  ],

                  // Form Container Card
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.cardDark : AppColors.cardLight,
                      borderRadius:
                          BorderRadius.circular(AppDimensions.cardRadius),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name (only for Sign up)
                        if (_isSignUp) ...[
                          Text(
                            'Name',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color:
                                  isDark ? Colors.white : AppColors.textLight,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              hintText: 'Your name',
                              fillColor: isDark
                                  ? const Color(0xFF161817)
                                  : Colors.white,
                            ),
                            validator: (val) {
                              if (_isSignUp &&
                                  (val == null || val.trim().isEmpty)) {
                                return 'Please enter your name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Email
                        Text(
                          'Email',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: isDark ? Colors.white : AppColors.textLight,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: 'name@example.com',
                            fillColor: isDark
                                ? const Color(0xFF161817)
                                : Colors.white,
                          ),
                          validator: (val) {
                            if (val == null || !val.contains('@')) {
                              return 'Enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Password
                        Text(
                          _isSignUp ? 'Password (min 8 chars)' : 'Password',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: isDark ? Colors.white : AppColors.textLight,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            hintText: _isSignUp
                                ? 'At least 8 characters'
                                : 'Enter your password',
                            fillColor: isDark
                                ? const Color(0xFF161817)
                                : Colors.white,
                            suffixIcon: IconButton(
                              icon: Icon(_obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility),
                              onPressed: () => setState(() =>
                                  _obscurePassword = !_obscurePassword),
                            ),
                          ),
                          validator: (val) {
                            if (val == null || val.length < 8) {
                              return 'Password must be at least 8 characters';
                            }
                            return null;
                          },
                        ),

                        if (!_isSignUp) ...[
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () => context.push('/forgot-password'),
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                'Forgot password?',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                  color: isDark
                                      ? AppColors.accentLime
                                      : AppColors.primaryGreen,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Submit Button
                  ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark
                          ? AppColors.accentLime
                          : AppColors.primaryGreen,
                      foregroundColor: isDark ? Colors.black : Colors.white,
                      minimumSize: const Size.fromHeight(56),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppDimensions.buttonRadius),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            _isSignUp ? 'Create Account' : 'Log In',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                  ),
                  const SizedBox(height: 16),

                  // Switch between modes text button
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isSignUp = !_isSignUp;
                        _errorMessage = null;
                      });
                    },
                    child: Text(
                      _isSignUp
                          ? 'Already have an account? Log in'
                          : 'Don\'t have an account? Sign up',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.accentLime
                            : AppColors.primaryGreen,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

