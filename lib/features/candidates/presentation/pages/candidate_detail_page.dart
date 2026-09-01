import 'package:flutter/material.dart';

import '../../data/candidate_repository.dart';
import '../../data/models/candidate_model.dart';
import '../../data/models/experience_model.dart';
import '../../data/models/project_model.dart';
import '../../data/models/qualification_model.dart';

class CandidateDetailPage extends StatefulWidget {
  final String candidateId;
  final CandidateRepository repository;

  const CandidateDetailPage({
    super.key,
    required this.candidateId,
    required this.repository,
  });

  @override
  State<CandidateDetailPage> createState() =>
      _CandidateDetailPageState();
}

class _CandidateDetailPageState
    extends State<CandidateDetailPage> {
  CandidateModel? _candidate;

  List<QualificationModel> _qualifications = [];
  List<ExperienceModel> _experience = [];
  List<ProjectModel> _projects = [];

  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCandidate();
  }

  // ============================================================
  // LOAD CANDIDATE
  // ============================================================

  Future<void> _loadCandidate() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      final candidate = await widget.repository.getCandidate(
        widget.candidateId,
      );

      final qualifications =
          await widget.repository.getQualifications(
        widget.candidateId,
      );

      final experience =
          await widget.repository.getExperience(
        widget.candidateId,
      );

      final projects =
          await widget.repository.getProjects(
        widget.candidateId,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _candidate = candidate;
        _qualifications = qualifications;
        _experience = experience;
        _projects = projects;
        _loading = false;
        _error = null;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _loading = false;
        _error = error.toString();
      });
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Candidate'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 48,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Unable to load candidate',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _loadCandidate,
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final candidate = _candidate;

    if (candidate == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Candidate'),
        ),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.person_off_outlined,
                  size: 56,
                ),
                SizedBox(height: 16),
                Text(
                  'Candidate not found',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'The requested candidate could not be found.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          candidate.fullName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadCandidate,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            _buildProfile(candidate),

            const SizedBox(height: 16),

            _buildQualifications(),

            const SizedBox(height: 16),

            _buildExperience(),

            const SizedBox(height: 16),

            _buildProjects(),

            const SizedBox(height: 16),

            _buildRankingHistory(),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // PROFILE
  // ============================================================

  Widget _buildProfile(
    CandidateModel candidate,
  ) {
    return _SectionCard(
      title: 'Profile',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            candidate.fullName,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),

          const SizedBox(height: 12),

          _InfoRow(
            icon: Icons.email_outlined,
            text: candidate.email,
          ),

          if (candidate.phone != null &&
              candidate.phone!.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            _InfoRow(
              icon: Icons.phone_outlined,
              text: candidate.phone!,
            ),
          ],

          if (candidate.location != null &&
              candidate.location!.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            _InfoRow(
              icon: Icons.location_on_outlined,
              text: candidate.location!,
            ),
          ],

          if (candidate.summary != null &&
              candidate.summary!.trim().isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Summary',
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(candidate.summary!),
          ],
        ],
      ),
    );
  }

  // ============================================================
  // QUALIFICATIONS
  // ============================================================

  Widget _buildQualifications() {
    return _SectionCard(
      title: 'Qualifications',
      child: _qualifications.isEmpty
          ? const _EmptyMessage(
              message: 'No qualifications added.',
            )
          : Column(
              children: _qualifications.map(
                (qualification) {
                  final details = <String>[];

                  if (qualification.institution != null &&
                      qualification.institution!
                          .trim()
                          .isNotEmpty) {
                    details.add(
                      qualification.institution!,
                    );
                  }

                  if (qualification.fieldOfStudy != null &&
                      qualification.fieldOfStudy!
                          .trim()
                          .isNotEmpty) {
                    details.add(
                      qualification.fieldOfStudy!,
                    );
                  }

                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const CircleAvatar(
                      child: Icon(
                        Icons.school_outlined,
                      ),
                    ),
                    title: Text(
                      qualification.name,
                    ),
                    subtitle: details.isEmpty
                        ? null
                        : Text(
                            details.join(' • '),
                          ),
                  );
                },
              ).toList(),
            ),
    );
  }

  // ============================================================
  // EXPERIENCE
  // ============================================================

  Widget _buildExperience() {
    return _SectionCard(
      title: 'Experience',
      child: _experience.isEmpty
          ? const _EmptyMessage(
              message: 'No experience added.',
            )
          : Column(
              children: _experience.map(
                (item) {
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const CircleAvatar(
                      child: Icon(
                        Icons.work_outline,
                      ),
                    ),
                    title: Text(
                      item.position,
                    ),
                    subtitle: item.company.trim().isNotEmpty
                      ? Text(item.company)
    : null,
                    trailing: item.current == true
                        ? const Text(
                            'Current',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          )
                        : null,
                  );
                },
              ).toList(),
            ),
    );
  }

  // ============================================================
  // PROJECTS
  // ============================================================

  Widget _buildProjects() {
    return _SectionCard(
      title: 'Projects',
      child: _projects.isEmpty
          ? const _EmptyMessage(
              message: 'No projects added.',
            )
          : Column(
              children: _projects.map(
                (project) {
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const CircleAvatar(
                      child: Icon(
                        Icons.folder_outlined,
                      ),
                    ),
                    title: Text(
                      project.name,
                    ),
                    subtitle: project.description != null &&
                            project.description!
                                .trim()
                                .isNotEmpty
                        ? Text(project.description!)
                        : null,
                  );
                },
              ).toList(),
            ),
    );
  }

  // ============================================================
  // RANKING HISTORY
  // ============================================================

  Widget _buildRankingHistory() {
    return _SectionCard(
      title: 'Ranking History',
      child: const Text(
        'Ranking history will be connected '
        'when the ranking API is integrated.',
      ),
    );
  }
}

// ================================================================
// SECTION CARD
// ================================================================

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

// ================================================================
// INFO ROW
// ================================================================

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text),
        ),
      ],
    );
  }
}

// ================================================================
// EMPTY MESSAGE
// ================================================================

class _EmptyMessage extends StatelessWidget {
  final String message;

  const _EmptyMessage({
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      style: Theme.of(context).textTheme.bodyMedium,
    );
  }
}