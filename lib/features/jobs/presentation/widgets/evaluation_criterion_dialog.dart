
import 'package:flutter/material.dart';

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

  bool saving = false;

  bool get editing => widget.criterion != null;

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(
      text: widget.criterion?.name ?? '',
    );

    descriptionController = TextEditingController(
      text: widget.criterion?.description ?? '',
    );

    weightController = TextEditingController(
      text: widget.criterion?.weight.toString() ?? '1',
    );
  }

  Future<void> _save() async {
    final name = nameController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a criterion name.'),
        ),
      );
      return;
    }

    final weight =
        double.tryParse(weightController.text.trim()) ?? 1;

    setState(() {
      saving = true;
    });

    try {
      final data = <String, dynamic>{
        'name': name,
        'description': descriptionController.text.trim(),
        'weight': weight,
      };

      if (editing) {
        await widget.repository.updateCriterion(
          widget.criterion!.id,
          data,
        );
      } else {
        await widget.repository.addCriterion(
          widget.jobId,
          data,
        );
      }

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to save criterion: $e',
          ),
        ),
      );
    } finally {
      if (!mounted) return;

      setState(() {
        saving = false;
      });
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        editing
            ? 'Edit Evaluation Criterion'
            : 'Add Evaluation Criterion',
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              enabled: !saving,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Criterion',
                hintText: 'e.g. Technical Skills',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descriptionController,
              enabled: !saving,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Describe the evaluation criterion',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: weightController,
              enabled: !saving,
              keyboardType:
                  const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Weight',
                hintText: 'e.g. 1.0',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: saving
              ? null
              : () {
                  Navigator.pop(context);
                },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: saving ? null : _save,
          child: saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  editing ? 'Update' : 'Add',
                ),
        ),
      ],
    );
  }
}

