// lib/providers/app_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_models.dart';

// ── Mock data ────────────────────────────────────────────────────────────────

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
    ),
    Milestone(
      title: 'Consistency Award',
      description: '4 weeks of 5+ sessions per week',
      timeAgo: '3 Days Ago',
      type: MilestoneType.consistency,
    ),
    Milestone(
      title: '30-Day Streak',
      description: 'Trained every day for a full month',
      timeAgo: '1 Week Ago',
      type: MilestoneType.streak,
    ),
  ],
);

// ── Providers ────────────────────────────────────────────────────────────────

final userProvider = Provider<UserModel>((ref) => _mockUser);

final statsProvider = Provider<StatsModel>((ref) => _mockStats);

final progressProvider = Provider<ProgressModel>((ref) => _mockProgress);

// Bottom nav index
final navIndexProvider = StateProvider<int>((ref) => 0);
