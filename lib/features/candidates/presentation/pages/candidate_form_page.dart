import 'package:flutter/material.dart';

import '../../data/candidate_repository.dart';
import '../../data/models/candidate_model.dart';

class CandidateFormPage extends StatefulWidget {
  final CandidateRepository repository;
  final CandidateModel? candidate;

  const CandidateFormPage({
    super.key,
    required this.repository,
    this.candidate,
  });

  bool get isEditing => candidate != null;

  @override
  State<CandidateFormPage> createState() =>
      _CandidateFormPageState();
}

class _CandidateFormPageState
    extends State<CandidateFormPage> {
  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>();

  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _locationController;
  late final TextEditingController _summaryController;

  bool _saving = false;

  @override
  void initState() {
    super.initState();

    final candidate = widget.candidate;

    _firstNameController = TextEditingController(
      text: candidate?.firstName ?? '',
    );

    _lastNameController = TextEditingController(
      text: candidate?.lastName ?? '',
    );

    _emailController = TextEditingController(
      text: candidate?.email ?? '',
    );

    _phoneController = TextEditingController(
      text: candidate?.phone ?? '',
    );

    _locationController = TextEditingController(
      text: candidate?.location ?? '',
    );

    _summaryController = TextEditingController(
      text: candidate?.summary ?? '',
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _summaryController.dispose();

    super.dispose();
  }

  // ============================================================
  // SAVE
  // ============================================================

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _saving = true;
    });

    final candidate = CandidateModel(
      id: widget.candidate?.id,
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim().isEmpty
          ? null
          : _phoneController.text.trim(),
      location: _locationController.text.trim().isEmpty
          ? null
          : _locationController.text.trim(),
      summary: _summaryController.text.trim().isEmpty
          ? null
          : _summaryController.text.trim(),
      status: widget.candidate?.status,
      rankScore: widget.candidate?.rankScore,
    );

    try {
      if (widget.isEditing) {
        final candidateId = widget.candidate?.id;

        if (candidateId == null ||
            candidateId.trim().isEmpty) {
          throw Exception(
            'Candidate ID is required to update a candidate.',
          );
        }

        await widget.repository.updateCandidate(
          candidateId,
          candidate,
        );
      } else {
        await widget.repository.createCandidate(
          candidate,
        );
      }

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to save candidate: $error',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.isEditing;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing
              ? 'Edit Candidate'
              : 'Add Candidate',
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 900,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        isEditing
                            ? 'Edit Candidate'
                            : 'New Candidate',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(
                              fontWeight:
                                  FontWeight.w600,
                            ),
                      ),

                      const SizedBox(height: 24),

                      // First Name
                      TextFormField(
                        controller:
                            _firstNameController,
                        textInputAction:
                            TextInputAction.next,
                        decoration:
                            const InputDecoration(
                          labelText: 'First name',
                          hintText:
                              'Enter first name',
                          border:
                              OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null ||
                              value.trim().isEmpty) {
                            return 'First name is required';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Last Name
                      TextFormField(
                        controller:
                            _lastNameController,
                        textInputAction:
                            TextInputAction.next,
                        decoration:
                            const InputDecoration(
                          labelText: 'Last name',
                          hintText:
                              'Enter last name',
                          border:
                              OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null ||
                              value.trim().isEmpty) {
                            return 'Last name is required';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Email
                      TextFormField(
                        controller:
                            _emailController,
                        keyboardType:
                            TextInputType.emailAddress,
                        textInputAction:
                            TextInputAction.next,
                        decoration:
                            const InputDecoration(
                          labelText: 'Email',
                          hintText:
                              'Enter email address',
                          border:
                              OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null ||
                              value.trim().isEmpty) {
                            return 'Email is required';
                          }

                          final email =
                              value.trim();

                          final emailRegex =
                              RegExp(
                            r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                          );

                          if (!emailRegex
                              .hasMatch(email)) {
                            return 'Enter a valid email address';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Phone
                      TextFormField(
                        controller:
                            _phoneController,
                        keyboardType:
                            TextInputType.phone,
                        textInputAction:
                            TextInputAction.next,
                        decoration:
                            const InputDecoration(
                          labelText: 'Phone',
                          hintText:
                              'Enter phone number',
                          border:
                              OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Location
                      TextFormField(
                        controller:
                            _locationController,
                        textInputAction:
                            TextInputAction.next,
                        decoration:
                            const InputDecoration(
                          labelText: 'Location',
                          hintText:
                              'Enter location',
                          border:
                              OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Summary
                      TextFormField(
                        controller:
                            _summaryController,
                        maxLines: 5,
                        minLines: 3,
                        keyboardType:
                            TextInputType.multiline,
                        decoration:
                            const InputDecoration(
                          labelText: 'Summary',
                          hintText:
                              'Enter candidate summary',
                          alignLabelWithHint: true,
                          border:
                              OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Save button
                      Align(
                        alignment:
                            Alignment.centerRight,
                        child: ElevatedButton(
                          onPressed:
                              _saving ? null : _save,
                          style: ElevatedButton.styleFrom(
                            padding:
                                const EdgeInsets
                                    .symmetric(
                              horizontal: 24,
                              vertical: 14,
                            ),
                          ),
                          child: _saving
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child:
                                      CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  isEditing
                                      ? 'Update Candidate'
                                      : 'Create Candidate',
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}