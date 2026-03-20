import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'provider_model.dart';
import 'booking_model.dart';
import 'review_model.dart';
import 'auth_gate.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _scaleAnim = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _controller.forward();
    _initApp();
  }

  Future<void> _initApp() async {
    final stopwatch = Stopwatch()..start();

    await Future.wait([
      Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform),
      _initHive(),
    ]);

    final elapsed = stopwatch.elapsedMilliseconds;
    if (elapsed < 3000) {
      await Future.delayed(Duration(milliseconds: 3000 - elapsed));
    }

    if (mounted) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 500),
          pageBuilder: (_, __, ___) => const AuthGate(),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
        ),
      );
    }
  }

  Future<void> _initHive() async {
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(ProviderModelAdapter());
    if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(BookingModelAdapter());
    if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(ReviewModelAdapter());
    if (!Hive.isBoxOpen('providers')) await Hive.openBox<ProviderModel>('providers');
    if (!Hive.isBoxOpen('bookings')) await Hive.openBox<BookingModel>('bookings');
    if (!Hive.isBoxOpen('reviews')) await Hive.openBox<ReviewModel>('reviews');
    if (!Hive.isBoxOpen('favourites')) await Hive.openBox<String>('favourites');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1565C0),
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: ScaleTransition(
            scale: _scaleAnim,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: const Icon(
                    Icons.home_repair_service_rounded,
                    size: 52,
                    color: Color(0xFF1565C0),
                  ),
                ),
                const SizedBox(height: 28),
                const Text('Local Service',
                    style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.5)),
                const SizedBox(height: 8),
                const Text('Professional help at your doorstep',
                    style: TextStyle(fontSize: 14, color: Colors.white70)),
                const SizedBox(height: 60),
                const SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}