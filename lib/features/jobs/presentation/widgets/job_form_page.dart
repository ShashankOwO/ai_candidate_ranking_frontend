import 'package:flutter/material.dart';

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
  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>();

  late TextEditingController titleController;
  late TextEditingController descriptionController;
  late TextEditingController locationController;
  late TextEditingController experienceController;

  String employmentType = 'Full-time';

  bool saving = false;

  @override
  void initState() {
    super.initState();

    titleController = TextEditingController(
      text: widget.job?.title ?? '',
    );

    descriptionController = TextEditingController(
      text: widget.job?.description ?? '',
    );

    locationController = TextEditingController(
      text: widget.job?.location ?? '',
    );

    experienceController = TextEditingController(
      text: widget.job?.minimumExperience?.toString() ?? '',
    );

    final existingEmployment =
        widget.job?.employmentType;

    if (existingEmployment != null &&
        existingEmployment.isNotEmpty) {
      if (existingEmployment == 'Full-time' ||
          existingEmployment == 'Part-time' ||
          existingEmployment == 'Contract') {
        employmentType = existingEmployment;
      }
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    locationController.dispose();
    experienceController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      saving = true;
    });

    try {
      final experienceText =
          experienceController.text.trim();

      final int? experience =
          experienceText.isEmpty
              ? null
              : int.tryParse(experienceText);

      final Map<String, dynamic> data = {
        'job_title': titleController.text.trim(),
        'job_description':
            descriptionController.text.trim(),
        'location': locationController.text.trim(),
        'employment_type': employmentType,
        'minimum_experience': experience,
      };

      if (widget.isEditing) {
        await widget.repository.updateJob(
          widget.job!.id,
          data,
        );
      } else {
        await widget.repository.createJob(data);
      }

      if (!mounted) {
        return;
      }

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
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to save job: $e',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          saving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isEditing
              ? 'Edit Job'
              : 'Create Job',
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: titleController,
                  textInputAction:
                      TextInputAction.next,
                  decoration:
                      const InputDecoration(
                    labelText: 'Job title',
                    hintText: 'Flutter Developer',
                    prefixIcon:
                        Icon(Icons.work_outline),
                    border:
                        OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Enter job title';
                    }

                    if (value.trim().length < 2) {
                      return 'Job title is too short';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller:
                      descriptionController,
                  maxLines: 5,
                  decoration:
                      const InputDecoration(
                    labelText:
                        'Job description',
                    hintText:
                        'Enter job responsibilities and requirements',
                    prefixIcon: Icon(
                      Icons.description_outlined,
                    ),
                    border:
                        OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Enter job description';
                    }

                    if (value.trim().length < 10) {
                      return 'Description must be at least 10 characters';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: locationController,
                  textInputAction:
                      TextInputAction.next,
                  decoration:
                      const InputDecoration(
                    labelText: 'Location',
                    hintText: 'Bangalore',
                    prefixIcon: Icon(
                      Icons.location_on_outlined,
                    ),
                    border:
                        OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 16),

                DropdownButtonFormField<String>(
                 initialValue: employmentType,
                  decoration:
                      const InputDecoration(
                    labelText:
                        'Employment type',
                    prefixIcon: Icon(
                      Icons.business_center_outlined,
                    ),
                    border:
                        OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem<String>(
                      value: 'Full-time',
                      child: Text('Full-time'),
                    ),
                    DropdownMenuItem<String>(
                      value: 'Part-time',
                      child: Text('Part-time'),
                    ),
                    DropdownMenuItem<String>(
                      value: 'Contract',
                      child: Text('Contract'),
                    ),
                  ],
                  onChanged: saving
                      ? null
                      : (value) {
                          if (value == null) {
                            return;
                          }

                          setState(() {
                            employmentType =
                                value;
                          });
                        },
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller:
                      experienceController,
                  keyboardType:
                      TextInputType.number,
                  decoration:
                      const InputDecoration(
                    labelText:
                        'Minimum experience',
                    hintText: '2',
                    suffixText: 'years',
                    prefixIcon:
                        Icon(Icons.timeline),
                    border:
                        OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return null;
                    }

                    final number =
                        int.tryParse(
                      value.trim(),
                    );

                    if (number == null) {
                      return 'Enter a valid number';
                    }

                    if (number < 0) {
                      return 'Experience cannot be negative';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 24),

                SizedBox(
                  height: 50,
                  child: FilledButton.icon(
                    onPressed:
                        saving ? null : _save,
                    icon: saving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child:
                                CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(
                            Icons.save,
                          ),
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