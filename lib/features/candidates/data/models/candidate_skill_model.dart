// Backend: { skill_id, skill_name, skill_category, proficiency, years_experience }
// years_experience is float in the backend schema
class CandidateSkillModel {
  final int skillId;
  final String skillName;
  final String? skillCategory;
  final String? proficiency;
  final double? yearsExperience; // float in backend

  const CandidateSkillModel({
    required this.skillId,
    required this.skillName,
    this.skillCategory,
    this.proficiency,
    this.yearsExperience,
  });

  factory CandidateSkillModel.fromJson(Map<String, dynamic> json) {
    return CandidateSkillModel(
      skillId: json['skill_id'] ?? json['id'] ?? 0,
      skillName: json['skill_name'] ?? json['name'] ?? '',
      skillCategory: json['skill_category']?.toString(),
      proficiency: json['proficiency']?.toString(),
      yearsExperience: json['years_experience'] is num
          ? (json['years_experience'] as num).toDouble()
          : double.tryParse('${json['years_experience'] ?? ''}'),
    );
  }
}
