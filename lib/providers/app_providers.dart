import 'package:flutter_riverpod/flutter_riverpod.dart';

// ─── App State ───────────────────────────────────────────────────────────────

// Theme mode
final themeProvider = StateProvider<bool>((ref) => true); // true = dark

// Auth state
final isLoggedInProvider = StateProvider<bool>((ref) => false);
final isLoginModeProvider = StateProvider<bool>((ref) => true); // true = login

// Ride state
final selectedRideProvider = StateProvider<int>((ref) => 0);

final selectedPaymentProvider = StateProvider<String>((ref) => 'Cash');

final rideStatusProvider = StateProvider<RideStatus>((ref) => RideStatus.driverArriving);

final rideHistoryProvider = StateProvider<List<RideHistoryItem>>((ref) => [
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
]);

// ─── Models ──────────────────────────────────────────────────────────────────

enum RideStatus { driverArriving, rideStarted, reached }

class RideHistoryItem {
  final String id;
  final String pickup;
  final String drop;
  final String date;
  final double fare;
  final String rideType;
  final String status;

  RideHistoryItem({
    required this.id,
    required this.pickup,
    required this.drop,
    required this.date,
    required this.fare,
    required this.rideType,
    required this.status,
  });
}

class RideOption {
  final String name;
  final String emoji;
  final double baseFare;
  final String eta;
  final String capacity;
  final String description;

  const RideOption({
    required this.name,
    required this.emoji,
    required this.baseFare,
    required this.eta,
    required this.capacity,
    required this.description,
  });
}

const List<RideOption> rideOptions = [
  RideOption(
    name: 'RideGo',
    emoji: '🛵',
    baseFare: 49,
    eta: '2 min',
    capacity: '1 seat',
    description: 'Fastest & affordable',
  ),
  RideOption(
    name: 'RideMini',
    emoji: '🚗',
    baseFare: 89,
    eta: '4 min',
    capacity: '3 seats',
    description: 'Compact & comfortable',
  ),
  RideOption(
    name: 'RidePremium',
    emoji: '🚙',
    baseFare: 149,
    eta: '6 min',
    capacity: '4 seats',
    description: 'Premium ride experience',
  ),
  RideOption(
    name: 'RideSUV',
    emoji: '🚐',
    baseFare: 249,
    eta: '8 min',
    capacity: '6 seats',
    description: 'Spacious for groups',
  ),
];
