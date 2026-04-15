import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/animations.dart';
import '../home/home_screen.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen>
    with TickerProviderStateMixin {
  late AnimationController _countUpController;
  late AnimationController _successController;
  late AnimationController _contentController;
  late Animation<double> _fare;
  late Animation<double> _successScale;
  late Animation<double> _successFade;
  late Animation<double> _contentFade;

  bool _paymentDone = false;
  bool _showSuccess = false;

  @override
  void initState() {
    super.initState();
    _countUpController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _successController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();

    _fare = Tween<double>(begin: 0, end: 285).animate(
      CurvedAnimation(parent: _countUpController, curve: Curves.easeOut),
    );
    _successScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _successController, curve: Curves.elasticOut),
    );
    _successFade = CurvedAnimation(parent: _successController, curve: Curves.easeIn);
    _contentFade = CurvedAnimation(parent: _contentController, curve: Curves.easeIn);

    _countUpController.forward();
  }

  @override
  void dispose() {
    _countUpController.dispose();
    _successController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pay() async {
    setState(() => _paymentDone = true);
    await Future.delayed(const Duration(milliseconds: 400));
    setState(() => _showSuccess = true);
    _successController.forward();
    await Future.delayed(const Duration(milliseconds: 2000));
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        FadeScalePageRoute(child: const HomeScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: _showSuccess ? _buildSuccessScreen() : _buildPaymentContent(),
    );
  }

  Widget _buildPaymentContent() {
    return SafeArea(
      child: FadeTransition(
        opacity: _contentFade,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 20),
              _buildHeader(),
              const SizedBox(height: 32),
              _buildFareBadge(),
              const SizedBox(height: 28),
              _buildBreakdown(),
              const SizedBox(height: 20),
              _buildRatingSummary(),
              const SizedBox(height: 20),
              _buildPaymentMethods(),
              const SizedBox(height: 32),
              _paymentDone
                  ? const CircularProgressIndicator(color: AppColors.primary)
                  : GradientButton(
                      text: 'Pay Now',
                      icon: Icons.payment_rounded,
                      onPressed: _pay,
                      colors: const [AppColors.success, Color(0xFF00A876)],
                    ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.secondary],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.4),
                blurRadius: 20,
              ),
            ],
          ),
          child: const Icon(Icons.receipt_rounded, color: Colors.white, size: 36),
        ),
        const SizedBox(height: 16),
        const Text(
          'Trip Summary',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Today, 3:45 PM  •  8.4 km  •  26 min',
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildFareBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1A35), Color(0xFF12122A)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.1),
            blurRadius: 20,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Total Fare',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          AnimatedBuilder(
            animation: _fare,
            builder: (_, __) {
              return ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary],
                ).createShader(bounds),
                child: Text(
                  '₹${_fare.value.toInt()}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 56,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdown() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Fare Details',
              style: TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16)),
          const SizedBox(height: 14),
          _row('Base Fare', '₹89'),
          _row('Distance (8.4 km)', '₹126'),
          _row('Taxes & Fees', '₹35'),
          _row('Promo (RIDE15)', '-₹15', color: AppColors.success),
          Divider(color: Colors.white.withOpacity(0.08), height: 24),
          _row('Total', '₹285', isBold: true, color: AppColors.primary),
        ],
      ),
    );
  }

  Widget _row(String label, String value,
      {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Text(label,
              style: TextStyle(
                  color: Colors.white.withOpacity(isBold ? 1 : 0.55),
                  fontWeight:
                      isBold ? FontWeight.w700 : FontWeight.w400,
                  fontSize: isBold ? 16 : 14)),
          const Spacer(),
          Text(value,
              style: TextStyle(
                  color: color ?? Colors.white,
                  fontWeight:
                      isBold ? FontWeight.w700 : FontWeight.w500,
                  fontSize: isBold ? 16 : 14)),
        ],
      ),
    );
  }

  Widget _buildRatingSummary() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Rate Your Ride',
              style: TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Icon(Icons.star_rounded,
                    color: i < 4 ? AppColors.warning : AppColors.darkBorder,
                    size: 36),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethods() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Pay With',
              style: TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16)),
          const SizedBox(height: 12),
          _payOption(Icons.payments_rounded, 'Cash', '₹285 to driver', true),
          const SizedBox(height: 8),
          _payOption(Icons.credit_card_rounded, 'Card', '**** 4242', false),
          const SizedBox(height: 8),
          _payOption(Icons.qr_code_rounded, 'UPI', 'user@upi', false),
        ],
      ),
    );
  }

  Widget _payOption(
      IconData icon, String name, String sub, bool isSelected) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.primary.withOpacity(0.1)
            : AppColors.darkSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.darkBorder,
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: isSelected ? AppColors.primary : AppColors.textSecondary, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        fontSize: 14)),
                Text(sub,
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.4), fontSize: 12)),
              ],
            ),
          ),
          if (isSelected)
            const Icon(Icons.check_circle_rounded,
                color: AppColors.primary, size: 20),
        ],
      ),
    );
  }

  Widget _buildSuccessScreen() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0A1A12), Color(0xFF0A2A18), Color(0xFF0A0A1A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: ScaleTransition(
          scale: _successScale,
          child: FadeTransition(
            opacity: _successFade,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildCheckAnimation(),
                const SizedBox(height: 24),
                const Text(
                  'Payment Successful!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '₹285 paid successfully',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Thank you for riding with RideNow!',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.4),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCheckAnimation() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeOutBack,
      builder: (_, value, __) {
        return Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.success.withOpacity(0.15),
            border: Border.all(
                color: AppColors.success.withOpacity(0.5 * value), width: 2),
            boxShadow: [
              BoxShadow(
                color: AppColors.success.withOpacity(0.3 * value),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Icon(
            Icons.check_rounded,
            color: AppColors.success.withOpacity(value),
            size: 64,
          ),
        );
      },
    );
  }
}
