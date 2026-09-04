import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import 'models/chat_models.dart';

class ChatbotRemoteDataSource {
  final ApiClient apiClient;

  ChatbotRemoteDataSource(this.apiClient);

  Future<ChatMessageModel> sendMessage({
    required String message,
    String? sessionId,
  }) async {
    final response = await apiClient.post(
      ApiConstants.chatbotMessage,
      body: {
        'message': message,
        'session_id': ?sessionId,
      },
    );

    if (response is Map<String, dynamic>) {
      return ChatMessageModel.fromJson(response);
    }
    throw Exception('Invalid chatbot response format');
  }

  Future<List<ChatMessageModel>> getHistory(String sessionId) async {
    final response = await apiClient.get(ApiConstants.chatbotHistory(sessionId));
    if (response is Map<String, dynamic> && response['messages'] is List) {
      final list = response['messages'] as List;
      return list
          .whereType<Map<String, dynamic>>()
          .map((m) => ChatMessageModel.fromJson(m))
          .toList();
    }
    return [];
  }

  Future<bool> resetSession(String sessionId) async {
    final response = await apiClient.delete(ApiConstants.chatbotSession(sessionId));
    if (response is Map<String, dynamic>) {
      return response['cleared'] == true;
    }
    return false;
  }
}
