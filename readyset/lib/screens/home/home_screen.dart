




import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/firestore_service.dart';
import '../../models/app_models.dart';
import '../../providers/app_providers.dart';
import '../../widgets/common/shared_widgets.dart';
import '../exercise/active_workout_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user  = ref.watch(userProvider);
    final stats = ref.watch(statsProvider);
    final now   = DateTime.now();

    return Scaffold(
      appBar: KZAppBar(), 
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        children: [
          
          Text(_greeting(now.hour),
              style: Theme.of(context).textTheme.displayMedium),
          Text(
            user.name.isNotEmpty ? user.name.split(' ').first : 'Athlete',
            style: Theme.of(context).textTheme.displayMedium,
          ),
          const SizedBox(height: 4),
          Text(
            _formattedDate(now).toUpperCase(),
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(letterSpacing: 0.5),
          ),
          const SizedBox(height: 24),

          
          
          _CTACard(
            label: 'LIVE SESSION',
            title: 'Start Workout',
            color: AppColors.primary,
            textColor: Colors.white,
            icon: Icons.play_circle_filled,
            onTap: () => _startQuickWorkout(context, ref),
          ),
          const SizedBox(height: 12),
          _CTACard(
            label: 'ANALYTICS',
            title: 'View Progress',
            color: AppColors.surface,
            textColor: AppColors.textPrimary,
            icon: Icons.show_chart,
            iconColor: AppColors.primary,
            onTap: () => ref.read(navIndexProvider.notifier).state = 2,
          ),
          const SizedBox(height: 12),
          _CTACard(
            label: 'COMMUNITY',
            title: 'Social Feed',
            color: AppColors.surface,
            textColor: AppColors.textPrimary,
            icon: Icons.people_outline,
            iconColor: AppColors.teal,
            onTap: () => ref.read(navIndexProvider.notifier).state = 3,
          ),
          const SizedBox(height: 24),

          
          _StreakCard(days: stats.currentStreak),
          const SizedBox(height: 16),

          
          Row(
            children: [
              Expanded(
                child: StatTile(
                  label: 'Calories Burned',
                  value: _fmt(stats.caloriesBurned),
                  icon: const Icon(Icons.local_fire_department,
                      color: AppColors.primary, size: 22),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatTile(
                  label: 'Workouts Done',
                  value: stats.workoutsCompleted.toString(),
                  icon: const Icon(Icons.fitness_center,
                      color: AppColors.teal, size: 22),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          
          _TodayFocusCard(
            title: stats.todayFocusTitle,
            duration: stats.todayFocusDuration,
            level: stats.todayFocusLevel,
            type: stats.todayFocusType,
            onTap: () => _startQuickWorkout(context, ref),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  
  void _startQuickWorkout(BuildContext context, WidgetRef ref) {
    final user = ref.read(userProvider);
    if (user.uid.isEmpty) return;

    final session = WorkoutBuilder()
        .setTitle('Quick Workout')
        .setUserId(user.uid)
        .setScheduledAt(DateTime.now())
        .addExercises([
          WorkoutExercise(
            exerciseId: 'back_squat',
            name: 'Barbell Back Squat',
            muscle: 'Legs',
            imageUrl: '',
            sets: [
              const ExerciseSet(reps: 12, weight: 80),
              const ExerciseSet(reps: 10, weight: 85),
              const ExerciseSet(reps: 8,  weight: 90),
            ],
          ),
          WorkoutExercise(
            exerciseId: 'bench_press',
            name: 'Bench Press',
            muscle: 'Chest',
            imageUrl: '',
            sets: [
              const ExerciseSet(reps: 10, weight: 60),
              const ExerciseSet(reps: 10, weight: 65),
            ],
          ),
        ])
        .build();

    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ActiveWorkoutScreen(prebuiltSession: session)),
    );
  }

  String _greeting(int hour) {
    if (hour < 12) return 'Good Morning,';
    if (hour < 17) return 'Good Afternoon,';
    return 'Good Evening,';
  }

  String _formattedDate(DateTime d) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    const days = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
    ];
    return '${days[d.weekday - 1]}, ${months[d.month - 1]} ${d.day}';
  }

  String _fmt(int n) {
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(n % 1000 == 0 ? 0 : 1)}K';
    return n.toString();
  }
}


class _CTACard extends StatelessWidget {
  final String label;
  final String title;
  final Color color;
  final Color textColor;
  final IconData icon;
  final Color? iconColor;
  final VoidCallback onTap;

  const _CTACard({
    required this.label,
    required this.title,
    required this.color,
    required this.textColor,
    required this.icon,
    this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: color == AppColors.primary
              ? [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 6))]
              : [const BoxShadow(color: Color(0x08000000), blurRadius: 12, offset: Offset(0, 2))],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          color: textColor.withOpacity(0.6))),
                  const SizedBox(height: 4),
                  Text(title,
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w700, color: textColor)),
                ],
              ),
            ),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color == AppColors.primary
                    ? Colors.white.withOpacity(0.2)
                    : AppColors.surfaceVariant,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor ?? Colors.white, size: 22),
            ),
          ],
        ),
      ),
    );
  }
}


class _StreakCard extends StatelessWidget {
  final int days;
  const _StreakCard({required this.days});

  @override
  Widget build(BuildContext context) {
    return KZCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('CURRENT STREAK', style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                days.toString(),
                style: Theme.of(context)
                    .textTheme
                    .displayLarge
                    ?.copyWith(color: AppColors.primary, height: 1),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text('DAYS',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(color: AppColors.textSecondary, letterSpacing: 1)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: List.generate(7, (i) {
              final active = i < (days % 7 == 0 ? 7 : days % 7);
              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: i < 6 ? 6 : 0),
                  height: 4,
                  decoration: BoxDecoration(
                    color: active ? AppColors.primary : AppColors.streakBlueLight,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}


class _TodayFocusCard extends StatelessWidget {
  final String title;
  final String duration;
  final String level;
  final String type;
  final VoidCallback onTap;

  const _TodayFocusCard({
    required this.title,
    required this.duration,
    required this.level,
    required this.type,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1E293B), Color(0xFF334155)],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              right: 80,
              top: -20,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.04),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "TODAY'S FOCUS",
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0,
                        color: Colors.white.withOpacity(0.6)),
                  ),
                  const Spacer(),
                  Text(title,
                      style: const TextStyle(
                          fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white)),
                  const SizedBox(height: 4),
                  Text('$duration • $level • $type',
                      style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.7))),
                ],
              ),
            ),
            Positioned(
              right: 20,
              bottom: 20,
              child: Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: const Icon(Icons.play_arrow, color: AppColors.primary, size: 24),
              ),
            ),
          ],
        ),
      ),
    );
  }
}