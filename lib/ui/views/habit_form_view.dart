import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/viewmodels/habit_view_model.dart';
import '../theme/app_colors.dart';
import '../widgets/glass_container.dart';
import '../widgets/gradient_button.dart';
import 'home_view.dart';

/// Premium habit form with glassmorphism design.
class HabitFormView extends StatefulWidget {
  const HabitFormView({super.key});

  @override
  State<HabitFormView> createState() => _HabitFormViewState();
}

class _HabitFormViewState extends State<HabitFormView> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String? _habitId;
  TimeOfDay? _reminderTime;
  bool _hasReminder = false;
  String _category = 'General';

  final List<String> _categories = [
    'General',
    'Health',
    'Work',
    'Personal',
    'Mindfulness',
    'Fitness',
    'Finance',
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is HabitFormArgs && _habitId == null) {
      _habitId = args.id;
      if (_habitId != null) {
        final habit = context.read<HabitViewModel>().getHabitById(_habitId!);
        if (habit != null) {
          _titleController.text = habit.title;
          _descriptionController.text = habit.description;
          _category = habit.category;
          if (habit.reminderTime != null) {
            _hasReminder = true;
            _reminderTime = TimeOfDay.fromDateTime(habit.reminderTime!);
          }
        }
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
    final isEditing = _habitId != null;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceGlass,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.surfaceBorder),
                      ),
                      child: IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(
                          Icons.close,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      isEditing ? 'Edit Habit' : 'New Habit',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Form
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Icon preview
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: AppColors.buttonShadow,
                          ),
                          child: const Icon(
                            Icons.track_changes,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      // Form fields
                      GlassContainer(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Habit Details',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 20),
                            
                            // Title
                            TextField(
                              controller: _titleController,
                              style: const TextStyle(color: AppColors.textPrimary),
                              decoration: const InputDecoration(
                                labelText: 'Habit Name',
                                hintText: 'e.g., Morning meditation',
                                prefixIcon: Icon(Icons.edit_outlined),
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            // Category
                            DropdownButtonFormField<String>(
                              value: _category,
                              items: _categories.map((category) {
                                return DropdownMenuItem(
                                  value: category,
                                  child: Text(category),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() => _category = value);
                                }
                              },
                              style: const TextStyle(color: AppColors.textPrimary),
                              decoration: const InputDecoration(
                                labelText: 'Category',
                                prefixIcon: Icon(Icons.category_outlined),
                              ),
                              dropdownColor: AppColors.surfaceGlass,
                            ),
                            const SizedBox(height: 16),
                            
                            // Description
                            TextField(
                              controller: _descriptionController,
                              style: const TextStyle(color: AppColors.textPrimary),
                              maxLines: 3,
                              decoration: const InputDecoration(
                                labelText: 'Description (optional)',
                                hintText: 'Add more details about your habit...',
                                prefixIcon: Icon(Icons.notes_outlined),
                                alignLabelWithHint: true,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Reminder
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceGlass,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.notifications_outlined, color: AppColors.primaryCyan),
                              ),
                              title: const Text('Daily Reminder', style: TextStyle(color: AppColors.textPrimary)),
                              trailing: Switch(
                                value: _hasReminder,
                                activeColor: AppColors.primaryCyan,
                                onChanged: (val) {
                                  setState(() {
                                    _hasReminder = val;
                                    if (val && _reminderTime == null) {
                                      _reminderTime = TimeOfDay.now();
                                    }
                                  });
                                },
                              ),
                            ),
                            
                            if (_hasReminder && _reminderTime != null) ...[
                              InkWell(
                                onTap: () async {
                                  final time = await showTimePicker(
                                    context: context,
                                    initialTime: _reminderTime!,
                                  );
                                  if (time != null) {
                                    setState(() => _reminderTime = time);
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceGlass,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppColors.surfaceBorder),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.access_time, color: AppColors.textSecondary, size: 20),
                                      const SizedBox(width: 12),
                                      Text(
                                        _reminderTime!.format(context),
                                        style: const TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      // Submit button
                      GradientButton(
                        label: isEditing ? 'Save Changes' : 'Create Habit',
                        icon: isEditing ? Icons.check : Icons.add,
                        onPressed: () async {
                          final title = _titleController.text.trim();
                          final description = _descriptionController.text.trim();
                          
                          if (title.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please enter a habit name'),
                                backgroundColor: AppColors.error,
                              ),
                            );
                            return;
                          }
                          
                          DateTime? reminderDateTime;
                          if (_hasReminder && _reminderTime != null) {
                            final now = DateTime.now();
                            reminderDateTime = DateTime(
                              now.year,
                              now.month,
                              now.day,
                              _reminderTime!.hour,
                              _reminderTime!.minute,
                            );
                          }
                          
                          final viewModel = context.read<HabitViewModel>();
                          if (isEditing) {
                            await viewModel.updateHabit(
                              id: _habitId!,
                              title: title,
                              description: description,
                              category: _category,
                              reminderTime: reminderDateTime,
                            );
                          } else {
                            await viewModel.addHabit(
                              title: title,
                              description: description,
                              category: _category,
                              reminderTime: reminderDateTime,
                            );
                          }
                          
                          if (mounted) {
                            Navigator.of(context).pop();
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
