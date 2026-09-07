import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';

class ChatbotRemoteDataSource {
  final ApiClient apiClient;

  ChatbotRemoteDataSource(this.apiClient);

  Future<Map<String, dynamic>> sendMessage({
    required String message,
    String? sessionId,
  }) async {
    final body = <String, dynamic>{
      'message': message,
    };
    if (sessionId != null) {
      body['session_id'] = sessionId;
    }
    final response = await apiClient.post(
      ApiConstants.chatbotMessage,
      body: body,
    );
    return response as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getHistory(String sessionId) async {
    final response = await apiClient.get(ApiConstants.chatbotHistory(sessionId));
    return response as Map<String, dynamic>;
  }

  Future<void> clearSession(String sessionId) async {
    await apiClient.delete(ApiConstants.chatbotSession(sessionId));
  }
}
