import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/animations.dart';
import '../driver_assigned/driver_assigned_screen.dart';

class BookingConfirmationScreen extends StatefulWidget {
  const BookingConfirmationScreen({super.key});

  @override
  State<BookingConfirmationScreen> createState() =>
      _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState extends State<BookingConfirmationScreen>
    with TickerProviderStateMixin {
  late AnimationController _contentController;
  late Animation<double> _contentFade;
  late Animation<Offset> _contentSlide;

  bool _fareExpanded = false;
  bool _isBooking = false;
  String _selectedPayment = 'Cash';

  @override
  void initState() {
    super.initState();
    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();

    _contentFade = CurvedAnimation(parent: _contentController, curve: Curves.easeIn);
    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _contentController, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _confirmBooking() async {
    setState(() => _isBooking = true);
    await Future.delayed(const Duration(milliseconds: 1500));
    if (mounted) {
      Navigator.pushReplacement(
        context,
        FadeScalePageRoute(child: const DriverAssignedScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.darkCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.darkBorder, width: 1),
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.white, size: 16),
          ),
        ),
        title: const Text('Booking Summary',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18)),
      ),
      body: SlideTransition(
        position: _contentSlide,
        child: FadeTransition(
          opacity: _contentFade,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildRideSummary(),
                const SizedBox(height: 16),
                _buildFareBreakdown(),
                const SizedBox(height: 16),
                _buildPaymentOptions(),
                const SizedBox(height: 16),
                _buildPromoCode(),
                const SizedBox(height: 24),

                // Confirm button
                _isBooking
                    ? Column(
                        children: [
                          const CircularProgressIndicator(
                            color: AppColors.primary,
                            strokeWidth: 3,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Finding your driver...',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      )
                    : GradientButton(
                        text: 'Confirm Booking  •  ₹285',
                        icon: Icons.check_circle_outline_rounded,
                        onPressed: _confirmBooking,
                        colors: const [AppColors.success, Color(0xFF00A876)],
                      ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRideSummary() {
    return GlassCard(
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: AppColors.primary.withOpacity(0.3), width: 1),
                ),
                child: const Center(
                    child: Text('🚗', style: TextStyle(fontSize: 28))),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('RideMini',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 18)),
                    Text('Compact & comfortable • 3 seats',
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.5), fontSize: 13)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('4 min',
                    style: TextStyle(
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                        fontSize: 13)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _routeItem('📍', 'Sector 15, Noida', AppColors.success),
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Column(
              children: List.generate(
                  3,
                  (_) => Container(
                      margin: const EdgeInsets.symmetric(vertical: 2),
                      width: 2,
                      height: 6,
                      color: AppColors.primary.withOpacity(0.3))),
            ),
          ),
          _routeItem('🏁', 'Airport, Terminal 2', AppColors.error),
        ],
      ),
    );
  }

  Widget _routeItem(String emoji, String address, Color color) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            address,
            style: const TextStyle(
                color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ),
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
      ],
    );
  }

  Widget _buildFareBreakdown() {
    return GlassCard(
      child: Column(
        children: [
          GestureDetector(
            onTap: () => setState(() => _fareExpanded = !_fareExpanded),
            child: Row(
              children: [
                const Icon(Icons.receipt_long_rounded,
                    color: AppColors.primary, size: 22),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text('Fare Breakdown',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16)),
                ),
                const Text('₹285',
                    style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 18)),
                const SizedBox(width: 8),
                AnimatedRotation(
                  turns: _fareExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 300),
                  child: const Icon(Icons.keyboard_arrow_down_rounded,
                      color: Colors.white, size: 22),
                ),
              ],
            ),
          ),

          // Animated expand
          AnimatedSize(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOut,
            child: _fareExpanded
                ? Padding(
                    padding: const EdgeInsets.only(top: 14),
                    child: Column(
                      children: [
                        Divider(color: Colors.white.withOpacity(0.05)),
                        const SizedBox(height: 8),
                        _fareRow('Base fare', '₹89'),
                        _fareRow('Distance (8.4 km)', '₹126'),
                        _fareRow('Taxes & fees', '₹35'),
                        _fareRow('Promo discount', '-₹15',
                            color: AppColors.success),
                        const SizedBox(height: 8),
                        Divider(color: Colors.white.withOpacity(0.05)),
                        _fareRow('Total', '₹285',
                            isBold: true, color: AppColors.primary),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _fareRow(String label, String value,
      {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(label,
              style: TextStyle(
                  color: Colors.white.withOpacity(isBold ? 1 : 0.6),
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

  Widget _buildPaymentOptions() {
    final options = [
      ('Cash', Icons.payments_rounded, AppColors.success),
      ('Card', Icons.credit_card_rounded, AppColors.primary),
      ('UPI', Icons.qr_code_rounded, AppColors.secondary),
    ];

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Payment Method',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16)),
          const SizedBox(height: 12),
          Row(
            children: options.map((opt) {
              final isSelected = _selectedPayment == opt.$1;
              return Expanded(
                child: GestureDetector(
                  onTap: () =>
                      setState(() => _selectedPayment = opt.$1),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? opt.$3.withOpacity(0.15)
                          : AppColors.darkSurface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: isSelected
                              ? opt.$3
                              : AppColors.darkBorder,
                          width: isSelected ? 2 : 1),
                    ),
                    child: Column(
                      children: [
                        Icon(opt.$2,
                            color: isSelected
                                ? opt.$3
                                : Colors.white.withOpacity(0.4),
                            size: 22),
                        const SizedBox(height: 4),
                        Text(opt.$1,
                            style: TextStyle(
                              color: isSelected
                                  ? opt.$3
                                  : Colors.white.withOpacity(0.4),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            )),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPromoCode() {
    return GlassCard(
      child: Row(
        children: [
          const Icon(Icons.local_offer_rounded,
              color: AppColors.warning, size: 22),
          const SizedBox(width: 10),
          const Expanded(
            child: Text('Apply Promo Code',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w500)),
          ),
          Text('RIDE15',
              style: TextStyle(
                  color: AppColors.warning,
                  fontWeight: FontWeight.w700,
                  fontSize: 14)),
          const SizedBox(width: 4),
          const Icon(Icons.check_circle_rounded,
              color: AppColors.success, size: 18),
        ],
      ),
    );
  }
}
