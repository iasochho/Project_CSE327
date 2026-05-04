import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/app_providers.dart';
import '../../models/app_models.dart';
import 'notifications.dart';
import 'profile_screen.dart';

class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      extendBody: true,
      appBar: _buildAppBar(context, user), // Passed context
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        children: [
          _buildCommunityPulse(context), // Passed context
          const SizedBox(height: 32),
          _buildHeroPost(context), // Passed context
          const SizedBox(height: 24),
          _buildStatBentoPost(context), // Passed context
          const SizedBox(height: 24),
          _buildVideoPost(context), // Passed context
          const SizedBox(height: 120),
        ],
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, UserModel user) {
    return AppBar(
      backgroundColor: Colors.white.withOpacity(0.8),
      elevation: 0,
      centerTitle: true,
      leading: Padding(
        padding: const EdgeInsets.only(left: 16.0),
        child: CircleAvatar(
          radius: 20,
          backgroundImage: NetworkImage(user.avatarUrl.isNotEmpty ? user.avatarUrl : 'https://via.placeholder.com/150'),
        ),
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
          icon: const Icon(Icons.notifications_outlined, color: Color(0xFF005DA7)),
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SocialScreen())),
        ),
      ],
    );
  }

  Widget _buildCommunityPulse(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('COMMUNITY', style: TextStyle(color: Color(0xFF005DA7), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                Text('Active Now', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
              ],
            ),
            const Text('View All', style: TextStyle(color: Color(0xFF005DA7), fontWeight: FontWeight.w600, fontSize: 14)),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 90,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildStoryItem(context, 'Leo.K', 'https://via.placeholder.com/150', isActive: true),
              _buildStoryItem(context, 'Sara_M', 'https://via.placeholder.com/150'),
              _buildStoryItem(context, 'Zen_Jin', 'https://via.placeholder.com/150'),
              _buildStoryItem(context, 'Miya.Fit', 'https://via.placeholder.com/150'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStoryItem(BuildContext context, String label, String url, {bool isActive = false}) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
      child: Padding(
        padding: const EdgeInsets.only(right: 16.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: isActive ? const LinearGradient(colors: [Color(0xFF005DA7), Color(0xFF00685F)]) : null,
                color: isActive ? null : Colors.grey[300],
              ),
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: CircleAvatar(radius: 28, backgroundImage: NetworkImage(url)),
              ),
            ),
            const SizedBox(height: 4),
            Text(label.toUpperCase(), style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 1)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroPost(BuildContext context) {
    return _buildPostCard(
      child: Column(
        children: [
          _buildPostHeader(context, 'Leo Kasparov', 'Berlin, DE • 2h ago', 'https://via.placeholder.com/150'),
          Stack(
            alignment: Alignment.bottomLeft,
            children: [
              AspectRatio(
                aspectRatio: 4 / 5,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network('https://via.placeholder.com/400x500', fit: BoxFit.cover),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildGlassStat('Power Flow', '745', 'kcal'),
                    Container(
                      height: 48, width: 48,
                      decoration: const BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [Color(0xFF005DA7), Color(0xFF2976C7)])),
                      child: const Icon(Icons.play_arrow, color: Colors.white),
                    ),
                  ],
                ),
              )
            ],
          ),
          _buildPostFooter('1.2k', '42', 'Found my rhythm today in the morning session.'),
        ],
      ),
    );
  }

  Widget _buildStatBentoPost(BuildContext context) {
    return _buildPostCard(
      child: Column(
        children: [
          _buildPostHeader(context, 'Sara Miller', 'London, UK • 5h ago', 'https://via.placeholder.com/150'),
          Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network('https://via.placeholder.com/400x200', height: 160, width: double.infinity, fit: BoxFit.cover),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildSimpleStat('Distance', '12.4', 'km', const Color(0xFF005DA7))),
                  const SizedBox(width: 12),
                  Expanded(child: _buildSimpleStat('Avg Pace', '4\'12"', '/km', const Color(0xFF00685F))),
                ],
              )
            ],
          ),
          _buildPostFooter('856', '18', 'Activity: Endurance Run'),
        ],
      ),
    );
  }

  Widget _buildVideoPost(BuildContext context) {
    return _buildPostCard(
      child: Column(
        children: [
          _buildPostHeader(context, 'Zen Jin', 'Tokyo, JP • Yesterday', 'https://via.placeholder.com/150'),
          Stack(
            alignment: Alignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: AspectRatio(aspectRatio: 16/9, child: Image.network('https://via.placeholder.com/400x225', fit: BoxFit.cover)),
              ),
              Container(
                width: 64, height: 64,
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle, border: Border.all(color: Colors.white.withOpacity(0.3))),
                child: const Icon(Icons.play_arrow, color: Colors.white, size: 32),
              ),
            ],
          ),
          _buildPostFooter('2.4k', '104', 'Mastering the breath today. 🧘‍♂️'),
        ],
      ),
    );
  }

  Widget _buildPostCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(32), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 32, offset: const Offset(0, 12))]),
      child: child,
    );
  }

  Widget _buildPostHeader(BuildContext context, String name, String meta, String url) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(children: [
            GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
              child: CircleAvatar(radius: 20, backgroundImage: NetworkImage(url)),
            ),
            const SizedBox(width: 12),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              Text(meta.toUpperCase(), style: const TextStyle(fontSize: 9, color: Color(0xFF5C5F60), letterSpacing: 0.5)),
            ]),
          ]),
          const Icon(Icons.more_horiz, color: Color(0xFF5C5F60)),
        ],
      ),
    );
  }

  Widget _buildPostFooter(String likes, String comments, String caption) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            _iconStat(Icons.favorite, likes, const Color(0xFF005DA7)),
            const SizedBox(width: 24),
            _iconStat(Icons.chat_bubble_outline, comments, const Color(0xFF5C5F60)),
            const Spacer(),
            const Icon(Icons.bookmark_border, color: Color(0xFF5C5F60)),
          ]),
          const SizedBox(height: 12),
          Text(caption, style: const TextStyle(fontSize: 13, height: 1.5, color: Color(0xFF414751))),
        ],
      ),
    );
  }

  Widget _iconStat(IconData icon, String count, Color color) {
    return Row(children: [
      Icon(icon, size: 18, color: color),
      const SizedBox(width: 6),
      Text(count, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
    ]);
  }

  Widget _buildGlassStat(String label, String value, String unit) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.8), borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Color(0xFF005DA7))),
          Row(crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, children: [
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(width: 2),
            Text(unit, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF5C5F60))),
          ]),
        ],
      ),
    );
  }

  Widget _buildSimpleStat(String label, String value, String unit, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFFF3F3F3), borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Color(0xFF5C5F60))),
          Row(crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, children: [
            Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(width: 2),
            Text(unit, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF5C5F60))),
          ]),
        ],
      ),
    );
  }

  Widget _buildFAB() {
    return FloatingActionButton(
      onPressed: () {},
      elevation: 10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.transparent,
      child: Container(
        width: 56, height: 56,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), gradient: const LinearGradient(colors: [Color(0xFF005DA7), Color(0xFF2976C7)])),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}