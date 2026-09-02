import 'package:flutter/material.dart';
 
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../main.dart';
import '../../jobs/data/models/skill_model.dart';
 
/// Multi-select pill dialog for adding skills to a candidate manually.
class AddCandidateSkillDialog extends StatefulWidget {
  final int candidateId;
 
  const AddCandidateSkillDialog({super.key, required this.candidateId});
 
  @override
  State<AddCandidateSkillDialog> createState() =>
      _AddCandidateSkillDialogState();
}
 
class _AddCandidateSkillDialogState extends State<AddCandidateSkillDialog> {
  List<SkillModel> allSkills = [];
  List<SkillModel> filtered = [];
 
  // Each selected skill can have its own proficiency & years
  // Map: skillId → {proficiency, years}
  final Map<int, _SkillEntry> selected = {};
 
  bool loadingSkills = true;
  bool saving = false;
 
  // Global defaults applied to all newly selected skills
  String defaultProficiency = 'Intermediate';
  final defaultYearsCtrl = TextEditingController(text: '1');
 
  // Custom skill creation
  bool creatingNew = false;
  final searchCtrl = TextEditingController();
  final newNameCtrl = TextEditingController();
  final newCategoryCtrl = TextEditingController();
  bool savingNew = false;
  String? validationMsg;
  bool? isValid;
 
  static const _proficiencies = ['Beginner', 'Intermediate', 'Advanced', 'Expert'];
 
  @override
  void initState() {
    super.initState();
    _loadSkills();
  }
 
  @override
  void dispose() {
    searchCtrl.dispose();
    defaultYearsCtrl.dispose();
    newNameCtrl.dispose();
    newCategoryCtrl.dispose();
    super.dispose();
  }
 
  Future<void> _loadSkills() async {
    try {
      final skills = await jobRepository.getAvailableSkills();
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
 
  void _filter(String q) {
    setState(() {
      filtered = allSkills
          .where((s) => s.skillName.toLowerCase().contains(q.toLowerCase()))
          .toList();
    });
  }
 
  bool _isValidSkillName(String name) {
    if (name.trim().length < 2) return false;
    if (RegExp(r'^\d+$').hasMatch(name)) return false;
    if (!RegExp(r'^[a-zA-Z0-9\s\.\+\#\-\_\/]+$').hasMatch(name)) return false;
    return true;
  }
 
  void _validateCustomSkill(String name) {
    final trimmed = name.trim();
    final exists = allSkills
        .any((s) => s.skillName.toLowerCase() == trimmed.toLowerCase());
    if (exists) {
      final match = allSkills.firstWhere(
          (s) => s.skillName.toLowerCase() == trimmed.toLowerCase());
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
    final existing = allSkills
        .where((s) => s.skillName.toLowerCase() == name.toLowerCase())
        .firstOrNull;
    if (existing != null) {
      setState(() {
        selected[existing.skillId] = _SkillEntry(defaultProficiency,
            double.tryParse(defaultYearsCtrl.text) ?? 1);
        creatingNew = false;
      });
      return;
    }
    if (!_isValidSkillName(name)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid skill name'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    setState(() => savingNew = true);
    try {
      final created = await jobRepository.createSkill({
        'skill_name': name,
        if (newCategoryCtrl.text.trim().isNotEmpty)
          'skill_category': newCategoryCtrl.text.trim(),
      });
      if (!mounted) return;
      setState(() {
        allSkills = [...allSkills, created];
        filtered = allSkills;
        selected[created.skillId] = _SkillEntry(
            defaultProficiency, double.tryParse(defaultYearsCtrl.text) ?? 1);
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
      setState(() => savingNew = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
 
  Future<void> _save() async {
    if (selected.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one skill')),
      );
      return;
    }
    setState(() => saving = true);
    int added = 0;
    for (final entry in selected.entries) {
      try {
        await candidateRepository.addSkill(widget.candidateId, {
          'skill_id': entry.key,
          'proficiency': entry.value.proficiency,
          'years_experience': entry.value.years,
        });
        added++;
      } catch (_) {}
    }
    if (!mounted) return;
    setState(() => saving = false);
    Navigator.pop(context, added > 0);
    if (added > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$added skill(s) added'),
          backgroundColor: AppColors.success,
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
          const Text('Add Skills'),
          if (selected.isNotEmpty)
            Text('${selected.length} selected',
                style: AppTextStyles.caption.copyWith(color: AppColors.primary)),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search
              TextField(
                controller: searchCtrl,
                enabled: !saving && !creatingNew,
                decoration: InputDecoration(
                  labelText: 'Search skill',
                  hintText: 'e.g. Python, React',
                  prefixIcon: const Icon(Icons.search),
                  border: const OutlineInputBorder(),
                  suffixIcon: searchCtrl.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () { searchCtrl.clear(); _filter(''); },
                        )
                      : null,
                ),
                onChanged: _filter,
              ),
 
              const SizedBox(height: 12),
 
              // Skill pills
              if (loadingSkills)
                const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()))
              else ...[
                if (filtered.isEmpty && searchCtrl.text.isNotEmpty && !creatingNew)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('No skill found for "${searchCtrl.text}"', style: AppTextStyles.caption),
                      const SizedBox(height: 8),
                      FilledButton.icon(
                        onPressed: () => setState(() {
                          creatingNew = true;
                          newNameCtrl.text = searchCtrl.text.trim();
                          _validateCustomSkill(newNameCtrl.text);
                        }),
                        icon: const Icon(Icons.add, size: 18),
                        label: Text('Add "${searchCtrl.text.trim()}" as new skill'),
                      ),
                    ],
                  )
                else ...[
                  SizedBox(
                    height: 160,
                    child: SingleChildScrollView(
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: filtered.map((skill) {
                          final isSel = selected.containsKey(skill.skillId);
                          return FilterChip(
                            label: Text(skill.skillName),
                            selected: isSel,
                            selectedColor: AppColors.primary.withValues(alpha: 0.15),
                            checkmarkColor: AppColors.primary,
                            side: BorderSide(
                              color: isSel ? AppColors.primary : AppColors.border,
                            ),
                            labelStyle: TextStyle(
                              color: isSel ? AppColors.primary : AppColors.textPrimary,
                              fontWeight: isSel ? FontWeight.w600 : FontWeight.normal,
                            ),
                            onSelected: saving ? null : (_) {
                              setState(() {
                                if (isSel) {
                                  selected.remove(skill.skillId);
                                } else {
                                  selected[skill.skillId] = _SkillEntry(
                                    defaultProficiency,
                                    double.tryParse(defaultYearsCtrl.text) ?? 1,
                                  );
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  if (searchCtrl.text.isNotEmpty)
                    Center(
                      child: TextButton.icon(
                        onPressed: () => setState(() {
                          creatingNew = true;
                          newNameCtrl.text = searchCtrl.text.trim();
                          _validateCustomSkill(newNameCtrl.text);
                        }),
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Add as new skill'),
                      ),
                    ),
                ],
              ],
 
              // Create new skill form
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
                  Text(validationMsg!,
                      style: AppTextStyles.caption.copyWith(
                        color: isValid == true ? AppColors.success : AppColors.error,
                      )),
                ],
                const SizedBox(height: 8),
                TextField(
                  controller: newCategoryCtrl,
                  enabled: !savingNew,
                  decoration: const InputDecoration(
                    labelText: 'Category (optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    TextButton(
                      onPressed: savingNew ? null : () => setState(() {
                        creatingNew = false;
                        validationMsg = null;
                        isValid = null;
                      }),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: (savingNew || isValid == false) ? null : _createAndSelect,
                      child: savingNew
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text('Create & Select'),
                    ),
                  ],
                ),
              ],
 
              const SizedBox(height: 16),
 
              // Default proficiency + years (applied to all selected)
              if (selected.isNotEmpty) ...[
                Text('Set proficiency & years for all selected:', style: AppTextStyles.label),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: defaultProficiency,
                        decoration: const InputDecoration(
                          labelText: 'Proficiency',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        ),
                        items: _proficiencies
                            .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                            .toList(),
                        onChanged: saving ? null : (v) {
                          setState(() {
                            defaultProficiency = v!;
                            for (final key in selected.keys) {
                              selected[key] = _SkillEntry(v, selected[key]!.years);
                            }
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: defaultYearsCtrl,
                        enabled: !saving,
                        decoration: const InputDecoration(
                          labelText: 'Years',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        onChanged: (v) {
                          final years = double.tryParse(v) ?? 1;
                          for (final key in selected.keys) {
                            selected[key] = _SkillEntry(selected[key]!.proficiency, years);
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
 
                // Selected chips
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: allSkills
                      .where((s) => selected.containsKey(s.skillId))
                      .map((s) => Chip(
                            label: Text(s.skillName, style: const TextStyle(fontSize: 12)),
                            backgroundColor: AppColors.success.withValues(alpha: 0.1),
                            side: BorderSide(color: AppColors.success.withValues(alpha: 0.4)),
                            deleteIcon: const Icon(Icons.close, size: 14),
                            onDeleted: () => setState(() => selected.remove(s.skillId)),
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
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
              : Text('Add ${selected.isEmpty ? "" : "${selected.length} "}Skill${selected.length == 1 ? "" : "s"}'),
        ),
      ],
    );
  }
}
 
class _SkillEntry {
  final String proficiency;
  final double years;
  const _SkillEntry(this.proficiency, this.years);
}
 
 