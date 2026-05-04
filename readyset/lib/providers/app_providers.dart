// lib/providers/app_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../core/services/auth_service.dart';
import '../core/services/firestore_service.dart';
import '../core/services/notification_service.dart';
import '../models/app_models.dart';

// ── Auth & Firestore service providers ───────────────────────────────────────
final authServiceProvider = Provider<AuthService>((ref) => AuthService());
final firestoreServiceProvider = Provider<FirestoreService>((ref) => FirestoreService());

// ── WorkoutEventBus (Observer pattern) ───────────────────────────────────────
final workoutEventBusProvider = Provider<WorkoutEventBus>((ref) => WorkoutEventBus.instance);

// ── Notification badge count ──────────────────────────────────────────────────
final notificationCountProvider = StateProvider<int>((ref) => 0);

// ── Preference toggles ────────────────────────────────────────────────────────
final notificationsEnabledProvider = StateProvider<bool>((ref) => true);
final darkModeEnabledProvider      = StateProvider<bool>((ref) => false);
final metricUnitsProvider          = StateProvider<bool>((ref) => true);

// ── Bottom nav ────────────────────────────────────────────────────────────────
final navIndexProvider = StateProvider<int>((ref) => 0);

// ── Mock data ─────────────────────────────────────────────────────────────────
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

// ── Riverpod providers ────────────────────────────────────────────────────────

// UserProfile (used by active_workout_screen, exercise_selection_screen, etc.)
final userProvider = Provider<UserProfile>((ref) => _mockUserProfile);

// Legacy UserModel provider (kept for any screen that still reads UserModel)
final userModelProvider = Provider<UserModel>((ref) => _mockUser);

final statsProvider = Provider<StatsModel>((ref) => _mockStats);

// progressProvider: StreamProvider so .when() works in progress_screen.dart
// Falls back to mock data when not authenticated / Firestore unavailable.
final progressProvider = StreamProvider<ProgressData>((ref) {
  try {
    return ref.read(firestoreServiceProvider).watchProgress();
  } catch (_) {
    return Stream.value(ProgressData(
      strengthData: _mockProgress.strengthData,
      strengthGainPercent: _mockProgress.strengthGainPercent,
      avgSessionsPerWeek: _mockProgress.avgSessionsPerWeek,
      prsHit: _mockProgress.prsHit,
      totalVolumeTons: _mockProgress.totalVolumeTons.toInt(),
      streakDays: _mockProgress.streakDays,
      weightKg: _mockProgress.weightKg,
      recentMilestones: _mockProgress.recentMilestones,
    ));
  }
});

// socialFeedProvider: StreamProvider so .when() works in social_feed.dart
final socialFeedProvider = StreamProvider<List<SocialPost>>((ref) {
  try {
    return ref.read(firestoreServiceProvider).watchSocialFeed();
  } catch (_) {
    return Stream.value([]);
  }
});
