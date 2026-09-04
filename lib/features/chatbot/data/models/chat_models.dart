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
      label: json['label']?.toString() ?? 'Unknown',
      value: (json['value'] is num) ? (json['value'] as num).toInt() : 0,
      candidateId: json['candidate_id'] as int?,
      email: json['email']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'label': label,
    'value': value,
    'candidate_id': candidateId,
    'email': email,
  };
}

class ChartSummaryModel {
  final int totalCandidates;
  final int totalResumes;
  final String? mostActiveCandidate;
  final int maxResumes;
  final double averageResumesPerCandidate;

  ChartSummaryModel({
    this.totalCandidates = 0,
    this.totalResumes = 0,
    this.mostActiveCandidate,
    this.maxResumes = 0,
    this.averageResumesPerCandidate = 0.0,
  });

  factory ChartSummaryModel.fromJson(Map<String, dynamic> json) {
    return ChartSummaryModel(
      totalCandidates: (json['total_candidates'] is num) ? (json['total_candidates'] as num).toInt() : 0,
      totalResumes: (json['total_resumes'] is num) ? (json['total_resumes'] as num).toInt() : 0,
      mostActiveCandidate: json['most_active_candidate']?.toString(),
      maxResumes: (json['max_resumes'] is num) ? (json['max_resumes'] as num).toInt() : 0,
      averageResumesPerCandidate: (json['average_resumes_per_candidate'] is num)
          ? (json['average_resumes_per_candidate'] as num).toDouble()
          : 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
    'total_candidates': totalCandidates,
    'total_resumes': totalResumes,
    'most_active_candidate': mostActiveCandidate,
    'max_resumes': maxResumes,
    'average_resumes_per_candidate': averageResumesPerCandidate,
  };
}

class ChartDataModel {
  final String chartType;
  final String title;
  final List<ChartItemModel> items;
  final ChartSummaryModel? summary;

  ChartDataModel({
    this.chartType = 'bar',
    this.title = 'Candidate Resumes',
    this.items = const [],
    this.summary,
  });

  factory ChartDataModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? [];
    final items = rawItems
        .whereType<Map<String, dynamic>>()
        .map((i) => ChartItemModel.fromJson(i))
        .toList();

    ChartSummaryModel? summary;
    if (json['summary'] is Map<String, dynamic>) {
      summary = ChartSummaryModel.fromJson(json['summary'] as Map<String, dynamic>);
    }

    return ChartDataModel(
      chartType: json['chart_type']?.toString() ?? 'bar',
      title: json['title']?.toString() ?? 'Candidate Resumes',
      items: items,
      summary: summary,
    );
  }

  Map<String, dynamic> toJson() => {
    'chart_type': chartType,
    'title': title,
    'items': items.map((i) => i.toJson()).toList(),
    'summary': summary?.toJson(),
  };
}

class ChatMessageModel {
  final String role;
  final String content;
  final String timestamp;
  final ChartDataModel? chartData;
  final String? toolCalled;
  final bool isError;

  ChatMessageModel({
    required this.role,
    required this.content,
    required this.timestamp,
    this.chartData,
    this.toolCalled,
    this.isError = false,
  });

  bool get isUser => role == 'user';

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    ChartDataModel? chartData;
    if (json['chart_data'] is Map<String, dynamic>) {
      chartData = ChartDataModel.fromJson(json['chart_data'] as Map<String, dynamic>);
    }

    return ChatMessageModel(
      role: json['role']?.toString() ?? 'assistant',
      content: json['content']?.toString() ?? json['reply']?.toString() ?? '',
      timestamp: json['timestamp']?.toString() ?? DateTime.now().toIso8601String(),
      chartData: chartData,
      toolCalled: json['tool_called']?.toString(),
    );
  }
}
