import 'package:flutter/material.dart';
 
import '../../../core/theme/app_colors.dart';
import '../../../main.dart';
 
/// Dialog to manually add a project to a candidate.
/// POST /candidates/{id}/projects
/// Body: { project_name, description?, technologies?, role?, duration? }
class AddProjectDialog extends StatefulWidget {
  final int candidateId;
 
  const AddProjectDialog({super.key, required this.candidateId});
 
  @override
  State<AddProjectDialog> createState() => _AddProjectDialogState();
}
 
class _AddProjectDialogState extends State<AddProjectDialog> {
  final _formKey = GlobalKey<FormState>();
  final nameCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final techCtrl = TextEditingController();
  final roleCtrl = TextEditingController();
  final durationCtrl = TextEditingController();
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
      await candidateRepository.addProject(widget.candidateId, {
        'project_name': nameCtrl.text.trim(),
        if (descCtrl.text.trim().isNotEmpty)
          'description': descCtrl.text.trim(),
        if (techCtrl.text.trim().isNotEmpty)
          'technologies': techCtrl.text.trim(),
        if (roleCtrl.text.trim().isNotEmpty) 'role': roleCtrl.text.trim(),
        if (durationCtrl.text.trim().isNotEmpty)
          'duration': durationCtrl.text.trim(),
      });
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Failed: ${e.toString().replaceFirst("Exception: ", "")}'),
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
                    hintText: 'e.g. Team Lead, Backend Developer',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: durationCtrl,
                  enabled: !saving,
                  decoration: const InputDecoration(
                    labelText: 'Duration',
                    hintText: 'e.g. 3 months, Jan 2023 - Mar 2023',
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
                  width: 18, height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Add Project'),
        ),
      ],
    );
  }
}
 