import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/services/hive_service.dart';
import 'core/viewmodels/auth_view_model.dart';
import 'core/viewmodels/habit_view_model.dart';
import 'ui/theme/app_theme.dart';
import 'ui/views/habit_form_view.dart';
import 'ui/views/home_view.dart';
import 'ui/views/login_view.dart';
import 'ui/views/signup_view.dart';
import 'ui/views/splash_view.dart';
import 'ui/views/stats_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService.initialize();
  runApp(const SmartRoutineApp());
}

/// Root widget wiring up Providers and routing.
class SmartRoutineApp extends StatelessWidget {
  const SmartRoutineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => HabitViewModel()),
      ],
      child: MaterialApp(
        title: 'SmartRoutine',
        theme: AppTheme.lightTheme(),
        initialRoute: '/',
        routes: {
          '/': (_) => const SplashView(),
          '/login': (_) => const LoginView(),
          '/signup': (_) => const SignupView(),
          '/home': (_) => const HomeView(),
          '/habit-form': (_) => const HabitFormView(),
          '/stats': (_) => const StatsView(),
        },
      ),
    );
  }
}
