import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/viewmodels/habit_view_model.dart';
import 'home_view.dart';

/// Form screen for creating or editing a habit.
class HabitFormView extends StatefulWidget {
  const HabitFormView({super.key});

  @override
  State<HabitFormView> createState() => _HabitFormViewState();
}

class _HabitFormViewState extends State<HabitFormView> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  int? _habitIndex;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is HabitFormArgs && _habitIndex == null) {
      _habitIndex = args.index;
      if (_habitIndex != null) {
        final habit = context.read<HabitViewModel>().habits[_habitIndex!];
        _titleController.text = habit.title;
        _descriptionController.text = habit.description;
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = _habitIndex != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Habit' : 'Add Habit')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                final title = _titleController.text.trim();
                final description = _descriptionController.text.trim();
                if (title.isEmpty) {
                  return;
                }
                final viewModel = context.read<HabitViewModel>();
                if (isEditing) {
                  await viewModel.updateHabit(
                    index: _habitIndex!,
                    title: title,
                    description: description,
                  );
                } else {
                  await viewModel.addHabit(
                    title: title,
                    description: description,
                  );
                }
                if (mounted) {
                  Navigator.of(context).pop();
                }
              },
              child: Text(isEditing ? 'Save Changes' : 'Add Habit'),
            ),
          ],
        ),
      ),
    );
  }
}
