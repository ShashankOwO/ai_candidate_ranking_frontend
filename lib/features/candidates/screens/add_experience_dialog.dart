import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../main.dart';

class AddExperienceDialog extends StatefulWidget {
  final int candidateId;

  const AddExperienceDialog({
    super.key,
    required this.candidateId,
  });

  @override
  State<AddExperienceDialog> createState() => _AddExperienceDialogState();
}

class _AddExperienceDialogState extends State<AddExperienceDialog> {
  final _formKey = GlobalKey<FormState>();

  final companyController = TextEditingController();
  final jobTitleController = TextEditingController();
  final yearsController = TextEditingController();
  final descriptionController = TextEditingController();

  DateTime? startDate;
  DateTime? endDate;
  bool saving = false;

  @override
  void dispose() {
    companyController.dispose();
    jobTitleController.dispose();
    yearsController.dispose();
    descriptionController.dispose();
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
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => saving = true);

    try {
      final body = {
        'company_name': companyController.text.trim(),
        'job_title': jobTitleController.text.trim(),
        if (startDate != null) 'start_date': _fmtDate(startDate!),
        if (endDate != null) 'end_date': _fmtDate(endDate!),
        if (yearsController.text.trim().isNotEmpty)
          'years': double.tryParse(yearsController.text.trim()) ?? 1.0,
        if (descriptionController.text.trim().isNotEmpty)
          'description': descriptionController.text.trim(),
      };

      await candidateRepository.addExperience(widget.candidateId, body);

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
      title: const Text('Add Experience'),
      content: SizedBox(
        width: 450,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: companyController,
                  enabled: !saving,
                  decoration: const InputDecoration(
                    labelText: 'Company Name *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Enter company name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: jobTitleController,
                  enabled: !saving,
                  decoration: const InputDecoration(
                    labelText: 'Job Title *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Enter job title';
                    }
                    return null;
                  },
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
                            : 'Start Date'),
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
                  controller: yearsController,
                  enabled: !saving,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Years of Experience',
                    hintText: 'e.g. 2.5',
                    border: OutlineInputBorder(),
                  ),
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
              : const Text('Add Experience'),
        ),
      ],
    );
  }
}