
class JobSkillModel {
  final int id;
  final String name;
  final bool required;
  final String? type;

  const JobSkillModel({
    required this.id,
    required this.name,
    required this.required,
    this.type,
  });

  factory JobSkillModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return JobSkillModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(
                '${json['id']}',
              ) ??
              0,
      name: json['name']?.toString() ?? '',
      required: json['required'] == true,
      type: json['type']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'required': required,
      if (type != null) 'type': type,
    };
  }
}

