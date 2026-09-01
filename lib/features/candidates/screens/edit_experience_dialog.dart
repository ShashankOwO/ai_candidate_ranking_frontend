import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../main.dart';
import '../data/models/candidate_experience_model.dart';

/// Edits an existing experience record via PUT.
class EditExperienceDialog extends StatefulWidget {
  final int candidateId;
  final CandidateExperienceModel existing;

  const EditExperienceDialog({
    super.key,
    required this.candidateId,
    required this.existing,
  });

  @override
  State<EditExperienceDialog> createState() => _EditExperienceDialogState();
}

class _EditExperienceDialogState extends State<EditExperienceDialog> {
  final _formKey = GlobalKey<FormState>();
  late final companyCtrl =
      TextEditingController(text: widget.existing.companyName);
  late final titleCtrl = TextEditingController(text: widget.existing.jobTitle);
  late final yearsCtrl =
      TextEditingController(text: widget.existing.years?.toString() ?? '');
  late final descCtrl =
      TextEditingController(text: widget.existing.description ?? '');
  DateTime? startDate;
  DateTime? endDate;
  bool saving = false;

  @override
  void initState() {
    super.initState();
    if (widget.existing.startDate != null) {
      startDate = DateTime.tryParse(widget.existing.startDate!);
    }
    if (widget.existing.endDate != null) {
      endDate = DateTime.tryParse(widget.existing.endDate!);
    }
  }

  @override
  void dispose() {
    companyCtrl.dispose();
    titleCtrl.dispose();
    yearsCtrl.dispose();
    descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: (isStart ? startDate : endDate) ?? DateTime.now(),
      firstDate: DateTime(1980),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => isStart ? startDate = picked : endDate = picked);
    }
  }

  String _fmtDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a start date')),
      );
      return;
    }

    final id = widget.existing.experienceId;
    if (id == null) {
      // Fallback: create new if no ID available
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot update: record has no ID. Adding as new entry.'),
          backgroundColor: AppColors.warning,
        ),
      );
    }

    setState(() => saving = true);
    try {
      final body = {
        'company_name': companyCtrl.text.trim(),
        'job_title': titleCtrl.text.trim(),
        'start_date': _fmtDate(startDate!),
        if (endDate != null) 'end_date': _fmtDate(endDate!),
        'years': double.tryParse(yearsCtrl.text.trim()) ?? 1.0,
        if (descCtrl.text.trim().isNotEmpty) 'description': descCtrl.text.trim(),
      };

      if (id != null) {
        await candidateRepository.updateExperience(widget.candidateId, id, body);
      } else {
        await candidateRepository.addExperience(widget.candidateId, body);
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
      title: const Text('Edit Experience'),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: companyCtrl,
                  enabled: !saving,
                  decoration: const InputDecoration(
                      labelText: 'Company Name *', border: OutlineInputBorder()),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: titleCtrl,
                  enabled: !saving,
                  decoration: const InputDecoration(
                      labelText: 'Job Title *', border: OutlineInputBorder()),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: saving ? null : () => _pickDate(true),
                        icon: const Icon(Icons.calendar_today, size: 16),
                        label: Text(startDate != null
                            ? _fmtDate(startDate!)
                            : 'Start Date *'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: saving ? null : () => _pickDate(false),
                        icon: const Icon(Icons.calendar_today, size: 16),
                        label: Text(endDate != null
                            ? _fmtDate(endDate!)
                            : 'End Date'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: yearsCtrl,
                  enabled: !saving,
                  decoration: const InputDecoration(
                      labelText: 'Years *', border: OutlineInputBorder()),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Required';
                    if (double.tryParse(v) == null) return 'Invalid number';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: descCtrl,
                  enabled: !saving,
                  decoration: const InputDecoration(
                      labelText: 'Description', border: OutlineInputBorder()),
                  maxLines: 3,
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