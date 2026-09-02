import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../main.dart';
import '../data/models/candidate_qualification_model.dart';

/// Edits an existing qualification record via PUT.
class EditQualificationDialog extends StatefulWidget {
  final int candidateId;
  final CandidateQualificationModel existing;

  const EditQualificationDialog({
    super.key,
    required this.candidateId,
    required this.existing,
  });

  @override
  State<EditQualificationDialog> createState() =>
      _EditQualificationDialogState();
}

class _EditQualificationDialogState extends State<EditQualificationDialog> {
  final _formKey = GlobalKey<FormState>();
  late final universityCtrl =
      TextEditingController(text: widget.existing.university ?? '');
  late final degreeCtrl =
      TextEditingController(text: widget.existing.degree ?? '');
  late final specCtrl =
      TextEditingController(text: widget.existing.specialization ?? '');
  late final percentCtrl = TextEditingController(
      text: widget.existing.percentage?.toString() ?? '');
  late final passedOutCtrl = TextEditingController(
      text: widget.existing.passedOutYear?.toString() ?? '');
  late final joiningCtrl = TextEditingController(
      text: widget.existing.joiningYear?.toString() ?? '');
  bool saving = false;

  @override
  void dispose() {
    universityCtrl.dispose();
    degreeCtrl.dispose();
    specCtrl.dispose();
    percentCtrl.dispose();
    passedOutCtrl.dispose();
    joiningCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => saving = true);
    try {
      final body = {
        'university': universityCtrl.text.trim(),
        'degree': degreeCtrl.text.trim(),
        if (specCtrl.text.trim().isNotEmpty) 'specialization': specCtrl.text.trim(),
        if (percentCtrl.text.trim().isNotEmpty)
          'percentage': double.tryParse(percentCtrl.text.trim()),
        if (passedOutCtrl.text.trim().isNotEmpty)
          'passed_out_year': int.tryParse(passedOutCtrl.text.trim()),
        if (joiningCtrl.text.trim().isNotEmpty)
          'joining_year': int.tryParse(joiningCtrl.text.trim()),
      };

      final id = widget.existing.qualificationId;
      if (id != null) {
        await candidateRepository.updateQualification(
            widget.candidateId, id, body);
      } else {
        await candidateRepository.addQualification(widget.candidateId, body);
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
      title: const Text('Edit Education'),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: universityCtrl,
                  enabled: !saving,
                  decoration: const InputDecoration(
                      labelText: 'University *', border: OutlineInputBorder()),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: degreeCtrl,
                  enabled: !saving,
                  decoration: const InputDecoration(
                    labelText: 'Degree *',
                    hintText: 'e.g. B.Tech, MBA',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: specCtrl,
                  enabled: !saving,
                  decoration: const InputDecoration(
                    labelText: 'Specialization',
                    hintText: 'e.g. Computer Science',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: percentCtrl,
                  enabled: !saving,
                  decoration: const InputDecoration(
                    labelText: 'Percentage / CGPA',
                    hintText: 'e.g. 85.5 or 8.5',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: joiningCtrl,
                        enabled: !saving,
                        decoration: const InputDecoration(
                          labelText: 'Joining Year',
                          hintText: '2018',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: passedOutCtrl,
                        enabled: !saving,
                        decoration: const InputDecoration(
                          labelText: 'Passed Out Year',
                          hintText: '2022',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
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