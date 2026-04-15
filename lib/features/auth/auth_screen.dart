import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/animations.dart';
import '../../providers/app_providers.dart';
import '../home/home_screen.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _toggleController;
  late AnimationController _bgController;

  late Animation<Offset> _fieldSlide;
  late Animation<double> _fieldFade;
  late Animation<double> _toggleAnim;

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  final _shakeKey = GlobalKey<ShakeWidgetState>();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _toggleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fieldSlide = Tween<Offset>(
      begin: const Offset(0, 0.8),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));

    _fieldFade = CurvedAnimation(parent: _slideController, curve: Curves.easeIn);

    _toggleAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _toggleController, curve: Curves.easeInOut),
    );

    _bgController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _slideController.forward();
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _toggleController.dispose();
    _bgController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _toggleMode() {
    final isLogin = ref.read(isLoginModeProvider);
    ref.read(isLoginModeProvider.notifier).state = !isLogin;
    _slideController.reset();
    _slideController.forward();
    if (isLogin) {
      _toggleController.forward();
    } else {
      _toggleController.reverse();
    }
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      _shakeKey.currentState?.shake();
      return;
    }
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    if (mounted) {
      setState(() => _isLoading = false);
      ref.read(isLoggedInProvider.notifier).state = true;
      Navigator.of(context).pushReplacement(
        FadeScalePageRoute(child: const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLogin = ref.watch(isLoginModeProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0A0A1A), Color(0xFF1A0A42), Color(0xFF0A0A1A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  // Back + Logo
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: AppColors.primary.withOpacity(0.3), width: 1),
                        ),
                        child: const Icon(Icons.electric_car_rounded,
                            color: AppColors.primary, size: 26),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Header
                  SlideTransition(
                    position: _fieldSlide,
                    child: FadeTransition(
                      opacity: _fieldFade,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isLogin ? 'Welcome\nBack! 👋' : 'Create\nAccount 🚀',
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            isLogin
                                ? 'Sign in to continue your journey'
                                : 'Join RideNow and ride smarter',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.white.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 36),

                  // Toggle
                  SlideTransition(
                    position: _fieldSlide,
                    child: FadeTransition(
                      opacity: _fieldFade,
                      child: _buildToggle(isLogin),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Fields
                  ShakeWidget(
                    key: _shakeKey,
                    child: Column(
                      children: [
                        if (!isLogin) ...[
                          StaggeredAnimationBuilder(
                            index: 0,
                            child: _buildField(
                              controller: _nameController,
                              label: 'Full Name',
                              icon: Icons.person_outline_rounded,
                              validator: (v) =>
                                  v!.isEmpty ? 'Enter your name' : null,
                            ),
                          ),
                          const SizedBox(height: 14),
                          StaggeredAnimationBuilder(
                            index: 1,
                            child: _buildField(
                              controller: _phoneController,
                              label: 'Phone Number',
                              icon: Icons.phone_outlined,
                              keyboardType: TextInputType.phone,
                              validator: (v) =>
                                  v!.length < 10 ? 'Enter valid phone' : null,
                            ),
                          ),
                          const SizedBox(height: 14),
                        ],
                        StaggeredAnimationBuilder(
                          index: isLogin ? 0 : 2,
                          child: _buildField(
                            controller: _emailController,
                            label: 'Email Address',
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) => !v!.contains('@')
                                ? 'Enter valid email'
                                : null,
                          ),
                        ),
                        const SizedBox(height: 14),
                        StaggeredAnimationBuilder(
                          index: isLogin ? 1 : 3,
                          child: _buildPasswordField(),
                        ),
                      ],
                    ),
                  ),

                  if (isLogin) ...[
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),

                  // Submit button
                  StaggeredAnimationBuilder(
                    index: isLogin ? 3 : 5,
                    child: _isLoading
                        ? Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                              strokeWidth: 3,
                            ),
                          )
                        : GradientButton(
                            text: isLogin ? 'Sign In' : 'Create Account',
                            icon: isLogin
                                ? Icons.login_rounded
                                : Icons.person_add_rounded,
                            onPressed: _submit,
                          ),
                  ),

                  const SizedBox(height: 24),

                  // Social divider
                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.white.withOpacity(0.1))),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'or continue with',
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.4), fontSize: 13),
                        ),
                      ),
                      Expanded(child: Divider(color: Colors.white.withOpacity(0.1))),
                    ],
                  ),

                  const SizedBox(height: 18),

                  Row(
                    children: [
                      Expanded(child: _buildSocialBtn('Google', Icons.g_mobiledata)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildSocialBtn('Apple', Icons.apple)),
                    ],
                  ),

                  const SizedBox(height: 28),

                  Center(
                    child: GestureDetector(
                      onTap: _toggleMode,
                      child: RichText(
                        text: TextSpan(
                          text: isLogin
                              ? "Don't have an account? "
                              : 'Already have an account? ',
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.5), fontSize: 14),
                          children: [
                            TextSpan(
                              text: isLogin ? 'Sign Up' : 'Sign In',
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
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
          ),
        ),
      ),
    );
  }

  Widget _buildToggle(bool isLogin) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.darkBorder, width: 1),
      ),
      child: AnimatedBuilder(
        animation: _toggleAnim,
        builder: (_, __) {
          return Row(
            children: [
              Expanded(child: _toggleBtn('Sign In', isLogin)),
              Expanded(child: _toggleBtn('Sign Up', !isLogin)),
            ],
          );
        },
      ),
    );
  }

  Widget _toggleBtn(String label, bool active) {
    return GestureDetector(
      onTap: active ? null : _toggleMode,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          gradient: active
              ? const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark])
              : null,
          borderRadius: BorderRadius.circular(12),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.4),
                    blurRadius: 10,
                  )
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: active ? Colors.white : Colors.white.withOpacity(0.4),
              fontWeight: active ? FontWeight.w600 : FontWeight.w400,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      style: const TextStyle(color: Colors.white),
      validator: (v) => v!.length < 6 ? 'Password too short' : null,
      decoration: InputDecoration(
        labelText: 'Password',
        prefixIcon:
            const Icon(Icons.lock_outline_rounded, color: AppColors.primary, size: 20),
        suffixIcon: GestureDetector(
          onTap: () => setState(() => _obscurePassword = !_obscurePassword),
          child: Icon(
            _obscurePassword
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: AppColors.textSecondary,
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildSocialBtn(String label, IconData icon) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.darkBorder, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 22),
          const SizedBox(width: 8),
          Text(label,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w500, fontSize: 14)),
        ],
      ),
    );
  }
}
