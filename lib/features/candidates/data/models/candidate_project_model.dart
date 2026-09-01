class CandidateProjectModel {
  final int? projectId;
  final String projectName;
  final String? description;
  final String? technologies;
  final String? role;
  final String? duration;

  const CandidateProjectModel({
    this.projectId,
    required this.projectName,
    this.description,
    this.technologies,
    this.role,
    this.duration,
  });

  factory CandidateProjectModel.fromJson(Map<String, dynamic> json) {
    return CandidateProjectModel(
      projectId: json['project_id'] is int
          ? json['project_id']
          : int.tryParse('${json['project_id'] ?? ''}'),
      projectName: json['project_name']?.toString() ?? '',
      description: json['description']?.toString(),
      technologies: json['technologies']?.toString(),
      role: json['role']?.toString(),
      duration: json['duration']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'project_name': projectName,
      if (description != null) 'description': description,
      if (technologies != null) 'technologies': technologies,
      if (role != null) 'role': role,
      if (duration != null) 'duration': duration,
    };
  }
}
