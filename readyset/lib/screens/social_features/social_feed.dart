



import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/firestore_service.dart';
import '../../core/services/notification_service.dart';
import '../../models/app_models.dart';
import '../../providers/app_providers.dart';

import '../../widgets/common/shared_widgets.dart';
import 'profile_screen.dart' as social_profile;

class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final feedAsync = ref.watch(socialFeedProvider);
    final notifCount = ref.watch(notificationCountProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.9),
        elevation: 0,
        centerTitle: false,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFF005DA7).withOpacity(0.1),
              backgroundImage: user.avatarUrl.isNotEmpty
                  ? NetworkImage(user.avatarUrl)
                  : null,
              child: user.avatarUrl.isEmpty
                  ? const Icon(Icons.person, color: Color(0xFF005DA7), size: 20)
                  : null,
            ),
            const SizedBox(width: 12),
            const Text(
              'ReadySet',
              style: TextStyle(
                color: Color(0xFF005DA7),
                fontWeight: FontWeight.bold,
                fontSize: 18,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        actions: [
          
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: BadgeDecorator(
              count: notifCount,
              child: IconButton(
                icon: const Icon(Icons.notifications_outlined,
                    color: Color(0xFF005DA7)),
                onPressed: () {
                  ref.read(notificationCountProvider.notifier).state = 0;
                },
              ),
            ),
          ),
        ],
      ),
      body: feedAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFF005DA7)),
        ),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off, size: 48, color: Color(0xFF5C5F60)),
              const SizedBox(height: 16),
              Text('Could not load feed', style: TextStyle(color: Colors.grey[600])),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => ref.invalidate(socialFeedProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (posts) => posts.isEmpty
            ? _buildEmptyState(context, ref, user)
            : _buildFeed(context, ref, posts, user),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreatePost(context, ref, user),
        backgroundColor: const Color(0xFF005DA7),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Share Workout',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildFeed(BuildContext context, WidgetRef ref,
      List<SocialPost> posts, UserProfile userProfile) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      children: [
        _buildHeadline(),
        const SizedBox(height: 24),
        _buildSectionHeader('Recent'),
        const SizedBox(height: 16),
        ...posts.map((post) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _PostCard(
                post: post,
                onLike: () => ref.read(firestoreServiceProvider).likePost(post.id),
                onTapProfile: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const social_profile.SocialProfileScreen()),
                ),
              ),
            )),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref, UserProfile user) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.people_outline, size: 64, color: Color(0xFF5C5F60)),
          const SizedBox(height: 16),
          const Text('No posts yet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Be the first to share a workout!',
              style: TextStyle(color: Colors.grey[600])),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => _showCreatePost(context, ref, user),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF005DA7),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)),
            ),
            child: const Text('Share a Workout',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildHeadline() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Activity',
            style: TextStyle(
                fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: -1)),
        SizedBox(height: 4),
        Text('Stay updated with your community.',
            style: TextStyle(color: Color(0xFF5C5F60), fontSize: 14)),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Text(title.toUpperCase(),
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: Color(0xFF5C5F60))),
        const SizedBox(width: 16),
        Expanded(child: Container(height: 1, color: Colors.grey.withOpacity(0.2))),
      ],
    );
  }

  void _showCreatePost(BuildContext context, WidgetRef ref, UserProfile user) {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          top: 24,
          left: 24,
          right: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Share a Workout',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'What did you crush today?',
                filled: true,
                fillColor: const Color(0xFFF3F4F6),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (controller.text.trim().isNotEmpty) {
                    final post = SocialPost(
                      id: '',
                      userId: user.uid,
                      userName: user.name,
                      userAvatarUrl: user.avatarUrl,
                      content: controller.text.trim(),
                      createdAt: DateTime.now(),
                    );
                    await ref.read(firestoreServiceProvider).createPost(post);
                    
                    ref.read(workoutEventBusProvider).notifyStarted('', 'Post shared');
                    if (context.mounted) Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF005DA7),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24)),
                ),
                child: const Text('POST',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class _PostCard extends StatefulWidget {
  final SocialPost post;
  final VoidCallback onLike;
  final VoidCallback onTapProfile;

  const _PostCard({required this.post, required this.onLike, required this.onTapProfile});

  @override
  State<_PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<_PostCard> {
  late bool _liked;
  late int _likes;

  @override
  void initState() {
    super.initState();
    _liked = widget.post.likedByCurrentUser;
    _likes = widget.post.likes;
  }

  void _toggleLike() {
    setState(() {
      _liked = !_liked;
      _likes += _liked ? 1 : -1;
    });
    if (_liked) widget.onLike();
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 20,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: widget.onTapProfile,
                child: CircleAvatar(
                  radius: 22,
                  backgroundColor:
                      const Color(0xFF005DA7).withOpacity(0.1),
                  backgroundImage: widget.post.userAvatarUrl.isNotEmpty
                      ? NetworkImage(widget.post.userAvatarUrl)
                      : null,
                  child: widget.post.userAvatarUrl.isEmpty
                      ? const Icon(Icons.person, color: Color(0xFF005DA7))
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.post.userName,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14)),
                    Text(_timeAgo(widget.post.createdAt),
                        style: const TextStyle(
                            color: Color(0xFF5C5F60), fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(widget.post.content,
              style: const TextStyle(fontSize: 14, height: 1.5)),
          if (widget.post.workoutTitle != null) ...[
            const SizedBox(height: 10),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF005DA7).withOpacity(0.06),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.fitness_center,
                      size: 14, color: Color(0xFF005DA7)),
                  const SizedBox(width: 8),
                  Text(widget.post.workoutTitle!,
                      style: const TextStyle(
                          color: Color(0xFF005DA7),
                          fontWeight: FontWeight.w600,
                          fontSize: 12)),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              GestureDetector(
                onTap: _toggleLike,
                child: Row(
                  children: [
                    Icon(
                      _liked ? Icons.favorite : Icons.favorite_border,
                      color: _liked
                          ? const Color(0xFFBA1A1A)
                          : const Color(0xFF5C5F60),
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Text('$_likes',
                        style: const TextStyle(
                            color: Color(0xFF5C5F60), fontSize: 13)),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              const Icon(Icons.chat_bubble_outline,
                  size: 20, color: Color(0xFF5C5F60)),
              const SizedBox(width: 4),
              const Text('Reply',
                  style: TextStyle(color: Color(0xFF5C5F60), fontSize: 13)),
            ],
          ),
        ],
      ),
    );
  }
}
