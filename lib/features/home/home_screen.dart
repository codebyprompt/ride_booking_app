import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/animations.dart';

import '../ride_selection/ride_selection_screen.dart';
import '../pickup_drop/pickup_drop_screen.dart';
import '../ride_history/ride_history_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _mapFadeController;
  late AnimationController _searchBarController;
  late AnimationController _bottomSheetController;
  late AnimationController _markerController;

  late Animation<double> _mapFade;
  late Animation<Offset> _searchBarSlide;
  late Animation<Offset> _bottomSheetSlide;
  late Animation<double> _markerPulse;

  int _currentIndex = 0;

  final DraggableScrollableController _draggableController =
      DraggableScrollableController();

  @override
  void initState() {
    super.initState();
    _mapFadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _searchBarController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _bottomSheetController = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _markerController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat();

    _mapFade = CurvedAnimation(parent: _mapFadeController, curve: Curves.easeIn);
    _searchBarSlide = Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _searchBarController, curve: Curves.easeOutCubic));
    _bottomSheetSlide = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _bottomSheetController, curve: Curves.easeOutCubic));
    _markerPulse = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(parent: _markerController, curve: Curves.easeOut),
    );

    _startAnimations();
  }

  Future<void> _startAnimations() async {
    _mapFadeController.forward();
    await Future.delayed(const Duration(milliseconds: 400));
    _searchBarController.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    _bottomSheetController.forward();
  }

  @override
  void dispose() {
    _mapFadeController.dispose();
    _searchBarController.dispose();
    _bottomSheetController.dispose();
    _markerController.dispose();
    _draggableController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildMapScreen(),
          const RideHistoryScreen(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildMapScreen() {
    return Stack(
      children: [
        // Mock Map background
        FadeTransition(
          opacity: _mapFade,
          child: _buildMockMap(),
        ),

        // Search bar from top
        SafeArea(
          child: SlideTransition(
            position: _searchBarSlide,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: _buildSearchBar(),
            ),
          ),
        ),

        // Bottom sheet
        SlideTransition(
          position: _bottomSheetSlide,
          child: _buildBottomSheet(),
        ),
      ],
    );
  }

  Widget _buildMockMap() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0E1B2A), Color(0xFF1A2D40), Color(0xFF0A1520)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // Grid lines (map roads)
          CustomPaint(
            size: Size.infinite,
            painter: MapGridPainter(),
          ),

          // Location marker center
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedBuilder(
                  animation: _markerPulse,
                  builder: (_, child) {
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 60 * _markerPulse.value,
                          height: 60 * _markerPulse.value,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary.withOpacity(
                                0.3 * (1 - (_markerPulse.value - 1) / 0.5)),
                          ),
                        ),
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.primary, AppColors.secondary],
                            ),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.5),
                                blurRadius: 12,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
                Container(
                  width: 2,
                  height: 20,
                  color: Colors.white,
                ),
              ],
            ),
          ),

          // Map labels
          Positioned(
            top: 200,
            left: 40,
            child: _mapLabel('Main Street'),
          ),
          Positioned(
            top: 160,
            right: 60,
            child: _mapLabel('Tech Park'),
          ),
          Positioned(
            bottom: 350,
            left: 80,
            child: _mapLabel('City Center'),
          ),

          // My location button
          Positioned(
            top: 160,
            right: 16,
            child: SafeArea(
              child: Column(
                children: [
                  _mapButton(Icons.my_location_rounded),
                  const SizedBox(height: 8),
                  _mapButton(Icons.add),
                  const SizedBox(height: 8),
                  _mapButton(Icons.remove),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _mapLabel(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: const TextStyle(
            color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _mapButton(IconData icon) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.darkCard.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.darkBorder, width: 1),
      ),
      child: Icon(icon, color: Colors.white, size: 18),
    );
  }

  Widget _buildSearchBar() {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        SlidePageRoute(child: const PickupDropScreen(), direction: AxisDirection.up),
      ),
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.darkCard.withOpacity(0.95),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.darkBorder, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 16),
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.success,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Where are you going?',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 15,
                ),
              ),
            ),
            Container(
              width: 40,
              height: 40,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary]),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.search_rounded, color: Colors.white, size: 20),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSheet() {
    return DraggableScrollableSheet(
      controller: _draggableController,
      initialChildSize: 0.32,
      minChildSize: 0.12,
      maxChildSize: 0.65,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.darkSurface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(color: AppColors.darkBorder, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 30,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: ListView(
            controller: scrollController,
            padding: EdgeInsets.zero,
            children: [
              _buildSheetHandle(),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Good Evening, Alex! 👋',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Where would you like to go?',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildQuickDestinations(),
                    const SizedBox(height: 16),
                    const Text(
                      'Recent Places',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildRecentPlace('Home', 'Sector 15, Noida', Icons.home_rounded),
                    const SizedBox(height: 8),
                    _buildRecentPlace('Office', 'Tech Park, Gurgaon', Icons.business_rounded),
                    const SizedBox(height: 8),
                    _buildRecentPlace('Gym', 'Fitness First, Sector 5', Icons.fitness_center_rounded),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSheetHandle() {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 12),
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildQuickDestinations() {
    return Row(
      children: [
        _quickDest('Airport', Icons.flight_rounded, AppColors.primary),
        const SizedBox(width: 10),
        _quickDest('Mall', Icons.local_mall_rounded, AppColors.secondary),
        const SizedBox(width: 10),
        _quickDest('Hotel', Icons.hotel_rounded, AppColors.accent),
        const SizedBox(width: 10),
        _quickDest('Hospital', Icons.local_hospital_rounded, AppColors.success),
      ],
    );
  }

  Widget _quickDest(String label, IconData icon, Color color) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        SlidePageRoute(child: const RideSelectionScreen()),
      ),
      child: Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withOpacity(0.3), width: 1),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 11,
                    fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentPlace(String name, String address, IconData icon) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        SlidePageRoute(child: const RideSelectionScreen()),
      ),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.darkCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.darkBorder, width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14)),
                  Text(address,
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.4), fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded,
                color: Colors.white.withOpacity(0.3), size: 14),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        border: Border(top: BorderSide(color: AppColors.darkBorder, width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(0, Icons.home_rounded, 'Home'),
              _navItem(1, Icons.history_rounded, 'History'),
              _navItem(2, Icons.person_rounded, 'Profile'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData icon, String label) {
    final isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? AppColors.primary : Colors.white.withOpacity(0.3),
              size: 22,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: isActive ? AppColors.primary : Colors.white.withOpacity(0.3),
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Map Grid Painter ─────────────────────────────────────────────────────────

class MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1E3A5F).withOpacity(0.4)
      ..strokeWidth = 1.0;

    // Horizontal roads
    for (double y = 0; y < size.height; y += 60) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Vertical roads
    for (double x = 0; x < size.width; x += 80) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Some diagonal "highways"
    final highwayPaint = Paint()
      ..color = const Color(0xFF2563EB).withOpacity(0.2)
      ..strokeWidth = 3.0;

    canvas.drawLine(
      Offset(0, size.height * 0.3),
      Offset(size.width, size.height * 0.7),
      highwayPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.2, 0),
      Offset(size.width * 0.8, size.height),
      highwayPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
