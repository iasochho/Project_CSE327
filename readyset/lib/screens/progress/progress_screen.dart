// lib/screens/progress/progress_screen.dart
// OBSERVER PATTERN: progressProvider streams live data from Firestore
// ADAPTER PATTERN:  FirestoreAdapter.progressFromDocs() adapts raw Firestore docs
//                  into ProgressData (applied upstream in FirestoreService)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_theme.dart';
import '../../models/app_models.dart';
import '../../providers/app_providers.dart';
import '../../widgets/common/shared_widgets.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Observer: rebuild whenever Firestore workout data changes.
    // progressProvider is a StreamProvider<ProgressData> so .when() is valid.
    final progressAsync = ref.watch(progressProvider);

    return Scaffold(
      appBar: const KZAppBar(),
      body: progressAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off, size: 48, color: AppColors.textMuted),
              const SizedBox(height: 12),
              Text('Could not load progress',
                  style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => ref.invalidate(progressProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (progress) => _ProgressBody(progress: progress),
      ),
    );
  }
}

class _ProgressBody extends StatelessWidget {
  final ProgressData progress;
  const _ProgressBody({required this.progress});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      children: [
        Text('INSIGHTS',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.primary, letterSpacing: 1.2)),
        const SizedBox(height: 4),
        Text('Progress Tracking',
            style: Theme.of(context).textTheme.headlineLarge),
        const SizedBox(height: 24),

        // ── Strength Line Chart ────────────────────────────────────────────
        _StrengthChart(
          data: progress.strengthData,
          gainPercent: progress.strengthGainPercent,
        ),
        const SizedBox(height: 16),

        // ── Weekly Frequency Bar Chart ─────────────────────────────────────
        _WeeklyFrequencyChart(avgSessions: progress.avgSessionsPerWeek),
        const SizedBox(height: 16),

        // ── Stat Grid ─────────────────────────────────────────────────────
        Row(
          children: [
            Expanded(
              child: StatTile(
                label: 'PRs Hit',
                value: progress.prsHit.toString(),
                icon: const Icon(Icons.emoji_events_outlined,
                    color: AppColors.teal, size: 22),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatTile(
                label: 'Total Volume',
                value: '${progress.totalVolumeTons} Tons',
                icon: const Icon(Icons.fitness_center,
                    color: AppColors.primary, size: 22),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _StreakStatTile(days: progress.streakDays)),
            const SizedBox(width: 12),
            Expanded(
              child: StatTile(
                label: 'Body Weight',
                value: '${progress.weightKg.toStringAsFixed(1)} kg',
                icon: const Icon(Icons.monitor_weight_outlined,
                    color: AppColors.textSecondary, size: 22),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // ── Recent Milestones ──────────────────────────────────────────────
        if (progress.recentMilestones.isNotEmpty) ...[
          Text('Recent Milestones',
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 16),
          ...progress.recentMilestones.map((m) => _MilestoneTile(milestone: m)),
        ],
        const SizedBox(height: 32),
      ],
    );
  }
}

// ── Strength Line Chart ───────────────────────────────────────────────────────
class _StrengthChart extends StatelessWidget {
  final List<double> data;
  final double gainPercent;

  const _StrengthChart({required this.data, required this.gainPercent});

  @override
  Widget build(BuildContext context) {
    final spots = data
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value))
        .toList();

    return KZCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Strength Progress',
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 2),
                    Text('Aggregated 1RM across compound lifts',
                        style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.teal.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '+${gainPercent.toStringAsFixed(1)}%',
                  style: const TextStyle(
                      color: AppColors.teal,
                      fontWeight: FontWeight.w700,
                      fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 160,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 2,
                      getTitlesWidget: (value, meta) {
                        const labels = [
                          'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
                          'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'
                        ];
                        final i = value.toInt();
                        if (i >= 0 && i < labels.length && i % 2 == 0) {
                          return Text(labels[i],
                              style: const TextStyle(
                                  fontSize: 9, color: AppColors.textMuted));
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: AppColors.primary,
                    barWidth: 2.5,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.primary.withOpacity(0.08),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Weekly Frequency Bar Chart ────────────────────────────────────────────────
class _WeeklyFrequencyChart extends StatelessWidget {
  final double avgSessions;
  const _WeeklyFrequencyChart({required this.avgSessions});

  @override
  Widget build(BuildContext context) {
    const weeklyData   = [2.8, 3.5, 4.2, 3.8, 4.0, 3.2, 4.5];
    const highlightIdx = 2;

    return KZCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Weekly Frequency',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 2),
          Text('Session density per week',
              style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 20),
          SizedBox(
            height: 120,
            child: BarChart(
              BarChartData(
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: const FlTitlesData(show: false),
                barTouchData: BarTouchData(enabled: false),
                barGroups: weeklyData.asMap().entries.map((e) {
                  final isHighlight = e.key == highlightIdx;
                  return BarChartGroupData(
                    x: e.key,
                    barRods: [
                      BarChartRodData(
                        toY: e.value,
                        color: isHighlight
                            ? AppColors.primary
                            : AppColors.surfaceVariant,
                        width: 28,
                        borderRadius:
                            const BorderRadius.vertical(top: Radius.circular(8)),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Column(
              children: [
                Text(
                  avgSessions.toStringAsFixed(1),
                  style: Theme.of(context)
                      .textTheme
                      .displayMedium
                      ?.copyWith(color: AppColors.textPrimary, height: 1),
                ),
                const SizedBox(height: 2),
                Text('AVG SESSIONS',
                    style: Theme.of(context).textTheme.labelSmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Streak Stat Tile ──────────────────────────────────────────────────────────
class _StreakStatTile extends StatelessWidget {
  final int days;
  const _StreakStatTile({required this.days});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: const Border(left: BorderSide(color: AppColors.primary, width: 4)),
        boxShadow: const [
          BoxShadow(color: Color(0x08000000), blurRadius: 12, offset: Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.local_fire_department, color: AppColors.primary, size: 22),
          const SizedBox(height: 8),
          Text('STREAK', style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(height: 4),
          Text('$days Days', style: Theme.of(context).textTheme.headlineMedium),
        ],
      ),
    );
  }
}

// ── Milestone Tile ─────────────────────────────────────────────────────────────
// FIX: milestone.icon and milestone.date are nullable (String?) — added null
//      fallback operators so the screen compiles under null-safety.
class _MilestoneTile extends StatelessWidget {
  final Milestone milestone;
  const _MilestoneTile({required this.milestone});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Color(0x08000000), blurRadius: 12, offset: Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Center(
              // FIX: milestone.icon is String? — use ?? fallback
              child: Text(milestone.icon ?? '⭐',
                  style: const TextStyle(fontSize: 22)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(milestone.title,
                    style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
          ),
          // FIX: milestone.date is String? — use ?? fallback before .toUpperCase()
          Text(
            (milestone.date ?? '').toUpperCase(),
            style: Theme.of(context)
                .textTheme
                .labelSmall
                ?.copyWith(fontSize: 9),
          ),
        ],
      ),
    );
  }
}
