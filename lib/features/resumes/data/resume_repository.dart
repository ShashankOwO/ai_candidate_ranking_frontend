import 'models/resume_model.dart';
import 'models/resume_upload_model.dart';
import 'resume_remote_data_source.dart';

class ResumeRepository {
  final ResumeRemoteDataSource _dataSource;

  ResumeRepository(this._dataSource);

  Future<List<ResumeModel>> getResumes() => _dataSource.getResumes();

  Future<ResumeModel> getResumeById(int id) => _dataSource.getResumeById(id);

  Future<void> deleteResume(int id) => _dataSource.deleteResume(id);

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
