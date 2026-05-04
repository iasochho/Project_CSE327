// lib/screens/exercise/exercise_selection_screen.dart
// FACTORY PATTERN:  ExerciseFactory.search() builds filtered result list
// OBSERVER PATTERN: filteredExercisesProvider re-fires on filter/search state change
// BUG FIX:         'app_bar:' corrected to 'appBar:' (was causing a compile error)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:readyset/core/services/firestore_service.dart';
import '../../core/theme/app_theme.dart';
import '../../models/app_models.dart';
import '../../models/exercise.dart';
import '../../providers/app_providers.dart';
import '../../providers/exercise_provider.dart';
import '../exercise/active_workout_screen.dart';

class ExerciseSelectionScreen extends ConsumerStatefulWidget {
  /// When provided, a selected exercise is added to this existing session
  final WorkoutSession? currentSession;

  const ExerciseSelectionScreen({super.key, this.currentSession});

  @override
  ConsumerState<ExerciseSelectionScreen> createState() =>
      _ExerciseSelectionScreenState();
}

class _ExerciseSelectionScreenState
    extends ConsumerState<ExerciseSelectionScreen> {

  // Tracks locally chosen exercises for multi-select before committing
  final Set<String> _selectedIds = {};

  @override
  Widget build(BuildContext context) {
    // Observer: rebuilds whenever filter or search changes via Factory
    final exercises = ref.watch(filteredExercisesProvider);
    final selected  = ref.watch(exerciseMuscleFilterProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: _buildAppBar(),   // FIX: was 'app_bar:' — now correctly 'appBar:'
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSearchBar(),
          _buildFilterChips(selected),
          const SizedBox(height: 8),
          Expanded(child: _buildList(exercises)),
        ],
      ),
      bottomNavigationBar: _selectedIds.isEmpty
          ? null
          : _buildActionBar(context),
    );
  }

  // ── App bar ────────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white.withOpacity(0.9),
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new,
            size: 20, color: Color(0xFF1A1C1C)),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: const Text(
        'CHOOSE EXERCISE',
        style: TextStyle(
          color: Color(0xFF005DA7),
          fontWeight: FontWeight.w800,
          fontSize: 16,
          letterSpacing: 1.5,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.tune, color: Color(0xFF005DA7)),
          onPressed: () {},
        ),
      ],
    );
  }

  // ── Search ─────────────────────────────────────────────────────────────────
  Widget _buildSearchBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F3F3),
          borderRadius: BorderRadius.circular(16),
        ),
        child: TextField(
          onChanged: (v) =>
              ref.read(exerciseSearchQueryProvider.notifier).state = v,
          decoration: const InputDecoration(
            hintText: 'Search exercises...',
            hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
            icon: Icon(Icons.search, color: Color(0xFF94A3B8)),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  // ── Muscle-group filter chips ──────────────────────────────────────────────
  Widget _buildFilterChips(String selected) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: exerciseMuscleFilters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final label  = exerciseMuscleFilters[i];
          final active = selected == label;
          return GestureDetector(
            // Observer: write → Factory re-filters via filteredExercisesProvider
            onTap: () =>
                ref.read(exerciseMuscleFilterProvider.notifier).state = label,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: active ? const Color(0xFF005DA7) : const Color(0xFFF3F3F3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: active ? Colors.white : const Color(0xFF5C5F60),
                  letterSpacing: 0.5,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Exercise list ──────────────────────────────────────────────────────────
  Widget _buildList(List<Exercise> exercises) {
    if (exercises.isEmpty) {
      return const Center(
        child: Text('No exercises found',
            style: TextStyle(color: Color(0xFF5C5F60))),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      itemCount: exercises.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) {
        final ex       = exercises[i];
        final isChosen = _selectedIds.contains(ex.id);
        return _ExerciseRow(
          exercise: ex,
          isSelected: isChosen,
          onToggle: () => setState(() {
            if (isChosen) {
              _selectedIds.remove(ex.id);
            } else {
              _selectedIds.add(ex.id);
            }
          }),
        );
      },
    );
  }

  // ── Bottom action bar (shown when ≥1 exercise is selected) ────────────────
  Widget _buildActionBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      color: Colors.white,
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton.icon(
          // Builder pattern: build a new session with the selected exercises
          onPressed: () => _startWithSelected(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF005DA7),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(26)),
            elevation: 0,
          ),
          icon: const Icon(Icons.play_arrow),
          label: Text(
            'START WITH ${_selectedIds.length} EXERCISE${_selectedIds.length == 1 ? '' : 'S'}',
            style: const TextStyle(
                fontWeight: FontWeight.bold, letterSpacing: 1, fontSize: 12),
          ),
        ),
      ),
    );
  }

  // Builder pattern: construct a WorkoutSession from the selected exercises
  void _startWithSelected(BuildContext context) {
    final user = ref.read(userProvider);
    if (user.uid.isEmpty) return;

    // Use ExerciseFactory to get full exercise objects
    final allExercises = ExerciseFactory.byMuscleGroup('ALL');
    final chosen = allExercises.where((e) => _selectedIds.contains(e.id));

    final session = WorkoutBuilder()
        .setTitle('Custom Workout')
        .setUserId(user.uid)
        .setScheduledAt(DateTime.now())
        .addExercises(chosen
            .map((e) => WorkoutExercise(
                  exerciseId: e.id,
                  exerciseName: e.name,
                  sets: [
                    const ExerciseSet(reps: 10, weight: 60),
                    const ExerciseSet(reps: 10, weight: 60),
                    const ExerciseSet(reps: 10, weight: 60),
                  ],
                ))
            .toList())
        .build();

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
          builder: (_) => ActiveWorkoutScreen(prebuiltSession: session)),
    );
  }
}

// ── Exercise Row ──────────────────────────────────────────────────────────────
class _ExerciseRow extends StatelessWidget {
  final Exercise exercise;
  final bool isSelected;
  final VoidCallback onToggle;

  const _ExerciseRow({
    required this.exercise,
    required this.isSelected,
    required this.onToggle,
  });

  Color get _accent {
    switch (exercise.category) {
      case ExerciseCategory.strength:   return const Color(0xFF005DA7);
      case ExerciseCategory.power:      return const Color(0xFF7C3AED);
      case ExerciseCategory.bodyweight: return const Color(0xFF00685F);
      case ExerciseCategory.isolation:  return const Color(0xFF0891B2);
      case ExerciseCategory.core:       return const Color(0xFF059669);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? _accent : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 24,
                offset: const Offset(0, 8))
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: _accent.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_icon, color: _accent, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(exercise.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 3),
                  Text('${exercise.muscleGroup} • ${exercise.type}',
                      style: const TextStyle(
                          color: Color(0xFF5C5F60), fontSize: 12)),
                ],
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: isSelected
                  ? CircleAvatar(
                      key: const ValueKey('checked'),
                      radius: 14,
                      backgroundColor: _accent,
                      child: const Icon(Icons.check,
                          color: Colors.white, size: 16),
                    )
                  : Icon(Icons.add_circle_outline,
                      key: const ValueKey('add'),
                      color: _accent,
                      size: 28),
            ),
          ],
        ),
      ),
    );
  }

  IconData get _icon {
    switch (exercise.category) {
      case ExerciseCategory.strength:   return Icons.fitness_center;
      case ExerciseCategory.power:      return Icons.bolt;
      case ExerciseCategory.bodyweight: return Icons.accessibility_new;
      case ExerciseCategory.isolation:  return Icons.sports_gymnastics;
      case ExerciseCategory.core:       return Icons.self_improvement;
    }
  }
}