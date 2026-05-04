
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/app_providers.dart';
import 'exercise_selection_screen.dart';
import 'active_workout_screen.dart';

class TemplateBuilderScreen extends ConsumerWidget {
  const TemplateBuilderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            _buildWorkoutIdentityCard(),
            const SizedBox(height: 32),
            _buildEmptyCanvas(context),
            const SizedBox(height: 48),
            _buildFoundationSection(context),
          ],
        ),
      ),
      bottomNavigationBar: _buildContextualActionBar(),
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
        'KINETIC ZEN',
        style: TextStyle(
          color: Color(0xFF005DA7),
          fontWeight: FontWeight.bold,
          fontStyle: FontStyle.italic,
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
          'CREATIVE BUILDER',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            color: Color(0xFF5C5F60),
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Define your momentum.',
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

  Widget _buildWorkoutIdentityCard() {
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
          Row(
            children: [
              _buildMiniStat('Estimated Duration', '-- mins'),
              const SizedBox(width: 16),
              _buildMiniStat('Target Focus', 'All', highlight: true),
            ],
          ),
        ],
      ),
    );
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
            height: 80, width: 80,
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
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ExerciseSelectionScreen()))
          ),
        ],
      ),
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
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ActiveWorkoutScreen())),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white, 
          borderRadius: BorderRadius.circular(16), 
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20)]
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

  Widget _buildContextualActionBar() {
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
              const Text('TEMPLATE STATUS', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Color(0xFF5C5F60))),
              Row(
                children: [
                  Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFFBA1A1A), shape: BoxShape.circle)),
                  const SizedBox(width: 8),
                  const Text('Draft Mode', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                ],
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE2E2E2),
              foregroundColor: const Color(0xFF414751),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              elevation: 0,
            ),
            child: const Text('SAVE DRAFT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
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