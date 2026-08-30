class CandidateModel {
  final String? id;
  final String firstName;
  final String lastName;
  final String email;
  final String? phone;
  final String? location;
  final String? summary;
  final String? status;
  final double? rankScore;

  const CandidateModel({
    this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phone,
    this.location,
    this.summary,
    this.status,
    this.rankScore,
  });

  String get fullName => '$firstName $lastName';

  factory CandidateModel.fromJson(Map<String, dynamic> json) {
    return CandidateModel(
      id: _stringValue(json['id'] ?? json['candidate_id']),
      firstName: _stringValue(
            json['first_name'] ?? json['firstName'],
          ) ??
          '',
      lastName: _stringValue(
            json['last_name'] ?? json['lastName'],
          ) ??
          '',
      email: _stringValue(json['email']) ?? '',
      phone: _stringValue(json['phone']),
      location: _stringValue(json['location']),
      summary: _stringValue(
        json['summary'] ?? json['bio'],
      ),
      status: _stringValue(json['status']),
      rankScore: _doubleValue(
        json['rank_score'] ?? json['rankScore'],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      if (phone != null) 'phone': phone,
      if (location != null) 'location': location,
      if (summary != null) 'summary': summary,
      if (status != null) 'status': status,
      if (rankScore != null) 'rank_score': rankScore,
    };
  }

  CandidateModel copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? location,
    String? summary,
    String? status,
    double? rankScore,
  }) {
    return CandidateModel(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      location: location ?? this.location,
      summary: summary ?? this.summary,
      status: status ?? this.status,
      rankScore: rankScore ?? this.rankScore,
    );
  }

  static String? _stringValue(dynamic value) {
    if (value == null) return null;
    return value.toString();
  }

  static double? _doubleValue(dynamic value) {
    if (value == null) return null;

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value.toString());
  }
}