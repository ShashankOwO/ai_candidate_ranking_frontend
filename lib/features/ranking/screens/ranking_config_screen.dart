import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../main.dart';
import '../../candidates/data/models/candidate_model.dart';
import '../../jobs/data/models/evaluation_criterion_model.dart';
import 'evaluation_runs_screen.dart';

/// Two-step ranking flow:
///  Step 1 — Select which candidates to evaluate
///  Step 2 — Review criteria & run ranking
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
  // Step 0 = candidate selection, Step 1 = criteria review + run
  int _step = 0;

  List<CandidateModel> allCandidates = [];
  final Set<int> selectedIds = {};
  bool loadingCandidates = true;
  bool running = false;

  @override
  void initState() {
    super.initState();
    _loadCandidates();
  }

  Future<void> _loadCandidates() async {
    try {
      final list = await candidateRepository.getCandidates();
      if (!mounted) return;
      setState(() {
        allCandidates = list;
        // Pre-select all
        selectedIds.addAll(list.map((c) => c.candidateId));
        loadingCandidates = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => loadingCandidates = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load candidates: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  double get totalWeight =>
      widget.criteria.fold<double>(0, (sum, c) => sum + c.weight);

  bool get isReady =>
      widget.criteria.isNotEmpty &&
      totalWeight == 100 &&
      selectedIds.isNotEmpty;

  Future<void> _runRanking() async {
    setState(() => running = true);
    try {
      await rankingRepository.runRanking(widget.jobId);

      if (!mounted) return;
      setState(() => running = false);

      // Navigate directly to the results screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => EvaluationRunsScreen(
            jobId: widget.jobId,
            embedded: false,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => running = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Ranking failed: ${e.toString().replaceFirst("Exception: ", "")}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Run Ranking'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: (_step + 1) / 2,
            backgroundColor: AppColors.border,
            color: AppColors.primary,
          ),
        ),
      ),
      body: _step == 0 ? _buildStep1() : _buildStep2(),
    );
  }

  // ─────────────────────────────────────────────
  // STEP 1 — Candidate Selection
  // ─────────────────────────────────────────────
  Widget _buildStep1() {
    return Column(
      children: [
        // Header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Step 1 of 2',
                  style: AppTextStyles.caption
                      .copyWith(color: Colors.white70)),
              const SizedBox(height: 4),
              Text(
                'Select Candidates',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${selectedIds.length} of ${allCandidates.length} selected',
                style: AppTextStyles.caption.copyWith(color: Colors.white70),
              ),
            ],
          ),
        ),

        // Select/Deselect All
        if (!loadingCandidates && allCandidates.isNotEmpty)
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text('Choose who to evaluate',
                    style: AppTextStyles.label),
                const Spacer(),
                TextButton(
                  onPressed: () => setState(() {
                    if (selectedIds.length == allCandidates.length) {
                      selectedIds.clear();
                    } else {
                      selectedIds.addAll(
                          allCandidates.map((c) => c.candidateId));
                    }
                  }),
                  child: Text(
                    selectedIds.length == allCandidates.length
                        ? 'Deselect All'
                        : 'Select All',
                  ),
                ),
              ],
            ),
          ),

        // Candidates list
        Expanded(
          child: loadingCandidates
              ? const Center(child: CircularProgressIndicator())
              : allCandidates.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.people_outline,
                              size: 48, color: AppColors.textTertiary),
                          const SizedBox(height: 12),
                          Text('No candidates found',
                              style: AppTextStyles.bodySecondary),
                          const SizedBox(height: 8),
                          Text(
                            'Upload resumes first to create candidates',
                            style: AppTextStyles.caption,
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      itemCount: allCandidates.length,
                      itemBuilder: (context, index) {
                        final c = allCandidates[index];
                        final isSelected = selectedIds.contains(c.candidateId);
                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          child: CheckboxListTile(
                            value: isSelected,
                            activeColor: AppColors.primary,
                            onChanged: (_) => setState(() {
                              if (isSelected) {
                                selectedIds.remove(c.candidateId);
                              } else {
                                selectedIds.add(c.candidateId);
                              }
                            }),
                            secondary: CircleAvatar(
                              backgroundColor:
                                  AppColors.primaryLight.withValues(alpha: 0.15),
                              child: Text(
                                c.fullName.isNotEmpty
                                    ? c.fullName[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            title: Text(c.fullName,
                                style: AppTextStyles.label),
                            subtitle: c.emailAddress != null
                                ? Text(c.emailAddress!,
                                    style: AppTextStyles.caption)
                                : null,
                          ),
                        );
                      },
                    ),
        ),

        // Next button
        SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton.icon(
                onPressed: selectedIds.isEmpty
                    ? null
                    : () => setState(() => _step = 1),
                icon: const Icon(Icons.arrow_forward),
                label: Text(
                  selectedIds.isEmpty
                      ? 'Select at least 1 candidate'
                      : 'Next: Review Criteria (${selectedIds.length} selected)',
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // STEP 2 — Criteria Review + Run
  // ─────────────────────────────────────────────
  Widget _buildStep2() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Job info card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Step 2 of 2',
                  style: AppTextStyles.caption
                      .copyWith(color: Colors.white70)),
              const SizedBox(height: 4),
              Text(
                widget.jobTitle,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Evaluating ${selectedIds.length} candidate(s)',
                style: AppTextStyles.caption.copyWith(color: Colors.white70),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Selected candidates summary
        Text('Selected Candidates', style: AppTextStyles.sectionHeader),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: allCandidates
              .where((c) => selectedIds.contains(c.candidateId))
              .map((c) => Chip(
                    avatar: CircleAvatar(
                      backgroundColor: AppColors.primary,
                      child: Text(
                        c.fullName.isNotEmpty
                            ? c.fullName[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    label: Text(c.fullName),
                  ))
              .toList(),
        ),

        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: () => setState(() => _step = 0),
          icon: const Icon(Icons.edit, size: 16),
          label: const Text('Change selection'),
        ),

        const SizedBox(height: 16),

        // Criteria
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
                        'No evaluation criteria configured. Go back and add criteria.'),
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
                        Text(criterion.criteriaType,
                            style: AppTextStyles.caption),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
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

        // Total weight card
        Card(
          color: totalWeight == 100
              ? AppColors.successLight
              : AppColors.errorLight,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total Weight', style: AppTextStyles.sectionHeader),
                Text(
                  '$totalWeight%',
                  style: AppTextStyles.title.copyWith(
                    color:
                        totalWeight == 100 ? AppColors.success : AppColors.error,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 32),

        // Run Ranking button
        SizedBox(
          height: 56,
          child: FilledButton.icon(
            onPressed: isReady && !running ? _runRanking : null,
            icon: running
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.auto_awesome, size: 24),
            label: Text(
              running
                  ? 'Running AI Ranking…'
                  : 'Run Ranking for ${selectedIds.length} Candidates',
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ),

        if (!isReady && widget.criteria.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            totalWeight != 100
                ? 'Total weight must equal 100% to run ranking.'
                : 'Select at least 1 candidate.',
            style: AppTextStyles.caption.copyWith(color: AppColors.error),
            textAlign: TextAlign.center,
          ),
        ],

        const SizedBox(height: 24),
      ],
    );
  }
}
