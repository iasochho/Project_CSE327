// lib/providers/exercise_provider.dart
// FACTORY PATTERN: ExerciseFactory drives all filtered exercise lists

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/exercise.dart';

const exerciseMuscleFilters = [
  'ALL', 'CHEST', 'LEGS', 'BACK', 'ARMS', 'CORE', 'SHOULDERS',
];

// ── UI State Providers ────────────────────────────────────────────────────────
final exerciseMuscleFilterProvider = StateProvider<String>((ref) => 'ALL');
final exerciseSearchQueryProvider  = StateProvider<String>((ref) => '');

// ── Derived list (Factory pattern) ────────────────────────────────────────────
final filteredExercisesProvider = Provider<List<Exercise>>((ref) {
  final muscle = ref.watch(exerciseMuscleFilterProvider);
  final query  = ref.watch(exerciseSearchQueryProvider);
  // Factory creates a filtered list without exposing the raw catalog
  return ExerciseFactory.search(query, muscleFilter: muscle);
});