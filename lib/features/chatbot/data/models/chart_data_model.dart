class ChartItemModel {
  final String label;
  final int value;
  final int? candidateId;
  final String? email;

  ChartItemModel({
    required this.label,
    required this.value,
    this.candidateId,
    this.email,
  });

  factory ChartItemModel.fromJson(Map<String, dynamic> json) {
    return ChartItemModel(
      label: json['label'] as String? ?? 'Unknown',
      value: (json['value'] as num?)?.toInt() ?? 0,
      candidateId: (json['candidate_id'] as num?)?.toInt(),
      email: json['email'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'label': label,
      'value': value,
    };
    if (candidateId != null) map['candidate_id'] = candidateId;
    if (email != null) map['email'] = email;
    return map;
  }
}

class ChartSummaryModel {
  final int totalCandidates;
  final int totalResumes;
  final String? mostActiveCandidate;
  final int maxResumes;
  final double averageResumesPerCandidate;

  ChartSummaryModel({
    required this.totalCandidates,
    required this.totalResumes,
    this.mostActiveCandidate,
    required this.maxResumes,
    required this.averageResumesPerCandidate,
  });

  factory ChartSummaryModel.fromJson(Map<String, dynamic> json) {
    return ChartSummaryModel(
      totalCandidates: (json['total_candidates'] as num?)?.toInt() ?? 0,
      totalResumes: (json['total_resumes'] as num?)?.toInt() ?? 0,
      mostActiveCandidate: json['most_active_candidate'] as String?,
      maxResumes: (json['max_resumes'] as num?)?.toInt() ?? 0,
      averageResumesPerCandidate:
          (json['average_resumes_per_candidate'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'total_candidates': totalCandidates,
      'total_resumes': totalResumes,
      'max_resumes': maxResumes,
      'average_resumes_per_candidate': averageResumesPerCandidate,
    };
    if (mostActiveCandidate != null) {
      map['most_active_candidate'] = mostActiveCandidate;
    }
    return map;
  }
}

class ChartDataModel {
  final String chartType;
  final String title;
  final List<ChartItemModel> items;
  final ChartSummaryModel? summary;

  ChartDataModel({
    this.chartType = 'bar',
    required this.title,
    required this.items,
    this.summary,
  });

  factory ChartDataModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? [];
    return ChartDataModel(
      chartType: json['chart_type'] as String? ?? 'bar',
      title: json['title'] as String? ?? 'Candidate Resumes',
      items: rawItems
          .map((e) => ChartItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      summary: json['summary'] != null
          ? ChartSummaryModel.fromJson(json['summary'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'chart_type': chartType,
      'title': title,
      'items': items.map((e) => e.toJson()).toList(),
    };
    if (summary != null) {
      map['summary'] = summary!.toJson();
    }
    return map;
  }
}
