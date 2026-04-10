// lib/models/user_model.dart
class UserModel {
  final String name;
  final String email;
  final String avatarUrl;
  final int totalWorkouts;
  final int dayStreak;
  final String currentLevel;
  final double levelProgress; // 0.0 to 1.0

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

// lib/models/stats_model.dart
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

// lib/models/progress_model.dart
class ProgressModel {
  final List<double> strengthData; // monthly 1RM data points
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

class Milestone {
  final String title;
  final String description;
  final String timeAgo;
  final MilestoneType type;

  const Milestone({
    required this.title,
    required this.description,
    required this.timeAgo,
    required this.type,
  });
}

enum MilestoneType { pr, consistency, streak, calorie }
