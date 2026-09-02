import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../main.dart';
import '../../data/models/job_model.dart';
import '../pages/job_detail_page.dart';
import '../widgets/job_form_page.dart';

class JobsPage extends StatefulWidget {
  const JobsPage({super.key});

  @override
  State<JobsPage> createState() => _JobsPageState();
}

class _JobsPageState extends State<JobsPage> {
  String search = '';
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
      final result = await jobRepository.getJobs();
      if (!mounted) return;
      setState(() {
        jobs = result;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => loading = false);
    }
  }

  List<JobModel> get filteredJobs {
    if (search.isEmpty) return jobs;
    return jobs
        .where((j) =>
            j.jobTitle.toLowerCase().contains(search.toLowerCase()))
        .toList();
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
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => JobDetailPage(
          jobId: job.jobId,
          repository: jobRepository,
        ),
      ),
    );
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jobs'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search jobs...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) => setState(() => search = value),
            ),
          ),
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _load,
                    child: filteredJobs.isEmpty
                        ? ListView(
                            children: [
                              const SizedBox(height: 100),
                              Icon(
                                Icons.work_off_outlined,
                                size: 64,
                                color: AppColors.textTertiary,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                search.isEmpty
                                    ? 'No jobs found'
                                    : 'No results for "$search"',
                                style: AppTextStyles.sectionHeader,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: filteredJobs.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final job = filteredJobs[index];
                              return Card(
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(16),
                                  onTap: () => _openJob(job),
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
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: const Icon(
                                            Icons.work_outline,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                job.jobTitle,
                                                style: AppTextStyles.label,
                                                maxLines: 2,
                                                overflow:
                                                    TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                job.minimumExperience != null
                                                    ? '${job.minimumExperience}+ years'
                                                    : 'No exp. requirement',
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
                            },
                          ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createJob,
        icon: const Icon(Icons.add),
        label: const Text('Create Job'),
      ),
    );
  }
}