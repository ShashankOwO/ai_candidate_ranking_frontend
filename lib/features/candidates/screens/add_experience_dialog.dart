import 'package:flutter/material.dart';
 
import '../../../core/theme/app_colors.dart';
import '../../../main.dart';
 
/// Dialog to manually add experience to a candidate.
/// POST /candidates/{id}/experience
/// Body: { company_name, job_title, start_date, end_date?, years, description? }
class AddExperienceDialog extends StatefulWidget {
  final int candidateId;
 
  const AddExperienceDialog({super.key, required this.candidateId});
 
  @override
  State<AddExperienceDialog> createState() => _AddExperienceDialogState();
}
 
class _AddExperienceDialogState extends State<AddExperienceDialog> {
  final _formKey = GlobalKey<FormState>();
  final companyCtrl = TextEditingController();
  final titleCtrl = TextEditingController();
  final yearsCtrl = TextEditingController(text: '1');
  final descCtrl = TextEditingController();
 
  DateTime? startDate;
  DateTime? endDate;
  bool saving = false;
 
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
      initialDate: DateTime.now(),
      firstDate: DateTime(1980),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          startDate = picked;
        } else {
          endDate = picked;
        }
      });
    }
  }
 
  String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
 
  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a start date')),
      );
      return;
    }
 
    setState(() => saving = true);
    try {
      await candidateRepository.addExperience(widget.candidateId, {
        'company_name': companyCtrl.text.trim(),
        'job_title': titleCtrl.text.trim(),
        'start_date': _formatDate(startDate!),
        if (endDate != null) 'end_date': _formatDate(endDate!),
        'years': double.tryParse(yearsCtrl.text.trim()) ?? 1,
        if (descCtrl.text.trim().isNotEmpty)
          'description': descCtrl.text.trim(),
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
      title: const Text('Add Experience'),
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
                    labelText: 'Company Name *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: titleCtrl,
                  enabled: !saving,
                  decoration: const InputDecoration(
                    labelText: 'Job Title *',
                    border: OutlineInputBorder(),
                  ),
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
                            ? _formatDate(startDate!)
                            : 'Start Date *'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: saving ? null : () => _pickDate(false),
                        icon: const Icon(Icons.calendar_today, size: 16),
                        label: Text(endDate != null
                            ? _formatDate(endDate!)
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
                    labelText: 'Years *',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
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
                    labelText: 'Description (optional)',
                    border: OutlineInputBorder(),
                  ),
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
                  width: 18, height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Add Experience'),
        ),
      ],
    );
  }
}