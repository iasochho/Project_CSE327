



abstract class WorkoutEventObserver {
  void onWorkoutStarted(String workoutId, String title);
  void onWorkoutCompleted(String workoutId, int durationMinutes);
  void onSetCompleted(String workoutId, String exerciseName, int setIndex);
  void onStreakUpdated(int newStreak);
}


class WorkoutEventBus {
  WorkoutEventBus._();
  static final WorkoutEventBus instance = WorkoutEventBus._();

  final List<WorkoutEventObserver> _observers = [];

  void subscribe(WorkoutEventObserver observer) {
    if (!_observers.contains(observer)) _observers.add(observer);
  }

  void unsubscribe(WorkoutEventObserver observer) {
    _observers.remove(observer);
  }

  void notifyStarted(String workoutId, String title) {
    for (final o in List.of(_observers)) {
      o.onWorkoutStarted(workoutId, title);
    }
  }

  void notifyCompleted(String workoutId, int durationMinutes) {
    for (final o in List.of(_observers)) {
      o.onWorkoutCompleted(workoutId, durationMinutes);
    }
  }

  void notifySetCompleted(String workoutId, String exerciseName, int setIndex) {
    for (final o in List.of(_observers)) {
      o.onSetCompleted(workoutId, exerciseName, setIndex);
    }
  }

  void notifyStreakUpdated(int newStreak) {
    for (final o in List.of(_observers)) {
      o.onStreakUpdated(newStreak);
    }
  }
}
