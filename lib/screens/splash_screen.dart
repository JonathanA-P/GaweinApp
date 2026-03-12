import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gawein/screens/onboarding_screen.dart';
import 'package:gawein/screens/home_screen.dart';
import 'package:gawein/screens/home_rekruiter_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final session = Supabase.instance.client.auth.currentSession;

    if (session != null) {
      final user = Supabase.instance.client.auth.currentUser!;

      try {
        final data = await Supabase.instance.client
            .from('profiles')
            .select('role')
            .eq('id', user.id)
            .maybeSingle();

        if (!mounted) return;

        final role = data?['role'];

        if (role == 'perekrut') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeRekruiterScreen()),
          );
        } else if (role != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const OnboardingScreen()),
          );
        }

      } catch (_) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const OnboardingScreen()),
          );
        }
      }

    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(

        // BACKGROUND GRADIENT
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE7E3F6),
              Color(0xFF5B3FA6),
            ],
          ),
        ),

        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              // LOGO IMAGE
              Image.asset(
                'assets/images/Logo_GaweIn.png',
                width: 160,
              ),

              const SizedBox(height: 20),

              const Text(
                'GaweIn',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E1A47),
                  letterSpacing: 1.2,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                'Temukan Peluangmu',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF3D2A5F),
                ),
              ),

              const SizedBox(height: 40),

              const CircularProgressIndicator(
                color: Color(0xFF3D2A5F),
                strokeWidth: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }
}