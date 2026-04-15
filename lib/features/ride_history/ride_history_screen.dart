import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/animations.dart';
import '../../providers/app_providers.dart';

class RideHistoryScreen extends StatefulWidget {
  const RideHistoryScreen({super.key});

  @override
  State<RideHistoryScreen> createState() => _RideHistoryScreenState();
}

class _RideHistoryScreenState extends State<RideHistoryScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _headerController;
  late Animation<double> _headerFade;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
    _headerFade = CurvedAnimation(parent: _headerController, curve: Curves.easeIn);
  }

  @override
  void dispose() {
    _headerController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    setState(() => _isRefreshing = true);
    await Future.delayed(const Duration(milliseconds: 1500));
    if (mounted) setState(() => _isRefreshing = false);
  }

  final List<RideHistoryItem> _rides = [
    RideHistoryItem(
      id: '1',
      pickup: 'Home, Sector 15',
      drop: 'Airport, Terminal 2',
      date: 'Today, 2:30 PM',
      fare: 285.0,
      rideType: 'RidePremium',
      status: 'Completed',
    ),
    RideHistoryItem(
      id: '2',
      pickup: 'Office, Tech Park',
      drop: 'Mall, Central Square',
      date: 'Yesterday, 11:00 AM',
      fare: 142.0,
      rideType: 'RideGo',
      status: 'Completed',
    ),
    RideHistoryItem(
      id: '3',
      pickup: 'Restaurant, MG Road',
      drop: 'Home, Sector 15',
      date: '12 Apr, 9:45 PM',
      fare: 98.0,
      rideType: 'RideMini',
      status: 'Completed',
    ),
    RideHistoryItem(
      id: '4',
      pickup: 'Station, Central',
      drop: 'Hotel, City Center',
      date: '10 Apr, 6:20 PM',
      fare: 210.0,
      rideType: 'RidePremium',
      status: 'Cancelled',
    ),
    RideHistoryItem(
      id: '5',
      pickup: 'Gym, Sector 5',
      drop: 'Office, Tech Park',
      date: '8 Apr, 7:00 AM',
      fare: 55.0,
      rideType: 'RideGo',
      status: 'Completed',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: SafeArea(
        child: Column(
          children: [
            FadeTransition(
              opacity: _headerFade,
              child: _buildHeader(),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refresh,
                color: AppColors.primary,
                backgroundColor: AppColors.darkCard,
                child: _isRefreshing
                    ? _buildSkeletonList()
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                        itemCount: _rides.length,
                        itemBuilder: (_, index) {
                          return StaggeredAnimationBuilder(
                            index: index,
                            child: GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                SlidePageRoute(
                                  child: RideHistoryDetailScreen(
                                      ride: _rides[index]),
                                ),
                              ),
                              child: _buildRideCard(_rides[index]),
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          const Text(
            'Ride History',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: AppColors.primary.withOpacity(0.3), width: 1),
            ),
            child: const Text(
              'All Rides',
              style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRideCard(RideHistoryItem ride) {
    final isCompleted = ride.status == 'Completed';
    final emoji = _getRideEmoji(ride.rideType);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.darkBorder, width: 1),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Hero(
                tag: 'ride_${ride.id}',
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: AppColors.primary.withOpacity(0.3), width: 1),
                  ),
                  child: Center(
                      child: Text(emoji,
                          style: const TextStyle(fontSize: 26))),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(ride.rideType,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 15)),
                    Text(ride.date,
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.4),
                            fontSize: 12)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('₹${ride.fare.toInt()}',
                      style: TextStyle(
                          color: isCompleted
                              ? AppColors.primary
                              : AppColors.textSecondary,
                          fontWeight: FontWeight.w700,
                          fontSize: 18)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: (isCompleted ? AppColors.success : AppColors.error)
                          .withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(ride.status,
                        style: TextStyle(
                            color: isCompleted
                                ? AppColors.success
                                : AppColors.error,
                            fontSize: 11,
                            fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(color: Colors.white.withOpacity(0.05), height: 1),
          const SizedBox(height: 12),
          _routeRow('📍', ride.pickup, AppColors.success),
          const SizedBox(height: 4),
          _routeRow('📌', ride.drop, AppColors.error),
        ],
      ),
    );
  }

  Widget _routeRow(String emoji, String address, Color color) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 14)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(address,
              style: TextStyle(
                  color: Colors.white.withOpacity(0.6), fontSize: 13)),
        ),
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
      ],
    );
  }

  Widget _buildSkeletonList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      itemCount: 4,
      itemBuilder: (_, __) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: SkeletonLoader(
            width: double.infinity,
            height: 140,
            borderRadius: BorderRadius.circular(20),
          ),
        );
      },
    );
  }

  String _getRideEmoji(String type) {
    switch (type) {
      case 'RideGo':
        return '🛵';
      case 'RideMini':
        return '🚗';
      case 'RidePremium':
        return '🚙';
      case 'RideSUV':
        return '🚐';
      default:
        return '🚗';
    }
  }
}

// ─── Ride History Detail Screen ───────────────────────────────────────────────

class RideHistoryDetailScreen extends StatelessWidget {
  final RideHistoryItem ride;

  const RideHistoryDetailScreen({super.key, required this.ride});

  @override
  Widget build(BuildContext context) {
    final isCompleted = ride.status == 'Completed';
    final emoji = _getEmoji(ride.rideType);

    return Scaffold(
      backgroundColor: AppColors.darkBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
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
        title: const Text('Ride Details',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Hero(
              tag: 'ride_${ride.id}',
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                      color: AppColors.primary.withOpacity(0.3), width: 2),
                ),
                child: Center(child: Text(emoji, style: const TextStyle(fontSize: 40))),
              ),
            ),
            const SizedBox(height: 16),
            Text(ride.rideType,
                style: const TextStyle(
                    color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
            Text(ride.date,
                style: TextStyle(
                    color: Colors.white.withOpacity(0.5), fontSize: 14)),
            const SizedBox(height: 24),
            _card([
              _infoRow('Pickup', ride.pickup),
              _infoRow('Drop', ride.drop),
              _infoRow('Distance', '8.4 km'),
              _infoRow('Duration', '26 min'),
              _infoRow('Status', ride.status,
                  color: isCompleted ? AppColors.success : AppColors.error),
              _infoRow('Fare', '₹${ride.fare.toInt()}',
                  color: AppColors.primary, isBold: true),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _card(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.darkBorder, width: 1),
      ),
      child: Column(children: children),
    );
  }

  Widget _infoRow(String label, String value,
      {Color? color, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(label,
              style: TextStyle(
                  color: Colors.white.withOpacity(0.5), fontSize: 14)),
          const Spacer(),
          Text(value,
              style: TextStyle(
                  color: color ?? Colors.white,
                  fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 14)),
        ],
      ),
    );
  }

  String _getEmoji(String type) {
    switch (type) {
      case 'RideGo':
        return '🛵';
      case 'RideMini':
        return '🚗';
      case 'RidePremium':
        return '🚙';
      default:
        return '🚗';
    }
  }
}
