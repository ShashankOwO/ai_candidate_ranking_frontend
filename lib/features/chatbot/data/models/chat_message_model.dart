import 'chart_data_model.dart';

class ChatMessageModel {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final ChartDataModel? chartData;
  final String? toolCalled;

  ChatMessageModel({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.chartData,
    this.toolCalled,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    final role = json['role'] as String? ?? 'user';
    final isUser = role == 'user';
    final content = json['content'] as String? ?? json['reply'] as String? ?? '';
    final timeStr = json['timestamp'] as String?;
    final time = timeStr != null
        ? (DateTime.tryParse(timeStr) ?? DateTime.now())
        : DateTime.now();

    ChartDataModel? chart;
    if (json['chart_data'] != null && json['chart_data'] is Map<String, dynamic>) {
      chart = ChartDataModel.fromJson(json['chart_data'] as Map<String, dynamic>);
    }

    return ChatMessageModel(
      id: json['id'] as String? ?? DateTime.now().microsecondsSinceEpoch.toString(),
      text: content,
      isUser: isUser,
      timestamp: time,
      chartData: chart,
      toolCalled: json['tool_called'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'id': id,
      'role': isUser ? 'user' : 'assistant',
      'content': text,
      'timestamp': timestamp.toIso8601String(),
    };
    if (chartData != null) map['chart_data'] = chartData!.toJson();
    if (toolCalled != null) map['tool_called'] = toolCalled;
    return map;
  }
}
