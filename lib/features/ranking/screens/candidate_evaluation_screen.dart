import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../main.dart';
import '../data/models/candidate_evaluation_model.dart';

class CandidateEvaluationScreen extends StatefulWidget {
  final int runId;
  final int candidateId;
  final String candidateName;

  const CandidateEvaluationScreen({
    super.key,
    required this.runId,
    required this.candidateId,
    required this.candidateName,
  });

  @override
  State<CandidateEvaluationScreen> createState() =>
      _CandidateEvaluationScreenState();
}

class _CandidateEvaluationScreenState
    extends State<CandidateEvaluationScreen> {
  CandidateEvaluationModel? evaluation;
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final result = await rankingRepository.getCandidateEvaluation(
        widget.runId,
        widget.candidateId,
      );

      if (!mounted) return;
      setState(() {
        evaluation = result;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        error = e.toString();
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.candidateName),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 48, color: AppColors.error),
                      const SizedBox(height: 12),
                      Text(error!),
                      const SizedBox(height: 12),
                      FilledButton(
                          onPressed: _load, child: const Text('Retry')),
                    ],
                  ),
                )
              : _buildContent(),
    );
  }

  Widget _buildContent() {
    final eval = evaluation!;
    final ranking = eval.ranking;
    final criteria = eval.criteriaResults;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Score header
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              Text(
                'Rank #${ranking.rankPosition}',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                ranking.finalScore.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 56,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Text(
                '/ 100',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white60,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  ranking.recommendation ?? 'Review',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Criteria Scores
        Text('Score Breakdown', style: AppTextStyles.sectionHeader),
        const SizedBox(height: 12),

        ...criteria.map((c) => _buildCriterionCard(c)),

        const SizedBox(height: 24),

        // Final Calculation
        Text('Final Calculation', style: AppTextStyles.sectionHeader),
        const SizedBox(height: 12),

        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ...criteria.map((c) {
                  // Try to find matching criterion weight.
                  // We calculate weighted contribution as score * weight / 100.
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(c.criteriaName,
                              style: AppTextStyles.body),
                        ),
                        Text(
                          c.score.toStringAsFixed(0),
                          style: AppTextStyles.body,
                        ),
                      ],
                    ),
                  );
                }),
                const Divider(height: 24),
                Row(
                  children: [
                    Text('Final Score',
                        style: AppTextStyles.sectionHeader),
                    const Spacer(),
                    Text(
                      ranking.finalScore.toStringAsFixed(1),
                      style: AppTextStyles.title.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCriterionCard(CriteriaResult criterion) {
    final scoreColor = _scoreColor(criterion.score);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(criterion.criteriaName,
                      style: AppTextStyles.label),
                ),
                Text(
                  '${criterion.score.toStringAsFixed(0)} / 100',
                  style: AppTextStyles.title.copyWith(color: scoreColor),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Score bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: criterion.score / 100,
                minHeight: 8,
                backgroundColor: AppColors.surfaceVariant,
                valueColor: AlwaysStoppedAnimation(scoreColor),
              ),
            ),

            // Reason
            if (criterion.reason != null &&
                criterion.reason!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.lightbulb_outline,
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        criterion.reason!,
                        style: AppTextStyles.bodySecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _scoreColor(double score) {
    if (score >= 85) return AppColors.success;
    if (score >= 70) return AppColors.info;
    if (score >= 50) return AppColors.warning;
    return AppColors.error;
  }

}
