
import 'package:flutter/material.dart';

import '../../data/job_repository.dart';

class AddSkillDialog extends StatefulWidget {
  final int jobId;
  final JobRepository repository;

  const AddSkillDialog({
    super.key,
    required this.jobId,
    required this.repository,
  });

  @override
  State<AddSkillDialog> createState() =>
      _AddSkillDialogState();
}

class _AddSkillDialogState
    extends State<AddSkillDialog> {
  final TextEditingController controller =
      TextEditingController();

  bool requiredSkill = true;
  bool saving = false;

  Future<void> _save() async {
    final skillName = controller.text.trim();

    if (skillName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter a skill name.',
          ),
        ),
      );
      return;
    }

    setState(() {
      saving = true;
    });

    try {
      await widget.repository.addSkill(
        widget.jobId,
        {
          'name': skillName,
          'required': requiredSkill,
        },
      );

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to add skill: $e',
          ),
        ),
      );
    } finally {
      if (!mounted) return;

      setState(() {
        saving = false;
      });
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Add Skill',
      ),

      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              enabled: !saving,
              textInputAction:
                  TextInputAction.done,
              decoration: const InputDecoration(
                labelText: 'Skill name',
                hintText: 'e.g. Flutter',
                prefixIcon: Icon(
                  Icons.code,
                ),
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) {
                if (!saving) {
                  _save();
                }
              },
            ),

            const SizedBox(height: 8),

            CheckboxListTile(
              contentPadding:
                  EdgeInsets.zero,
              value: requiredSkill,
              title: const Text(
                'Required skill',
              ),
              subtitle: Text(
                requiredSkill
                    ? 'Candidate must have this skill'
                    : 'This skill is preferred',
              ),
              onChanged: saving
                  ? null
                  : (value) {
                      setState(() {
                        requiredSkill =
                            value ?? true;
                      });
                    },
            ),
          ],
        ),
      ),

      actions: [
        TextButton(
          onPressed: saving
              ? null
              : () {
                  Navigator.pop(
                    context,
                  );
                },
          child: const Text(
            'Cancel',
          ),
        ),

        ElevatedButton(
          onPressed: saving
              ? null
              : _save,
          child: saving
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child:
                      CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              : const Text(
                  'Add',
                ),
        ),
      ],
    );
  }
}

