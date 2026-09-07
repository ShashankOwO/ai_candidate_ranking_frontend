import 'dart:math';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/models/chart_data_model.dart';

class ResumeChartWidget extends StatelessWidget {
  final ChartDataModel chartData;

  const ResumeChartWidget({
    super.key,
    required this.chartData,
  });

  @override
  Widget build(BuildContext context) {
    final maxVal = max(
      chartData.items.map((e) => e.value).fold(0, max),
      1,
    );

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.bar_chart_rounded,
                  size: 20,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  chartData.title,
                  style: AppTextStyles.label.copyWith(fontSize: 15),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          // Summary Stats Pills
          if (chartData.summary != null) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                _buildStatPill(
                  icon: Icons.people_outline,
                  label: 'Candidates',
                  value: '${chartData.summary!.totalCandidates}',
                  color: AppColors.primary,
                ),
                _buildStatPill(
                  icon: Icons.description_outlined,
                  label: 'Total Resumes',
                  value: '${chartData.summary!.totalResumes}',
                  color: AppColors.success,
                ),
                if (chartData.summary!.mostActiveCandidate != null)
                  _buildStatPill(
                    icon: Icons.star_border,
                    label: 'Top',
                    value: chartData.summary!.mostActiveCandidate!,
                    color: AppColors.gold,
                  ),
              ],
            ),
          ],

          const Divider(height: 20, thickness: 1),

          // Bar items
          if (chartData.items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: Text(
                  'No candidates or resumes found.',
                  style: AppTextStyles.caption,
                ),
              ),
            )
          else
            ...chartData.items.map((item) {
              final ratio = item.value / maxVal;
              final isTop = chartData.summary?.mostActiveCandidate == item.label &&
                  item.value > 0;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Flexible(
                                child: Text(
                                  item.label,
                                  style: AppTextStyles.body.copyWith(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (isTop) ...[
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.workspace_premium,
                                  size: 16,
                                  color: AppColors.gold,
                                ),
                              ],
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: isTop
                                ? AppColors.gold.withValues(alpha: 0.15)
                                : AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${item.value} ${item.value == 1 ? "resume" : "resumes"}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isTop ? AppColors.gold : AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Progress Bar
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final barWidth = max(
                          constraints.maxWidth * ratio,
                          12.0,
                        );
                        return Stack(
                          children: [
                            Container(
                              height: 10,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: AppColors.border.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 600),
                              curve: Curves.easeOutCubic,
                              height: 10,
                              width: barWidth,
                              decoration: BoxDecoration(
                                gradient: isTop
                                    ? const LinearGradient(
                                        colors: [AppColors.gold, Color(0xFFF59E0B)],
                                      )
                                    : AppColors.primaryGradient,
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildStatPill({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
