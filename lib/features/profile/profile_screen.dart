import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/animations.dart';
import '../../providers/app_providers.dart';
import '../auth/auth_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with TickerProviderStateMixin {
  late AnimationController _headerController;
  late AnimationController _menuController;
  late AnimationController _logoutController;
  late Animation<double> _headerFade;
  late Animation<Offset> _headerSlide;
  late Animation<double> _menuFade;
  late Animation<double> _logoutShake;

  final _logoutKey = GlobalKey<ShakeWidgetState>();

  @override
  void initState() {
    super.initState();
    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
    _menuController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _logoutController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _headerFade = CurvedAnimation(parent: _headerController, curve: Curves.easeIn);
    _headerSlide = Tween<Offset>(
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _headerController, curve: Curves.easeOutCubic));
    _menuFade = CurvedAnimation(parent: _menuController, curve: Curves.easeIn);
    _logoutShake = Tween<double>(begin: 0, end: 1).animate(_logoutController);

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _menuController.forward();
    });
  }

  @override
  void dispose() {
    _headerController.dispose();
    _menuController.dispose();
    _logoutController.dispose();
    super.dispose();
  }

  void _logout() {
    _logoutKey.currentState?.shake();
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        ref.read(isLoggedInProvider.notifier).state = false;
        Navigator.of(context).pushAndRemoveUntil(
          FadeScalePageRoute(child: const AuthScreen()),
          (route) => false,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile header
            SlideTransition(
              position: _headerSlide,
              child: FadeTransition(
                opacity: _headerFade,
                child: _buildProfileHeader(),
              ),
            ),

            const SizedBox(height: 24),

            // Stats row
            FadeTransition(
              opacity: _menuFade,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildStatsRow(),
              ),
            ),

            const SizedBox(height: 24),

            // Menu items
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _buildMenuSection('Account', [
                    _MenuItem(Icons.person_outline_rounded, 'Personal Info',
                        'Update your profile'),
                    _MenuItem(Icons.shield_outlined, 'Safety',
                        'Emergency contacts'),
                    _MenuItem(Icons.notifications_outlined, 'Notifications',
                        'Manage alerts'),
                  ]),
                  const SizedBox(height: 20),
                  _buildMenuSection('Payments', [
                    _MenuItem(Icons.credit_card_rounded, 'Saved Cards',
                        '2 cards linked'),
                    _MenuItem(Icons.local_offer_rounded, 'Promotions',
                        '3 active coupons'),
                    _MenuItem(Icons.history_rounded, 'Transactions',
                        'View all payments'),
                  ]),
                  const SizedBox(height: 20),
                  _buildMenuSection('Support', [
                    _MenuItem(Icons.help_outline_rounded, 'Help Center',
                        'FAQs & support'),
                    _MenuItem(Icons.feedback_outlined, 'Rate the App',
                        'Share feedback'),
                    _MenuItem(Icons.info_outline_rounded, 'About',
                        'Version 1.0.0'),
                  ]),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Logout
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ShakeWidget(
                key: _logoutKey,
                child: GestureDetector(
                  onTap: _logout,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: AppColors.error.withOpacity(0.4), width: 1),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.logout_rounded, color: AppColors.error, size: 20),
                        SizedBox(width: 10),
                        Text('Sign Out',
                            style: TextStyle(
                                color: AppColors.error,
                                fontWeight: FontWeight.w700,
                                fontSize: 16)),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1A0A42), Color(0xFF0A0A1A)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: Column(
            children: [
              Row(
                children: [
                  const Text(
                    'Profile',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.darkCard,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.darkBorder, width: 1),
                    ),
                    child: const Icon(Icons.edit_rounded,
                        color: Colors.white, size: 18),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Hero(
                tag: 'profile_image',
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.secondary],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.5),
                            blurRadius: 20,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Center(
                          child: Text('👤', style: TextStyle(fontSize: 48))),
                    ),
                    Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.darkBg, width: 2),
                      ),
                      child: const Icon(Icons.check_rounded,
                          color: Colors.white, size: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Alex Johnson',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'alex.johnson@email.com',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star_rounded,
                      color: AppColors.warning, size: 16),
                  const SizedBox(width: 4),
                  const Text('4.8 Rating',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        _statCard('48', 'Total Rides', Icons.directions_car_rounded, AppColors.primary),
        const SizedBox(width: 12),
        _statCard('₹4.2k', 'Total Spent', Icons.payments_rounded, AppColors.secondary),
        const SizedBox(width: 12),
        _statCard('320', 'km Traveled', Icons.route_rounded, AppColors.accent),
      ],
    );
  }

  Widget _statCard(String value, String label, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(value,
                style: TextStyle(
                    color: color, fontWeight: FontWeight.w800, fontSize: 16)),
            Text(label,
                style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 10),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuSection(String title, List<_MenuItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: TextStyle(
                color: Colors.white.withOpacity(0.4),
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2)),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: AppColors.darkCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.darkBorder, width: 1),
          ),
          child: Column(
            children: items.asMap().entries.map((entry) {
              final i = entry.key;
              final item = entry.value;
              return StaggeredAnimationBuilder(
                index: i,
                delay: const Duration(milliseconds: 50),
                child: _buildMenuItem(item, i == items.length - 1),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(_MenuItem item, bool isLast) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(item.icon, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.title,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 14)),
                    Text(item.subtitle,
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.4),
                            fontSize: 12)),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded,
                  color: Colors.white.withOpacity(0.2), size: 14),
            ],
          ),
        ),
        if (!isLast)
          Divider(
              height: 1,
              indent: 66,
              color: AppColors.darkBorder.withOpacity(0.5)),
      ],
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String title;
  final String subtitle;

  _MenuItem(this.icon, this.title, this.subtitle);
}
