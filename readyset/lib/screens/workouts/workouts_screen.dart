// lib/screens/workouts/workouts_screen.dart
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/common/shared_widgets.dart';

// ── Model ─────────────────────────────────────────────────────────────────────
class Exercise {
  final String name;
  final String muscleGroup;
  final String type; // Compound / Isolation / Stability
  final ExerciseCategory category;

  const Exercise({
    required this.name,
    required this.muscleGroup,
    required this.type,
    required this.category,
  });
}

enum ExerciseCategory { strength, power, bodyweight, isolation, core }

// ── Mock data ─────────────────────────────────────────────────────────────────
const _exercises = [
  Exercise(name: 'Barbell Bench Press', muscleGroup: 'CHEST', type: 'COMPOUND', category: ExerciseCategory.strength),
  Exercise(name: 'Back Squat', muscleGroup: 'LEGS', type: 'COMPOUND', category: ExerciseCategory.strength),
  Exercise(name: 'Conventional Deadlift', muscleGroup: 'BACK', type: 'COMPOUND', category: ExerciseCategory.power),
  Exercise(name: 'Pull Ups', muscleGroup: 'BACK', type: 'COMPOUND', category: ExerciseCategory.bodyweight),
  Exercise(name: 'Dumbbell Curls', muscleGroup: 'ARMS', type: 'ISOLATION', category: ExerciseCategory.isolation),
  Exercise(name: 'Hanging Leg Raise', muscleGroup: 'CORE', type: 'STABILITY', category: ExerciseCategory.core),
  Exercise(name: 'Overhead Press', muscleGroup: 'SHOULDERS', type: 'COMPOUND', category: ExerciseCategory.strength),
  Exercise(name: 'Romanian Deadlift', muscleGroup: 'LEGS', type: 'COMPOUND', category: ExerciseCategory.strength),
];

const _filterLabels = ['ALL', 'CHEST', 'LEGS', 'BACK', 'ARMS', 'CORE', 'SHOULDERS'];

// ── Screen ────────────────────────────────────────────────────────────────────
class WorkoutsScreen extends StatefulWidget {
  const WorkoutsScreen({super.key});

  @override
  State<WorkoutsScreen> createState() => _WorkoutsScreenState();
}

class _WorkoutsScreenState extends State<WorkoutsScreen> {
  String _selectedFilter = 'ALL';
  String _searchQuery = '';

  List<Exercise> get _filtered => _exercises.where((e) {
        final matchesFilter =
            _selectedFilter == 'ALL' || e.muscleGroup == _selectedFilter;
        final matchesSearch = _searchQuery.isEmpty ||
            e.name.toLowerCase().contains(_searchQuery.toLowerCase());
        return matchesFilter && matchesSearch;
      }).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const KZAppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: Text('Exercise Library',
                style: Theme.of(context).textTheme.headlineLarge),
          ),

          // ── Search ───────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: 'Search movements...',
                hintStyle: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: AppColors.textMuted),
                prefixIcon: const Icon(Icons.search,
                    color: AppColors.textMuted, size: 20),
                filled: true,
                fillColor: AppColors.surfaceVariant,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // ── Filter chips ─────────────────────────────────────────────────
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _filterLabels.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final label = _filterLabels[i];
                final active = _selectedFilter == label;
                return GestureDetector(
                  onTap: () => setState(() => _selectedFilter = label),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color:
                          active ? AppColors.primary : AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        color: active ? Colors.white : AppColors.textSecondary,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // ── List ─────────────────────────────────────────────────────────
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _filtered.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (_, i) => _ExerciseCard(exercise: _filtered[i]),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Exercise card ─────────────────────────────────────────────────────────────
class _ExerciseCard extends StatelessWidget {
  final Exercise exercise;
  const _ExerciseCard({required this.exercise});

  Color get _categoryColor {
    switch (exercise.category) {
      case ExerciseCategory.strength:
        return AppColors.primary;
      case ExerciseCategory.power:
        return const Color(0xFF7C3AED);
      case ExerciseCategory.bodyweight:
        return AppColors.teal;
      case ExerciseCategory.isolation:
        return const Color(0xFF0891B2);
      case ExerciseCategory.core:
        return const Color(0xFF059669);
    }
  }

  String get _categoryLabel =>
      exercise.category.name.toUpperCase();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
                color: Color(0x08000000), blurRadius: 12, offset: Offset(0, 2))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image placeholder with category badge
            Stack(
              children: [
                Container(
                  height: 160,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16)),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        _categoryColor.withOpacity(0.3),
                        const Color(0xFF1E293B),
                      ],
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      _exerciseIcon,
                      size: 56,
                      color: Colors.white.withOpacity(0.3),
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: _categoryColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _categoryLabel,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Info
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(exercise.name,
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 4),
                  Text(
                    '${exercise.muscleGroup} • ${exercise.type}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          letterSpacing: 0.3,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData get _exerciseIcon {
    switch (exercise.category) {
      case ExerciseCategory.strength:
        return Icons.fitness_center;
      case ExerciseCategory.power:
        return Icons.bolt;
      case ExerciseCategory.bodyweight:
        return Icons.accessibility_new;
      case ExerciseCategory.isolation:
        return Icons.sports_gymnastics;
      case ExerciseCategory.core:
        return Icons.self_improvement;
    }
  }
}
