import 'models/resume_list_model.dart';
import 'models/resume_upload_model.dart';
import 'resume_remote_data_source.dart';

class ResumeRepository {
  final ResumeRemoteDataSource _dataSource;

  ResumeRepository(this._dataSource);

  Future<List<ResumeListModel>> getResumes() => _dataSource.getResumes();

  Future<void> deleteResume(int resumeId) => _dataSource.deleteResume(resumeId);

  Future<ResumeUploadModel> uploadResume(String filePath) =>
      _dataSource.uploadResume(filePath);

  Future<ResumeUploadModel> uploadResumeBytes({
    required List<int> bytes,
    required String fileName,
    String mimeType = 'application/pdf',
  }) =>
      _dataSource.uploadResumeBytes(
        bytes: bytes,
        fileName: fileName,
        mimeType: mimeType,
      );
}

