import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../main.dart';
import '../data/models/candidate_project_model.dart';

/// Edits an existing project record via PUT.
class EditProjectDialog extends StatefulWidget {
  final int candidateId;
  final CandidateProjectModel existing;

  const EditProjectDialog({
    super.key,
    required this.candidateId,
    required this.existing,
  });

  @override
  State<EditProjectDialog> createState() => _EditProjectDialogState();
}

class _EditProjectDialogState extends State<EditProjectDialog> {
  final _formKey = GlobalKey<FormState>();
  late final nameCtrl =
      TextEditingController(text: widget.existing.projectName);
  late final descCtrl =
      TextEditingController(text: widget.existing.description ?? '');
  late final techCtrl =
      TextEditingController(text: widget.existing.technologies ?? '');
  late final roleCtrl =
      TextEditingController(text: widget.existing.role ?? '');
  late final durationCtrl =
      TextEditingController(text: widget.existing.duration ?? '');
  bool saving = false;

  @override
  void dispose() {
    nameCtrl.dispose();
    descCtrl.dispose();
    techCtrl.dispose();
    roleCtrl.dispose();
    durationCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => saving = true);
    try {
      final body = {
        'project_name': nameCtrl.text.trim(),
        if (descCtrl.text.trim().isNotEmpty) 'description': descCtrl.text.trim(),
        if (techCtrl.text.trim().isNotEmpty) 'technologies': techCtrl.text.trim(),
        if (roleCtrl.text.trim().isNotEmpty) 'role': roleCtrl.text.trim(),
        if (durationCtrl.text.trim().isNotEmpty)
          'duration': durationCtrl.text.trim(),
      };

      final id = widget.existing.projectId;
      if (id != null) {
        await candidateRepository.updateProject(widget.candidateId, id, body);
      } else {
        await candidateRepository.addProject(widget.candidateId, body);
      }

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Project'),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameCtrl,
                  enabled: !saving,
                  decoration: const InputDecoration(
                    labelText: 'Project Name *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: descCtrl,
                  enabled: !saving,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: techCtrl,
                  enabled: !saving,
                  decoration: const InputDecoration(
                    labelText: 'Technologies',
                    hintText: 'Python, React, PostgreSQL',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: roleCtrl,
                  enabled: !saving,
                  decoration: const InputDecoration(
                    labelText: 'Role',
                    hintText: 'e.g. Backend Developer',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: durationCtrl,
                  enabled: !saving,
                  decoration: const InputDecoration(
                    labelText: 'Duration',
                    hintText: 'e.g. 3 months',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: saving ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: saving ? null : _save,
          child: saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Save Changes'),
        ),
      ],
    );
  }
}