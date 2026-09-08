import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../main.dart';
import '../data/models/candidate_experience_model.dart';
import '../data/models/candidate_model.dart';
import '../data/models/candidate_project_model.dart';
import '../data/models/candidate_qualification_model.dart';
import '../data/models/candidate_skill_model.dart';
import 'add_candidate_skill_dialog.dart';
import 'add_experience_dialog.dart';
import 'add_project_dialog.dart';
import 'add_qualification_dialog.dart';
import 'candidate_form_dialog.dart';
import 'edit_experience_dialog.dart';
import 'edit_project_dialog.dart';
import 'edit_qualification_dialog.dart';
import 'edit_skill_dialog.dart';

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
  String? error;

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
      error = null;
    });

    // Load candidate info first
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

    // Load each section independently
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

  Future<void> _loadSafe(Future<void> Function() fn) async {
    try {
      await fn();
    } catch (e) {
      debugPrint('CandidateDetail: section load failed: $e');
    }
  }

  static const _tabLabels = ['Skill', 'Experience', 'Education', 'Project'];

  Future<void> _showAddDialog() async {
    final tab = tabController.index;
    bool? result;

    switch (tab) {
      case 0:
        result = await showDialog<bool>(
          context: context,
          builder: (_) => AddCandidateSkillDialog(candidateId: widget.candidateId),
        );
        if (result == true && mounted) {
          final r = await candidateRepository.getCandidateSkills(widget.candidateId);
          setState(() => skills = r);
        }
        break;
      case 1:
        result = await showDialog<bool>(
          context: context,
          builder: (_) => AddExperienceDialog(candidateId: widget.candidateId),
        );
        if (result == true && mounted) {
          final r = await candidateRepository.getCandidateExperience(widget.candidateId);
          setState(() => experience = r);
        }
        break;
      case 2:
        result = await showDialog<bool>(
          context: context,
          builder: (_) => AddQualificationDialog(candidateId: widget.candidateId),
        );
        if (result == true && mounted) {
          final r = await candidateRepository.getCandidateQualifications(widget.candidateId);
          setState(() => qualifications = r);
        }
        break;
      case 3:
        result = await showDialog<bool>(
          context: context,
          builder: (_) => AddProjectDialog(candidateId: widget.candidateId),
        );
        if (result == true && mounted) {
          final r = await candidateRepository.getCandidateProjects(widget.candidateId);
          setState(() => projects = r);
        }
        break;
    }
  }

  // ── Delete Helpers ──

  Future<void> _deleteSkill(CandidateSkillModel skill) async {
    final confirmed = await _showDeleteConfirm('Remove skill "${skill.skillName}"?');
    if (confirmed != true) return;
    try {
      await candidateRepository.deleteSkill(widget.candidateId, skill.skillId);
      final r = await candidateRepository.getCandidateSkills(widget.candidateId);
      if (mounted) setState(() => skills = r);
      _showSuccess('Skill removed');
    } catch (e) {
      _showError('Failed to remove skill: $e');
    }
  }

  Future<void> _deleteExperience(CandidateExperienceModel exp) async {
    if (exp.experienceId == null) return;
    final confirmed = await _showDeleteConfirm('Delete experience at "${exp.companyName}"?');
    if (confirmed != true) return;
    try {
      await candidateRepository.deleteExperience(widget.candidateId, exp.experienceId!);
      final r = await candidateRepository.getCandidateExperience(widget.candidateId);
      if (mounted) setState(() => experience = r);
      _showSuccess('Experience deleted');
    } catch (e) {
      _showError('Failed to delete experience: $e');
    }
  }

  Future<void> _deleteQualification(CandidateQualificationModel qual) async {
    if (qual.qualificationId == null) return;
    final title = qual.degree ?? qual.university ?? 'Education entry';
    final confirmed = await _showDeleteConfirm('Delete qualification "$title"?');
    if (confirmed != true) return;
    try {
      await candidateRepository.deleteQualification(widget.candidateId, qual.qualificationId!);
      final r = await candidateRepository.getCandidateQualifications(widget.candidateId);
      if (mounted) setState(() => qualifications = r);
      _showSuccess('Qualification deleted');
    } catch (e) {
      _showError('Failed to delete qualification: $e');
    }
  }

  Future<void> _deleteProject(CandidateProjectModel project) async {
    if (project.projectId == null) return;
    final confirmed = await _showDeleteConfirm('Delete project "${project.projectName}"?');
    if (confirmed != true) return;
    try {
      await candidateRepository.deleteProject(widget.candidateId, project.projectId!);
      final r = await candidateRepository.getCandidateProjects(widget.candidateId);
      if (mounted) setState(() => projects = r);
      _showSuccess('Project deleted');
    } catch (e) {
      _showError('Failed to delete project: $e');
    }
  }

  Future<bool?> _showDeleteConfirm(String message) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.success),
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message.replaceFirst('Exception: ', '')),
        backgroundColor: AppColors.error,
      ),
    );
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
      floatingActionButton: candidate == null
          ? null
          : AnimatedBuilder(
              animation: tabController,
              builder: (context, _) {
                final label = _tabLabels[tabController.index];
                return FloatingActionButton.extended(
                  onPressed: _showAddDialog,
                  icon: const Icon(Icons.add),
                  label: Text('Add $label'),
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                );
              },
            ),
    );
  }

  // ── Skills Tab (Pill Design) ───────────────────────────────
  Widget _buildSkillsTab() {
    if (skills.isEmpty) return _emptyState('No skills extracted');
    return SingleChildScrollView(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header summary pill & count
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.bolt_rounded, size: 16, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Text(
                      '${skills.length} ${skills.length == 1 ? 'Skill' : 'Skills'}',
                      style: AppTextStyles.caption.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                'Tap pill to edit',
                style: AppTextStyles.caption.copyWith(
                  fontStyle: FontStyle.italic,
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Flowing pill tags
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: skills.map(_buildCandidateSkillPill).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCandidateSkillPill(CandidateSkillModel skill) {
    final hasGap = skill.proficiency == null || skill.yearsExperience == null;
    final List<String> details = [];
    if (skill.proficiency != null) details.add(skill.proficiency!);
    if (skill.yearsExperience != null) details.add('${skill.yearsExperience} yrs');

    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () => _editSkill(skill),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: hasGap
              ? AppColors.warning.withValues(alpha: 0.08)
              : AppColors.primary.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: hasGap
                ? AppColors.warning.withValues(alpha: 0.35)
                : AppColors.primary.withValues(alpha: 0.28),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Pill icon
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: hasGap
                    ? AppColors.warning.withValues(alpha: 0.2)
                    : AppColors.primary.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.code_rounded,
                size: 14,
                color: hasGap ? AppColors.warning : AppColors.primary,
              ),
            ),
            const SizedBox(width: 8),

            // Skill Name
            Text(
              skill.skillName,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),

            // Inner sub-pill with details (e.g. Intermediate • 2 yrs)
            if (details.isNotEmpty) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: Text(
                  details.join(' • '),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],

            // Gap warning icon
            if (hasGap) ...[
              const SizedBox(width: 6),
              Tooltip(
                message: 'Incomplete — tap to fill in missing info',
                child: const Icon(
                  Icons.warning_amber_rounded,
                  size: 16,
                  color: AppColors.warning,
                ),
              ),
            ],

            const SizedBox(width: 6),

            // Edit Action
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => _editSkill(skill),
              child: const Padding(
                padding: EdgeInsets.all(2),
                child: Icon(
                  Icons.edit_outlined,
                  size: 15,
                  color: AppColors.textSecondary,
                ),
              ),
            ),

            const SizedBox(width: 4),

            // Delete Action
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => _deleteSkill(skill),
              child: const Padding(
                padding: EdgeInsets.all(2),
                child: Icon(
                  Icons.close_rounded,
                  size: 16,
                  color: AppColors.error,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _editSkill(CandidateSkillModel skill) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => EditSkillDialog(
        candidateId: widget.candidateId,
        existing: skill,
      ),
    );
    if (result == true && mounted) {
      final r = await candidateRepository.getCandidateSkills(widget.candidateId);
      setState(() => skills = r);
    }
  }

  // ── Experience Tab ─────────────────────────────────────────
  Widget _buildExperienceTab() {
    if (experience.isEmpty) return _emptyState('No experience extracted');
    return ListView.builder(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 80),
      itemCount: experience.length,
      itemBuilder: (context, index) {
        final exp = experience[index];
        final hasMissing = exp.years == null || exp.description == null;
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(child: Text(exp.companyName, style: AppTextStyles.label)),
                          if (hasMissing)
                            Icon(Icons.warning_amber_rounded,
                                size: 16, color: AppColors.warning),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(exp.jobTitle, style: AppTextStyles.body),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.calendar_today,
                              size: 13, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            '${exp.startDate ?? '?'} – ${exp.endDate ?? 'Present'}',
                            style: AppTextStyles.caption,
                          ),
                          if (exp.years != null) ...[
                            const SizedBox(width: 10),
                            Text('${exp.years} yrs',
                                style: AppTextStyles.caption),
                          ] else ...[
                            const SizedBox(width: 10),
                            Text('Years: ?',
                                style: AppTextStyles.caption
                                     .copyWith(color: AppColors.warning)),
                          ],
                        ],
                      ),
                      if (exp.description != null) ...[
                        const SizedBox(height: 6),
                        Text(exp.description!,
                            style: AppTextStyles.bodySecondary,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis),
                      ] else ...[
                        const SizedBox(height: 4),
                        Text('Description missing',
                            style: AppTextStyles.caption
                                .copyWith(color: AppColors.warning)),
                      ],
                    ],
                  ),
                ),
                // Actions
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      color: AppColors.textSecondary,
                      tooltip: 'Edit / add missing info',
                      onPressed: () async {
                        final result = await showDialog<bool>(
                          context: context,
                          builder: (_) => EditExperienceDialog(
                            candidateId: widget.candidateId,
                            existing: exp,
                          ),
                        );
                        if (result == true && mounted) {
                          final r = await candidateRepository
                              .getCandidateExperience(widget.candidateId);
                          setState(() => experience = r);
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 18),
                      color: AppColors.error,
                      tooltip: 'Delete experience',
                      onPressed: () => _deleteExperience(exp),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Education Tab ──────────────────────────────────────────
  Widget _buildQualificationsTab() {
    if (qualifications.isEmpty) return _emptyState('No qualifications extracted');
    return ListView.builder(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 80),
      itemCount: qualifications.length,
      itemBuilder: (context, index) {
        final qual = qualifications[index];
        final hasMissing = qual.percentage == null || qual.passedOutYear == null;
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (qual.university != null)
                            Expanded(
                              child: Text(qual.university!,
                                  style: AppTextStyles.label),
                            ),
                          if (hasMissing)
                            Icon(Icons.warning_amber_rounded,
                                size: 16, color: AppColors.warning),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        [
                          qual.degree,
                          qual.specialization,
                        ].whereType<String>().join(' – '),
                        style: AppTextStyles.body,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          if (qual.percentage != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text('${qual.percentage}%',
                                  style: AppTextStyles.caption
                                      .copyWith(color: AppColors.primary,
                                          fontWeight: FontWeight.w600)),
                            )
                          else
                            Text('Percentage: ?',
                                style: AppTextStyles.caption
                                    .copyWith(color: AppColors.warning)),
                          const Spacer(),
                          if (qual.passedOutYear != null)
                            Text('Class of ${qual.passedOutYear}',
                                style: AppTextStyles.caption)
                          else
                            Text('Year: ?',
                                style: AppTextStyles.caption
                                    .copyWith(color: AppColors.warning)),
                        ],
                      ),
                    ],
                  ),
                ),
                // Actions
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      color: AppColors.textSecondary,
                      tooltip: 'Edit / add missing info',
                      onPressed: () async {
                        final result = await showDialog<bool>(
                          context: context,
                          builder: (_) => EditQualificationDialog(
                            candidateId: widget.candidateId,
                            existing: qual,
                          ),
                        );
                        if (result == true && mounted) {
                          final r = await candidateRepository
                              .getCandidateQualifications(widget.candidateId);
                          setState(() => qualifications = r);
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 18),
                      color: AppColors.error,
                      tooltip: 'Delete qualification',
                      onPressed: () => _deleteQualification(qual),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Projects Tab ───────────────────────────────────────────
  Widget _buildProjectsTab() {
    if (projects.isEmpty) return _emptyState('No projects extracted');
    return ListView.builder(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 80),
      itemCount: projects.length,
      itemBuilder: (context, index) {
        final project = projects[index];
        final hasMissing = project.role == null || project.duration == null;
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(project.projectName,
                                style: AppTextStyles.label),
                          ),
                          if (hasMissing)
                            Icon(Icons.warning_amber_rounded,
                                size: 16, color: AppColors.warning),
                        ],
                      ),
                      if (project.description != null) ...[
                        const SizedBox(height: 6),
                        Text(project.description!,
                            style: AppTextStyles.bodySecondary,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis),
                      ],
                      const SizedBox(height: 6),
                      if (project.technologies != null)
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: project.technologies!
                              .split(',')
                              .take(5)
                              .map((tech) => Chip(
                                    label: Text(tech.trim(),
                                        style: const TextStyle(fontSize: 11)),
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    visualDensity: VisualDensity.compact,
                                    padding: EdgeInsets.zero,
                                  ))
                              .toList(),
                        ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (project.role != null)
                            Text('Role: ${project.role}',
                                style: AppTextStyles.caption)
                          else
                            Text('Role: ?',
                                style: AppTextStyles.caption
                                    .copyWith(color: AppColors.warning)),
                          const Spacer(),
                          if (project.duration != null)
                            Text(project.duration!,
                                style: AppTextStyles.caption)
                          else
                            Text('Duration: ?',
                                style: AppTextStyles.caption
                                    .copyWith(color: AppColors.warning)),
                        ],
                      ),
                    ],
                  ),
                ),
                // Actions
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      color: AppColors.textSecondary,
                      tooltip: 'Edit / add missing info',
                      onPressed: () async {
                        final result = await showDialog<bool>(
                          context: context,
                          builder: (_) => EditProjectDialog(
                            candidateId: widget.candidateId,
                            existing: project,
                          ),
                        );
                        if (result == true && mounted) {
                          final r = await candidateRepository
                              .getCandidateProjects(widget.candidateId);
                          setState(() => projects = r);
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 18),
                      color: AppColors.error,
                      tooltip: 'Delete project',
                      onPressed: () => _deleteProject(project),
                    ),
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