import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/animations.dart';
import '../../providers/app_providers.dart';
import '../payment/payment_screen.dart';

class RideProgressScreen extends ConsumerStatefulWidget {
  const RideProgressScreen({super.key});

  @override
  ConsumerState<RideProgressScreen> createState() => _RideProgressScreenState();
}

class _RideProgressScreenState extends ConsumerState<RideProgressScreen>
    with TickerProviderStateMixin {
  late AnimationController _statusController;
  late AnimationController _carController;
  late AnimationController _progressController;
  late Animation<double> _statusFade;
  late Animation<double> _carPosition;
  late Animation<double> _progress;

  int _statusIndex = 0;
  final List<Map<String, dynamic>> _statuses = [
    {
      'text': 'Driver Arriving',
      'sub': 'Your driver is on the way',
      'icon': '🚗',
      'color': AppColors.warning,
      'progress': 0.15,
    },
    {
      'text': 'Ride Started',
      'sub': 'On the way to your destination',
      'icon': '🛣️',
      'color': AppColors.primary,
      'progress': 0.55,
    },
    {
      'text': 'You\'ve Arrived!',
      'sub': 'You have reached your destination',
      'icon': '🏁',
      'color': AppColors.success,
      'progress': 1.0,
    },
  ];

  @override
  void initState() {
    super.initState();
    _statusController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
    _carController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: false);
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..forward();

    _statusFade = CurvedAnimation(parent: _statusController, curve: Curves.easeIn);
    _carPosition = Tween<double>(begin: 0.05, end: 0.80).animate(
      CurvedAnimation(parent: _carController, curve: Curves.easeInOut),
    );
    _progress = Tween<double>(
      begin: 0,
      end: _statuses[_statusIndex]['progress'],
    ).animate(CurvedAnimation(parent: _progressController, curve: Curves.easeOut));

    // Auto cycle statuses for demo
    Future.delayed(const Duration(seconds: 3), _nextStatus);
  }

  void _nextStatus() {
    if (!mounted) return;
    if (_statusIndex < _statuses.length - 1) {
      _statusController.reset();
      setState(() => _statusIndex++);
      _statusController.forward();
      _progressController.reset();
      _progress = Tween<double>(
        begin: _statuses[_statusIndex - 1]['progress'],
        end: _statuses[_statusIndex]['progress'],
      ).animate(CurvedAnimation(parent: _progressController, curve: Curves.easeOut));
      _progressController.forward();
      Future.delayed(const Duration(seconds: 3), _nextStatus);
    }
  }

  @override
  void dispose() {
    _statusController.dispose();
    _carController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final status = _statuses[_statusIndex];

    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: Stack(
        children: [
          _buildMapSection(),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppColors.darkSurface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Status with fade animation
                  FadeTransition(
                    opacity: _statusFade,
                    child: Column(
                      children: [
                        Text(
                          status['icon'],
                          style: const TextStyle(fontSize: 48),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          status['text'],
                          style: TextStyle(
                            color: status['color'],
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          status['sub'],
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Progress bar
                  _buildProgressBar(status['color']),

                  const SizedBox(height: 16),

                  // Status steps
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: _statuses.asMap().entries.map((entry) {
                      final i = entry.key;
                      final s = entry.value;
                      final isDone = i <= _statusIndex;
                      return _statusStep(
                          s['text'].toString().split(' ')[0], isDone, s['color']);
                    }).toList(),
                  ),

                  const SizedBox(height: 20),

                  // Driver info strip
                  _buildDriverStrip(),

                  const SizedBox(height: 16),

                  if (_statusIndex == _statuses.length - 1)
                    GradientButton(
                      text: 'Proceed to Payment',
                      icon: Icons.payment_rounded,
                      onPressed: () => Navigator.pushReplacement(
                        context,
                        FadeScalePageRoute(child: const PaymentScreen()),
                      ),
                      colors: const [AppColors.success, Color(0xFF00A876)],
                    )
                  else
                    GradientButton(
                      text: 'SOS Emergency',
                      icon: Icons.sos_rounded,
                      onPressed: () {},
                      colors: const [AppColors.error, Color(0xFFCC1111)],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapSection() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.48,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0E1B2A), Color(0xFF1A2D40)],
        ),
      ),
      child: Stack(
        children: [
          CustomPaint(
            size: Size(
              double.infinity,
              MediaQuery.of(context).size.height * 0.48,
            ),
            painter: _ProgressMapPainter(),
          ),

          // Route drawn
          CustomPaint(
            painter: _RouteLinePainter(),
            child: Container(),
          ),

          // Animated car on route
          AnimatedBuilder(
            animation: _carPosition,
            builder: (_, __) {
              return Positioned(
                left: MediaQuery.of(context).size.width * _carPosition.value,
                top: 160 + (_carPosition.value - 0.4).abs() * 50,
                child: Transform.rotate(
                  angle: _carPosition.value > 0.4 ? 0.3 : -0.3,
                  child: const Text('🚗', style: TextStyle(fontSize: 30)),
                ),
              );
            },
          ),

          // Destination pin
          Positioned(
            right: 60,
            top: 100,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🏁', style: TextStyle(fontSize: 28)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.error.withOpacity(0.5)),
                  ),
                  child: const Text('Airport',
                      style: TextStyle(
                          color: AppColors.error, fontSize: 11, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),

          // Back button
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.darkCard.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.darkBorder, width: 1),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: Colors.white, size: 18),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Route Progress',
                style: TextStyle(
                    color: Colors.white.withOpacity(0.5), fontSize: 12)),
            AnimatedBuilder(
              animation: _progress,
              builder: (_, __) => Text(
                '${(_progress.value * 100).toInt()}%',
                style: TextStyle(
                    color: color, fontWeight: FontWeight.w700, fontSize: 14),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Container(
            height: 8,
            color: AppColors.darkCard,
            child: AnimatedBuilder(
              animation: _progress,
              builder: (_, __) {
                return FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: _progress.value,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [color, color.withOpacity(0.6)],
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _statusStep(String label, bool isDone, Color color) {
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDone ? color.withOpacity(0.2) : AppColors.darkCard,
            border: Border.all(
              color: isDone ? color : AppColors.darkBorder,
              width: 2,
            ),
          ),
          child: Icon(
            isDone ? Icons.check_rounded : Icons.circle_outlined,
            color: isDone ? color : AppColors.textSecondary,
            size: 16,
          ),
        ),
        const SizedBox(height: 4),
        Text(label,
            style: TextStyle(
              color: isDone ? color : Colors.white.withOpacity(0.3),
              fontSize: 11,
              fontWeight: isDone ? FontWeight.w600 : FontWeight.w400,
            )),
      ],
    );
  }

  Widget _buildDriverStrip() {
    return Hero(
      tag: 'driver_profile',
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.darkCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.darkBorder, width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary],
                ),
              ),
              child: const Center(
                  child: Text('👨', style: TextStyle(fontSize: 24))),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Rajesh Kumar',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 15)),
                  Text('MH 02 AB 1234 • Swift Dzire',
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 12)),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {},
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: AppColors.success.withOpacity(0.4), width: 1),
                ),
                child: const Icon(Icons.call_rounded,
                    color: AppColors.success, size: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1E3A5F).withOpacity(0.4)
      ..strokeWidth = 1.0;
    for (double y = 0; y < size.height; y += 50) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    for (double x = 0; x < size.width; x += 70) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}

class _RouteLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary.withOpacity(0.6)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(size.width * 0.05, size.height * 0.6)
      ..cubicTo(
        size.width * 0.2,
        size.height * 0.3,
        size.width * 0.6,
        size.height * 0.8,
        size.width * 0.9,
        size.height * 0.25,
      );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}
