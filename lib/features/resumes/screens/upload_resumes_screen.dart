import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../main.dart';
import '../data/models/resume_upload_model.dart';

class UploadResumesScreen extends StatefulWidget {
  const UploadResumesScreen({super.key});

  @override
  State<UploadResumesScreen> createState() => _UploadResumesScreenState();
}

class _UploadResumesScreenState extends State<UploadResumesScreen> {
  List<PlatformFile> selectedFiles = [];
  bool uploading = false;
  int uploadedCount = 0;
  final List<String> uploadLog = [];
  int successCount = 0;
  int failCount = 0;

  static const _allowedExtensions = ['pdf', 'doc', 'docx'];

  Future<void> _pickFiles() async {
    try {
      final pickerResult = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: _allowedExtensions,
        allowMultiple: true,
        withData: true, // Required for web — loads file bytes
      );

      if (pickerResult == null) return;

      final validFiles = <PlatformFile>[];
      final rejectedFiles = <String>[];

      for (final file in pickerResult.files) {
        final ext = file.extension?.toLowerCase() ?? '';
        if (!_allowedExtensions.contains(ext)) {
          rejectedFiles.add('${file.name} – Unsupported file type');
        } else if (file.size > 10 * 1024 * 1024) {
          rejectedFiles.add('${file.name} – File too large (max 10MB)');
        } else {
          validFiles.add(file);
        }
      }

      setState(() {
        selectedFiles = validFiles;
        uploadLog.clear();
        successCount = 0;
        failCount = 0;
      });

      if (rejectedFiles.isNotEmpty && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${rejectedFiles.length} file(s) rejected: ${rejectedFiles.first}'),
            backgroundColor: AppColors.warning,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking files: $e')),
      );
    }
  }

  void _removeFile(int index) {
    setState(() => selectedFiles.removeAt(index));
  }

  /// Get the correct MIME type from extension (important for web FilePicker).
  String _mimeType(String ext) {
    switch (ext.toLowerCase()) {
      case 'pdf':
        return 'application/pdf';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      default:
        return 'application/octet-stream';
    }
  }

  Future<void> _upload() async {
    if (selectedFiles.isEmpty) return;

    setState(() {
      uploading = true;
      uploadedCount = 0;
      successCount = 0;
      failCount = 0;
      uploadLog.clear();
    });

    try {
      for (int i = 0; i < selectedFiles.length; i++) {
        final file = selectedFiles[i];
        final ext = file.extension ?? 'pdf';
        final mime = _mimeType(ext);

        try {
          ResumeUploadModel uploadResult;

          if (file.bytes != null) {
            // Web — use bytes with explicit MIME type
            uploadResult = await resumeRepository.uploadResumeBytes(
              bytes: file.bytes!,
              fileName: file.name,
              mimeType: mime,
            );
          } else if (file.path != null) {
            // Mobile / Desktop — use file path
            uploadResult = await resumeRepository.uploadResume(file.path!);
          } else {
            throw Exception('No file data available');
          }

          if (!mounted) return;
          setState(() {
            uploadedCount = i + 1;
            successCount++;
            uploadLog.add(
                '✓ ${file.name} → Candidate #${uploadResult.candidateId} (${uploadResult.textLength ?? 0} chars extracted)');
          });
        } catch (e) {
          if (!mounted) return;
          final errorMsg = e.toString().replaceFirst('Exception: ', '');
          setState(() {
            uploadedCount = i + 1;
            failCount++;
            uploadLog.add('✗ ${file.name} – $errorMsg');
          });
        }
      }

      if (!mounted) return;
      setState(() => uploading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Done: $successCount uploaded, $failCount failed.'),
          backgroundColor:
              failCount == 0 ? AppColors.success : AppColors.warning,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => uploading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Resumes'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Upload drop zone
          InkWell(
            onTap: uploading ? null : _pickFiles,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40),
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.primaryLight,
                  width: 2,
                  style: BorderStyle.solid,
                ),
                borderRadius: BorderRadius.circular(16),
                color: AppColors.primaryLight.withValues(alpha: 0.05),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cloud_upload_outlined,
                      size: 48, color: AppColors.primary),
                  const SizedBox(height: 12),
                  Text('Select Resumes',
                      style: AppTextStyles.label
                          .copyWith(color: AppColors.primary)),
                  const SizedBox(height: 6),
                  Text(
                    'Supported formats: PDF, DOC, DOCX',
                    style: AppTextStyles.caption,
                  ),
                  Text('Max file size: 10MB', style: AppTextStyles.caption),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Selected files list
          if (selectedFiles.isNotEmpty) ...[
            Row(
              children: [
                Text('${selectedFiles.length} file(s) selected',
                    style: AppTextStyles.label),
                const Spacer(),
                TextButton(
                  onPressed: uploading
                      ? null
                      : () => setState(() => selectedFiles.clear()),
                  child: const Text('Clear All'),
                ),
              ],
            ),
            ...selectedFiles.asMap().entries.map((entry) {
              final i = entry.key;
              final file = entry.value;
              final kb = (file.size / 1024).toStringAsFixed(1);
              return ListTile(
                dense: true,
                leading: Icon(
                  file.extension == 'pdf'
                      ? Icons.picture_as_pdf
                      : Icons.description,
                  color: AppColors.primary,
                ),
                title: Text(file.name, style: AppTextStyles.body),
                subtitle: Text('$kb KB'),
                trailing: uploading
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () => _removeFile(i),
                      ),
              );
            }),

            const SizedBox(height: 16),
          ],

          // Upload button
          if (selectedFiles.isNotEmpty)
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton.icon(
                onPressed: uploading ? null : _upload,
                icon: uploading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.upload),
                label: Text(uploading
                    ? 'Uploading $uploadedCount / ${selectedFiles.length}…'
                    : 'Upload ${selectedFiles.length} Resume(s)'),
              ),
            ),

          // Progress bar
          if (uploading) ...[
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: selectedFiles.isEmpty
                  ? 0
                  : uploadedCount / selectedFiles.length,
            ),
          ],

          // Upload log
          if (uploadLog.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text('Upload Results', style: AppTextStyles.sectionHeader),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: uploadLog.map((log) {
                  final isSuccess = log.startsWith('✓');
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      log,
                      style: AppTextStyles.body.copyWith(
                        color: isSuccess ? AppColors.success : AppColors.error,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            // Summary
            if (!uploading) ...[
              const SizedBox(height: 12),
              if (successCount > 0)
                _InfoRow(
                  icon: Icons.check_circle_outline,
                  color: AppColors.success,
                  text:
                      '$successCount resume(s) uploaded and extracted successfully. '
                      'Go to Candidates to view extracted data.',
                ),
              if (failCount > 0)
                _InfoRow(
                  icon: Icons.error_outline,
                  color: AppColors.error,
                  text:
                      '$failCount upload(s) failed. Check the error details above.',
                ),
            ],
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;

  const _InfoRow(
      {required this.icon, required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
                style: AppTextStyles.body.copyWith(color: color)),
          ),
        ],
      ),
    );
  }
}
