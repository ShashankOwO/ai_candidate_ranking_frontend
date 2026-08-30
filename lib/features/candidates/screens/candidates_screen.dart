import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../main.dart';
import '../data/models/candidate_model.dart';
import 'candidate_detail_screen.dart';

class CandidatesScreen extends StatefulWidget {
  const CandidatesScreen({super.key});

  @override
  State<CandidatesScreen> createState() => _CandidatesScreenState();
}

class _CandidatesScreenState extends State<CandidatesScreen> {
  List<CandidateModel> candidates = [];
  String search = '';
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final result = await candidateRepository.getCandidates();
      if (!mounted) return;
      setState(() {
        candidates = result;
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

  List<CandidateModel> get filteredCandidates {
    if (search.isEmpty) return candidates;
    return candidates
        .where((c) =>
            c.fullName.toLowerCase().contains(search.toLowerCase()) ||
            (c.emailAddress ?? '').toLowerCase().contains(search.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Candidates (${candidates.length})'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _load,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search candidates...',
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
                : error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, size: 48),
                            const SizedBox(height: 12),
                            Text(error!, textAlign: TextAlign.center),
                            const SizedBox(height: 12),
                            FilledButton(
                                onPressed: _load,
                                child: const Text('Retry')),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _load,
                        child: filteredCandidates.isEmpty
                            ? ListView(
                                children: [
                                  const SizedBox(height: 100),
                                  Icon(Icons.people_outline,
                                      size: 64,
                                      color: AppColors.textTertiary),
                                  const SizedBox(height: 16),
                                  Text(
                                    search.isEmpty
                                        ? 'No candidates found.\nUpload resumes to create candidates.'
                                        : 'No results for "$search"',
                                    style: AppTextStyles.bodySecondary,
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16),
                                itemCount: filteredCandidates.length,
                                itemBuilder: (context, index) {
                                  final candidate =
                                      filteredCandidates[index];
                                  return Card(
                                    margin:
                                        const EdgeInsets.only(bottom: 8),
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: AppColors.primaryLight
                                            .withValues(alpha: 0.15),
                                        child: Text(
                                          '${index + 1}',
                                          style: const TextStyle(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      title: Text(
                                        candidate.fullName,
                                        style: AppTextStyles.label,
                                      ),
                                      subtitle: Text(
                                        candidate.emailAddress ??
                                            'No email',
                                        style: AppTextStyles.caption,
                                      ),
                                      trailing: const Icon(
                                          Icons.chevron_right),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                CandidateDetailScreen(
                                              candidateId:
                                                  candidate.candidateId,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                },
                              ),
                      ),
          ),
        ],
      ),
    );
  }
}
