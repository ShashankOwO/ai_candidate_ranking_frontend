import 'package:flutter/material.dart';

import '../../data/candidate_repository.dart';
import '../../data/models/candidate_model.dart';
import '../widgets/candidate_card.dart';

class CandidatesPage extends StatefulWidget {
  final CandidateRepository repository;

  const CandidatesPage({
    super.key,
    required this.repository,
  });

  @override
  State<CandidatesPage> createState() =>
      _CandidatesPageState();
}

class _CandidatesPageState
    extends State<CandidatesPage> {
  final TextEditingController _searchController =
      TextEditingController();

  List<CandidateModel> _candidates =
      <CandidateModel>[];

  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCandidates();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ============================================================
  // LOAD CANDIDATES
  // ============================================================

  Future<void> _loadCandidates() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      final candidates =
          await widget.repository.getCandidates();

      if (!mounted) {
        return;
      }

      setState(() {
        _candidates = candidates;
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
  // SEARCH
  // ============================================================

  List<CandidateModel> get _filteredCandidates {
    final query = _searchController.text
        .trim()
        .toLowerCase();

    if (query.isEmpty) {
      return _candidates;
    }

    return _candidates.where((candidate) {
      final fullName =
          candidate.fullName.toLowerCase();

      final email =
          candidate.email.toLowerCase();

      return fullName.contains(query) ||
          email.contains(query);
    }).toList();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Candidates'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSearchAndAddButton(),

            const SizedBox(height: 16),

            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SEARCH + ADD BUTTON
  // ============================================================

  Widget _buildSearchAndAddButton() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: TextField(
            controller: _searchController,
            onChanged: (_) {
              setState(() {});
            },
            decoration: InputDecoration(
              hintText: 'Search candidates...',
              prefixIcon: const Icon(
                Icons.search,
              ),
              suffixIcon:
                  _searchController.text.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                          },
                          icon: const Icon(
                            Icons.clear,
                          ),
                        )
                      : null,
              border: const OutlineInputBorder(),
            ),
          ),
        ),

        const SizedBox(width: 12),

        ElevatedButton.icon(
          onPressed: _onAddCandidate,
          icon: const Icon(Icons.add),
          label: const Text('Add Candidate'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // CONTENT
  // ============================================================

  Widget _buildContent() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return _buildErrorView();
    }

    final candidates = _filteredCandidates;

    if (candidates.isEmpty) {
      return _buildEmptyView();
    }

    return ListView.separated(
      physics:
          const AlwaysScrollableScrollPhysics(),
      itemCount: candidates.length,
      separatorBuilder: (_, _) {
        return const SizedBox(height: 12);
      },
      itemBuilder: (context, index) {
        final candidate = candidates[index];

        return CandidateCard(
          candidate: candidate,
          onTap: () {
            _onCandidateTap(candidate);
          },
          onEdit: () {
            _onEditCandidate(candidate);
          },
          onDelete: () {
            _onDeleteCandidate(candidate);
          },
        );
      },
    );
  }

  // ============================================================
  // ERROR VIEW
  // ============================================================

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 56,
            ),

            const SizedBox(height: 16),

            Text(
              'Unable to load candidates',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            Text(
              _error!,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: _loadCandidates,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY VIEW
  // ============================================================

  Widget _buildEmptyView() {
    final hasSearch =
        _searchController.text.trim().isNotEmpty;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.people_outline,
              size: 56,
            ),

            const SizedBox(height: 16),

            Text(
              hasSearch
                  ? 'No candidates found'
                  : 'No candidates yet',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),

            const SizedBox(height: 8),

            Text(
              hasSearch
                  ? 'There are no candidates matching your search.'
                  : 'Add a candidate to get started.',
              textAlign: TextAlign.center,
            ),

            if (hasSearch) ...[
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () {
                  _searchController.clear();
                  setState(() {});
                },
                child: const Text(
                  'Clear Search',
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ADD CANDIDATE
  // ============================================================

  void _onAddCandidate() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Add Candidate screen will be connected here.',
        ),
      ),
    );
  }

  // ============================================================
  // CANDIDATE TAP
  // ============================================================

  void _onCandidateTap(
    CandidateModel candidate,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Selected ${candidate.fullName}',
        ),
      ),
    );
  }

  // ============================================================
  // EDIT CANDIDATE
  // ============================================================

  void _onEditCandidate(
    CandidateModel candidate,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Edit ${candidate.fullName}',
        ),
      ),
    );
  }

  // ============================================================
  // DELETE CANDIDATE
  // ============================================================

  Future<void> _onDeleteCandidate(
    CandidateModel candidate,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Delete Candidate',
          ),
          content: Text(
            'Are you sure you want to delete '
            '${candidate.fullName}?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    final candidateId = candidate.id;

    if (candidateId == null ||
        candidateId.trim().isEmpty) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Cannot delete candidate: ID is missing.',
          ),
        ),
      );

      return;
    }

    try {
      await widget.repository.deleteCandidate(
        candidateId,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _candidates.removeWhere(
          (item) => item.id == candidateId,
        );
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Candidate deleted successfully.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to delete candidate: $error',
          ),
        ),
      );
    }
  }
}