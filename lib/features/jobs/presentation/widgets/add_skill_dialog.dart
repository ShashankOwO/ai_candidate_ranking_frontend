import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/job_repository.dart';
import '../../data/models/skill_model.dart';

/// Multi-select pill skill dialog for adding skills to a job.
/// - Shows ALL skills as selectable chip pills
/// - Supports selecting multiple at once
/// - Allows creating a custom skill (with basic validity check)
/// - Assigns required / preferred type to all selected skills
class AddSkillDialog extends StatefulWidget {
  final int jobId;
  final String jobTitle; // used for context in custom skill validation
  final JobRepository repository;

  const AddSkillDialog({
    super.key,
    required this.jobId,
    required this.jobTitle,
    required this.repository,
  });

  @override
  State<AddSkillDialog> createState() => _AddSkillDialogState();
}

class _AddSkillDialogState extends State<AddSkillDialog> {
  List<SkillModel> allSkills = [];
  List<SkillModel> filtered = [];
  final Set<int> selectedIds = {};
  String skillType = 'required';
  bool loadingSkills = true;
  bool saving = false;

  // Custom skill creation
  final searchCtrl = TextEditingController();
  bool creatingNew = false;
  final newNameCtrl = TextEditingController();
  final newCategoryCtrl = TextEditingController();
  bool savingNew = false;
  String? validationMsg;
  bool? isValid;

  @override
  void initState() {
    super.initState();
    _loadSkills();
  }

  @override
  void dispose() {
    searchCtrl.dispose();
    newNameCtrl.dispose();
    newCategoryCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadSkills() async {
    try {
      final skills = await widget.repository.getAvailableSkills();
      if (!mounted) return;
      setState(() {
        allSkills = skills;
        filtered = skills;
        loadingSkills = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => loadingSkills = false);
    }
  }

  void _filterSkills(String q) {
    setState(() {
      filtered = allSkills
          .where((s) => s.skillName.toLowerCase().contains(q.toLowerCase()))
          .toList();
    });
  }

  /// Simple validity check for custom skill.
  /// A skill name is considered valid if:
  /// - At least 2 characters long
  /// - Not purely numeric
  /// - Doesn't contain special characters beyond hyphens/dots/plus
  /// - Matches common skill patterns (letter-based names)
  bool _isValidSkillName(String name) {
    if (name.trim().length < 2) return false;
    if (RegExp(r'^\d+$').hasMatch(name)) return false;
    if (!RegExp(r'^[a-zA-Z0-9\s\.\+\#\-\_\/]+$').hasMatch(name)) return false;
    return true;
  }

  void _validateCustomSkill(String name) {
    final trimmed = name.trim();
    // Check if it already exists in DB
    final exists = allSkills
        .any((s) => s.skillName.toLowerCase() == trimmed.toLowerCase());

    if (exists) {
      final match =
          allSkills.firstWhere((s) => s.skillName.toLowerCase() == trimmed.toLowerCase());
      setState(() {
        validationMsg = '✓ "${match.skillName}" already exists — select it below';
        isValid = true;
      });
      return;
    }

    if (!_isValidSkillName(trimmed)) {
      setState(() {
        validationMsg = '✗ "$trimmed" doesn\'t look like a valid skill name';
        isValid = false;
      });
      return;
    }

    setState(() {
      validationMsg = '✓ "$trimmed" can be added as a new skill';
      isValid = true;
    });
  }

  Future<void> _createAndSelect() async {
    final name = newNameCtrl.text.trim();

    // Check if already exists — just select it
    final existing = allSkills
        .where((s) => s.skillName.toLowerCase() == name.toLowerCase())
        .firstOrNull;
    if (existing != null) {
      setState(() {
        selectedIds.add(existing.skillId);
        creatingNew = false;
      });
      return;
    }

    if (!_isValidSkillName(name)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid skill name. Please enter a proper skill.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => savingNew = true);
    try {
      final created = await widget.repository.createSkill({
        'skill_name': name,
        if (newCategoryCtrl.text.trim().isNotEmpty)
          'skill_category': newCategoryCtrl.text.trim(),
      });
      if (!mounted) return;
      setState(() {
        allSkills = [...allSkills, created];
        filtered = allSkills;
        selectedIds.add(created.skillId);
        creatingNew = false;
        savingNew = false;
        searchCtrl.clear();
        validationMsg = null;
        isValid = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Skill "${created.skillName}" created and selected'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString().replaceFirst('Exception: ', '');
      if (msg.contains('already exists')) {
        // Reload and select existing
        await _loadSkills();
        final ex = allSkills.firstWhere(
          (s) => s.skillName.toLowerCase() == name.toLowerCase(),
          orElse: () => allSkills.last,
        );
        setState(() {
          selectedIds.add(ex.skillId);
          creatingNew = false;
          savingNew = false;
        });
      } else {
        setState(() => savingNew = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed: $msg'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _save() async {
    if (selectedIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one skill')),
      );
      return;
    }
    setState(() => saving = true);
    int added = 0;
    final List<String> alreadyExist = [];
    final List<String> otherErrors = [];

    for (final id in selectedIds) {
      final skillName = allSkills
          .firstWhere((s) => s.skillId == id,
              orElse: () => allSkills.first)
          .skillName;
      try {
        await widget.repository.addJobSkill(widget.jobId, {
          'skill_id': id,
          'skill_type': skillType,
        });
        added++;
      } catch (e) {
        final msg = e.toString().toLowerCase();
        if (msg.contains('already') || msg.contains('duplicate') || msg.contains('400')) {
          alreadyExist.add(skillName);
        } else {
          otherErrors.add(skillName);
        }
      }
    }
    if (!mounted) return;
    setState(() => saving = false);

    if (added > 0) {
      Navigator.pop(context, true);
      String snackMsg = '$added skill(s) added successfully';
      if (alreadyExist.isNotEmpty) {
        snackMsg += '\n${alreadyExist.join(", ")} already exist in this job';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(snackMsg),
          backgroundColor: AppColors.success,
        ),
      );
    } else if (alreadyExist.isNotEmpty) {
      // All selected skills are duplicates
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '⚠ ${alreadyExist.length == 1 ? '"${alreadyExist[0]}" is' : 'These skills are'} already added to this job.',
          ),
          backgroundColor: AppColors.warning,
          duration: const Duration(seconds: 4),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add skills: ${otherErrors.join(", ")}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Add Job Skills'),
          if (selectedIds.isNotEmpty)
            Text(
              '${selectedIds.length} skill(s) selected',
              style: AppTextStyles.caption.copyWith(color: AppColors.primary),
            ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search field
              TextField(
                controller: searchCtrl,
                enabled: !saving && !creatingNew,
                decoration: InputDecoration(
                  labelText: 'Search or type a skill',
                  hintText: 'e.g. Python, Docker',
                  prefixIcon: const Icon(Icons.search),
                  border: const OutlineInputBorder(),
                  suffixIcon: searchCtrl.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            searchCtrl.clear();
                            _filterSkills('');
                          },
                        )
                      : null,
                ),
                onChanged: (q) {
                  _filterSkills(q);
                  // Show option to add if not in list
                  final exists = allSkills.any((s) =>
                      s.skillName.toLowerCase() == q.trim().toLowerCase());
                  if (q.trim().length >= 2 && !exists) {
                    setState(() {});
                  }
                },
              ),

              const SizedBox(height: 12),

              // Skill pills
              if (loadingSkills)
                const Center(
                    child: Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator()))
              else ...[
                if (filtered.isEmpty && searchCtrl.text.isNotEmpty && !creatingNew)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'No skill found for "${searchCtrl.text}"',
                        style: AppTextStyles.caption,
                      ),
                      const SizedBox(height: 8),
                      FilledButton.icon(
                        onPressed: () {
                          setState(() {
                            creatingNew = true;
                            newNameCtrl.text = searchCtrl.text.trim();
                            _validateCustomSkill(newNameCtrl.text);
                          });
                        },
                        icon: const Icon(Icons.add, size: 18),
                        label: Text('Add "${searchCtrl.text.trim()}" as new skill'),
                      ),
                    ],
                  )
                else ...[
                  // Pill chips — multi-select
                  SizedBox(
                    height: 180,
                    child: SingleChildScrollView(
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: filtered.map((skill) {
                          final isSelected = selectedIds.contains(skill.skillId);
                          return FilterChip(
                            label: Text(skill.skillName),
                            selected: isSelected,
                            selectedColor: AppColors.primary.withValues(alpha: 0.15),
                            checkmarkColor: AppColors.primary,
                            side: BorderSide(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.border,
                            ),
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.textPrimary,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                            onSelected: saving
                                ? null
                                : (_) {
                                    setState(() {
                                      if (isSelected) {
                                        selectedIds.remove(skill.skillId);
                                      } else {
                                        selectedIds.add(skill.skillId);
                                      }
                                    });
                                  },
                          );
                        }).toList(),
                      ),
                    ),
                  ),

                  // Add custom skill button (below pills)
                  if (!creatingNew && searchCtrl.text.isNotEmpty)
                    Center(
                      child: TextButton.icon(
                        onPressed: () {
                          setState(() {
                            creatingNew = true;
                            newNameCtrl.text = searchCtrl.text.trim();
                            _validateCustomSkill(newNameCtrl.text);
                          });
                        },
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Add as new skill'),
                      ),
                    ),
                ],
              ],

              // Custom skill creation form
              if (creatingNew) ...[
                const Divider(height: 24),
                Text('Create New Skill', style: AppTextStyles.label),
                const SizedBox(height: 8),
                TextField(
                  controller: newNameCtrl,
                  enabled: !savingNew,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: 'Skill Name *',
                    border: const OutlineInputBorder(),
                    suffixIcon: isValid == null
                        ? null
                        : Icon(
                            isValid! ? Icons.check_circle : Icons.cancel,
                            color: isValid! ? AppColors.success : AppColors.error,
                          ),
                  ),
                  onChanged: _validateCustomSkill,
                ),
                if (validationMsg != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    validationMsg!,
                    style: AppTextStyles.caption.copyWith(
                      color: isValid == true ? AppColors.success : AppColors.error,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                TextField(
                  controller: newCategoryCtrl,
                  enabled: !savingNew,
                  decoration: const InputDecoration(
                    labelText: 'Category (optional)',
                    hintText: 'e.g. Programming, Cloud, DevOps',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    TextButton(
                      onPressed: savingNew ? null : () {
                        setState(() {
                          creatingNew = false;
                          validationMsg = null;
                          isValid = null;
                        });
                      },
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: (savingNew || isValid == false) ? null : _createAndSelect,
                      child: savingNew
                          ? const SizedBox(
                              width: 16, height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text('Create & Select'),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 16),

              // Skill type
              Text('Apply type to all selected skills:', style: AppTextStyles.label),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'required', label: Text('Required ⭐')),
                  ButtonSegment(value: 'preferred', label: Text('Preferred 👍')),
                ],
                selected: {skillType},
                onSelectionChanged: saving ? null : (v) => setState(() => skillType = v.first),
              ),

              // Selection summary
              if (selectedIds.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: allSkills
                      .where((s) => selectedIds.contains(s.skillId))
                      .map((s) => Chip(
                            label: Text(s.skillName,
                                style: const TextStyle(fontSize: 12)),
                            backgroundColor:
                                AppColors.success.withValues(alpha: 0.1),
                            side: BorderSide(
                                color: AppColors.success.withValues(alpha: 0.4)),
                            deleteIcon: const Icon(Icons.close, size: 14),
                            onDeleted: () =>
                                setState(() => selectedIds.remove(s.skillId)),
                          ))
                      .toList(),
                ),
              ],
            ],
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
              : Text('Add ${selectedIds.isEmpty ? "" : "${selectedIds.length} "}Skill${selectedIds.length == 1 ? "" : "s"}'),
        ),
      ],
    );
  }
}
