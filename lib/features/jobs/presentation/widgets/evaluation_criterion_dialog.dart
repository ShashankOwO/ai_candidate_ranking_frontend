import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/job_repository.dart';
import '../../data/models/evaluation_criterion_model.dart';

class EvaluationCriterionDialog extends StatefulWidget {
  final int jobId;
  final JobRepository repository;
  final EvaluationCriterionModel? criterion;

  const EvaluationCriterionDialog({
    super.key,
    required this.jobId,
    required this.repository,
    this.criterion,
  });

  @override
  State<EvaluationCriterionDialog> createState() =>
      _EvaluationCriterionDialogState();
}

class _EvaluationCriterionDialogState
    extends State<EvaluationCriterionDialog> {
  late final TextEditingController nameController;
  late final TextEditingController descriptionController;
  late final TextEditingController weightController;
  late final TextEditingController maxScoreController;
  late String criteriaType;

  bool saving = false;
  bool get editing => widget.criterion != null;

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(
      text: widget.criterion?.criteriaName ?? '',
    );
    descriptionController = TextEditingController(
      text: widget.criterion?.criteriaDescription ?? '',
    );
    weightController = TextEditingController(
      text: widget.criterion?.weight.toString() ?? '',
    );
    maxScoreController = TextEditingController(
      text: widget.criterion?.maxScore.toString() ?? '100',
    );
    criteriaType = widget.criterion?.criteriaType ?? 'skills';
  }

  Future<void> _save() async {
    final name = nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a criterion name')),
      );
      return;
    }

    final weight = double.tryParse(weightController.text.trim());
    if (weight == null || weight <= 0 || weight > 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Weight must be between 1 and 100')),
      );
      return;
    }

    final maxScore = double.tryParse(maxScoreController.text.trim()) ?? 100.0;

    setState(() => saving = true);

    try {
      final data = {
        'criteria_name': name,
        'criteria_type': criteriaType,
        'criteria_description': descriptionController.text.trim(),
        'weight': weight,
        'max_score': maxScore,
      };

      if (editing) {
        await widget.repository.updateCriterion(
          widget.jobId,
          widget.criterion!.criteriaId,
          data,
        );
      } else {
        await widget.repository.addCriterion(widget.jobId, data);
      }

      if (!mounted) return;
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
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    weightController.dispose();
    maxScoreController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(editing ? 'Edit Criterion' : 'Add Evaluation Criterion'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              enabled: !saving,
              decoration: const InputDecoration(
                labelText: 'Criterion Name',
                hintText: 'e.g. Skills',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            // Criteria Type Dropdown
            DropdownButtonFormField<String>(
              initialValue: criteriaType,
              decoration: const InputDecoration(
                labelText: 'Criterion Type',
                border: OutlineInputBorder(),
              ),
              items: EvaluationCriterionModel.criteriaTypes.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(_formatType(type)),
                );
              }).toList(),
              onChanged: saving
                  ? null
                  : (value) {
                      if (value != null) {
                        setState(() => criteriaType = value);
                      }
                    },
            ),

            const SizedBox(height: 12),

            TextField(
              controller: descriptionController,
              enabled: !saving,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Describe how this criterion should be evaluated',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: weightController,
                    enabled: !saving,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Weight (%)',
                      hintText: 'e.g. 40',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: maxScoreController,
                    enabled: !saving,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Max Score',
                      hintText: '100',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Weight should be a percentage (total must equal 100%)',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: saving ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: saving ? null : _save,
          child: saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(editing ? 'Update' : 'Add'),
        ),
      ],
    );
  }

  String _formatType(String type) {
    return type[0].toUpperCase() + type.substring(1);
  }
}
