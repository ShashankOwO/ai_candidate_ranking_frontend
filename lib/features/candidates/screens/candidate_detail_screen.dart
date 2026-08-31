import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../main.dart';
import '../data/models/candidate_experience_model.dart';
import '../data/models/candidate_model.dart';
import '../data/models/candidate_project_model.dart';
import '../data/models/candidate_qualification_model.dart';
import '../data/models/candidate_skill_model.dart';
import 'candidate_form_dialog.dart';

class CandidateDetailScreen extends StatefulWidget {
  final int candidateId;

  const CandidateDetailScreen({
    super.key,
    required this.candidateId,
  });

  @override
  State<CandidateDetailScreen> createState() =>
      _CandidateDetailScreenState();
}

class _CandidateDetailScreenState extends State<CandidateDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController tabController;

  CandidateModel? candidate;
  List<CandidateSkillModel> skills = [];
  List<CandidateExperienceModel> experience = [];
  List<CandidateQualificationModel> qualifications = [];
  List<CandidateProjectModel> projects = [];

  bool loading = true;

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

  String? error;

  Future<void> _load() async {
    setState(() {
      loading = true;
      error = null;
    });

    // Load candidate info first — if this fails, nothing else makes sense.
    try {
      final c = await candidateRepository.getCandidate(widget.candidateId);
      if (!mounted) return;
      setState(() => candidate = c);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        loading = false;
        error = 'Failed to load candidate: $e';
      });
      return;
    }

    // Load each section independently — one failure shouldn't block the rest.
    await Future.wait([
      _loadSafe(() async {
        final r = await candidateRepository.getCandidateSkills(widget.candidateId);
        if (mounted) setState(() => skills = r);
      }),
      _loadSafe(() async {
        final r = await candidateRepository.getCandidateExperience(widget.candidateId);
        if (mounted) setState(() => experience = r);
      }),
      _loadSafe(() async {
        final r = await candidateRepository.getCandidateQualifications(widget.candidateId);
        if (mounted) setState(() => qualifications = r);
      }),
      _loadSafe(() async {
        final r = await candidateRepository.getCandidateProjects(widget.candidateId);
        if (mounted) setState(() => projects = r);
      }),
    ]);

    if (!mounted) return;
    setState(() => loading = false);
  }

  /// Runs an async function and swallows errors so other sections still load.
  Future<void> _loadSafe(Future<void> Function() fn) async {
    try {
      await fn();
    } catch (e) {
      debugPrint('CandidateDetail: section load failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Candidate')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: 12),
              Text(error!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              FilledButton(onPressed: _load, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(candidate?.fullName ?? 'Candidate'),
        actions: [
          if (candidate != null)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Edit candidate',
              onPressed: () async {
                final result = await showDialog<CandidateModel>(
                  context: context,
                  builder: (_) => CandidateFormDialog(candidate: candidate),
                );
                if (result != null) _load();
              },
            ),
        ],
        bottom: TabBar(
          controller: tabController,
          tabs: const [
            Tab(text: 'Skills'),
            Tab(text: 'Experience'),
            Tab(text: 'Education'),
            Tab(text: 'Projects'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Candidate Info Header
          if (candidate != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: AppColors.surface,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor:
                        AppColors.primaryLight.withValues(alpha: 0.15),
                    child: Text(
                      (candidate!.fullName.isNotEmpty
                              ? candidate!.fullName[0]
                              : '?')
                          .toUpperCase(),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(candidate!.fullName,
                            style: AppTextStyles.title),
                        if (candidate!.emailAddress != null)
                          Text(candidate!.emailAddress!,
                              style: AppTextStyles.bodySecondary),
                        if (candidate!.contactNo != null)
                          Text(candidate!.contactNo!,
                              style: AppTextStyles.caption),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          const Divider(height: 1),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: tabController,
              children: [
                _buildSkillsTab(),
                _buildExperienceTab(),
                _buildQualificationsTab(),
                _buildProjectsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillsTab() {
    if (skills.isEmpty) return _emptyState('No skills extracted');

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: skills.length,
      itemBuilder: (context, index) {
        final skill = skills[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: const Icon(Icons.code, color: AppColors.primary),
            title: Text(skill.skillName, style: AppTextStyles.label),
            subtitle: Text(
              [
                if (skill.proficiency != null) skill.proficiency!,
                if (skill.yearsExperience != null)
                  '${skill.yearsExperience} years',
              ].join(' · '),
              style: AppTextStyles.caption,
            ),
          ),
        );
      },
    );
  }

  Widget _buildExperienceTab() {
    if (experience.isEmpty) return _emptyState('No experience extracted');

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: experience.length,
      itemBuilder: (context, index) {
        final exp = experience[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(exp.companyName, style: AppTextStyles.label),
                const SizedBox(height: 4),
                Text(exp.jobTitle, style: AppTextStyles.body),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.calendar_today,
                        size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      '${exp.startDate ?? '?'} – ${exp.endDate ?? 'Present'}',
                      style: AppTextStyles.caption,
                    ),
                    if (exp.years != null) ...[
                      const SizedBox(width: 12),
                      Text('${exp.years} years',
                          style: AppTextStyles.caption),
                    ],
                  ],
                ),
                if (exp.description != null) ...[
                  const SizedBox(height: 8),
                  Text(exp.description!, style: AppTextStyles.bodySecondary),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQualificationsTab() {
    if (qualifications.isEmpty) {
      return _emptyState('No qualifications extracted');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: qualifications.length,
      itemBuilder: (context, index) {
        final qual = qualifications[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (qual.university != null)
                  Text(qual.university!, style: AppTextStyles.label),
                const SizedBox(height: 4),
                Text(
                  [
                    qual.degree,
                    qual.specialization,
                  ].where((e) => e != null).join(' – '),
                  style: AppTextStyles.body,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (qual.percentage != null)
                      Text('${qual.percentage}%',
                          style: AppTextStyles.label
                              .copyWith(color: AppColors.primary)),
                    const Spacer(),
                    if (qual.passedOutYear != null)
                      Text('Class of ${qual.passedOutYear}',
                          style: AppTextStyles.caption),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProjectsTab() {
    if (projects.isEmpty) return _emptyState('No projects extracted');

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: projects.length,
      itemBuilder: (context, index) {
        final project = projects[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(project.projectName, style: AppTextStyles.label),
                if (project.description != null) ...[
                  const SizedBox(height: 8),
                  Text(project.description!,
                      style: AppTextStyles.bodySecondary),
                ],
                const SizedBox(height: 8),
                if (project.technologies != null)
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: project.technologies!
                        .split(',')
                        .map((tech) => Chip(
                              label: Text(tech.trim(),
                                  style: const TextStyle(fontSize: 12)),
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              visualDensity: VisualDensity.compact,
                            ))
                        .toList(),
                  ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (project.role != null)
                      Text('Role: ${project.role}',
                          style: AppTextStyles.caption),
                    const Spacer(),
                    if (project.duration != null)
                      Text(project.duration!,
                          style: AppTextStyles.caption),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _emptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.info_outline, size: 48, color: AppColors.textTertiary),
          const SizedBox(height: 12),
          Text(message, style: AppTextStyles.bodySecondary),
        ],
      ),
    );
  }
}
