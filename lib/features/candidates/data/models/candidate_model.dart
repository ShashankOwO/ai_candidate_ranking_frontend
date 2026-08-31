// Backend CandidateResponse:
// { candidate_id, user_id, full_name, contact_no, email_address }
class CandidateModel {
  final int candidateId;
  final String fullName;
  final String? emailAddress;
  final String? contactNo; // maps to contact_no in backend

  const CandidateModel({
    required this.candidateId,
    required this.fullName,
    this.emailAddress,
    this.contactNo,
  });

  factory CandidateModel.fromJson(Map<String, dynamic> json) {
    return CandidateModel(
      candidateId: json['candidate_id'] ?? json['id'] ?? 0,
      fullName: json['full_name'] ?? json['name'] ?? '',
      emailAddress: json['email_address'] ?? json['email'],
      contactNo: json['contact_no']?.toString() ?? json['phone']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'full_name': fullName,
        if (contactNo != null) 'contact_no': contactNo,
        if (emailAddress != null) 'email_address': emailAddress,
      };
}
