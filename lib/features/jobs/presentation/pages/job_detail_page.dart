
import 'package:flutter/material.dart';

import '../../data/job_repository.dart';
import '../../data/models/evaluation_criterion_model.dart';
import '../../data/models/job_model.dart';
import '../../data/models/job_skill_model.dart';
import '../widgets/job_form_page.dart';
import 'ranking_results_page.dart';

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

    tabController = TabController(
      length: 4,
      vsync: this,
    );

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
      final jobResult =
          await widget.repository.getJob(widget.jobId);

      final skillsResult =
          await widget.repository.getSkills(widget.jobId);

      final criteriaResult =
          await widget.repository.getCriteria(widget.jobId);

      if (!mounted) return;

      setState(() {
        job = jobResult;
        skills = skillsResult;
        criteria = criteriaResult;
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

  Future<void> _runRanking() async {
    try {
      setState(() {
        loading = true;
      });

      await widget.repository.rankJob(widget.jobId);

      if (!mounted) return;

      setState(() {
        loading = false;
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => RankingResultsPage(
            jobId: widget.jobId,
            repository: widget.repository,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Ranking failed: $e',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Job Details'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 56,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Unable to load job',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  errorMessage!,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _load,
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (job == null) {
      return const Scaffold(
        body: Center(
          child: Text('Job not found'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(job!.title),
        actions: [
          IconButton(
            onPressed: _runRanking,
            tooltip: 'Run Ranking',
            icon: const Icon(
              Icons.auto_awesome,
            ),
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
            Tab(
              text: 'Overview',
            ),
            Tab(
              text: 'Skills',
            ),
            Tab(
              text: 'Criteria',
            ),
            Tab(
              text: 'Rankings',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: tabController,
        children: [
          _overview(),
          _skills(),
          _criteria(),
          RankingResultsPage(
            jobId: widget.jobId,
            repository: widget.repository,
            embedded: true,
          ),
        ],
      ),
      floatingActionButton:
          FloatingActionButton.extended(
        onPressed: _runRanking,
        icon: const Icon(
          Icons.auto_awesome,
        ),
        label: const Text(
          'Run Ranking',
        ),
      ),
    );
  }

  Future<void> _editJob() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => JobFormPage(
          repository: widget.repository,
          job: job,
        ),
      ),
    );

    if (result == true) {
      await _load();
    }
  }

  Widget _overview() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          job!.title,
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),

        const SizedBox(height: 12),

        Text(
          job!.description,
          style: Theme.of(context)
              .textTheme
              .bodyLarge,
        ),

        const SizedBox(height: 24),

        if (job!.location != null &&
            job!.location!.isNotEmpty)
          Card(
            child: ListTile(
              leading: const Icon(
                Icons.location_on_outlined,
              ),
              title: const Text(
                'Location',
              ),
              subtitle: Text(
                job!.location!,
              ),
            ),
          ),

        if (job!.employmentType != null &&
            job!.employmentType!.isNotEmpty)
          Card(
            child: ListTile(
              leading: const Icon(
                Icons.business_center_outlined,
              ),
              title: const Text(
                'Employment',
              ),
              subtitle: Text(
                job!.employmentType!,
              ),
            ),
          ),
      ],
    );
  }

  Widget _skills() {
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Required Skills',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              IconButton(
                onPressed: _addSkill,
                icon: const Icon(
                  Icons.add,
                ),
                tooltip: 'Add Skill',
              ),
            ],
          ),

          const SizedBox(height: 12),

          if (skills.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                child: Text(
                  'No skills added yet.',
                ),
              ),
            ),

          ...skills.map(
            (skill) => Card(
              margin: const EdgeInsets.only(
                bottom: 12,
              ),
              child: ListTile(
                leading: const Icon(
                  Icons.check_circle_outline,
                ),
                title: Text(
                  skill.name,
                ),
                subtitle: Text(
                  skill.required
                      ? 'Required'
                      : 'Preferred',
                ),
                trailing: IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                  ),
                  onPressed: () {
                    _deleteSkill(skill);
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _criteria() {
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Evaluation Criteria',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              IconButton(
                onPressed: _addCriterion,
                icon: const Icon(
                  Icons.add,
                ),
                tooltip: 'Add Criterion',
              ),
            ],
          ),

          const SizedBox(height: 12),

          if (criteria.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                child: Text(
                  'No criteria added yet.',
                ),
              ),
            ),

          ...criteria.map(
            (criterion) => Card(
              margin: const EdgeInsets.only(
                bottom: 12,
              ),
              child: ListTile(
                title: Text(
                  criterion.name,
                ),
                subtitle: Text(
                  criterion.description ?? '',
                ),
                trailing: Text(
                  'Weight ${criterion.weight}',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _addSkill() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Add Skill dialog will be added next.',
        ),
      ),
    );
  }

  Future<void> _deleteSkill(
    JobSkillModel skill,
  ) async {
    try {
      await widget.repository.deleteSkill(
        widget.jobId,
        skill.id,
      );

      await _load();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Skill deleted successfully.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to delete skill: $e',
          ),
        ),
      );
    }
  }

  void _addCriterion() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Add Criterion dialog will be added next.',
        ),
      ),
    );
  }
}
