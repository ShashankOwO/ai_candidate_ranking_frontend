import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../main.dart';
import '../../jobs/data/models/evaluation_criterion_model.dart';

class RankingConfigScreen extends StatefulWidget {
  final int jobId;
  final String jobTitle;
  final List<EvaluationCriterionModel> criteria;

  const RankingConfigScreen({
    super.key,
    required this.jobId,
    required this.jobTitle,
    required this.criteria,
  });

  @override
  State<RankingConfigScreen> createState() => _RankingConfigScreenState();
}

class _RankingConfigScreenState extends State<RankingConfigScreen> {
  bool running = false;

  double get totalWeight =>
      widget.criteria.fold<double>(0, (sum, c) => sum + c.weight);

  bool get isReady => widget.criteria.isNotEmpty && totalWeight == 100;

  Future<void> _runRanking() async {
    setState(() => running = true);

    try {
      await rankingRepository.runRanking(widget.jobId);

      if (!mounted) return;
      setState(() => running = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ranking completed successfully!'),
          backgroundColor: AppColors.success,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => running = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ranking failed: ${e.toString().replaceFirst('Exception: ', '')}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Run Ranking')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Job info
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ready to Rank',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.jobTitle,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Criteria Summary
          Text('Evaluation Criteria', style: AppTextStyles.sectionHeader),
          const SizedBox(height: 12),

          if (widget.criteria.isEmpty)
            Card(
              color: AppColors.warningLight,
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber, color: AppColors.warning),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'No evaluation criteria configured. Go back and add criteria before ranking.',
                      ),
                    ),
                  ],
                ),
              ),
            ),

          ...widget.criteria.map(
            (criterion) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(criterion.criteriaName,
                              style: AppTextStyles.label),
                          const SizedBox(height: 2),
                          Text(
                            criterion.criteriaType,
                            style: AppTextStyles.caption,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${criterion.weightDisplay}%',
                        style: AppTextStyles.label
                            .copyWith(color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Total weight
          Card(
            color: totalWeight == 100
                ? AppColors.successLight
                : AppColors.errorLight,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total Weight',
                      style: AppTextStyles.sectionHeader),
                  Text(
                    '$totalWeight%',
                    style: AppTextStyles.title.copyWith(
                      color: totalWeight == 100
                          ? AppColors.success
                          : AppColors.error,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Run Ranking Button
          SizedBox(
            height: 56,
            child: FilledButton.icon(
              onPressed: isReady && !running ? _runRanking : null,
              icon: running
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.auto_awesome, size: 24),
              label: Text(
                running ? 'Running AI Ranking...' : 'Run Ranking',
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),

          if (!isReady && widget.criteria.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'Total weight must equal 100% to run ranking.',
              style: AppTextStyles.caption.copyWith(color: AppColors.error),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
