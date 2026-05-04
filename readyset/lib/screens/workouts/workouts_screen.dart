// lib/screens/workouts/workouts_screen.dart
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/common/shared_widgets.dart';

// ── HUB SCREEN (Main Entry) ──────────────────────────────────────────────────
class WorkoutsScreen extends StatelessWidget {
  const WorkoutsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const KZAppBar(),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Text(
                'Workouts',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
            ),

            // ── ACTION HUB ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _HubCard(
                    title: "Start Workout",
                    subtitle: "Begin a session from scratch",
                    icon: Icons.play_arrow_rounded,
                    color: AppColors.primary,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ActiveWorkoutScreen()),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _HubCard(
                    title: "Build Template",
                    subtitle: "Create a reusable routine",
                    icon: Icons.add_task_rounded,
                    color: const Color(0xFF7C3AED),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const TemplateBuilderScreen()),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _HubCard(
                    title: "Browse Exercises",
                    subtitle: "Search the movement library",
                    icon: Icons.manage_search_rounded,
                    color: AppColors.teal,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ExerciseSelectionScreen()),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // ── RECENT ACTIVITY (Firestore Section) ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Recent Activity', style: Theme.of(context).textTheme.titleLarge),
                  TextButton(
                    onPressed: () {},
                    child: const Text("View All", style: TextStyle(color: AppColors.primary)),
                  ),
                ],
              ),
            ),
            const _RecentWorkoutsList(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// ── HUB CARD COMPONENT ───────────────────────────────────────────────────────
class _HubCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _HubCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(color: Color(0x08000000), blurRadius: 8, offset: Offset(0, 2))
          ],
          border: Border.all(color: AppColors.surfaceVariant.withOpacity(0.5)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(subtitle, style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textMuted, size: 20),
          ],
        ),
      ),
    );
  }
}

// ── RECENT WORKOUTS LIST (Firestore Placeholder) ──────────────────────────────
class _RecentWorkoutsList extends StatelessWidget {
  const _RecentWorkoutsList();

  @override
  Widget build(BuildContext context) {
    // Note: In production, wrap this in a StreamBuilder or FutureBuilder hooked to Firestore
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: 2, // Example count
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.history, color: AppColors.textMuted, size: 20),
              const SizedBox(width: 12),
              const Expanded(
                child: Text("Push Day A", style: TextStyle(fontWeight: FontWeight.w600)),
              ),
              Text("2 days ago", style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        );
      },
    );
  }
}

// ── EXERCISE SELECTION SCREEN (The Library) ───────────────────────────────────
class ExerciseSelectionScreen extends StatefulWidget {
  const ExerciseSelectionScreen({super.key});

  @override
  State<ExerciseSelectionScreen> createState() => _ExerciseSelectionScreenState();
}

class _ExerciseSelectionScreenState extends State<ExerciseSelectionScreen> {
  String _selectedFilter = 'ALL';
  String _searchQuery = '';

  final List<Exercise> _exercises = const [
    Exercise(name: 'Barbell Bench Press', muscleGroup: 'CHEST', type: 'COMPOUND', category: ExerciseCategory.strength),
    Exercise(name: 'Back Squat', muscleGroup: 'LEGS', type: 'COMPOUND', category: ExerciseCategory.strength),
    Exercise(name: 'Conventional Deadlift', muscleGroup: 'BACK', type: 'COMPOUND', category: ExerciseCategory.power),
    Exercise(name: 'Pull Ups', muscleGroup: 'BACK', type: 'COMPOUND', category: ExerciseCategory.bodyweight),
    Exercise(name: 'Dumbbell Curls', muscleGroup: 'ARMS', type: 'ISOLATION', category: ExerciseCategory.isolation),
    Exercise(name: 'Hanging Leg Raise', muscleGroup: 'CORE', type: 'STABILITY', category: ExerciseCategory.core),
  ];

  final _filterLabels = ['ALL', 'CHEST', 'LEGS', 'BACK', 'ARMS', 'CORE'];

  List<Exercise> get _filtered => _exercises.where((e) {
        final matchesFilter = _selectedFilter == 'ALL' || e.muscleGroup == _selectedFilter;
        final matchesSearch = _searchQuery.isEmpty || e.name.toLowerCase().contains(_searchQuery.toLowerCase());
        return matchesFilter && matchesSearch;
      }).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Exercise Library")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: 'Search movements...',
                prefixIcon: const Icon(Icons.search, size: 20),
                filled: true,
                fillColor: AppColors.surfaceVariant,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              ),
            ),
          ),
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _filterLabels.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final label = _filterLabels[i];
                final active = _selectedFilter == label;
                return GestureDetector(
                  onTap: () => setState(() => _selectedFilter = label),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: active ? AppColors.primary : AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: active ? Colors.white : AppColors.textSecondary)),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _filtered.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) => _ExerciseCard(exercise: _filtered[i]),
            ),
          ),
        ],
      ),
    );
  }
}

// ── MODELS & SUB-COMPONENTS ──────────────────────────────────────────────────
enum ExerciseCategory { strength, power, bodyweight, isolation, core }

class Exercise {
  final String name;
  final String muscleGroup;
  final String type;
  final ExerciseCategory category;
  const Exercise({required this.name, required this.muscleGroup, required this.type, required this.category});
}

class _ExerciseCard extends StatelessWidget {
  final Exercise exercise;
  const _ExerciseCard({required this.exercise});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      tileColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Text(exercise.name),
      subtitle: Text("${exercise.muscleGroup} • ${exercise.type}"),
      trailing: const Icon(Icons.add_circle_outline, color: AppColors.primary),
    );
  }
}

// Empty Destinations
class ActiveWorkoutScreen extends StatelessWidget { const ActiveWorkoutScreen({super.key}); @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text("Active Session"))); }
class TemplateBuilderScreen extends StatelessWidget { const TemplateBuilderScreen({super.key}); @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text("Create Template"))); }