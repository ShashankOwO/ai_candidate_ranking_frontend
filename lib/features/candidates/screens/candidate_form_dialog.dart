import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../main.dart';
import '../data/models/candidate_model.dart';

/// Dialog for creating a new candidate or editing an existing one.
/// Uses POST /candidates/create or PUT /candidates/{id}
class CandidateFormDialog extends StatefulWidget {
  final CandidateModel? candidate; // null = create mode

  const CandidateFormDialog({super.key, this.candidate});

  @override
  State<CandidateFormDialog> createState() => _CandidateFormDialogState();
}

class _CandidateFormDialogState extends State<CandidateFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  bool _saving = false;

  bool get _isEditing => widget.candidate != null;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.candidate?.fullName ?? '');
    _emailController =
        TextEditingController(text: widget.candidate?.emailAddress ?? '');
    _phoneController =
        TextEditingController(text: widget.candidate?.contactNo ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final data = {
      'full_name': _nameController.text.trim(),
      if (_emailController.text.trim().isNotEmpty)
        'email_address': _emailController.text.trim(),
      if (_phoneController.text.trim().isNotEmpty)
        'contact_no': _phoneController.text.trim(),
    };

    try {
      CandidateModel result;
      if (_isEditing) {
        result = await candidateRepository.updateCandidate(
          widget.candidate!.candidateId,
          data,
        );
      } else {
        result = await candidateRepository.createCandidate(data);
      }

      if (!mounted) return;
      Navigator.pop(context, result);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: $e'), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isEditing ? 'Edit Candidate' : 'Add Candidate'),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                enabled: !_saving,
                decoration: const InputDecoration(
                  labelText: 'Full Name *',
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.trim().length < 2) {
                    return 'Name must be at least 2 characters';
                  }
                  return null;
                },
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                enabled: !_saving,
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  prefixIcon: Icon(Icons.email_outlined),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                enabled: !_saving,
                decoration: const InputDecoration(
                  labelText: 'Contact No.',
                  prefixIcon: Icon(Icons.phone_outlined),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.done,
              ),
              if (!_isEditing) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.info_outline,
                        size: 14, color: AppColors.textTertiary),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'You can also upload resumes — candidates will be auto-created from the extracted data.',
                        style: AppTextStyles.caption,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(_isEditing ? 'Save Changes' : 'Add Candidate'),
        ),
      ],
    );
  }
}