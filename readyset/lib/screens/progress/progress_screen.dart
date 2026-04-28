// lib/screens/progress/progress_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/app_providers.dart';
import '../../widgets/common/shared_widgets.dart';
import '../../models/app_models.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(progressProvider);

    return Scaffold(
      appBar: const KZAppBar(),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        children: [
          Text('INSIGHTS',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.primary,
                    letterSpacing: 1.2,
                  )),
          const SizedBox(height: 4),
          Text('Progress Tracking',
              style: Theme.of(context).textTheme.headlineLarge),
          const SizedBox(height: 24),

          // ── Strength Line Chart ──────────────────────────────────────────
          _StrengthChart(
            data: progress.strengthData,
            gainPercent: progress.strengthGainPercent,
          ),
          const SizedBox(height: 16),

          // ── Weekly Frequency Bar Chart ───────────────────────────────────
          _WeeklyFrequencyChart(avgSessions: progress.avgSessionsPerWeek),
          const SizedBox(height: 16),

          // ── 2x2 Stat Grid ────────────────────────────────────────────────
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
              Expanded(
                child: _StreakStatTile(days: progress.streakDays),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatTile(
                  label: 'Weight',
                  value: '${progress.weightKg} kg',
                  icon: const Icon(Icons.monitor_weight_outlined,
                      color: AppColors.textSecondary, size: 22),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ── Recent Milestones ────────────────────────────────────────────
          Text('Recent Milestones',
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 16),
          ...progress.recentMilestones
              .map((m) => _MilestoneTile(milestone: m)),
          const SizedBox(height: 32),
        ],
      ),
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
                    Text('Aggregated 1RM performance across compound lifts',
                        style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 160,
            child: Stack(
              children: [
                LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: false),
                    titlesData: FlTitlesData(
                      leftTitles:
                          const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles:
                          const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles:
                          const AxisTitles(sideTitles: SideTitles(showTitles: false)),
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
                                      fontSize: 9,
                                      color: AppColors.textMuted,
                                      fontWeight: FontWeight.w600));
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
                        curveSmoothness: 0.35,
                        color: AppColors.primary,
                        barWidth: 2.5,
                        isStrokeCapRound: true,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              AppColors.primary.withValues(alpha: 0.15),
                              AppColors.primary.withValues(alpha: 0.0),
                            ],
                          ),
                        ),
                      ),
                    ],
                    lineTouchData: LineTouchData(
                      touchTooltipData: LineTouchTooltipData(
                        tooltipBgColor: AppColors.primary,
                        tooltipRoundedRadius: 8,
                      ),
                    ),
                  ),
                ),
                // Gain badge
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '+${gainPercent.toStringAsFixed(1)}% THIS MONTH',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
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
    // Mock weekly data — week 3 is the current/highlighted week
    const weeklyData = [2.8, 3.5, 4.2, 3.8, 4.0, 3.2, 4.5];
    const highlightIndex = 2;

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
                  final isHighlight = e.key == highlightIndex;
                  return BarChartGroupData(
                    x: e.key,
                    barRods: [
                      BarChartRodData(
                        toY: e.value,
                        color: isHighlight
                            ? AppColors.primary
                            : AppColors.surfaceVariant,
                        width: 28,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(8),
                        ),
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
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        color: AppColors.textPrimary,
                        height: 1,
                      ),
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

// ── Streak stat with left accent ──────────────────────────────────────────────
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
        border: const Border(
          left: BorderSide(color: AppColors.primary, width: 4),
        ),
        boxShadow: const [
          BoxShadow(
              color: Color(0x08000000), blurRadius: 12, offset: Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.local_fire_department,
              color: AppColors.primary, size: 22),
          const SizedBox(height: 8),
          Text('STREAK', style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(height: 4),
          Text('$days Days',
              style: Theme.of(context).textTheme.headlineMedium),
        ],
      ),
    );
  }
}

// ── Milestone Tile ────────────────────────────────────────────────────────────
class _MilestoneTile extends StatelessWidget {
  final Milestone milestone;
  const _MilestoneTile({required this.milestone});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          _MilestoneIcon(type: milestone.type),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(milestone.title,
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 2),
                Text(milestone.description,
                    style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            milestone.timeAgo.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontSize: 9,
                ),
          ),
        ],
      ),
    );
  }
}

class _MilestoneIcon extends StatelessWidget {
  final MilestoneType type;
  const _MilestoneIcon({required this.type});

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;

    switch (type) {
      case MilestoneType.pr:
        icon = Icons.trending_up;
        color = AppColors.teal;
        break;
      case MilestoneType.consistency:
        icon = Icons.workspace_premium_outlined;
        color = AppColors.primary;
        break;
      case MilestoneType.streak:
        icon = Icons.local_fire_department;
        color = AppColors.warning;
        break;
      case MilestoneType.calorie:
        icon = Icons.bolt;
        color = AppColors.success;
        break;
    }

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }
}
