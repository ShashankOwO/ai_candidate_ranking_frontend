import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../main.dart';
import '../data/models/evaluation_run_model.dart';
import '../../jobs/data/models/ranking_result_model.dart';
import 'candidate_evaluation_screen.dart';

class EvaluationRunsScreen extends StatefulWidget {
  final int jobId;
  final bool embedded;

  const EvaluationRunsScreen({
    super.key,
    required this.jobId,
    this.embedded = false,
  });

  @override
  State<EvaluationRunsScreen> createState() =>
      _EvaluationRunsScreenState();
}

class _EvaluationRunsScreenState extends State<EvaluationRunsScreen> {
  List<EvaluationRunModel> runs = [];
  bool loading = true;

  // For viewing ranked candidates of a selected run.
  int? selectedRunId;
  List<RankingResultModel> rankings = [];
  bool loadingRankings = false;

  @override
  void initState() {
    super.initState();
    _loadRuns();
  }

  Future<void> _loadRuns() async {
    setState(() => loading = true);

    try {
      final result =
          await rankingRepository.getEvaluationRuns(widget.jobId);
      if (!mounted) return;
      setState(() {
        runs = result;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => loading = false);
    }
  }

  Future<void> _loadRankings(int runId) async {
    setState(() {
      selectedRunId = runId;
      loadingRankings = true;
    });

    try {
      final result = await rankingRepository.getRankedCandidates(runId);
      if (!mounted) return;
      setState(() {
        rankings = result;
        loadingRankings = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => loadingRankings = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = _buildContent();

    if (widget.embedded) return content;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Evaluation History'),
      ),
      body: content,
    );
  }

  Widget _buildContent() {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (runs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 56, color: AppColors.textTertiary),
            const SizedBox(height: 12),
            const Text('No evaluation runs yet',
                style: AppTextStyles.sectionHeader),
            const SizedBox(height: 8),
            const Text(
              'Run ranking to create evaluation runs.',
              style: AppTextStyles.bodySecondary,
            ),
          ],
        ),
      );
    }

    // If a run is selected, show rankings.
    if (selectedRunId != null) {
      return _buildRankings();
    }

    // Show runs list.
    return RefreshIndicator(
      onRefresh: _loadRuns,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: runs.length,
        itemBuilder: (context, index) {
          final run = runs[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => _loadRankings(run.evaluationRunId),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight
                            .withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.assessment,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            run.runName ?? 'Run #${run.evaluationRunId}',
                            style: AppTextStyles.label,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            [
                              if (run.totalCandidates != null)
                                '${run.totalCandidates} candidates',
                              if (run.createdAt != null) run.createdAt!,
                            ].join(' · '),
                            style: AppTextStyles.caption,
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right,
                        color: AppColors.textTertiary),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRankings() {
    return Column(
      children: [
        // Back button
        Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    selectedRunId = null;
                    rankings.clear();
                  });
                },
                icon: const Icon(Icons.arrow_back, size: 18),
                label: const Text('Back to Runs'),
              ),
              const Spacer(),
              Text('${rankings.length} candidates',
                  style: AppTextStyles.caption),
            ],
          ),
        ),

        if (loadingRankings)
          const Expanded(
            child: Center(child: CircularProgressIndicator()),
          )
        else if (rankings.isEmpty)
          const Expanded(
            child: Center(
              child: Text('No ranked candidates in this run.',
                  style: AppTextStyles.bodySecondary),
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: rankings.length,
              itemBuilder: (context, index) {
                final item = rankings[index];
                return _buildRankingCard(item);
              },
            ),
          ),
      ],
    );
  }

  Widget _buildRankingCard(RankingResultModel item) {
    final recColor = _recommendationColor(item.recommendationLabel);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CandidateEvaluationScreen(
                runId: selectedRunId!,
                candidateId: item.candidateId,
                candidateName: item.candidateName,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Rank badge
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _rankColor(item.rankPosition)
                      .withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${item.rankPosition}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _rankColor(item.rankPosition),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Name & recommendation
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.candidateName,
                        style: AppTextStyles.label),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: recColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        item.recommendationLabel,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: recColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Score
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    item.finalScore.toStringAsFixed(1),
                    style: AppTextStyles.title.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  const Text('Score', style: AppTextStyles.caption),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _rankColor(int rank) {
    if (rank == 1) return AppColors.gold;
    if (rank == 2) return AppColors.silver;
    if (rank == 3) return AppColors.bronze;
    return AppColors.textSecondary;
  }

  Color _recommendationColor(String rec) {
    switch (rec.toLowerCase()) {
      case 'strong match':
        return AppColors.success;
      case 'good match':
        return AppColors.info;
      case 'average match':
        return AppColors.warning;
      default:
        return AppColors.error;
    }
  }
}
