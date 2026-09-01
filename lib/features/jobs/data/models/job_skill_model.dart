/// Skill associated with a job (from GET /jobs/{id}/skills).
class JobSkillModel {
  final int skillId;
  final String skillName;
  final String skillType; // "required" or "preferred"

  const JobSkillModel({
    required this.skillId,
    required this.skillName,
    required this.skillType,
  });

  factory JobSkillModel.fromJson(Map<String, dynamic> json) {
    return JobSkillModel(
      skillId: json['skill_id'] ?? json['id'] ?? 0,
      skillName: json['skill_name'] ?? json['name'] ?? '',
      skillType: json['skill_type'] ?? json['type'] ?? 'required',
    );
  }

  bool get isRequired => skillType == 'required';
}
