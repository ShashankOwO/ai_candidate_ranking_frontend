import 'package:flutter/material.dart';

import '../../data/models/candidate_model.dart';

class CandidateCard extends StatelessWidget {
  final CandidateModel candidate;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const CandidateCard({
    super.key,
    required this.candidate,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final firstName = candidate.firstName.trim();

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              // ==================================================
              // CANDIDATE HEADER
              // ==================================================

              Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 24,
                    child: Text(
                      firstName.isNotEmpty
                          ? firstName[0].toUpperCase()
                          : '?',
                      style: theme
                          .textTheme
                          .titleMedium,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          candidate.fullName,
                          maxLines: 1,
                          overflow:
                              TextOverflow.ellipsis,
                          style: theme
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                fontWeight:
                                    FontWeight.w600,
                              ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          candidate.email,
                          maxLines: 1,
                          overflow:
                              TextOverflow.ellipsis,
                          style: theme
                              .textTheme
                              .bodyMedium,
                        ),
                      ],
                    ),
                  ),

                  // ==================================================
                  // RANK SCORE
                  // ==================================================

                  if (candidate.rankScore != null) ...[
                    const SizedBox(width: 8),

                    _RankScore(
                      score: candidate.rankScore!,
                    ),
                  ],
                ],
              ),

              // ==================================================
              // LOCATION
              // ==================================================

              if (candidate.location != null &&
                  candidate.location!
                      .trim()
                      .isNotEmpty) ...[
                const SizedBox(height: 12),

                Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 18,
                    ),

                    const SizedBox(width: 6),

                    Expanded(
                      child: Text(
                        candidate.location!,
                        maxLines: 2,
                        overflow:
                            TextOverflow.ellipsis,
                        style: theme
                            .textTheme
                            .bodyMedium,
                      ),
                    ),
                  ],
                ),
              ],

              // ==================================================
              // STATUS
              // ==================================================

              if (candidate.status != null &&
                  candidate.status!
                      .trim()
                      .isNotEmpty) ...[
                const SizedBox(height: 8),

                _StatusBadge(
                  status: candidate.status!,
                ),
              ],

              // ==================================================
              // ACTION BUTTONS
              // ==================================================

              if (onEdit != null ||
                  onDelete != null) ...[
                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.end,
                  children: [
                    if (onEdit != null)
                      OutlinedButton(
                        onPressed: onEdit,
                        child: const Text(
                          'Edit',
                        ),
                      ),

                    if (onEdit != null &&
                        onDelete != null)
                      const SizedBox(width: 8),

                    if (onDelete != null)
                      OutlinedButton(
                        onPressed: onDelete,
                        child: const Text(
                          'Delete',
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ================================================================
// RANK SCORE
// ================================================================

class _RankScore extends StatelessWidget {
  final num score;

  const _RankScore({
    required this.score,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: colorScheme.primary
    .withValues(alpha: 0.1),
      ),
      child: Text(
        '${score.toStringAsFixed(1)}%',
        style: Theme.of(context)
            .textTheme
            .labelLarge
            ?.copyWith(
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

// ================================================================
// STATUS BADGE
// ================================================================

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
       color: colorScheme.secondary
    .withValues(alpha: 0.1),
      ),
      child: Text(
        status.toUpperCase(),
        style: Theme.of(context)
            .textTheme
            .labelMedium
            ?.copyWith(
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}