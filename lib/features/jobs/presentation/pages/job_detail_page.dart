import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/job_repository.dart';
import '../../data/models/evaluation_criterion_model.dart';
import '../../data/models/job_model.dart';
import '../../data/models/job_skill_model.dart';
import '../../../ranking/screens/evaluation_runs_screen.dart';
import '../../../ranking/screens/ranking_config_screen.dart';
import '../../../resumes/screens/upload_resumes_screen.dart';
import '../../../candidates/screens/candidates_screen.dart';
import '../widgets/add_skill_dialog.dart';
import '../widgets/evaluation_criterion_dialog.dart';
import '../widgets/job_form_page.dart';

class JobDetailPage extends StatefulWidget {
  final int jobId;
  final JobRepository repository;

  const JobDetailPage({
    super.key,
    required this.jobId,
    required this.repository,
  });

  @override
  State<JobDetailPage> createState() => _JobDetailPageState();
}

class _JobDetailPageState extends State<JobDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController tabController;

  JobModel? job;
  List<JobSkillModel> skills = [];
  List<EvaluationCriterionModel> criteria = [];

  bool loading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 4, vsync: this);
    _load();
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      loading = true;
      errorMessage = null;
    });

    try {
      final results = await Future.wait([
        widget.repository.getJob(widget.jobId),
        widget.repository.getJobSkills(widget.jobId),
        widget.repository.getCriteria(widget.jobId),
      ]);

      if (!mounted) return;

      setState(() {
        job = results[0] as JobModel;
        skills = results[1] as List<JobSkillModel>;
        criteria = results[2] as List<EvaluationCriterionModel>;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
        errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Job Details')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 56, color: AppColors.error),
                const SizedBox(height: 16),
                const Text('Unable to load job', style: AppTextStyles.sectionHeader),
                const SizedBox(height: 8),
                Text(errorMessage!, textAlign: TextAlign.center),
                const SizedBox(height: 20),
                FilledButton(onPressed: _load, child: const Text('Retry')),
              ],
            ),
          ),
        ),
      );
    }

    if (job == null) {
      return const Scaffold(body: Center(child: Text('Job not found')));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(job!.jobTitle),
        actions: [
          IconButton(
            onPressed: _openRankingConfig,
            tooltip: 'Run Ranking',
            icon: const Icon(Icons.auto_awesome),
          ),
          IconButton(
            onPressed: _editJob,
            tooltip: 'Edit Job',
            icon: const Icon(Icons.edit),
          ),
        ],
        bottom: TabBar(
          controller: tabController,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Skills'),
            Tab(text: 'Criteria'),
            Tab(text: 'History'),
          ],
        ),
      ),
      body: TabBarView(
        controller: tabController,
        children: [
          _buildOverview(),
          _buildSkills(),
          _buildCriteria(),
          _buildHistory(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openRankingConfig,
        icon: const Icon(Icons.auto_awesome),
        label: const Text('Run Ranking'),
      ),
    );
  }

  Future<void> _editJob() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => JobFormPage(repository: widget.repository, job: job),
      ),
    );
    if (result == true) await _load();
  }

  void _openRankingConfig() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RankingConfigScreen(
          jobId: widget.jobId,
          jobTitle: job!.jobTitle,
          criteria: criteria,
        ),
      ),
    );
  }

  Widget _buildOverview() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Job Info Card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(job!.jobTitle, style: AppTextStyles.title),
                const SizedBox(height: 16),
                Text(job!.jobDescription, style: AppTextStyles.body),
                if (job!.minimumExperience != null) ...[
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.timeline, size: 20, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        '${job!.minimumExperience}+ years experience required',
                        style: AppTextStyles.label,
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Quick Actions
        Text('Quick Actions', style: AppTextStyles.sectionHeader),
        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: _ActionCard(
                icon: Icons.upload_file,
                label: 'Upload Resumes',
                color: AppColors.info,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const UploadResumesScreen()),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ActionCard(
                icon: Icons.people,
                label: 'Candidates',
                color: AppColors.success,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CandidatesScreen()),
                  );
                },
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Summary
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _SummaryRow(
                  label: 'Skills configured',
                  value: '${skills.length}',
                  icon: Icons.code,
                ),
                const Divider(),
                _SummaryRow(
                  label: 'Evaluation criteria',
                  value: '${criteria.length}',
                  icon: Icons.assessment,
                ),
                const Divider(),
                _SummaryRow(
                  label: 'Total weight',
                  value: '${criteria.fold<double>(0, (sum, c) => sum + c.weight).toStringAsFixed(0)}%',
                  icon: Icons.pie_chart_outline,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSkills() {
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Text('Job Skills', style: AppTextStyles.sectionHeader),
              const Spacer(),
              FilledButton.icon(
                onPressed: _addSkill,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Skill'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (skills.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(Icons.code_off, size: 48, color: AppColors.textTertiary),
                    const SizedBox(height: 12),
                    const Text('No skills added', style: AppTextStyles.sectionHeader),
                    const SizedBox(height: 8),
                    const Text(
                      'Add required or preferred skills for this job.',
                      style: AppTextStyles.bodySecondary,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

          // Required Skills
          if (skills.where((s) => s.isRequired).isNotEmpty) ...[
            Text('Required', style: AppTextStyles.label.copyWith(color: AppColors.error)),
            const SizedBox(height: 8),
            ...skills.where((s) => s.isRequired).map(_buildSkillCard),
            const SizedBox(height: 16),
          ],

          // Preferred Skills
          if (skills.where((s) => !s.isRequired).isNotEmpty) ...[
            Text('Preferred', style: AppTextStyles.label.copyWith(color: AppColors.info)),
            const SizedBox(height: 8),
            ...skills.where((s) => !s.isRequired).map(_buildSkillCard),
          ],
        ],
      ),
    );
  }

  Widget _buildSkillCard(JobSkillModel skill) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          Icons.check_circle,
          color: skill.isRequired ? AppColors.error : AppColors.info,
        ),
        title: Text(skill.skillName),
        subtitle: Text(skill.isRequired ? 'Required' : 'Preferred'),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: AppColors.error),
          onPressed: () => _deleteSkill(skill),
        ),
      ),
    );
  }

  Widget _buildCriteria() {
    final totalWeight = criteria.fold<double>(0, (sum, c) => sum + c.weight);

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Text('Evaluation Criteria', style: AppTextStyles.sectionHeader),
              const Spacer(),
              FilledButton.icon(
                onPressed: _addCriterion,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add'),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Weight indicator
          Card(
            color: totalWeight == 100
                ? AppColors.successLight
                : AppColors.warningLight,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Icon(
                    totalWeight == 100
                        ? Icons.check_circle
                        : Icons.warning_amber,
                    color: totalWeight == 100
                        ? AppColors.success
                        : AppColors.warning,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Total Weight: $totalWeight% ${totalWeight == 100 ? '✓' : '(must be 100%)'}',
                    style: AppTextStyles.label.copyWith(
                      color: totalWeight == 100
                          ? AppColors.success
                          : AppColors.warning,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          if (criteria.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(Icons.assessment_outlined, size: 48,
                        color: AppColors.textTertiary),
                    const SizedBox(height: 12),
                    const Text('No criteria added', style: AppTextStyles.sectionHeader),
                    const SizedBox(height: 8),
                    const Text(
                      'Add evaluation criteria to define how candidates are ranked.',
                      style: AppTextStyles.bodySecondary,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

          ...criteria.map(
            (criterion) => Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(criterion.criteriaName, style: AppTextStyles.label),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${criterion.weightDisplay}%',
                            style: AppTextStyles.label.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'edit') _editCriterion(criterion);
                            if (value == 'delete') _deleteCriterion(criterion);
                          },
                          itemBuilder: (_) => [
                            const PopupMenuItem(value: 'edit', child: Text('Edit')),
                            const PopupMenuItem(value: 'delete', child: Text('Delete')),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Type: ${criterion.criteriaType}',
                      style: AppTextStyles.caption,
                    ),
                    if (criterion.criteriaDescription != null &&
                        criterion.criteriaDescription!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        criterion.criteriaDescription!,
                        style: AppTextStyles.bodySecondary,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistory() {
    return EvaluationRunsScreen(
      jobId: widget.jobId,
      embedded: true,
    );
  }

  // ── Actions ──

  Future<void> _addSkill() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AddSkillDialog(
        jobId: widget.jobId,
        repository: widget.repository,
      ),
    );
    if (result == true) await _load();
  }

  Future<void> _deleteSkill(JobSkillModel skill) async {
    try {
      await widget.repository.deleteJobSkill(widget.jobId, skill.skillId);
      await _load();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Skill removed')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: $e')),
      );
    }
  }

  Future<void> _addCriterion() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => EvaluationCriterionDialog(
        jobId: widget.jobId,
        repository: widget.repository,
      ),
    );
    if (result == true) await _load();
  }

  Future<void> _editCriterion(EvaluationCriterionModel criterion) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => EvaluationCriterionDialog(
        jobId: widget.jobId,
        repository: widget.repository,
        criterion: criterion,
      ),
    );
    if (result == true) await _load();
  }

  Future<void> _deleteCriterion(EvaluationCriterionModel criterion) async {
    try {
      await widget.repository.deleteCriterion(
        widget.jobId,
        criterion.criteriaId,
      );
      await _load();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Criterion deleted')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: $e')),
      );
    }
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8),
              Text(label, style: AppTextStyles.label, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _SummaryRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: AppTextStyles.body)),
          Text(value, style: AppTextStyles.label),
        ],
      ),
    );
  }
}
