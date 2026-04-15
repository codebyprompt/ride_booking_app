import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/animations.dart';
import '../booking_confirmation/booking_confirmation_screen.dart';

class PickupDropScreen extends StatefulWidget {
  const PickupDropScreen({super.key});

  @override
  State<PickupDropScreen> createState() => _PickupDropScreenState();
}

class _PickupDropScreenState extends State<PickupDropScreen>
    with TickerProviderStateMixin {
  late AnimationController _swapController;
  late AnimationController _pinController;
  late AnimationController _routeController;
  late Animation<double> _swapRotation;
  late Animation<double> _pinBounce;
  late Animation<double> _routeProgress;

  final _pickupController = TextEditingController(text: 'Sector 15, Noida');
  final _dropController = TextEditingController();
  bool _pickupFocused = false;
  bool _dropFocused = false;

  @override
  void initState() {
    super.initState();
    _swapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _pinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _routeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _swapRotation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _swapController, curve: Curves.easeInOut),
    );
    _pinBounce = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _pinController, curve: Curves.elasticOut),
    );
    _routeProgress = CurvedAnimation(
      parent: _routeController,
      curve: Curves.easeInOut,
    );

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _pinController.forward();
        _routeController.forward();
      }
    });
  }

  @override
  void dispose() {
    _swapController.dispose();
    _pinController.dispose();
    _routeController.dispose();
    _pickupController.dispose();
    _dropController.dispose();
    super.dispose();
  }

  void _swap() {
    final pickup = _pickupController.text;
    final drop = _dropController.text;
    _swapController.forward(from: 0);
    setState(() {
      _pickupController.text = drop;
      _dropController.text = pickup;
    });
    _routeController.reset();
    _routeController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            const SizedBox(height: 16),
            _buildInputSection(),
            const SizedBox(height: 8),
            Expanded(child: _buildMapWithRoute()),
            _buildConfirmButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.darkCard,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.darkBorder, width: 1),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white, size: 18),
            ),
          ),
          const SizedBox(width: 14),
          const Text(
            'Set Your Route',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.darkBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.1),
            blurRadius: 20,
          ),
        ],
      ),
      child: Column(
        children: [
          // Pickup
          _buildLocationInput(
            controller: _pickupController,
            label: 'Pickup Location',
            color: AppColors.success,
            isFocused: _pickupFocused,
            onFocus: (f) => setState(() => _pickupFocused = f),
          ),

          const SizedBox(height: 8),

          // Line + swap button
          Row(
            children: [
              const SizedBox(width: 18),
              Container(width: 2, height: 24, color: AppColors.darkBorder),
              const Spacer(),
              GestureDetector(
                onTap: _swap,
                child: RotationTransition(
                  turns: _swapRotation,
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.secondary],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.swap_vert_rounded,
                        color: Colors.white, size: 18),
                  ),
                ),
              ),
              const SizedBox(width: 6),
            ],
          ),

          const SizedBox(height: 8),

          // Drop
          _buildLocationInput(
            controller: _dropController,
            label: 'Drop Location',
            color: AppColors.error,
            isFocused: _dropFocused,
            onFocus: (f) => setState(() => _dropFocused = f),
            hint: 'Where to?',
          ),
        ],
      ),
    );
  }

  Widget _buildLocationInput({
    required TextEditingController controller,
    required String label,
    required Color color,
    required bool isFocused,
    required Function(bool) onFocus,
    String? hint,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isFocused
            ? color.withOpacity(0.08)
            : AppColors.darkSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isFocused ? color : AppColors.darkBorder,
          width: isFocused ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Focus(
              onFocusChange: onFocus,
              child: TextField(
                controller: controller,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  hintText: hint ?? label,
                  hintStyle: TextStyle(
                      color: Colors.white.withOpacity(0.3), fontSize: 14),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ),
          if (controller.text.isNotEmpty)
            GestureDetector(
              onTap: () => setState(() => controller.clear()),
              child: Icon(Icons.close_rounded,
                  color: Colors.white.withOpacity(0.3), size: 18),
            ),
        ],
      ),
    );
  }

  Widget _buildMapWithRoute() {
    return Stack(
      children: [
        // Mock map
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0E1B2A), Color(0xFF1A2D40)],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.darkBorder, width: 1),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: CustomPaint(
              painter: MapGridPainter3(),
              child: AnimatedBuilder(
                animation: _routeProgress,
                builder: (_, __) {
                  return CustomPaint(
                    painter: RouteDrawPainter(_routeProgress.value),
                    child: Container(),
                  );
                },
              ),
            ),
          ),
        ),

        // Pickup pin
        Positioned(
          top: 60,
          left: 80,
          child: AnimatedBuilder(
            animation: _pinBounce,
            builder: (_, __) {
              return Transform.translate(
                offset: Offset(0, -20 * (1 - _pinBounce.value)),
                child: _buildPin('📍', AppColors.success),
              );
            },
          ),
        ),

        // Drop pin
        Positioned(
          bottom: 80,
          right: 80,
          child: AnimatedBuilder(
            animation: _pinBounce,
            builder: (_, __) {
              return Transform.translate(
                offset: Offset(0, -15 * (1 - _pinBounce.value)),
                child: _buildPin('🏁', AppColors.error),
              );
            },
          ),
        ),

        // Distance badge center
        Center(
          child: FadeTransition(
            opacity: _routeProgress,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.darkCard.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primary.withOpacity(0.5), width: 1),
              ),
              child: const Text(
                '⏱ ~12 min  •  8.4 km',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPin(String emoji, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 30)),
        Container(
          width: 2,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(0.4),
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: GradientButton(
        text: 'Confirm Route',
        icon: Icons.check_circle_outline_rounded,
        onPressed: () {
          if (_dropController.text.isNotEmpty) {
            Navigator.push(
              context,
              FadeScalePageRoute(child: const BookingConfirmationScreen()),
            );
          }
        },
      ),
    );
  }
}

class MapGridPainter3 extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1E3A5F).withOpacity(0.5)
      ..strokeWidth = 1.0;
    for (double y = 0; y < size.height; y += 35) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    for (double x = 0; x < size.width; x += 45) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class RouteDrawPainter extends CustomPainter {
  final double progress;
  RouteDrawPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width * 0.2, size.height * 0.25)
      ..cubicTo(
        size.width * 0.3, size.height * 0.1,
        size.width * 0.7, size.height * 0.9,
        size.width * 0.8, size.height * 0.75,
      );

    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      final extractPath = metric.extractPath(0, metric.length * progress);
      final paint = Paint()
        ..color = AppColors.primary
        ..strokeWidth = 3.0
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      canvas.drawPath(extractPath, paint);
    }
  }

  @override
  bool shouldRepaint(RouteDrawPainter old) => old.progress != progress;
}
