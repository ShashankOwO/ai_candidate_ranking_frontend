class ProjectModel {
  final String? id;
  final String? candidateId;
  final String name;
  final String? description;
  final String? technologies;
  final String? url;
  final String? startDate;
  final String? endDate;

  const ProjectModel({
    this.id,
    this.candidateId,
    required this.name,
    this.description,
    this.technologies,
    this.url,
    this.startDate,
    this.endDate,
  });

  factory ProjectModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return ProjectModel(
      id: _stringValue(
        json['id'] ?? json['project_id'],
      ),
      candidateId: _stringValue(
        json['candidate_id'] ?? json['candidateId'],
      ),
      name: _stringValue(json['name']) ?? '',
      description: _stringValue(
        json['description'],
      ),
      technologies: _stringValue(
        json['technologies'] ?? json['tech_stack'],
      ),
      url: _stringValue(
        json['url'] ?? json['project_url'],
      ),
      startDate: _stringValue(
        json['start_date'] ?? json['startDate'],
      ),
      endDate: _stringValue(
        json['end_date'] ?? json['endDate'],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (candidateId != null) 'candidate_id': candidateId,
      'name': name,
      if (description != null) 'description': description,
      if (technologies != null) 'technologies': technologies,
      if (url != null) 'url': url,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
    };
  }

  static String? _stringValue(dynamic value) {
    if (value == null) return null;
    return value.toString();
  }
}