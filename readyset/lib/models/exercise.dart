// lib/models/exercise.dart
// FACTORY PATTERN: ExerciseFactory creates and filters exercises by category/muscle group

enum ExerciseCategory { strength, power, bodyweight, isolation, core }

class Exercise {
  final String id;
  final String name;
  final String muscleGroup;
  final String type; // 'COMPOUND' | 'ISOLATION' | 'STABILITY'
  final ExerciseCategory category;
  final String? imageUrl;

  const Exercise({
    required this.id,
    required this.name,
    required this.muscleGroup,
    required this.type,
    required this.category,
    this.imageUrl,
  });
}

// ── Factory Pattern ───────────────────────────────────────────────────────────
// Creates exercises without exposing the raw data list to callers
class ExerciseFactory {
  ExerciseFactory._();

  /// Returns all exercises matching the given muscle group label.
  /// Pass 'ALL' to return everything.
  static List<Exercise> byMuscleGroup(String muscleGroup) {
    if (muscleGroup == 'ALL') return List.unmodifiable(_catalog);
    return _catalog.where((e) => e.muscleGroup == muscleGroup).toList();
  }

  /// Returns all exercises matching the given [ExerciseCategory].
  static List<Exercise> byCategory(ExerciseCategory category) {
    return _catalog.where((e) => e.category == category).toList();
  }

  /// Full-text search across exercise names.
  static List<Exercise> search(String query, {String muscleFilter = 'ALL'}) {
    final q = query.toLowerCase();
    return _catalog.where((e) {
      final matchesMuscle = muscleFilter == 'ALL' || e.muscleGroup == muscleFilter;
      final matchesQuery = q.isEmpty || e.name.toLowerCase().contains(q);
      return matchesMuscle && matchesQuery;
    }).toList();
  }

  // ── Catalog ──────────────────────────────────────────────────────────────
  static const List<Exercise> _catalog = [
    Exercise(id: 'bench_press',     name: 'Barbell Bench Press',   muscleGroup: 'CHEST',     type: 'COMPOUND',  category: ExerciseCategory.strength),
    Exercise(id: 'incline_press',   name: 'Incline Dumbbell Press',muscleGroup: 'CHEST',     type: 'COMPOUND',  category: ExerciseCategory.strength),
    Exercise(id: 'chest_fly',       name: 'Cable Chest Fly',       muscleGroup: 'CHEST',     type: 'ISOLATION', category: ExerciseCategory.isolation),
    Exercise(id: 'back_squat',      name: 'Back Squat',            muscleGroup: 'LEGS',      type: 'COMPOUND',  category: ExerciseCategory.strength),
    Exercise(id: 'rdl',             name: 'Romanian Deadlift',     muscleGroup: 'LEGS',      type: 'COMPOUND',  category: ExerciseCategory.strength),
    Exercise(id: 'leg_press',       name: 'Leg Press',             muscleGroup: 'LEGS',      type: 'COMPOUND',  category: ExerciseCategory.strength),
    Exercise(id: 'deadlift',        name: 'Conventional Deadlift', muscleGroup: 'BACK',      type: 'COMPOUND',  category: ExerciseCategory.power),
    Exercise(id: 'pull_ups',        name: 'Pull Ups',              muscleGroup: 'BACK',      type: 'COMPOUND',  category: ExerciseCategory.bodyweight),
    Exercise(id: 'lat_pulldown',    name: 'Lat Pulldown',          muscleGroup: 'BACK',      type: 'COMPOUND',  category: ExerciseCategory.strength),
    Exercise(id: 'dumbbell_curls',  name: 'Dumbbell Curls',        muscleGroup: 'ARMS',      type: 'ISOLATION', category: ExerciseCategory.isolation),
    Exercise(id: 'tricep_pushdown', name: 'Tricep Pushdown',       muscleGroup: 'ARMS',      type: 'ISOLATION', category: ExerciseCategory.isolation),
    Exercise(id: 'ohp',             name: 'Overhead Press',        muscleGroup: 'SHOULDERS', type: 'COMPOUND',  category: ExerciseCategory.strength),
    Exercise(id: 'lateral_raise',   name: 'Lateral Raise',         muscleGroup: 'SHOULDERS', type: 'ISOLATION', category: ExerciseCategory.isolation),
    Exercise(id: 'hanging_leg_raise',name:'Hanging Leg Raise',     muscleGroup: 'CORE',      type: 'STABILITY', category: ExerciseCategory.core),
    Exercise(id: 'plank',           name: 'Plank',                 muscleGroup: 'CORE',      type: 'STABILITY', category: ExerciseCategory.core),
  ];
}