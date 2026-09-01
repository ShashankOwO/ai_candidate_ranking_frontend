import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../main.dart';
import '../data/models/candidate_model.dart';
import 'candidate_detail_screen.dart';
import 'candidate_form_dialog.dart';

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

  Future<void> _openCreate() async {
    final result = await showDialog<CandidateModel>(
      context: context,
      builder: (_) => const CandidateFormDialog(),
    );
    if (result != null) {
      await _load();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Candidate "${result.fullName}" created'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  Future<void> _openEdit(CandidateModel candidate) async {
    final result = await showDialog<CandidateModel>(
      context: context,
      builder: (_) => CandidateFormDialog(candidate: candidate),
    );
    if (result != null) await _load();
  }

  Future<void> _delete(CandidateModel candidate) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Candidate'),
        content: Text(
          'Delete "${candidate.fullName}"? This will also remove all their skills, experience, qualifications, projects, and evaluation results.',
        ),
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

    if (confirmed != true) return;

    try {
      await candidateRepository.deleteCandidate(candidate.candidateId);
      await _load();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('"${candidate.fullName}" deleted')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Delete failed: $e'),
            backgroundColor: AppColors.error),
      );
    }
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
            tooltip: 'Refresh',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreate,
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('Add Candidate'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by name or email…',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onChanged: (value) => setState(() => search = value),
            ),
          ),
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : error != null
                    ? _ErrorState(message: error!, onRetry: _load)
                    : RefreshIndicator(
                        onRefresh: _load,
                        child: filteredCandidates.isEmpty
                            ? _EmptyState(
                                searching: search.isNotEmpty,
                                onAdd: _openCreate,
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                                itemCount: filteredCandidates.length,
                                itemBuilder: (context, index) {
                                  final candidate = filteredCandidates[index];
                                  return _CandidateCard(
                                    index: index,
                                    candidate: candidate,
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => CandidateDetailScreen(
                                          candidateId: candidate.candidateId,
                                        ),
                                      ),
                                    ),
                                    onEdit: () => _openEdit(candidate),
                                    onDelete: () => _delete(candidate),
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

// ── Subwidgets ───────────────────────────────────────────────────────────────

class _CandidateCard extends StatelessWidget {
  final int index;
  final CandidateModel candidate;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CandidateCard({
    required this.index,
    required this.candidate,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: AppColors.primaryLight.withValues(alpha: 0.15),
          child: Text(
            candidate.fullName.isNotEmpty
                ? candidate.fullName[0].toUpperCase()
                : '?',
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(candidate.fullName, style: AppTextStyles.label),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (candidate.emailAddress != null)
              Text(candidate.emailAddress!, style: AppTextStyles.caption),
            if (candidate.contactNo != null)
              Text(candidate.contactNo!, style: AppTextStyles.caption),
          ],
        ),
        isThreeLine: candidate.contactNo != null,
        trailing: PopupMenuButton<String>(
          onSelected: (v) {
            if (v == 'edit') onEdit();
            if (v == 'delete') onDelete();
          },
          itemBuilder: (_) => [
            const PopupMenuItem(
              value: 'edit',
              child: ListTile(
                dense: true,
                leading: Icon(Icons.edit_outlined),
                title: Text('Edit'),
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: ListTile(
                dense: true,
                leading: Icon(Icons.delete_outline, color: Colors.red),
                title: Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool searching;
  final VoidCallback onAdd;

  const _EmptyState({required this.searching, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const SizedBox(height: 100),
        Icon(Icons.people_outline, size: 64, color: AppColors.textTertiary),
        const SizedBox(height: 16),
        Text(
          searching
              ? 'No candidates match your search.'
              : 'No candidates yet.\nUpload resumes to auto-create, or add manually.',
          style: AppTextStyles.bodySecondary,
          textAlign: TextAlign.center,
        ),
        if (!searching) ...[
          const SizedBox(height: 20),
          Center(
            child: FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.person_add_alt_1),
              label: const Text('Add Candidate'),
            ),
          ),
        ],
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: AppColors.error),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          FilledButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
