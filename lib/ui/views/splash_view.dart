import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/viewmodels/auth_view_model.dart';

/// Simple splash screen that routes based on auth state.
class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), () {
      final isLoggedIn = context.read<AuthViewModel>().isLoggedIn;
      Navigator.of(context).pushReplacementNamed(
        isLoggedIn ? '/home' : '/login',
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.track_changes, size: 72),
            SizedBox(height: 16),
            Text('SmartRoutine', style: TextStyle(fontSize: 24)),
          ],
        ),
      ),
    );
  }
}
