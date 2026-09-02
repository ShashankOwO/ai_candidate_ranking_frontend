
import 'package:flutter/material.dart';

import '../../data/models/job_skill_model.dart';

class JobSkillList extends StatelessWidget {
  final List<JobSkillModel> skills;
  final VoidCallback? onAdd;
  final ValueChanged<JobSkillModel>? onDelete;

  const JobSkillList({
    super.key,
    required this.skills,
    this.onAdd,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Job Skills',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge,
              ),
            ),
            if (onAdd != null)
              FilledButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add),
                label: const Text('Add Skill'),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (skills.isEmpty)
          _buildEmpty(context)
        else
          ListView.builder(
            shrinkWrap: true,
            physics:
                const NeverScrollableScrollPhysics(),
            itemCount: skills.length,
            itemBuilder: (context, index) {
              final skill = skills[index];

              return Card(
                margin: const EdgeInsets.only(
                  bottom: 8,
                ),
                child: ListTile(
                  leading: const Icon(
                    Icons.code,
                  ),
                  title: Text(
                    skill.name,
                  ),
                  subtitle: Text(
                    skill.required
                        ? 'Required'
                        : 'Preferred',
                  ),
                  trailing: onDelete == null
                      ? null
                      : IconButton(
                          onPressed: () {
                            onDelete!(skill);
                          },
                          icon: const Icon(
                            Icons.delete_outline,
                          ),
                        ),
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            children: [
              const Icon(
                Icons.code_off,
                size: 40,
              ),
              const SizedBox(height: 12),
              Text(
                'No skills added',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium,
              ),
              const SizedBox(height: 8),
              const Text(
                'Add required or preferred skills for this job.',
                textAlign: TextAlign.center,
              ),
              if (onAdd != null) ...[
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: onAdd,
                  icon: const Icon(Icons.add),
                  label: const Text(
                    'Add Skill',
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

