import 'models/resume_upload_model.dart';
import 'resume_remote_data_source.dart';

class ResumeRepository {
  final ResumeRemoteDataSource _dataSource;

  ResumeRepository(this._dataSource);

  Future<ResumeUploadModel> uploadResume(String filePath) =>
      _dataSource.uploadResume(filePath);

  Future<ResumeUploadModel> uploadResumeBytes({
    required List<int> bytes,
    required String fileName,
  }) =>
      _dataSource.uploadResumeBytes(bytes: bytes, fileName: fileName);
}
