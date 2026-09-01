class CandidateSkillModel {
  final int skillId;
  final String skillName;
  final String? proficiency;
  final int? yearsExperience;

  const CandidateSkillModel({
    required this.skillId,
    required this.skillName,
    this.proficiency,
    this.yearsExperience,
  });

  factory CandidateSkillModel.fromJson(Map<String, dynamic> json) {
    return CandidateSkillModel(
      skillId: json['skill_id'] ?? json['id'] ?? 0,
      skillName: json['skill_name'] ?? json['name'] ?? '',
      proficiency: json['proficiency']?.toString(),
      yearsExperience: json['years_experience'] is int
          ? json['years_experience']
          : int.tryParse('${json['years_experience'] ?? ''}'),
    );
  }
}
