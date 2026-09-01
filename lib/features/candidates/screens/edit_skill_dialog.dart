import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../main.dart';
import '../data/models/candidate_skill_model.dart';

/// Edits proficiency and years_experience for an existing candidate skill via PUT.
class EditSkillDialog extends StatefulWidget {
  final int candidateId;
  final CandidateSkillModel existing;

  const EditSkillDialog({
    super.key,
    required this.candidateId,
    required this.existing,
  });

  @override
  State<EditSkillDialog> createState() => _EditSkillDialogState();
}

class _EditSkillDialogState extends State<EditSkillDialog> {
  static const _proficiencies = ['Beginner', 'Intermediate', 'Advanced', 'Expert'];

  late String proficiency;
  late final yearsCtrl = TextEditingController(
      text: widget.existing.yearsExperience?.toStringAsFixed(1) ?? '');
  bool saving = false;

  @override
  void initState() {
    super.initState();
    proficiency = _proficiencies.contains(widget.existing.proficiency)
        ? widget.existing.proficiency!
        : 'Intermediate';
  }

  @override
  void dispose() {
    yearsCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => saving = true);
    try {
      await candidateRepository.updateSkill(
        widget.candidateId,
        widget.existing.skillId,
        {
          'skill_id': widget.existing.skillId,
          'proficiency': proficiency,
          'years_experience': double.tryParse(yearsCtrl.text.trim()) ?? 1.0,
        },
      );
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
      title: Text('Edit Skill: ${widget.existing.skillName}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Proficiency Level', style: AppTextStyles.label),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _proficiencies.map((p) {
              final isSelected = proficiency == p;
              return ChoiceChip(
                label: Text(p),
                selected: isSelected,
                selectedColor: AppColors.primary.withValues(alpha: 0.15),
                labelStyle: TextStyle(
                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                onSelected: saving ? null : (_) => setState(() => proficiency = p),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: yearsCtrl,
            enabled: !saving,
            decoration: const InputDecoration(
              labelText: 'Years of Experience',
              hintText: 'e.g. 2.5',
              border: OutlineInputBorder(),
            ),
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
          ),
        ],
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