// lib/screens/exercise/active_workout_screen.dart
// Uses: Builder (WorkoutBuilder), Observer (WorkoutEventBus), Decorator (LoadingDecorator)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/firestore_service.dart';
import '../../core/services/notification_service.dart';
import '../../models/app_models.dart';
import '../../providers/app_providers.dart';
import '../../widgets/common/shared_widgets.dart';

class ActiveWorkoutScreen extends ConsumerStatefulWidget {
  final WorkoutSession? prebuiltSession;
  const ActiveWorkoutScreen({super.key, this.prebuiltSession});

  @override
  ConsumerState<ActiveWorkoutScreen> createState() => _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends ConsumerState<ActiveWorkoutScreen>
    implements WorkoutEventObserver {
  late WorkoutSession _session;
  final Stopwatch _stopwatch = Stopwatch();
  bool _isFinishing = false;

  @override
  void initState() {
    super.initState();

    // Observer registration
    ref.read(workoutEventBusProvider).subscribe(this);

    // Builder pattern: build a WorkoutSession if none provided
    if (widget.prebuiltSession != null) {
      _session = widget.prebuiltSession!;
    } else {
      final user = ref.read(userProvider);
      _session = WorkoutBuilder()
          .setTitle('Quick Workout')
          .setUserId(user.uid)
          .addExercises([
            WorkoutExercise(
              exerciseId: 'barbell_squat',
              name: 'Barbell Back Squat',
              muscle: 'Legs',
              imageUrl: '',
              sets: [
                const ExerciseSet(reps: 12, weight: 100),
                const ExerciseSet(reps: 12, weight: 100),
                const ExerciseSet(reps: 12, weight: 100),
              ],
            ),
            WorkoutExercise(
              exerciseId: 'romanian_deadlift',
              name: 'Romanian Deadlift',
              muscle: 'Back',
              imageUrl: '',
              sets: [
                const ExerciseSet(reps: 10, weight: 80),
                const ExerciseSet(reps: 10, weight: 80),
              ],
            ),
          ])
          .build();
    }

    _stopwatch.start();
    ref.read(workoutEventBusProvider).notifyStarted(_session.id, _session.title);
  }

  @override
  void dispose() {
    ref.read(workoutEventBusProvider).unsubscribe(this);
    _stopwatch.stop();
    super.dispose();
  }

  // ── Observer callbacks ─────────────────────────────────────────────────────
  @override
  void onWorkoutStarted(String workoutId, String title) {
    debugPrint('[ActiveWorkout] Started: $title');
  }

  @override
  void onWorkoutCompleted(String workoutId, int durationMinutes) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Workout complete! ${durationMinutes}m logged.'),
          backgroundColor: const Color(0xFF00685F),
        ),
      );
    }
  }

  @override
  void onSetCompleted(String workoutId, String exerciseName, int setIndex) {
    debugPrint('[ActiveWorkout] Set ${setIndex + 1} of $exerciseName completed');
  }

  @override
  void onStreakUpdated(int newStreak) {}

  // ── Actions ────────────────────────────────────────────────────────────────
  void _toggleSet(int exIdx, int setIdx) {
    final exercises = [..._session.exercises];
    final sets = [...exercises[exIdx].sets];
    sets[setIdx] = sets[setIdx].copyWith(isCompleted: !sets[setIdx].isCompleted);
    exercises[exIdx] = WorkoutExercise(
      exerciseId: exercises[exIdx].exerciseId,
      exerciseName: exercises[exIdx].exerciseName,
      sets: sets,
    );
    setState(() {
      _session = WorkoutSession(
        id: _session.id,
        title: _session.title,
        userId: _session.userId,
        exercises: exercises,
        scheduledAt: _session.scheduledAt,
        durationMinutes: _session.durationMinutes,
        isCompleted: _session.isCompleted,
      );
    });

    if (sets[setIdx].isCompleted) {
      ref.read(workoutEventBusProvider).notifySetCompleted(
        _session.id,
        exercises[exIdx].exerciseName,
        setIdx,
      );
    }
  }

  Future<void> _finishWorkout() async {
    setState(() => _isFinishing = true);
    final minutes = (_stopwatch.elapsed.inSeconds / 60).round();
    try {
      // Save to Firestore (Builder-built session gets persisted via Adapter pattern)
      final id = await ref.read(firestoreServiceProvider).saveWorkout(_session);
      await ref.read(firestoreServiceProvider).completeWorkout(id, minutes);
      ref.read(workoutEventBusProvider).notifyCompleted(id, minutes);
    } finally {
      if (mounted) {
        setState(() => _isFinishing = false);
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final elapsed = _stopwatch.elapsed;
    final timer = '${elapsed.inMinutes.toString().padLeft(2, '0')}:'
        '${(elapsed.inSeconds % 60).toString().padLeft(2, '0')}';

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      extendBody: true,
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.9),
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Color(0xFF414751)),
          onPressed: () => _showExitDialog(context),
        ),
        title: const Text(
          'ACTIVE WORKOUT',
          style: TextStyle(
            color: Color(0xFF005DA7),
            fontWeight: FontWeight.w800,
            fontStyle: FontStyle.italic,
            fontSize: 18,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF008379).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.timer, color: Color(0xFF00685F), size: 16),
                const SizedBox(width: 6),
                Text(
                  timer,
                  style: const TextStyle(
                    color: Color(0xFF00685F),
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: LoadingDecorator(
        isLoading: _isFinishing,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 140),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _session.title.toUpperCase(),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                  color: Color(0xFF1A1C1C),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${_session.exercises.length} exercises',
                style: const TextStyle(fontSize: 13, color: Color(0xFF5C5F60)),
              ),
              const SizedBox(height: 32),

              ..._session.exercises.asMap().entries.map((entry) {
                final exIdx = entry.key;
                final ex = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 32),
                  child: _ExerciseBlock(
                    exercise: ex,
                    onSetToggled: (setIdx) => _toggleSet(exIdx, setIdx),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildActionBar(),
    );
  }

  Widget _buildActionBar() {
    final completedSets = _session.exercises
        .expand((e) => e.sets)
        .where((s) => s.isCompleted)
        .length;
    final totalSets =
        _session.exercises.expand((e) => e.sets).length;

    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 32,
              offset: const Offset(0, 8))
        ],
      ),
      child: Row(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('SETS DONE',
                  style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5C5F60))),
              Text('$completedSets / $totalSets',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const Spacer(),
          GestureDetector(
            onTap: _isFinishing ? null : _finishWorkout,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Color(0xFF005DA7), Color(0xFF2976C7)]),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                      color: const Color(0xFF005DA7).withOpacity(0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 6))
                ],
              ),
              child: const Row(
                children: [
                  Icon(Icons.check, color: Colors.white, size: 16),
                  SizedBox(width: 8),
                  Text('FINISH',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          letterSpacing: 1.2)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showExitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Leave Workout?'),
        content: const Text('Progress will not be saved.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('STAY'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.of(context).pop();
            },
            child: const Text('LEAVE',
                style: TextStyle(color: Color(0xFFBA1A1A))),
          ),
        ],
      ),
    );
  }
}

class _ExerciseBlock extends StatelessWidget {
  final WorkoutExercise exercise;
  final void Function(int setIdx) onSetToggled;

  const _ExerciseBlock({required this.exercise, required this.onSetToggled});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 6))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            exercise.exerciseName,
            style: const TextStyle(
                fontWeight: FontWeight.w800, fontSize: 16, letterSpacing: -0.3),
          ),
          const SizedBox(height: 4),
          Text(
            '${exercise.sets.length} sets',
            style: const TextStyle(color: Color(0xFF5C5F60), fontSize: 12),
          ),
          const SizedBox(height: 16),
          // Set rows
          ...exercise.sets.asMap().entries.map((e) {
            final i = e.key;
            final s = e.value;
            return GestureDetector(
              onTap: () => onSetToggled(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 10),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: s.isCompleted
                      ? const Color(0xFF005DA7).withOpacity(0.08)
                      : const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: s.isCompleted
                        ? const Color(0xFF005DA7).withOpacity(0.3)
                        : Colors.transparent,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: s.isCompleted
                            ? const Color(0xFF005DA7)
                            : Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: s.isCompleted
                                ? const Color(0xFF005DA7)
                                : const Color(0xFFDDE1E7)),
                      ),
                      child: s.isCompleted
                          ? const Icon(Icons.check,
                              color: Colors.white, size: 16)
                          : Center(
                              child: Text(
                                '${i + 1}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: Color(0xFF5C5F60)),
                              ),
                            ),
                    ),
                    const SizedBox(width: 14),
                    Text(
                      'Set ${i + 1}',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: s.isCompleted
                            ? const Color(0xFF005DA7)
                            : const Color(0xFF1A1C1C),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${s.weight.toInt()} kg × ${s.reps} reps',
                      style: TextStyle(
                        fontSize: 13,
                        color: s.isCompleted
                            ? const Color(0xFF005DA7)
                            : const Color(0xFF5C5F60),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}