import 'chatbot_remote_data_source.dart';
import 'models/chat_models.dart';

class ChatbotRepository {
  final ChatbotRemoteDataSource _remoteDataSource;

  ChatbotRepository(this._remoteDataSource);

  Future<ChatMessageModel> sendMessage({
    required String message,
    String? sessionId,
  }) =>
      _remoteDataSource.sendMessage(
        message: message,
        sessionId: sessionId,
      );

  Future<List<ChatMessageModel>> getHistory(String sessionId) =>
      _remoteDataSource.getHistory(sessionId);

  Future<bool> resetSession(String sessionId) =>
      _remoteDataSource.resetSession(sessionId);
}
