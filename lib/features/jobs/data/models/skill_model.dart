/// Master skill from GET /skills.
class SkillModel {
  final int skillId;
  final String skillName;

  const SkillModel({
    required this.skillId,
    required this.skillName,
  });

  factory SkillModel.fromJson(Map<String, dynamic> json) {
    return SkillModel(
      skillId: json['skill_id'] ?? json['id'] ?? 0,
      skillName: json['skill_name'] ?? json['name'] ?? '',
    );
  }
}
