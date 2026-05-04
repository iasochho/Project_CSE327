// lib/screens/social features/profile_screen.dart
// FIX 1: Renamed class from 'ProfileScreen' to 'SocialProfileScreen' so that
//         social_feed.dart can resolve it via:
//           import 'profile_screen.dart' as social_profile;
//           social_profile.SocialProfileScreen()
// FIX 2: Changed _buildProfileHeader / _buildAchievementChips parameter type
//         from UserModel to UserProfile (userProvider now returns UserProfile).
//         Both models have the same fields used here (name, avatarUrl,
//         totalWorkouts, dayStreak), so no logic changes are needed.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/app_models.dart';
import '../../providers/app_providers.dart';

class SocialProfileScreen extends ConsumerWidget {
  const SocialProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  _buildProfileHeader(user),
                  const SizedBox(height: 32),
                  _buildAchievementChips(user),
                  const SizedBox(height: 32),
                  _buildTabNavigation(),
                  const SizedBox(height: 16),
                  _buildPostGrid(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      floating: true,
      backgroundColor: Colors.white.withOpacity(0.8),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1C1C)),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'ReadySet',
        style: TextStyle(
          color: Color(0xFF005DA7),
          fontWeight: FontWeight.bold,
          fontSize: 18,
          letterSpacing: -1,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.more_vert, color: Color(0xFF94A3B8)),
          onPressed: () => showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Options'),
              content: const Text('More options for this profile.'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close')),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // FIX: parameter is UserProfile, not UserModel
  Widget _buildProfileHeader(UserProfile user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      )
                    ],
                    image: DecorationImage(
                      image: NetworkImage(user.avatarUrl.isNotEmpty
                          ? user.avatarUrl
                          : 'https://via.placeholder.com/150'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 5,
                  right: 5,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                        color: Color(0xFF00685F), shape: BoxShape.circle),
                    child:
                        const Icon(Icons.verified, color: Colors.white, size: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildFollowButton(),
                      const SizedBox(width: 8),
                      _buildIconButton(Icons.mail_outline),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        const Text(
          'Marathon runner & Pilates instructor. Believer in functional movement and sustainable growth. ✨',
          style:
              TextStyle(color: Color(0xFF5C5F60), height: 1.5, fontSize: 14),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            _buildStatItem('1.2k', 'Followers'),
            const SizedBox(width: 32),
            _buildStatItem('482', 'Following'),
            const SizedBox(width: 32),
            _buildStatItem(user.totalWorkouts.toString(), 'Workouts',
                isHighlight: true),
          ],
        ),
      ],
    );
  }

  Widget _buildFollowButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [Color(0xFF005DA7), Color(0xFF2976C7)]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFF005DA7).withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 8))
        ],
      ),
      child: const Text(
        'FOLLOW',
        style: TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5),
      ),
    );
  }

  Widget _buildIconButton(IconData icon) {
    return Container(
      width: 36,
      height: 36,
      decoration:
          const BoxDecoration(color: Color(0xFFEEEEEE), shape: BoxShape.circle),
      child: Icon(icon, size: 18, color: const Color(0xFF414751)),
    );
  }

  Widget _buildStatItem(String value, String label, {bool isHighlight = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: -1,
            color: isHighlight
                ? const Color(0xFF00685F)
                : const Color(0xFF1A1C1C),
          ),
        ),
        Text(
          label.toUpperCase(),
          style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: Color(0xFF94A3B8),
              letterSpacing: 1),
        ),
      ],
    );
  }

  // FIX: parameter is UserProfile, not UserModel
  Widget _buildAchievementChips(UserProfile user) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _buildChip(Icons.workspace_premium, 'Early Bird', const Color(0xFF005DA7)),
        _buildChip(Icons.timer, 'Consistency King', const Color(0xFF00685F)),
        _buildChip(Icons.local_fire_department, '${user.dayStreak} Day Streak',
            const Color(0xFFBA1A1A)),
      ],
    );
  }

  Widget _buildChip(IconData icon, String label, Color iconColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
          color: const Color(0xFFDEE0E2),
          borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: iconColor),
          const SizedBox(width: 6),
          Text(
            label.toUpperCase(),
            style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Color(0xFF444749)),
          ),
        ],
      ),
    );
  }

  Widget _buildTabNavigation() {
    return Row(
      children: [
        _buildTabItem('Posts', isActive: true),
        const SizedBox(width: 32),
        _buildTabItem('Stats'),
        const SizedBox(width: 32),
        _buildTabItem('Videos'),
      ],
    );
  }

  Widget _buildTabItem(String label, {bool isActive = false}) {
    return Container(
      padding: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border(
            bottom: BorderSide(
                color: isActive
                    ? const Color(0xFF005DA7)
                    : Colors.transparent,
                width: 2)),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
          color:
              isActive ? const Color(0xFF005DA7) : const Color(0xFF94A3B8),
        ),
      ),
    );
  }

  Widget _buildPostGrid() {
    final List<String> images = [
      'https://via.placeholder.com/200',
      'https://via.placeholder.com/200',
      'https://via.placeholder.com/200',
      'https://via.placeholder.com/200',
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemCount: images.length,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            image: DecorationImage(
                image: NetworkImage(images[index]), fit: BoxFit.cover),
          ),
        );
      },
    );
  }
}
