// lib/models/app_models.dart
// Unified model file: UserProfile, WorkoutSession, WorkoutExercise,
// ExerciseSet, ProgressData, Milestone, SocialPost
// Also re-exports the legacy UserModel / StatsModel / ProgressModel for
// any screens that still reference them.

// ── UserProfile (used by FirestoreService, active_workout_screen, etc.) ────────
class UserProfile {
  final String uid;
  final String name;
  final String email;
  final String avatarUrl;
  final int totalWorkouts;
  final int dayStreak;
  final String currentLevel;
  final double levelProgress;

  const UserProfile({
    required this.uid,
    required this.name,
    required this.email,
    required this.avatarUrl,
    required this.totalWorkouts,
    required this.dayStreak,
    required this.currentLevel,
    required this.levelProgress,
  });

  UserProfile copyWith({
    String? uid,
    String? name,
    String? email,
    String? avatarUrl,
    int? totalWorkouts,
    int? dayStreak,
    String? currentLevel,
    double? levelProgress,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      totalWorkouts: totalWorkouts ?? this.totalWorkouts,
      dayStreak: dayStreak ?? this.dayStreak,
      currentLevel: currentLevel ?? this.currentLevel,
      levelProgress: levelProgress ?? this.levelProgress,
    );
  }
}

// ── ExerciseSet ────────────────────────────────────────────────────────────────
class ExerciseSet {
  final int reps;
  final double weight;
  final bool isCompleted;

  const ExerciseSet({
    required this.reps,
    required this.weight,
    this.isCompleted = false,
  });

  ExerciseSet copyWith({int? reps, double? weight, bool? isCompleted}) {
    return ExerciseSet(
      reps: reps ?? this.reps,
      weight: weight ?? this.weight,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

// ── WorkoutExercise ────────────────────────────────────────────────────────────
// FIX: Added optional 'name' and 'muscle' parameters as aliases for
// 'exerciseName' and 'muscleGroup' so both calling conventions work:
//   WorkoutExercise(exerciseId: ..., exerciseName: ..., sets: ...)  ← firestore / home
//   WorkoutExercise(exerciseId: ..., name: ..., muscle: ..., sets: ...)  ← active_workout
class WorkoutExercise {
  final String exerciseId;
  final String exerciseName;  // canonical field used by Firestore adapter
  final String muscleGroup;   // canonical field
  final String? imageUrl;
  final List<ExerciseSet> sets;

  WorkoutExercise({
    required this.exerciseId,
    // Accept either 'exerciseName' or 'name'; one must be provided.
    String? exerciseName,
    String? name,
    // Accept either 'muscleGroup' or 'muscle'
    String? muscleGroup,
    String? muscle,
    this.imageUrl,
    required this.sets,
  })  : exerciseName = exerciseName ?? name ?? '',
        muscleGroup  = muscleGroup  ?? muscle ?? '';

  // Convenience getter so code that reads `.name` still works.
  String get name => exerciseName;
  String get muscle => muscleGroup;
}

// ── WorkoutSession ─────────────────────────────────────────────────────────────
class WorkoutSession {
  final String id;
  final String title;
  final String userId;
  final List<WorkoutExercise> exercises;
  final DateTime scheduledAt;
  final int durationMinutes;
  final bool isCompleted;

  const WorkoutSession({
    required this.id,
    required this.title,
    required this.userId,
    required this.exercises,
    required this.scheduledAt,
    required this.durationMinutes,
    required this.isCompleted,
  });
}

// ── Milestone ─────────────────────────────────────────────────────────────────
// Supports both the old-style (description/timeAgo/type) fields used by
// app_providers.dart AND the new-style (date/icon) fields used by
// progress_screen.dart and firestore_service.dart.
class Milestone {
  final String title;

  // New-style fields (progress_screen / firestore_service)
  final String? date;
  final String? icon;

  // Old-style fields (app_providers mock data)
  final String? description;
  final String? timeAgo;
  final MilestoneType? type;

  const Milestone({
    required this.title,
    this.date,
    this.icon,
    this.description,
    this.timeAgo,
    this.type,
  });
}

enum MilestoneType { pr, consistency, streak, calorie }

// ── ProgressData ───────────────────────────────────────────────────────────────
// Used by FirestoreService.progressFromDocs() and progress_screen.dart
class ProgressData {
  final List<double> strengthData;
  final double strengthGainPercent;
  final double avgSessionsPerWeek;
  final int prsHit;
  final int totalVolumeTons;
  final int streakDays;
  final double weightKg;
  final List<Milestone> recentMilestones;

  const ProgressData({
    required this.strengthData,
    required this.strengthGainPercent,
    required this.avgSessionsPerWeek,
    required this.prsHit,
    required this.totalVolumeTons,
    required this.streakDays,
    required this.weightKg,
    required this.recentMilestones,
  });
}

// ── SocialPost ─────────────────────────────────────────────────────────────────
class SocialPost {
  final String id;
  final String userId;
  final String userName;
  final String userAvatarUrl;
  final String content;
  final String? workoutTitle;
  final int likes;
  final bool likedByCurrentUser;
  final DateTime createdAt;

  const SocialPost({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userAvatarUrl,
    required this.content,
    this.workoutTitle,
    this.likes = 0,
    this.likedByCurrentUser = false,
    required this.createdAt,
  });
}

// ── Legacy models (kept for backward-compat with app_providers.dart) ──────────
class UserModel {
  final String name;
  final String email;
  final String avatarUrl;
  final int totalWorkouts;
  final int dayStreak;
  final String currentLevel;
  final double levelProgress;

  const UserModel({
    required this.name,
    required this.email,
    required this.avatarUrl,
    required this.totalWorkouts,
    required this.dayStreak,
    required this.currentLevel,
    required this.levelProgress,
  });
}

class StatsModel {
  final int caloriesBurned;
  final int workoutsCompleted;
  final int currentStreak;
  final String todayFocusTitle;
  final String todayFocusDuration;
  final String todayFocusLevel;
  final String todayFocusType;

  const StatsModel({
    required this.caloriesBurned,
    required this.workoutsCompleted,
    required this.currentStreak,
    required this.todayFocusTitle,
    required this.todayFocusDuration,
    required this.todayFocusLevel,
    required this.todayFocusType,
  });
}

class ProgressModel {
  final List<double> strengthData;
  final double strengthGainPercent;
  final double avgSessionsPerWeek;
  final int prsHit;
  final double totalVolumeTons;
  final int streakDays;
  final double weightKg;
  final List<Milestone> recentMilestones;

  const ProgressModel({
    required this.strengthData,
    required this.strengthGainPercent,
    required this.avgSessionsPerWeek,
    required this.prsHit,
    required this.totalVolumeTons,
    required this.streakDays,
    required this.weightKg,
    required this.recentMilestones,
  });
}
