
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../core/services/auth_service.dart';
import '../core/services/firestore_service.dart';
import '../core/services/notification_service.dart';
import '../models/app_models.dart';


final authServiceProvider = Provider<AuthService>((ref) => AuthService());
final firestoreServiceProvider = Provider<FirestoreService>((ref) => FirestoreService());


final workoutEventBusProvider = Provider<WorkoutEventBus>((ref) => WorkoutEventBus.instance);


final notificationCountProvider = StateProvider<int>((ref) => 0);


final notificationsEnabledProvider = StateProvider<bool>((ref) => true);
final darkModeEnabledProvider      = StateProvider<bool>((ref) => false);
final metricUnitsProvider          = StateProvider<bool>((ref) => true);


final navIndexProvider = StateProvider<int>((ref) => 0);


const _mockUserProfile = UserProfile(
  uid: 'mock_uid_001',
  name: 'Alex Rivera',
  email: 'alex.rivera@readyset.com',
  avatarUrl: '',
  totalWorkouts: 124,
  dayStreak: 14,
  currentLevel: 'Elite Runner',
  levelProgress: 0.85,
);

const _mockUser = UserModel(
  name: 'Alex Rivera',
  email: 'alex.rivera@readyset.com',
  avatarUrl: '',
  totalWorkouts: 124,
  dayStreak: 14,
  currentLevel: 'Elite Runner',
  levelProgress: 0.85,
);

const _mockStats = StatsModel(
  caloriesBurned: 1840,
  workoutsCompleted: 24,
  currentStreak: 12,
  todayFocusTitle: 'Flow & Mobility',
  todayFocusDuration: '45 mins',
  todayFocusLevel: 'Intermediate',
  todayFocusType: 'Yoga Fusion',
);

final _mockProgress = ProgressModel(
  strengthData: [42, 48, 53, 57, 62, 68, 71, 73, 75, 78, 82, 85],
  strengthGainPercent: 14.2,
  avgSessionsPerWeek: 4.2,
  prsHit: 12,
  totalVolumeTons: 42.5,
  streakDays: 18,
  weightKg: 78.4,
  recentMilestones: [
    Milestone(
      title: 'Back Squat PR',
      description: 'New personal record at 140kg x 3 reps',
      timeAgo: 'Yesterday',
      type: MilestoneType.pr,
      date: 'May 4',
      icon: '🏋️',
    ),
    Milestone(
      title: 'Consistency Award',
      description: '4 weeks of 5+ sessions per week',
      timeAgo: '3 Days Ago',
      type: MilestoneType.consistency,
      date: 'May 2',
      icon: '🔥',
    ),
    Milestone(
      title: '30-Day Streak',
      description: 'Trained every day for a full month',
      timeAgo: '1 Week Ago',
      type: MilestoneType.streak,
      date: 'Apr 28',
      icon: '⭐',
    ),
  ],
);




final userProvider = Provider<UserProfile>((ref) => _mockUserProfile);


final userModelProvider = Provider<UserModel>((ref) => _mockUser);

final statsProvider = Provider<StatsModel>((ref) => _mockStats);



final progressProvider = StreamProvider<ProgressData>((ref) {
  return ref.read(firestoreServiceProvider).watchProgress().handleError(
    (error, stack) {
      
      return ProgressData(
        strengthData: _mockProgress.strengthData,
        strengthGainPercent: _mockProgress.strengthGainPercent,
        avgSessionsPerWeek: _mockProgress.avgSessionsPerWeek,
        prsHit: _mockProgress.prsHit,
        totalVolumeTons: _mockProgress.totalVolumeTons.toInt(),
        streakDays: _mockProgress.streakDays,
        weightKg: _mockProgress.weightKg,
        recentMilestones: _mockProgress.recentMilestones,
      );
    },
  );
});


final socialFeedProvider = StreamProvider<List<SocialPost>>((ref) {
  try {
    return ref.read(firestoreServiceProvider).watchSocialFeed();
  } catch (_) {
    return Stream.value([]);
  }
});


final templatesProvider = StreamProvider<List<WorkoutTemplate>>((ref) {
  return ref.read(firestoreServiceProvider).watchTemplates();
});


class TemplateBuilderNotifier extends StateNotifier<WorkoutTemplate> {
  final FirestoreService _firestoreService;

  TemplateBuilderNotifier(this._firestoreService)
    : super(WorkoutTemplate(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: '',
        name: '',
        exercises: [],
        createdAt: DateTime.now(),
      ));

  void setName(String name) {
    state = state.copyWith(name: name);
  }

  void setDescription(String description) {
    state = state.copyWith(description: description);
  }

  void setTargetFocus(String focus) {
    state = state.copyWith(targetFocus: focus);
  }

  void setEstimatedDuration(int minutes) {
    state = state.copyWith(estimatedDurationMinutes: minutes);
  }

  void addExercise(WorkoutExercise exercise) {
    final updated = List<WorkoutExercise>.from(state.exercises)..add(exercise);
    state = state.copyWith(exercises: updated);
  }

  void removeExercise(int index) {
    final updated = List<WorkoutExercise>.from(state.exercises)..removeAt(index);
    state = state.copyWith(exercises: updated);
  }

  void updateExercise(int index, WorkoutExercise exercise) {
    final updated = List<WorkoutExercise>.from(state.exercises);
    updated[index] = exercise;
    state = state.copyWith(exercises: updated);
  }

  Future<void> saveTemplate(String userId) async {
    final template = state.copyWith(
      userId: userId,
      isDraft: false,
      updatedAt: DateTime.now(),
    );
    await _firestoreService.saveTemplate(template);
  }

  Future<void> saveDraft(String userId) async {
    final template = state.copyWith(
      userId: userId,
      isDraft: true,
      updatedAt: DateTime.now(),
    );
    await _firestoreService.saveTemplate(template);
  }
}

final templateBuilderProvider = StateNotifierProvider<TemplateBuilderNotifier, WorkoutTemplate>((ref) {
  return TemplateBuilderNotifier(ref.read(firestoreServiceProvider));
});
