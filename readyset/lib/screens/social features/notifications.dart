import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/app_providers.dart';
import '../../models/app_models.dart';
import 'profile_screen.dart';

class SocialScreen extends ConsumerWidget {
  const SocialScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: _buildAppBar(user),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        children: [
          const SizedBox(height: 20),
          _buildHeadline(),
          const SizedBox(height: 32),
          _buildSectionHeader('Recent'),
          const SizedBox(height: 24),
          _buildFollowerNotification(context,
            name: 'Marcus Chen',
            time: '2 minutes ago',
            imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDtrLXebY9Vr3hRlSLlGf9tStRzjgNIr97yXf5OY8DSCEzahPy9CMhxdT0QqU1waW09aZDMdXr1MMjE_IxfImLTDotGQNj-ucY1IpyZikAtJhYv4da8VbNNyi6XLOaZ2DVJweU1gA0gIxSTpchjjTs4aAz8f-BUXygSQk7HMPXgt3YRjoR7VBvtANE9T5u7eokV5Q_qjR4IKEkVGI_p42_e5wr3_JtGXtXecvIdsjkeRpGnd1njfsMn-ofRu2d6YW0Hd9-iogIAaXOD',
          ),
          const SizedBox(height: 24),
          _buildLikeNotification(context,
            name: 'Elena Rodriguez',
            time: '45 minutes ago',
            milestone: '5km Morning Run',
            imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBQtMUyO3t40wuNDNgQqg77Ib6_W_eEF-95XRZB6MBW5N1gBFoVPAKLfr2ly9xKIb8hRdu2Q3OZXKmBwdHMk6Lu1LQLgQwx4lRJZ6xpMI-t0YZ6PnPIM4bJG4hZ72yMAPlXUxz38OtiCbm_VjcgUT341w5RvrsXnvyiGLHNt3Kf6UiH7l_PzghvbD4iG8AMHsG6KXAhavV0LQcXkqalkuJZwswAeli0s4oF1xDndXZRG_0qRFGbMdIpESumBKsQFUwbfJnCWwHcmm4e',
          ),
          const SizedBox(height: 32),
          _buildSectionHeader('This Week'),
          const SizedBox(height: 24),
          _buildWorkoutSharedNotification(context,
            coach: 'Coach Julian',
            workoutTitle: 'Zen Flow Yoga',
            time: 'Yesterday',
            imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuA8twsyp1AXcielIBliwASJXveDNU8R0MRoh5JoDWJRCxLafbJiJygEcXaj0TqdZx0vgZnpWkGxHiOWhBhKeujqfi2z7eBvTexwEq_yl_JYPoiVW4G3agFg2SZn8pB6c2letro2P_k7RyrFSpG2qBNYq-bvJgZ_YDGrrWPmTnIF8Mp-9stBmvD5EESqKp3vNEyRmrwG-yWsyGPcp6ibtLHCY1hFL8lokTfIapevTGyUyBPp1WnEirJkuS7j-BmCkf-uDmvohDRnOEXO',
          ),
          const SizedBox(height: 24),
          _buildCommunityAchievement(),
          const SizedBox(height: 100), // Bottom nav buffer
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(UserModel user) {
    return AppBar(
      backgroundColor: Colors.white.withOpacity(0.8),
      elevation: 0,
      centerTitle: false,
      title: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage(user.avatarUrl.isNotEmpty 
              ? user.avatarUrl 
              : 'https://lh3.googleusercontent.com/aida-public/AB6AXuBOB1xRoC0mXEBww9Z-e-E9EuX0wd0DRpGWEYiNBiKdr0vA3eo7Ufk7yJBVujLxeoWVZndGngxr3xCZ1JFufmFFUSkYR8TUzHEq4rUmU2K-PuLvft4nklMAYfxQ5TYIxmPrk-txvSZ2P6KWqONLWGapoqpE1vcwPmHk3DUThNgZW2a1qM_dHdx8TJggDgtvpfbgv9Paq7SNFbLJmpuTI24VSJzbjMzn5qfyb4rV_yRPwZ1JcoProaw1iPx6qBKIDAFboyiuJ8EIozs8'),
          ),
          const SizedBox(width: 12),
          const Text(
            'ReadySet',
            style: TextStyle(
              color: Color(0xFF005DA7),
              fontWeight: FontWeight.bold,
              fontSize: 18,
              letterSpacing: -1,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: Color(0xFF005DA7)),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildHeadline() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Activity',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            letterSpacing: -1,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Stay updated with your community.',
          style: TextStyle(color: Color(0xFF5C5F60), fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: Color(0xFF5C5F60),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(height: 1, color: Colors.grey.withOpacity(0.2)),
        ),
      ],
    );
  }

  Widget _buildFollowerNotification(BuildContext context, {required String name, required String time, required String imageUrl}) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: _cardDecoration(),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAvatarWithIcon(imageUrl, Icons.person_add, const Color(0xFF005DA7)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(color: Colors.black, fontSize: 14),
                      children: [
                        TextSpan(text: name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        const TextSpan(text: ' started following you.'),
                      ],
                    ),
                  ),
                  Text(time.toUpperCase(), style: _timeStyle()),
                ],
              ),
            ),
            _buildActionButton('Follow Back'),
          ],
        ),
      ),
    );
  }

  Widget _buildLikeNotification(BuildContext context, {required String name, required String time, required String milestone, required String imageUrl}) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: _cardDecoration(),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAvatarWithIcon(imageUrl, Icons.favorite, const Color(0xFFBA1A1A)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(color: Colors.black, fontSize: 14),
                      children: [
                        TextSpan(text: name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        TextSpan(text: ' liked your $milestone milestone.'),
                      ],
                    ),
                  ),
                  Text(time.toUpperCase(), style: _timeStyle()),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: const DecorationImage(
                  image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuAABFSWADmmmNN2QZs6bai4A3XeMpaC1YbmtxSTPOiDYGfkDnMPXBn_nEBay-rPiwMm2wZNsAAiG9RBW27FDMlbLV7jS-uEjyWJtvzA_VjBw5mNAmobH27hEfHXbGZNVN-dEtT2k1e86j0qtZeEXS3lK6_n-BfYydmBzrlpKn4hrKfQ2SlYCF2qEsn-l14r7FS1DFk4eUi8U4TuCrjjZVUROagrFGInxpps8KhMlF2A17GMkdYB98fKGaopGK7c4E65gOybAgfFe5GD'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkoutSharedNotification(BuildContext context, {required String coach, required String workoutTitle, required String time, required String imageUrl}) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: _cardDecoration(lowEmphasis: true),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAvatarWithIcon(imageUrl, Icons.fitness_center, const Color(0xFF00685F)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(color: Colors.black, fontSize: 14),
                      children: [
                        TextSpan(text: coach, style: const TextStyle(fontWeight: FontWeight.bold)),
                        const TextSpan(text: ' shared a new '),
                        TextSpan(text: workoutTitle, style: const TextStyle(color: Color(0xFF00685F), fontWeight: FontWeight.w600)),
                        const TextSpan(text: ' workout.'),
                      ],
                    ),
                  ),
                  Text(time.toUpperCase(), style: _timeStyle()),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: const Color(0xFF00685F).withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                          child: const Icon(Icons.self_improvement, color: Color(0xFF00685F), size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text('Zen Flow: Level 2', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              Text('45 min • Intermediate', style: TextStyle(fontSize: 10, color: Color(0xFF5C5F60))),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right, size: 16, color: Color(0xFF5C5F60)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommunityAchievement() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(lowEmphasis: true),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: const Color(0xFF005DA7).withOpacity(0.1), shape: BoxShape.circle),
            child: const Icon(Icons.group, color: Color(0xFF005DA7), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your community just hit 1,000 combined kilometers this month! Keep pushing.',
                  style: TextStyle(fontSize: 14),
                ),
                Text('3 DAYS AGO', style: _timeStyle()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper widgets for consistent styling
  BoxDecoration _cardDecoration({bool lowEmphasis = false}) {
    return BoxDecoration(
      color: lowEmphasis ? const Color(0xFFF3F3F3) : Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: lowEmphasis ? [] : [
        BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 32, offset: const Offset(0, 12)),
      ],
    );
  }

  Widget _buildAvatarWithIcon(String imageUrl, IconData icon, Color iconBg) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        CircleAvatar(radius: 24, backgroundImage: NetworkImage(imageUrl), backgroundColor: Colors.grey[200]),
        Positioned(
          bottom: -2,
          right: -2,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
            child: Icon(icon, color: Colors.white, size: 10),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF005DA7), Color(0xFF2976C7)]),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
      ),
    );
  }

  TextStyle _timeStyle() => const TextStyle(fontSize: 10, color: Color(0xFF5C5F60), fontWeight: FontWeight.w500, letterSpacing: 0.5);
}