import 'package:flutter/material.dart';
import '../../data/job_repository.dart';


class JobsPage extends StatefulWidget {
  final JobRepository repository;

  const JobsPage({
    super.key,
    required this.repository,
  });

  @override
  State<JobsPage> createState() => _JobsPageState();
}

class _JobsPageState extends State<JobsPage> {
  String search = '';
  String statusFilter = 'All';

  final List<Map<String, dynamic>> demoJobs = [];

  List<Map<String, dynamic>> get filteredJobs {
    return demoJobs.where((job) {
      final matchesSearch =
          job['title']
              .toString()
              .toLowerCase()
              .contains(search.toLowerCase());

      final matchesStatus =
          statusFilter == 'All' ||
          job['status'] == statusFilter;

      return matchesSearch && matchesStatus;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Jobs',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search jobs...',
                      prefixIcon:
                          const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        search = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                DropdownButton<String>(
                  value: statusFilter,
                  items: const [
                    DropdownMenuItem(
                      value: 'All',
                      child: Text('All'),
                    ),
                    DropdownMenuItem(
                      value: 'Open',
                      child: Text('Open'),
                    ),
                    DropdownMenuItem(
                      value: 'Closed',
                      child: Text('Closed'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value == null) {
                      return;
                    }

                    setState(() {
                      statusFilter = value;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: filteredJobs.isEmpty
                  ? const Center(
                      child: Text(
                        'No jobs found',
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    )
                  : ListView.separated(
                      itemCount: filteredJobs.length,
                      separatorBuilder:
                          (_, index) =>
                              const SizedBox(
                        height: 12,
                      ),
                      itemBuilder:
                          (context, index) {
                        final job =
                            filteredJobs[index];

                        return _DemoJobCard(
                          title: job['title'],
                          description:
                              job['description'],
                          location:
                              job['location'],
                          employmentType:
                              job['employmentType'],
                          status: job['status'],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton:
          FloatingActionButton.extended(
        onPressed: () {
          _showCreateJobDialog();
        },
        icon: const Icon(Icons.add),
        label: const Text('Create Job'),
      ),
    );
  }

  void _showCreateJobDialog() {
    final titleController =
        TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create Job'),
          content: TextField(
            controller: titleController,
            decoration: const InputDecoration(
              labelText: 'Job title',
              hintText: 'Flutter Developer',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController
                    .text
                    .trim()
                    .isEmpty) {
                  return;
                }

                setState(() {
                  demoJobs.add({
                    'id': demoJobs.length + 1,
                    'title':
                        titleController.text.trim(),
                    'description':
                        'New job position',
                    'location': 'Not specified',
                    'employmentType':
                        'Full-time',
                    'status': 'Open',
                  });
                });

                Navigator.pop(context);
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }
}

class _DemoJobCard extends StatelessWidget {
  final String title;
  final String description;
  final String location;
  final String employmentType;
  final String status;

  const _DemoJobCard({
    required this.title,
    required this.description,
    required this.location,
    required this.employmentType,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = status == 'Open'
        ? Colors.green
        : Colors.red;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .primaryContainer,
                    borderRadius:
                        BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.work_outline,
                    color: Theme.of(context)
                        .colorScheme
                        .onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(
                          fontWeight:
                              FontWeight.bold,
                        ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color:
                        statusColor.withValues(
                      alpha: 0.12,
                    ),
                    borderRadius:
                        BorderRadius.circular(20),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(description),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 18,
                ),
                const SizedBox(width: 5),
                Text(location),
                const SizedBox(width: 20),
                const Icon(
                  Icons.business_center_outlined,
                  size: 18,
                ),
                const SizedBox(width: 5),
                Text(employmentType),
              ],
            ),
          ],
        ),
      ),
    );
  }
}