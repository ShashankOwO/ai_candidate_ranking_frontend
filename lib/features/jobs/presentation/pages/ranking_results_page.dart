import 'package:flutter/material.dart';

import '../../data/job_repository.dart';
import '../../data/models/ranking_result_model.dart';

class RankingResultsPage extends StatefulWidget {
  final int jobId;
  final JobRepository repository;
  final bool embedded;

  const RankingResultsPage({
    super.key,
    required this.jobId,
    required this.repository,
    this.embedded = false,
  });

  @override
  State<RankingResultsPage> createState() =>
      _RankingResultsPageState();
}

class _RankingResultsPageState
    extends State<RankingResultsPage> {
  bool loading = true;
  String? error;
  List<RankingResultModel> rankings = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (mounted) {
      setState(() {
        loading = true;
        error = null;
      });
    }

    try {
      final result = await widget.repository.getRankings(
        widget.jobId,
      );

      if (!mounted) return;

      setState(() {
        rankings = result;
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
    if (widget.embedded) {
      return _buildContent();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ranking Results'),
      ),
      body: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
              ),
              const SizedBox(height: 12),
              const Text(
                'Unable to load rankings',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error!,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _load,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (rankings.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.leaderboard_outlined,
                size: 56,
              ),
              SizedBox(height: 12),
              Text(
                'No ranking results available.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Run ranking after adding candidates and criteria.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: rankings.length,
        itemBuilder: (context, index) {
          final item = rankings[index];

          return _buildRankingCard(
            context,
            item,
          );
        },
      ),
    );
  }

  Widget _buildRankingCard(
    BuildContext context,
    RankingResultModel item,
  ) {
    final status = item.status ?? 'Review';
    final statusColor = _getStatusColor(status);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  child: Text(
                    '#${item.rank}',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.candidateName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      _StatusBadge(
                        text: status,
                        color: statusColor,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${item.score.toStringAsFixed(1)}%',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const Text(
                      'Score',
                    ),
                  ],
                ),
              ],
            ),
            if (item.skillMatchSummary != null &&
                item.skillMatchSummary!.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Skill Match',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item.skillMatchSummary!,
              ),
            ],
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  _openCandidate(
                    context,
                    item.candidateId,
                  );
                },
                icon: const Icon(
                  Icons.person_outline,
                ),
                label: const Text(
                  'View Candidate',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'shortlisted':
      case 'selected':
      case 'success':
        return Colors.green;

      case 'rejected':
        return Colors.red;

      case 'pending':
      case 'review':
        return Colors.amber.shade800;

      default:
        return Theme.of(context).colorScheme.primary;
    }
  }

  void _openCandidate(
    BuildContext context,
    int candidateId,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Candidate ID: $candidateId',
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String text;
  final Color color;

  const _StatusBadge({
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}