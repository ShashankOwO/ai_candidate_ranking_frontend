import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/job_repository.dart';
import '../../data/models/skill_model.dart';

class AddSkillDialog extends StatefulWidget {
  final int jobId;
  final JobRepository repository;

  const AddSkillDialog({
    super.key,
    required this.jobId,
    required this.repository,
  });

  @override
  State<AddSkillDialog> createState() => _AddSkillDialogState();
}

class _AddSkillDialogState extends State<AddSkillDialog> {
  List<SkillModel> availableSkills = [];
  List<SkillModel> filteredSkills = [];
  SkillModel? selectedSkill;
  String skillType = 'required';
  bool loadingSkills = true;
  bool saving = false;

  final searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSkills();
  }

  Future<void> _loadSkills() async {
    try {
      final skills = await widget.repository.getAvailableSkills();
      if (!mounted) return;
      setState(() {
        availableSkills = skills;
        filteredSkills = skills;
        loadingSkills = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => loadingSkills = false);
    }
  }

  void _filterSkills(String query) {
    setState(() {
      filteredSkills = availableSkills
          .where((s) =>
              s.skillName.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  Future<void> _save() async {
    if (selectedSkill == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a skill')),
      );
      return;
    }

    setState(() => saving = true);

    try {
      await widget.repository.addJobSkill(widget.jobId, {
        'skill_id': selectedSkill!.skillId,
        'skill_type': skillType,
      });

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
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Job Skill'),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search
              TextField(
                controller: searchController,
                enabled: !saving,
                decoration: const InputDecoration(
                  labelText: 'Search Skill',
                  hintText: 'e.g. Python',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: _filterSkills,
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
              else if (filteredSkills.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No skills found'),
                )
              else
                SizedBox(
                  height: 180,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: filteredSkills.length,
                    itemBuilder: (context, index) {
                      final skill = filteredSkills[index];
                      final isSelected =
                          selectedSkill?.skillId == skill.skillId;

                      return ListTile(
                        dense: true,
                        selected: isSelected,
                        selectedTileColor:
                            AppColors.primary.withValues(alpha: 0.08),
                        leading: Icon(
                          isSelected
                              ? Icons.check_circle
                              : Icons.circle_outlined,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textTertiary,
                        ),
                        title: Text(skill.skillName),
                        onTap: saving
                            ? null
                            : () {
                                setState(() => selectedSkill = skill);
                              },
                      );
                    },
                  ),
                ),

              const SizedBox(height: 16),

              // Skill Type
              const Text('Skill Type',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'required', label: Text('Required')),
                  ButtonSegment(value: 'preferred', label: Text('Preferred')),
                ],
                selected: {skillType},
                onSelectionChanged: saving
                    ? null
                    : (values) {
                        setState(() => skillType = values.first);
                      },
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
        ElevatedButton(
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
