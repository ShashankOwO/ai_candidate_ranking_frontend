import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import 'models/resume_upload_model.dart';

class ResumeRemoteDataSource {
  final ApiClient apiClient;

  ResumeRemoteDataSource(this.apiClient);

  /// Upload via file path (mobile/desktop).
  Future<ResumeUploadModel> uploadResume(String filePath) async {
    final response = await apiClient.uploadFile(
      ApiConstants.uploadResume,
      filePath: filePath,
      fieldName: 'file',
    );
    return ResumeUploadModel.fromJson(response as Map<String, dynamic>);
  }

  /// Upload via bytes (web). Explicitly sets MIME type so the backend
  /// content_type check (application/pdf etc.) passes correctly.
  Future<ResumeUploadModel> uploadResumeBytes({
    required List<int> bytes,
    required String fileName,
    String mimeType = 'application/pdf',
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${apiClient.baseUrl}${ApiConstants.uploadResume}'),
    );

    if (apiClient.token != null) {
      request.headers['Authorization'] = 'Bearer ${apiClient.token}';
    }

    // Parse mimeType → MediaType (e.g. "application/pdf" → type=application, subtype=pdf)
    final parts = mimeType.split('/');
    final mediaType = MediaType(parts[0], parts.length > 1 ? parts[1] : '*');

    request.files.add(
      http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: fileName,
        contentType: mediaType,
      ),
    );

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return ResumeUploadModel.fromJson(data);
    }

    String detail = 'Upload failed (${response.statusCode})';
    try {
      final err = jsonDecode(response.body);
      if (err is Map && err['detail'] != null) {
        detail = err['detail'].toString();
      }
    } catch (_) {}
    throw Exception(detail);
  }
}
