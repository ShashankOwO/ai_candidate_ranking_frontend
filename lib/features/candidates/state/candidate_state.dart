import '../data/models/candidate_model.dart';

enum CandidateStatus {
  initial,
  loading,
  success,
  empty,
  error,
}

class CandidateState {
  final CandidateStatus status;
  final List<CandidateModel> candidates;
  final String? errorMessage;

  const CandidateState({
    this.status = CandidateStatus.initial,
    this.candidates = const [],
    this.errorMessage,
  });

  CandidateState copyWith({
    CandidateStatus? status,
    List<CandidateModel>? candidates,
    String? errorMessage,
  }) {
    return CandidateState(
      status: status ?? this.status,
      candidates: candidates ?? this.candidates,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}