import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'provider_model.dart';
import 'booking_model.dart';
import 'splashscreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();

  // Register Adapters
  Hive.registerAdapter(ProviderModelAdapter());
  Hive.registerAdapter(BookingModelAdapter());

  // Open Boxes before running the app to ensure they are available everywhere
  await Hive.openBox<ProviderModel>('providers');
  await Hive.openBox<BookingModel>('bookings');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}
