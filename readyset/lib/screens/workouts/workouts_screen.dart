// lib/screens/workouts/workouts_screen.dart
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/common/shared_widgets.dart';
import '../exercise/active_workout_screen.dart';
import '../exercise/template_builder_screen.dart';
import '../exercise/exercise_selection_screen.dart';

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
