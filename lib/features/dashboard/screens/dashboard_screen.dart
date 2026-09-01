import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../main.dart';
import '../../auth/data/models/user_model.dart';
import '../../auth/screens/login_screen.dart';
import '../../candidates/screens/candidates_screen.dart';
import '../../jobs/data/models/job_model.dart';
import '../../jobs/presentation/pages/job_detail_page.dart';
import '../../jobs/presentation/widgets/job_form_page.dart';
import '../../resumes/screens/upload_resumes_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  UserModel? user;
  List<JobModel> jobs = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = true);

    try {
      final results = await Future.wait([
        authRepository.getCurrentUser(),
        jobRepository.getJobs(),
      ]);

      if (!mounted) return;

      setState(() {
        user = results[0] as UserModel;
        jobs = results[1] as List<JobModel>;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => loading = false);

      // If auth fails, still show dashboard with stored username
      try {
        final jobList = await jobRepository.getJobs();
        if (!mounted) return;
        setState(() => jobs = jobList);
      } catch (_) {}
    }
  }

  Future<void> _logout() async {
    await authRepository.logout();
    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  void _createJob() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => JobFormPage(repository: jobRepository),
      ),
    );

    if (result == true) _load();
  }

  void _openJob(JobModel job) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => JobDetailPage(
          jobId: job.jobId,
          repository: jobRepository,
        ),
      ),
    );

    if (result == true) _load();
  }

  @override
  Widget build(BuildContext context) {
    final displayName = user?.username ??
        authStorage.getUsername() ??
        'Recruiter';

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Candidate Ranking'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _load,
            tooltip: 'Refresh',
          ),
        ],
      ),
      drawer: _buildDrawer(displayName),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Welcome Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome, $displayName',
                          style: AppTextStyles.title.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Manage your jobs and rank candidates with AI',
                          style: AppTextStyles.bodySecondary.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 20),
                        FilledButton.icon(
                          onPressed: _createJob,
                          icon: const Icon(Icons.add),
                          label: const Text('Create Job'),
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Stats Row
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: Icons.work_outline,
                          label: 'Total Jobs',
                          value: '${jobs.length}',
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.people_outline,
                          label: 'Candidates',
                          value: '—',
                          color: AppColors.success,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.description_outlined,
                          label: 'Resumes',
                          value: '—',
                          color: AppColors.info,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Jobs Section
                  Row(
                    children: [
                      Text('Your Jobs', style: AppTextStyles.sectionHeader),
                      const Spacer(),
                      TextButton(
                        onPressed: _createJob,
                        child: const Text('+ New Job'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  if (jobs.isEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          children: [
                            Icon(
                              Icons.work_off_outlined,
                              size: 56,
                              color: AppColors.textTertiary,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No jobs created yet',
                              style: AppTextStyles.sectionHeader,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Create your first job to start ranking candidates',
                              style: AppTextStyles.bodySecondary,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                            FilledButton.icon(
                              onPressed: _createJob,
                              icon: const Icon(Icons.add),
                              label: const Text('Create Job'),
                            ),
                          ],
                        ),
                      ),
                    ),

                  ...jobs.map(
                    (job) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _JobDashboardCard(
                        job: job,
                        onTap: () => _openJob(job),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildDrawer(String displayName) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white24,
                  child: Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  displayName,
                  style: AppTextStyles.title.copyWith(color: Colors.white),
                ),
                if (user?.email != null)
                  Text(
                    user!.email,
                    style: AppTextStyles.caption.copyWith(
                      color: Colors.white70,
                    ),
                  ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            selected: true,
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.work_outline),
            title: const Text('Jobs'),
            onTap: () {
              Navigator.pop(context);
              // Already on dashboard which shows jobs
            },
          ),
          ListTile(
            leading: const Icon(Icons.people_outline),
            title: const Text('Candidates'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CandidatesScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.upload_file),
            title: const Text('Upload Resumes'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const UploadResumesScreen(),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.error),
            title: const Text(
              'Logout',
              style: TextStyle(color: AppColors.error),
            ),
            onTap: () {
              Navigator.pop(context);
              _logout();
            },
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: AppTextStyles.title.copyWith(color: color),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.caption,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _JobDashboardCard extends StatelessWidget {
  final JobModel job;
  final VoidCallback onTap;

  const _JobDashboardCard({
    required this.job,
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
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.work_outline,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.jobTitle,
                      style: AppTextStyles.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      job.minimumExperience != null
                          ? '${job.minimumExperience}+ years experience'
                          : 'No experience requirement',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: AppColors.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
