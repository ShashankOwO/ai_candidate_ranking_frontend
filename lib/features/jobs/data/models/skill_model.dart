/// Master skill from GET /skills.
class SkillModel {
  final int skillId;
  final String skillName;
  final String? skillCategory;

  const SkillModel({
    required this.skillId,
    required this.skillName,
    this.skillCategory,
  });

  factory SkillModel.fromJson(Map<String, dynamic> json) {
    return SkillModel(
      skillId: json['skill_id'] ?? json['id'] ?? 0,
      skillName: json['skill_name'] ?? json['name'] ?? '',
      skillCategory: json['skill_category'] ?? json['category'],
    );
  }
}

