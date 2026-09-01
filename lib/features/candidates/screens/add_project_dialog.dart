import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../main.dart';

class AddProjectDialog extends StatefulWidget {
  final int candidateId;

  const AddProjectDialog({
    super.key,
    required this.candidateId,
  });

  @override
  State<AddProjectDialog> createState() => _AddProjectDialogState();
}

class _AddProjectDialogState extends State<AddProjectDialog> {
  final _formKey = GlobalKey<FormState>();

  final projectNameController = TextEditingController();
  final descriptionController = TextEditingController();
  final technologiesController = TextEditingController();
  final roleController = TextEditingController();
  final durationController = TextEditingController();
  bool saving = false;

  @override
  void dispose() {
    projectNameController.dispose();
    descriptionController.dispose();
    technologiesController.dispose();
    roleController.dispose();
    durationController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => saving = true);

    try {
      final body = {
        'project_name': projectNameController.text.trim(),
        if (descriptionController.text.trim().isNotEmpty)
          'description': descriptionController.text.trim(),
        if (technologiesController.text.trim().isNotEmpty)
          'technologies': technologiesController.text.trim(),
        if (roleController.text.trim().isNotEmpty)
          'role': roleController.text.trim(),
        if (durationController.text.trim().isNotEmpty)
          'duration': durationController.text.trim(),
      };

      await candidateRepository.addProject(widget.candidateId, body);

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed: ${e.toString().replaceFirst("Exception: ", "")}'),
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
      title: const Text('Add Project'),
      content: SizedBox(
        width: 450,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: projectNameController,
                  enabled: !saving,
                  decoration: const InputDecoration(
                    labelText: 'Project Name *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Project name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: descriptionController,
                  enabled: !saving,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: technologiesController,
                  enabled: !saving,
                  decoration: const InputDecoration(
                    labelText: 'Technologies',
                    hintText: 'Flutter, Dart, Firebase',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: roleController,
                  enabled: !saving,
                  decoration: const InputDecoration(
                    labelText: 'Role',
                    hintText: 'e.g. Lead Developer',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: durationController,
                  enabled: !saving,
                  decoration: const InputDecoration(
                    labelText: 'Duration',
                    hintText: 'e.g. 6 months',
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
          onPressed: saving ? null : () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: saving ? null : _save,
          child: saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Add Project'),
        ),
      ],
    );
  }
}