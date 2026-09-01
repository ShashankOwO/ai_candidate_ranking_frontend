import '../../../core/network/api_client.dart';
import '../../../core/network/auth_storage.dart';
import 'auth_remote_data_source.dart';
import 'models/login_response_model.dart';
import 'models/user_model.dart';

class AuthRepository {
  final AuthRemoteDataSource _dataSource;
  final AuthStorage _authStorage;
  final ApiClient _apiClient;

  AuthRepository(this._dataSource, this._authStorage, this._apiClient);

  Future<UserModel> register({
    required String username,
    required String email,
    required String password,
  }) async {
    return _dataSource.register({
      'username': username,
      'email': email,
      'password': password,
    });
  }

  Future<LoginResponseModel> login({
    required String username,
    required String password,
  }) async {
    final response = await _dataSource.login({
      'username_or_email': username,
      'password': password,
    });

    // Store token and set on API client.
    await _authStorage.saveToken(response.accessToken);
    await _authStorage.saveUsername(username);
    _apiClient.setToken(response.accessToken);

    return response;
  }

  Future<UserModel> getCurrentUser() async {
    return _dataSource.getCurrentUser();
  }

  Future<void> logout() async {
    _apiClient.clearToken();
    await _authStorage.clearAll();
  }

  bool get isLoggedIn => _apiClient.token != null;
}
