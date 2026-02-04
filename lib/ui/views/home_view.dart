import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/viewmodels/auth_view_model.dart';
import '../../core/viewmodels/habit_view_model.dart';
import '../widgets/habit_card.dart';

/// Main dashboard listing the daily habits.
class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<HabitViewModel>().loadHabits());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SmartRoutine'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () => Navigator.of(context).pushNamed('/stats'),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthViewModel>().logout();
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
      ),
      body: Consumer<HabitViewModel>(
        builder: (context, viewModel, _) {
          if (viewModel.habits.isEmpty) {
            return const Center(
              child: Text('No habits yet. Add your first habit!'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: viewModel.habits.length,
            itemBuilder: (context, index) {
              final habit = viewModel.habits[index];
              return HabitCard(
                habit: habit,
                onToggle: () => viewModel.toggleCompletion(index),
                onEdit: () {
                  Navigator.of(context).pushNamed(
                    '/habit-form',
                    arguments: HabitFormArgs(index: index),
                  );
                },
                onDelete: () => viewModel.deleteHabit(index),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed('/habit-form');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// Arguments passed to the habit form.
class HabitFormArgs {
  final int? index;

  HabitFormArgs({this.index});
}
