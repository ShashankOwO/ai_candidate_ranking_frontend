import 'package:flutter/material.dart';
 
import '../../../core/theme/app_colors.dart';
import '../../../main.dart';
 
/// Dialog to manually add a qualification/education to a candidate.
/// POST /candidates/{id}/qualifications
/// Body: { university, degree, specialization?, percentage?, passed_out_year?, joining_year? }
class AddQualificationDialog extends StatefulWidget {
  final int candidateId;
 
  const AddQualificationDialog({super.key, required this.candidateId});
 
  @override
  State<AddQualificationDialog> createState() =>
      _AddQualificationDialogState();
}
 
class _AddQualificationDialogState extends State<AddQualificationDialog> {
  final _formKey = GlobalKey<FormState>();
  final universityCtrl = TextEditingController();
  final degreeCtrl = TextEditingController();
  final specCtrl = TextEditingController();
  final percentCtrl = TextEditingController();
  final passedOutCtrl = TextEditingController();
  final joiningCtrl = TextEditingController();
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
      await candidateRepository.addQualification(widget.candidateId, {
        'university': universityCtrl.text.trim(),
        'degree': degreeCtrl.text.trim(),
        if (specCtrl.text.trim().isNotEmpty)
          'specialization': specCtrl.text.trim(),
        if (percentCtrl.text.trim().isNotEmpty)
          'percentage': double.tryParse(percentCtrl.text.trim()),
        if (passedOutCtrl.text.trim().isNotEmpty)
          'passed_out_year': int.tryParse(passedOutCtrl.text.trim()),
        if (joiningCtrl.text.trim().isNotEmpty)
          'joining_year': int.tryParse(joiningCtrl.text.trim()),
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
      title: const Text('Add Education'),
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
                    labelText: 'University *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: degreeCtrl,
                  enabled: !saving,
                  decoration: const InputDecoration(
                    labelText: 'Degree *',
                    hintText: 'e.g. B.Tech, MBA, M.Sc',
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
                  width: 18, height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Add Education'),
        ),
      ],
    );
  }
}