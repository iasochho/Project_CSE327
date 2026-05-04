// lib/widgets/common/shared_widgets.dart
// DECORATOR PATTERN:
//   KZAppBar        – wraps notification icon with a live badge (BadgeDecorator)
//   LoadingDecorator – overlays a spinner on any child
//   ErrorDecorator  – prepends an error banner to any child
//   BadgeDecorator  – adds a count bubble to any child widget

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/notification_service.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/app_providers.dart';
// FIX: was '../screens/social features/notifications.dart' (one level too shallow)
import '../../screens/social_features/notifications.dart';

// ── KZ Card ───────────────────────────────────────────────────────────────────
class KZCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final double? borderRadius;
  final VoidCallback? onTap;

  const KZCard({
    super.key,
    required this.child,
    this.padding,
    this.color,
    this.borderRadius,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color ?? AppColors.surface,
        borderRadius: BorderRadius.circular(borderRadius ?? 16),
        boxShadow: const [
          BoxShadow(color: Color(0x08000000), blurRadius: 12, offset: Offset(0, 2)),
        ],
      ),
      child: child,
    );
    if (onTap != null) return GestureDetector(onTap: onTap, child: card);
    return card;
  }
}

// ── Stat Tile ─────────────────────────────────────────────────────────────────
class StatTile extends StatelessWidget {
  final String label;
  final String value;
  final Widget? icon;

  const StatTile({
    super.key,
    required this.label,
    required this.value,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return KZCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[icon!, const SizedBox(height: 8)],
          Text(label.toUpperCase(), style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(height: 4),
          Text(value, style: Theme.of(context).textTheme.headlineMedium),
        ],
      ),
    );
  }
}

// ── App Bar (Decorator: BadgeDecorator wraps notification icon) ───────────────
// ConsumerWidget so it reactively reads notificationCountProvider
class KZAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final String? subtitle;

  const KZAppBar({super.key, this.subtitle});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Observer: badge count updates whenever a new notification arrives
    final notifCount = ref.watch(notificationCountProvider);

    return AppBar(
      titleSpacing: 20,
      title: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: AppColors.primaryDark,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.bolt, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 8),
          Text(
            'READYSET',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8),
          // Decorator: BadgeDecorator adds count bubble to the bell icon
          child: BadgeDecorator(
            count: notifCount,
            child: IconButton(
              icon: const Icon(Icons.notifications_outlined,
                  color: AppColors.textSecondary),
              onPressed: () {
                // Reset badge then open notifications
                ref.read(notificationCountProvider.notifier).state = 0;
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

// ── Decorator Pattern ─────────────────────────────────────────────────────────
// Base decorator interface
abstract class WidgetDecorator extends StatelessWidget {
  final Widget child;
  const WidgetDecorator({super.key, required this.child});
}

// Loading overlay – absorbs taps while spinning
class LoadingDecorator extends WidgetDecorator {
  final bool isLoading;
  const LoadingDecorator({
    super.key,
    required super.child,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AbsorbPointer(absorbing: isLoading, child: child),
        if (isLoading)
          Positioned.fill(
            child: Container(
              color: Colors.white.withOpacity(0.7),
              child: const Center(
                child: CircularProgressIndicator(color: Color(0xFF005DA7)),
              ),
            ),
          ),
      ],
    );
  }
}

// Error banner – prepends a dismissible red banner above child
class ErrorDecorator extends WidgetDecorator {
  final String? error;
  final VoidCallback? onDismiss;

  const ErrorDecorator({
    super.key,
    required super.child,
    this.error,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (error != null && error!.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFFEE2E2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: Color(0xFFBA1A1A), size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    error!,
                    style: const TextStyle(
                      color: Color(0xFFBA1A1A),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (onDismiss != null)
                  GestureDetector(
                    onTap: onDismiss,
                    child: const Icon(Icons.close, color: Color(0xFFBA1A1A), size: 16),
                  ),
              ],
            ),
          ),
        Expanded(child: child),
      ],
    );
  }
}

// Badge count bubble – wraps any widget with a red count indicator
class BadgeDecorator extends WidgetDecorator {
  final int count;
  const BadgeDecorator({super.key, required super.child, required this.count});

  @override
  Widget build(BuildContext context) {
    if (count == 0) return child;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned(
          top: -4,
          right: -4,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              color: Color(0xFFBA1A1A),
              shape: BoxShape.circle,
            ),
            constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
            child: Text(
              count > 99 ? '99+' : '$count',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}
