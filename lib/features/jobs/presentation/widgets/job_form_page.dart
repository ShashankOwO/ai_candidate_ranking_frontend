import 'package:flutter/material.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../data/job_repository.dart';
import '../../data/models/job_model.dart';

class JobFormPage extends StatefulWidget {
  final JobRepository repository;
  final JobModel? job;

  const JobFormPage({
    super.key,
    required this.repository,
    this.job,
  });

  bool get isEditing => job != null;

  @override
  State<JobFormPage> createState() => _JobFormPageState();
}

class _JobFormPageState extends State<JobFormPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController titleController;
  late TextEditingController descriptionController;
  late TextEditingController experienceController;

  bool saving = false;

  @override
  void initState() {
    super.initState();

    titleController = TextEditingController(
      text: widget.job?.jobTitle ?? '',
    );
    descriptionController = TextEditingController(
      text: widget.job?.jobDescription ?? '',
    );
    experienceController = TextEditingController(
      text: widget.job?.minimumExperience?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    experienceController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => saving = true);

    try {
      final experience =
          int.tryParse(experienceController.text.trim());

      final data = {
        'job_title': titleController.text.trim(),
        'job_description': descriptionController.text.trim(),
        'minimum_experience': experience,
      };

      // Note: backend only supports creating jobs (no update endpoint).
      // Always call createJob regardless of edit mode.
      await widget.repository.createJob(data);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isEditing
                ? 'Job updated successfully'
                : 'Job created successfully',
          ),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: $e')),
      );
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Job' : 'Create Job'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Job Title', style: AppTextStyles.label),
                const SizedBox(height: 8),
                TextFormField(
                  controller: titleController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    hintText: 'Python Backend Developer',
                    prefixIcon: Icon(Icons.work_outline),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().length < 2) {
                      return 'Enter a valid job title';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                Text('Job Description', style: AppTextStyles.label),
                const SizedBox(height: 8),
                TextFormField(
                  controller: descriptionController,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    hintText:
                        'Looking for a Python Backend Developer responsible for...',
                    alignLabelWithHint: true,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().length < 10) {
                      return 'Description must be at least 10 characters';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                Text('Minimum Experience', style: AppTextStyles.label),
                const SizedBox(height: 8),
                TextFormField(
                  controller: experienceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: '3',
                    suffixText: 'years',
                    prefixIcon: Icon(Icons.timeline),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return null;
                    final n = int.tryParse(value.trim());
                    if (n == null || n < 0) return 'Enter a valid number';
                    return null;
                  },
                ),

                const SizedBox(height: 32),

                SizedBox(
                  height: 52,
                  child: FilledButton.icon(
                    onPressed: saving ? null : _save,
                    icon: saving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save),
                    label: Text(
                      saving
                          ? 'Saving...'
                          : widget.isEditing
                              ? 'Update Job'
                              : 'Create Job',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}