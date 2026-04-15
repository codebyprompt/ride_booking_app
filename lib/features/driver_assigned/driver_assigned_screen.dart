import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/animations.dart';
import '../ride_progress/ride_progress_screen.dart';

class DriverAssignedScreen extends StatefulWidget {
  const DriverAssignedScreen({super.key});

  @override
  State<DriverAssignedScreen> createState() => _DriverAssignedScreenState();
}

class _DriverAssignedScreenState extends State<DriverAssignedScreen>
    with TickerProviderStateMixin {
  late AnimationController _cardController;
  late AnimationController _carController;
  late AnimationController _pulseController;

  late Animation<Offset> _cardSlide;
  late Animation<double> _cardFade;
  late Animation<double> _carX;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _cardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _carController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    )..repeat(reverse: true);
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _cardSlide = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _cardController, curve: Curves.easeOutCubic));
    _cardFade = CurvedAnimation(parent: _cardController, curve: Curves.easeIn);
    _carX = Tween<double>(begin: 0.15, end: 0.75).animate(
      CurvedAnimation(parent: _carController, curve: Curves.easeInOut),
    );
    _pulse = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _cardController.forward();
    });
  }

  @override
  void dispose() {
    _cardController.dispose();
    _carController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: Stack(
        children: [
          // Map with animated car
          _buildMapWithCar(),

          // Driver card from bottom
          Align(
            alignment: Alignment.bottomCenter,
            child: SlideTransition(
              position: _cardSlide,
              child: FadeTransition(
                opacity: _cardFade,
                child: _buildDriverCard(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapWithCar() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.55,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0E1B2A), Color(0xFF1A2D40), Color(0xFF0A1520)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          CustomPaint(
            size: Size(
              double.infinity,
              MediaQuery.of(context).size.height * 0.55,
            ),
            painter: MapGridPainter(),
          ),

          // Destination marker
          Positioned(
            right: 80,
            top: 120,
            child: _buildMapMarker('🏁', AppColors.error),
          ),

          // Moving car
          AnimatedBuilder(
            animation: _carX,
            builder: (_, __) {
              return Positioned(
                left: MediaQuery.of(context).size.width * _carX.value,
                top: 180,
                child: Transform.rotate(
                  angle: _carController.status == AnimationStatus.forward
                      ? 0
                      : 3.14159,
                  child: Text('🚗',
                      style: const TextStyle(fontSize: 28)),
                ),
              );
            },
          ),

          // Pulse marker for driver
          Positioned(
            left: 60,
            top: 200,
            child: AnimatedBuilder(
              animation: _pulse,
              builder: (_, child) {
                return Transform.scale(
                  scale: _pulse.value,
                  child: child,
                );
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withOpacity(0.3),
                  border: Border.all(color: AppColors.primary, width: 2),
                ),
                child: const Icon(Icons.navigation_rounded,
                    color: Colors.white, size: 20),
              ),
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

          // ETA badge
          Positioned(
            top: 24,
            right: 16,
            child: SafeArea(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.darkCard.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: AppColors.primary.withOpacity(0.4), width: 1),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.access_time_rounded,
                        color: AppColors.primary, size: 16),
                    SizedBox(width: 6),
                    Text('4 min away',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 13)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapMarker(String emoji, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 30)),
        Container(
          width: 2,
          height: 12,
          color: color,
        ),
      ],
    );
  }

  Widget _buildDriverCard(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
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
          const SizedBox(height: 16),

          // Status banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark]),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.directions_car_rounded,
                    color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text('Driver Assigned!',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15)),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Driver info
          Row(
            children: [
              // Hero profile image
              Hero(
                tag: 'driver_profile',
                child: Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.secondary],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.4),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text('👨', style: TextStyle(fontSize: 36)),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Rajesh Kumar',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 18)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded,
                            color: AppColors.warning, size: 16),
                        const SizedBox(width: 4),
                        const Text('4.9',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14)),
                        const SizedBox(width: 8),
                        Text('2,481 trips',
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.5),
                                fontSize: 13)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                                color: AppColors.primary.withOpacity(0.3)),
                          ),
                          child: const Text('MH 02 AB 1234',
                              style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12)),
                        ),
                        const SizedBox(width: 8),
                        Text('Swift Dzire',
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.5),
                                fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: _actionButton(
                    Icons.call_rounded, 'Call', AppColors.success, () {}),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _actionButton(
                    Icons.message_rounded, 'Message', AppColors.secondary, () {}),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _actionButton(
                    Icons.share_location_rounded, 'Share', AppColors.warning, () {}),
              ),
            ],
          ),

          const SizedBox(height: 20),

          GradientButton(
            text: 'View Ride Progress',
            icon: Icons.route_rounded,
            onPressed: () => Navigator.push(
              context,
              FadeScalePageRoute(child: const RideProgressScreen()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton(
      IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedBuilder(
        animation: _pulse,
        builder: (_, child) {
          return Transform.scale(
            scale: label == 'Call' ? _pulse.value * 0.97 + 0.03 : 1.0,
            child: child,
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withOpacity(0.4), width: 1),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 4),
              Text(label,
                  style: TextStyle(
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }
}

// Re-export the painter
class MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1E3A5F).withOpacity(0.4)
      ..strokeWidth = 1.0;
    for (double y = 0; y < size.height; y += 60) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    for (double x = 0; x < size.width; x += 80) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    final highwayPaint = Paint()
      ..color = const Color(0xFF2563EB).withOpacity(0.2)
      ..strokeWidth = 3.0;
    canvas.drawLine(
      Offset(0, size.height * 0.3),
      Offset(size.width, size.height * 0.7),
      highwayPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
