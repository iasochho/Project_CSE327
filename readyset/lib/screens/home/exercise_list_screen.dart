



import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../models/exercise.dart';
import '../../providers/exercise_provider.dart';
import '../../widgets/common/shared_widgets.dart';

class ExerciseListScreen extends ConsumerWidget {
  const ExerciseListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    
    final exercises = ref.watch(filteredExercisesProvider);
    final selected  = ref.watch(exerciseMuscleFilterProvider);

    return Scaffold(
      appBar: KZAppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
            child: Text('Exercise Library',
                style: Theme.of(context).textTheme.headlineLarge),
          ),

          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              
              onChanged: (v) =>
                  ref.read(exerciseSearchQueryProvider.notifier).state = v,
              decoration: InputDecoration(
                hintText: 'Search movements...',
                hintStyle: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: AppColors.textMuted),
                prefixIcon: const Icon(Icons.search,
                    color: AppColors.textMuted, size: 20),
                filled: true,
                fillColor: AppColors.surfaceVariant,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 14),

          
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: exerciseMuscleFilters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final label  = exerciseMuscleFilters[i];
                final active = selected == label;
                return GestureDetector(
                  
                  onTap: () => ref
                      .read(exerciseMuscleFilterProvider.notifier)
                      .state = label,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: active
                          ? AppColors.primary
                          : AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        color: active ? Colors.white : AppColors.textSecondary,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          
          Expanded(
            child: exercises.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.fitness_center_outlined,
                            size: 56, color: AppColors.textMuted),
                        const SizedBox(height: 12),
                        Text('No exercises found',
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(color: AppColors.textSecondary)),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: exercises.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (_, i) => _ExerciseCard(exercise: exercises[i]),
                  ),
          ),
        ],
      ),
    );
  }
}


class _ExerciseCard extends StatelessWidget {
  final Exercise exercise;
  const _ExerciseCard({required this.exercise});

  Color get _categoryColor {
    switch (exercise.category) {
      case ExerciseCategory.strength:   return AppColors.primary;
      case ExerciseCategory.power:      return const Color(0xFF7C3AED);
      case ExerciseCategory.bodyweight: return AppColors.teal;
      case ExerciseCategory.isolation:  return const Color(0xFF0891B2);
      case ExerciseCategory.core:       return const Color(0xFF059669);
    }
  }

  IconData get _exerciseIcon {
    switch (exercise.category) {
      case ExerciseCategory.strength:   return Icons.fitness_center;
      case ExerciseCategory.power:      return Icons.bolt;
      case ExerciseCategory.bodyweight: return Icons.accessibility_new;
      case ExerciseCategory.isolation:  return Icons.sports_gymnastics;
      case ExerciseCategory.core:       return Icons.self_improvement;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Color(0x08000000), blurRadius: 12, offset: Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          
          Stack(
            children: [
              Container(
                height: 140,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _categoryColor.withOpacity(0.4),
                      const Color(0xFF1E293B),
                    ],
                  ),
                ),
                child: Center(
                  child: Icon(_exerciseIcon,
                      size: 52, color: Colors.white.withOpacity(0.3)),
                ),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _categoryColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    exercise.category.name.toUpperCase(),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5),
                  ),
                ),
              ),
            ],
          ),
          
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(exercise.name,
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 4),
                Text(
                  '${exercise.muscleGroup} • ${exercise.type}',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(letterSpacing: 0.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}