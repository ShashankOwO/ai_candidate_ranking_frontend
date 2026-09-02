import 'chatbot_remote_data_source.dart';
import 'models/chat_message_model.dart';
import 'models/chart_data_model.dart';

class ChatbotRepository {
  final ChatbotRemoteDataSource remoteDataSource;
  String? _sessionId;

  ChatbotRepository(this.remoteDataSource);

  String? get currentSessionId => _sessionId;

  void setSessionId(String? id) {
    _sessionId = id;
  }

  Future<ChatMessageModel> sendMessage(String text) async {
    final res = await remoteDataSource.sendMessage(
      message: text,
      sessionId: _sessionId,
    );

    _sessionId = res['session_id'] as String?;

    ChartDataModel? chart;
    if (res['chart_data'] != null && res['chart_data'] is Map<String, dynamic>) {
      chart = ChartDataModel.fromJson(res['chart_data'] as Map<String, dynamic>);
    }

    return ChatMessageModel(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      text: res['reply'] as String? ?? '',
      isUser: false,
      timestamp: DateTime.now(),
      chartData: chart,
      toolCalled: res['tool_called'] as String?,
    );
  }

  Future<List<ChatMessageModel>> getHistory() async {
    if (_sessionId == null) return [];
    try {
      final res = await remoteDataSource.getHistory(_sessionId!);
      final rawList = res['messages'] as List<dynamic>? ?? [];
      return rawList
          .map((e) => ChatMessageModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> clearSession() async {
    if (_sessionId != null) {
      try {
        await remoteDataSource.clearSession(_sessionId!);
      } catch (_) {}
      _sessionId = null;
    }
  }
}
