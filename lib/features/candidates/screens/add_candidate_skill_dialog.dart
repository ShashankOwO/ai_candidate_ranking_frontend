import 'package:flutter/material.dart';
 
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../main.dart';
import '../../jobs/data/models/skill_model.dart';
 
/// Dialog to manually add a skill to a candidate.
/// Uses POST /candidates/{id}/skills
/// Body: { skill_id, proficiency, years_experience }
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
  SkillModel? selected;
  String proficiency = 'Intermediate';
  final yearsCtrl = TextEditingController(text: '1');
  final searchCtrl = TextEditingController();
  bool loadingSkills = true;
  bool saving = false;
 
  // For creating a new skill inline
  bool creatingNew = false;
  final newSkillCtrl = TextEditingController();
  final newCategoryCtrl = TextEditingController();
  bool savingNew = false;
 
  static const _proficiencies = [
    'Beginner',
    'Intermediate',
    'Advanced',
    'Expert',
  ];
 
  @override
  void initState() {
    super.initState();
    _loadSkills();
  }
 
  @override
  void dispose() {
    yearsCtrl.dispose();
    searchCtrl.dispose();
    newSkillCtrl.dispose();
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
    } catch (e) {
      if (!mounted) return;
      setState(() => loadingSkills = false);
    }
  }
 
  void _filter(String q) {
    setState(() {
      filtered = allSkills
          .where(
              (s) => s.skillName.toLowerCase().contains(q.toLowerCase()))
          .toList();
    });
  }
 
  Future<void> _createNewSkill() async {
    final name = newSkillCtrl.text.trim();
    if (name.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Skill name must be at least 2 characters')),
      );
      return;
    }
 
    setState(() => savingNew = true);
    try {
      final body = <String, dynamic>{
        'skill_name': name,
        if (newCategoryCtrl.text.trim().isNotEmpty)
          'skill_category': newCategoryCtrl.text.trim(),
      };
      await jobRepository.createSkill(body);
 
      // Reload skills and auto-select the new one
      await _loadSkills();
      if (!mounted) return;
 
      final newSkill = allSkills.firstWhere(
        (s) => s.skillName.toLowerCase() == name.toLowerCase(),
        orElse: () => allSkills.last,
      );
 
      setState(() {
        selected = newSkill;
        creatingNew = false;
        savingNew = false;
        searchCtrl.text = newSkill.skillName;
        _filter(newSkill.skillName);
      });
 
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Skill "${newSkill.skillName}" created'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => savingNew = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed: ${e.toString().replaceFirst("Exception: ", "")}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
 
  Future<void> _save() async {
    if (selected == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a skill')),
      );
      return;
    }
    final years = double.tryParse(yearsCtrl.text.trim()) ?? 0;
 
    setState(() => saving = true);
    try {
      await candidateRepository.addSkill(widget.candidateId, {
        'skill_id': selected!.skillId,
        'proficiency': proficiency,
        'years_experience': years,
      });
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed: ${e.toString().replaceFirst("Exception: ", "")}'),
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
      title: const Text('Add Skill'),
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
                enabled: !saving,
                decoration: const InputDecoration(
                  labelText: 'Search Skill',
                  hintText: 'e.g. Python',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: _filter,
              ),
              const SizedBox(height: 12),
 
              // Skills list
              if (loadingSkills)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (filtered.isEmpty && !creatingNew) ...[
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No matching skills found'),
                ),
                // Offer to create a new skill
                Center(
                  child: FilledButton.icon(
                    onPressed: () {
                      setState(() {
                        creatingNew = true;
                        newSkillCtrl.text = searchCtrl.text.trim();
                      });
                    },
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Create New Skill'),
                  ),
                ),
              ] else if (!creatingNew)
                SizedBox(
                  height: 160,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final skill = filtered[index];
                      final isSel = selected?.skillId == skill.skillId;
                      return ListTile(
                        dense: true,
                        selected: isSel,
                        selectedTileColor:
                            AppColors.primary.withValues(alpha: 0.08),
                        leading: Icon(
                          isSel
                              ? Icons.check_circle
                              : Icons.circle_outlined,
                          color: isSel
                              ? AppColors.primary
                              : AppColors.textTertiary,
                        ),
                        title: Text(skill.skillName),
                        subtitle: skill.skillCategory != null
                            ? Text(skill.skillCategory!,
                                style: AppTextStyles.caption)
                            : null,
                        onTap: saving
                            ? null
                            : () => setState(() => selected = skill),
                      );
                    },
                  ),
                ),
 
              // Create new skill inline
              if (creatingNew) ...[
                const SizedBox(height: 8),
                Text('Create New Skill',
                    style: AppTextStyles.label),
                const SizedBox(height: 8),
                TextField(
                  controller: newSkillCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Skill Name *',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: newCategoryCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Category (optional)',
                    hintText: 'e.g. Programming, Cloud, Database',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    TextButton(
                      onPressed: savingNew
                          ? null
                          : () => setState(() => creatingNew = false),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: savingNew ? null : _createNewSkill,
                      child: savingNew
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child:
                                  CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Create'),
                    ),
                  ],
                ),
              ],
 
              // Also add "Create New Skill" button below list when it has items
              if (!creatingNew && filtered.isNotEmpty && !loadingSkills) ...[
                const SizedBox(height: 8),
                Center(
                  child: TextButton.icon(
                    onPressed: () {
                      setState(() {
                        creatingNew = true;
                        newSkillCtrl.text = '';
                      });
                    },
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Create New Skill'),
                  ),
                ),
              ],
 
              const SizedBox(height: 16),
 
              // Proficiency
              DropdownButtonFormField<String>(
                initialValue: proficiency,
                decoration: const InputDecoration(
                  labelText: 'Proficiency',
                  border: OutlineInputBorder(),
                ),
                items: _proficiencies
                    .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                    .toList(),
                onChanged: saving ? null : (v) => setState(() => proficiency = v!),
              ),
 
              const SizedBox(height: 12),
 
              // Years
              TextField(
                controller: yearsCtrl,
                enabled: !saving,
                decoration: const InputDecoration(
                  labelText: 'Years of Experience',
                  border: OutlineInputBorder(),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
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
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Add Skill'),
        ),
      ],
    );
  }
}
 