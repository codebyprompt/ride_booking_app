import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ride_booking_clone/main.dart';

void main() {
  testWidgets('RideNow app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: RideNowApp()));
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
