class CandidateModel {
  final int candidateId;
  final String fullName;
  final String? emailAddress;
  final String? phone;

  const CandidateModel({
    required this.candidateId,
    required this.fullName,
    this.emailAddress,
    this.phone,
  });

  factory CandidateModel.fromJson(Map<String, dynamic> json) {
    return CandidateModel(
      candidateId: json['candidate_id'] ?? json['id'] ?? 0,
      fullName: json['full_name'] ?? json['name'] ?? '',
      emailAddress: json['email_address'] ?? json['email'],
      phone: json['phone']?.toString(),
    );
  }
}
