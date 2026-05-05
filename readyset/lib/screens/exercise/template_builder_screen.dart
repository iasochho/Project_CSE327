
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/app_models.dart';
import '../../providers/app_providers.dart';
import 'exercise_selection_screen.dart';

class TemplateBuilderScreen extends ConsumerStatefulWidget {
  const TemplateBuilderScreen({super.key});

  @override
  ConsumerState<TemplateBuilderScreen> createState() => _TemplateBuilderScreenState();
}

class _TemplateBuilderScreenState extends ConsumerState<TemplateBuilderScreen> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final template = ref.watch(templateBuilderProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      extendBody: true,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 140),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeroTitle(),
            const SizedBox(height: 32),
            _buildWorkoutIdentityCard(template),
            const SizedBox(height: 32),
            _buildExercisesCanvas(context, template),
            const SizedBox(height: 48),
            _buildFoundationSection(context),
          ],
        ),
      ),
      bottomNavigationBar: _buildContextualActionBar(context, template),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white.withOpacity(0.8),
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.close, color: Color(0xFF005DA7)),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'TEMPLATE BUILDER',
        style: TextStyle(
          color: Color(0xFF005DA7),
          fontWeight: FontWeight.bold,
          fontSize: 18,
          letterSpacing: -1,
        ),
      ),
    );
  }

  Widget _buildHeroTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'CREATE ROUTINE',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            color: Color(0xFF5C5F60),
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Build your custom workout.',
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold,
            letterSpacing: -1,
            height: 1.1,
          ),
        ),
      ],
    );
  }

  Widget _buildWorkoutIdentityCard(WorkoutTemplate template) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 32, offset: const Offset(0, 12))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'TEMPLATE NAME',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Color(0xFF414751)),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            onChanged: (value) => ref.read(templateBuilderProvider.notifier).setName(value),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              hintText: 'e.g., Upper Body Blast',
              filled: true,
              fillColor: const Color(0xFFE2E2E2),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'DESCRIPTION',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Color(0xFF414751)),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _descriptionController,
            onChanged: (value) => ref.read(templateBuilderProvider.notifier).setDescription(value),
            maxLines: 3,
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Add notes about this routine...',
              filled: true,
              fillColor: const Color(0xFFE2E2E2),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildMiniStat('Exercises', template.exercises.length.toString()),
              const SizedBox(width: 16),
              _buildMiniStat('Duration', '${_calculateDuration(template)} mins'),
            ],
          ),
        ],
      ),
    );
  }

  int _calculateDuration(WorkoutTemplate template) {
    int total = 0;
    for (var exercise in template.exercises) {
      total += (exercise.sets.length * 3) + 2;
    }
    return total;
  }

  Widget _buildMiniStat(String label, String value, {bool highlight = false}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: const Color(0xFFF3F3F3), borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label.toUpperCase(), style: const TextStyle(fontSize: 9, color: Color(0xFF5C5F60), fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: highlight ? const Color(0xFF005DA7) : Colors.black)),
          ],
        ),
      ),
    );
  }

  Widget _buildExercisesCanvas(BuildContext context, WorkoutTemplate template) {
    return template.exercises.isEmpty
        ? _buildEmptyCanvas(context)
        : _buildExercisesList(context, template);
  }

  Widget _buildEmptyCanvas(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F3F3),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFC1C7D3).withOpacity(0.3), width: 2),
      ),
      child: Column(
        children: [
          Container(
            height: 80,
            width: 80,
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: const Icon(Icons.fitness_center, color: Color(0xFF005DA7), size: 32),
          ),
          const SizedBox(height: 24),
          const Text('The canvas is yours.', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          const Text(
            'Your custom exercises will appear here. Start adding movements to build your sequence.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF414751), height: 1.5),
          ),
          const SizedBox(height: 32),
          _buildPrimaryButton(
            'Add First Exercise',
            Icons.add,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ExerciseSelectionScreen()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExercisesList(BuildContext context, WorkoutTemplate template) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Exercises', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        ...template.exercises.asMap().entries.map((e) {
          final idx = e.key;
          final exercise = e.value;
          return Dismissible(
            key: Key('$idx-${exercise.exerciseId}'),
            onDismissed: (_) => ref.read(templateBuilderProvider.notifier).removeExercise(idx),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(exercise.exerciseName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            Text('${exercise.muscleGroup} • ${exercise.sets.length} sets', style: const TextStyle(fontSize: 13, color: Color(0xFF5C5F60))),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Color(0xFFBA1A1A), size: 20),
                        onPressed: () => ref.read(templateBuilderProvider.notifier).removeExercise(idx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: exercise.sets.map((set) => Chip(
                      label: Text('${set.reps}x${set.weight.toStringAsFixed(0)}kg'),
                      backgroundColor: const Color(0xFFF3F3F3),
                      side: const BorderSide(color: Color(0xFFE0E0E0)),
                    )).toList(),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
        const SizedBox(height: 16),
        _buildPrimaryButton(
          'Add Exercise',
          Icons.add,
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ExerciseSelectionScreen()),
          ),
        ),
      ],
    );
  }

  Widget _buildFoundationSection(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text('Quick Foundations', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text('BROWSE ALL', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF005DA7), letterSpacing: 1)),
          ],
        ),
        const SizedBox(height: 24),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.3,
          children: [
            _buildBentoCard(context, 'HIIT Core', '8 Movements', Icons.speed, const Color(0xFF00685F)),
            _buildBentoCard(context, 'Flow State', '12 Movements', Icons.architecture, const Color(0xFF005DA7)),
          ],
        ),
      ],
    );
  }

  Widget _buildBentoCard(BuildContext context, String title, String sub, IconData icon, Color color) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: color),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text(sub.toUpperCase(), style: const TextStyle(fontSize: 9, color: Color(0xFF414751), fontWeight: FontWeight.bold)),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildContextualActionBar(BuildContext context, WorkoutTemplate template) {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 32)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('STATUS', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Color(0xFF5C5F60))),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: template.isDraft ? const Color(0xFFBA1A1A) : const Color(0xFF4CAF50),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    template.isDraft ? 'Draft' : 'Saved',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
          ElevatedButton(
            onPressed: _isSaving
                ? null
                : () async {
                    if (_nameController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter a template name')),
                      );
                      return;
                    }
                    setState(() => _isSaving = true);
                    try {
                      final user = ref.read(userProvider);
                      await ref.read(templateBuilderProvider.notifier).saveTemplate(user.uid);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Template saved successfully!')),
                        );
                        Navigator.pop(context);
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e')),
                        );
                      }
                    } finally {
                      if (mounted) setState(() => _isSaving = false);
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF005DA7),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              elevation: 0,
            ),
            child: _isSaving
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white)))
                : const Text('SAVE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryButton(String label, IconData icon, {VoidCallback? onPressed}) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF005DA7), Color(0xFF2976C7)]),
          borderRadius: BorderRadius.circular(32),
          boxShadow: [BoxShadow(color: const Color(0xFF005DA7).withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 12),
            Text(label.toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 1.5)),
          ],
        ),
      ),
    );
  }
}