import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import 'models/resume_upload_model.dart';

class ResumeRemoteDataSource {
  final ApiClient apiClient;

  ResumeRemoteDataSource(this.apiClient);

  // Backend expects field name "file" (not "resume")
  // Response: {message, resume_id, candidate_id, filename, text_length}
  Future<ResumeUploadModel> uploadResume(String filePath) async {
    final response = await apiClient.uploadFile(
      ApiConstants.uploadResume,
      filePath: filePath,
      fieldName: 'file',
    );

    return ResumeUploadModel.fromJson(response as Map<String, dynamic>);
  }

  Future<ResumeUploadModel> uploadResumeBytes({
    required List<int> bytes,
    required String fileName,
  }) async {
    final response = await apiClient.uploadFileBytes(
      ApiConstants.uploadResume,
      fileBytes: bytes,
      fileName: fileName,
      fieldName: 'file',
    );

    return ResumeUploadModel.fromJson(response as Map<String, dynamic>);
  }
}
