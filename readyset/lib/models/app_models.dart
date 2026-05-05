






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


class WorkoutExercise {
  final String exerciseId;
  final String exerciseName;  
  final String muscleGroup;   
  final String? imageUrl;
  final List<ExerciseSet> sets;

  WorkoutExercise({
    required this.exerciseId,
    
    String? exerciseName,
    String? name,
    
    String? muscleGroup,
    String? muscle,
    this.imageUrl,
    required this.sets,
  })  : exerciseName = exerciseName ?? name ?? '',
        muscleGroup  = muscleGroup  ?? muscle ?? '';

  
  String get name => exerciseName;
  String get muscle => muscleGroup;
}


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





class Milestone {
  final String title;

  
  final String? date;
  final String? icon;

  
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



class WorkoutTemplate {
  final String id;
  final String userId;
  final String name;
  final String description;
  final List<WorkoutExercise> exercises;
  final int estimatedDurationMinutes;
  final String targetFocus;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isDraft;

  const WorkoutTemplate({
    required this.id,
    required this.userId,
    required this.name,
    this.description = '',
    required this.exercises,
    this.estimatedDurationMinutes = 0,
    this.targetFocus = 'All',
    required this.createdAt,
    this.updatedAt,
    this.isDraft = true,
  });

  WorkoutTemplate copyWith({
    String? id,
    String? userId,
    String? name,
    String? description,
    List<WorkoutExercise>? exercises,
    int? estimatedDurationMinutes,
    String? targetFocus,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDraft,
  }) {
    return WorkoutTemplate(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      exercises: exercises ?? this.exercises,
      estimatedDurationMinutes: estimatedDurationMinutes ?? this.estimatedDurationMinutes,
      targetFocus: targetFocus ?? this.targetFocus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDraft: isDraft ?? this.isDraft,
    );
  }
}
