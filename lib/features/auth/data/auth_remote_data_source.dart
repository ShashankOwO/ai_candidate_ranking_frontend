import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import 'models/login_response_model.dart';
import 'models/user_model.dart';

class AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSource(this.apiClient);

  Future<UserModel> register(Map<String, dynamic> data) async {
    final response = await apiClient.post(
      ApiConstants.register,
      body: data,
    );

    return UserModel.fromJson(response as Map<String, dynamic>);
  }

  Future<LoginResponseModel> login(Map<String, dynamic> data) async {
    final response = await apiClient.post(
      ApiConstants.login,
      body: data,
    );

    return LoginResponseModel.fromJson(response as Map<String, dynamic>);
  }

  Future<UserModel> getCurrentUser() async {
    final response = await apiClient.get(ApiConstants.me);

    return UserModel.fromJson(response as Map<String, dynamic>);
  }
}
