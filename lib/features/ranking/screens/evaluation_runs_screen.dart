import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../main.dart';
import '../../candidates/data/models/candidate_model.dart';
import '../../candidates/screens/candidate_detail_screen.dart';
import '../../jobs/data/models/ranking_result_model.dart';
import '../data/models/evaluation_run_model.dart';
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

  int? selectedRunId;
  List<RankingResultModel> rankings = [];
  Map<int, String> candidateNames = {}; // candidateId → name
  bool loadingRankings = false;

  @override
  void initState() {
    super.initState();
    _loadRuns();
  }

  Future<void> _loadRuns() async {
    setState(() => loading = true);
    try {
      final result = await rankingRepository.getEvaluationRuns(widget.jobId);
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
      rankings = [];
      candidateNames = {};
    });

    try {
      // Load rankings and all candidates in parallel.
      final results = await Future.wait([
        rankingRepository.getRankedCandidates(runId),
        candidateRepository.getCandidates(),
      ]);

      if (!mounted) return;

      final rankList = results[0] as List<RankingResultModel>;
      final candidateList = results[1] as List<CandidateModel>;

      // Build a lookup map: candidateId → fullName
      final nameMap = {for (var c in candidateList) c.candidateId: c.fullName};

      setState(() {
        rankings = rankList;
        candidateNames = nameMap;
        loadingRankings = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => loadingRankings = false);
    }
  }

  String _candidateName(int id) =>
      candidateNames[id] ?? 'Candidate #$id';

  @override
  Widget build(BuildContext context) {
    final content = _buildContent();
    if (widget.embedded) return content;

    return Scaffold(
      appBar: AppBar(title: const Text('Evaluation History')),
      body: content,
    );
  }

  Widget _buildContent() {
    if (loading) return const Center(child: CircularProgressIndicator());

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

    if (selectedRunId != null) return _buildRankings();

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
                        color: AppColors.primaryLight.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.assessment,
                          color: AppColors.primary),
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
        // Header bar
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
          child: Row(
            children: [
              TextButton.icon(
                onPressed: () => setState(() {
                  selectedRunId = null;
                  rankings.clear();
                  candidateNames.clear();
                }),
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
              child: Text(
                'No ranked candidates in this run.',
                style: AppTextStyles.bodySecondary,
              ),
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: rankings.length,
              itemBuilder: (context, index) {
                final item = rankings[index];
                return _RankingCard(
                  item: item,
                  name: _candidateName(item.candidateId),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CandidateEvaluationScreen(
                        runId: selectedRunId!,
                        candidateId: item.candidateId,
                        candidateName: _candidateName(item.candidateId),
                      ),
                    ),
                  ),
                  onViewProfile: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CandidateDetailScreen(
                        candidateId: item.candidateId,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

// ─── Ranking Card ─────────────────────────────────────────────────────────────

class _RankingCard extends StatelessWidget {
  final RankingResultModel item;
  final String name;
  final VoidCallback onTap;
  final VoidCallback onViewProfile;

  const _RankingCard({
    required this.item,
    required this.name,
    required this.onTap,
    required this.onViewProfile,
  });

  @override
  Widget build(BuildContext context) {
    final recColor = _recommendationColor(item.recommendationLabel);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Rank badge
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: _rankColor(item.rankPosition)
                          .withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '#${item.rankPosition}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
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
                        Text(name, style: AppTextStyles.label),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
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
                        style: AppTextStyles.title
                            .copyWith(color: AppColors.primary),
                      ),
                      const Text('/ 100', style: AppTextStyles.caption),
                    ],
                  ),
                ],
              ),

              // View profile link
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: onViewProfile,
                    icon: const Icon(Icons.person_outline, size: 14),
                    label: const Text('View Profile'),
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: onTap,
                    icon: const Icon(Icons.analytics_outlined, size: 14),
                    label: const Text('Score Details'),
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                    ),
                  ),
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
      case 'potential match':
        return AppColors.warning;
      default:
        return AppColors.error;
    }
  }
}
