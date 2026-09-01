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

      // Validate files
      final validFiles = <PlatformFile>[];
      final rejectedFiles = <String>[];

      for (final file in pickerResult.files) {
        final ext = file.extension?.toLowerCase() ?? '';
        if (!_allowedExtensions.contains(ext)) {
          rejectedFiles.add('${file.name} – Unsupported file type');
        } else if (file.size > 10 * 1024 * 1024) {
          // 10MB limit
          rejectedFiles.add('${file.name} – File too large (max 10MB)');
        } else {
          validFiles.add(file);
        }
      }

      setState(() {
        selectedFiles = validFiles;
      });

      if (rejectedFiles.isNotEmpty && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${rejectedFiles.length} file(s) rejected'),
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

  Future<void> _upload() async {
    if (selectedFiles.isEmpty) return;

    setState(() {
      uploading = true;
      uploadedCount = 0;
      uploadLog.clear();
    });

    try {
      // Upload files one by one for progress tracking.
      for (int i = 0; i < selectedFiles.length; i++) {
        final file = selectedFiles[i];

        try {
          ResumeUploadModel uploadResult;

          if (file.path != null) {
            // Mobile / Desktop — use file path
            uploadResult =
                await resumeRepository.uploadResume(file.path!);
          } else if (file.bytes != null) {
            // Web — use bytes
            uploadResult = await resumeRepository.uploadResumeBytes(
              bytes: file.bytes!,
              fileName: file.name,
            );
          } else {
            throw Exception('No file data available');
          }

          if (!mounted) return;
          setState(() {
            uploadedCount = i + 1;
            uploadLog.add('✓ ${file.name} → candidate #${uploadResult.candidateId}');
          });
        } catch (e) {
          if (!mounted) return;
          setState(() {
            uploadedCount = i + 1;
            uploadLog.add('✗ ${file.name} – Failed');
          });
        }
      }

      if (!mounted) return;

      setState(() => uploading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Upload complete. $uploadedCount files processed.'),
          backgroundColor: AppColors.success,
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
          // Upload area
          InkWell(
            onTap: uploading ? null : _pickFiles,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  width: 2,
                  style: BorderStyle.solid,
                ),
                borderRadius: BorderRadius.circular(16),
                color: AppColors.primaryLight.withValues(alpha: 0.05),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.cloud_upload_outlined,
                    size: 56,
                    color: AppColors.primary.withValues(alpha: 0.7),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Select Resumes',
                    style: AppTextStyles.sectionHeader
                        .copyWith(color: AppColors.primary),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Supported formats: PDF, DOC, DOCX\nMax file size: 10MB',
                    style: AppTextStyles.bodySecondary,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Selected files
          if (selectedFiles.isNotEmpty) ...[
            Row(
              children: [
                Text(
                  '${selectedFiles.length} file(s) selected',
                  style: AppTextStyles.label,
                ),
                const Spacer(),
                if (!uploading)
                  TextButton(
                    onPressed: () =>
                        setState(() => selectedFiles.clear()),
                    child: const Text('Clear All'),
                  ),
              ],
            ),
            const SizedBox(height: 8),

            ...selectedFiles.asMap().entries.map(
                  (entry) => Card(
                    margin: const EdgeInsets.only(bottom: 6),
                    child: ListTile(
                      dense: true,
                      leading: const Icon(Icons.description,
                          color: AppColors.info),
                      title: Text(
                        entry.value.name,
                        style: AppTextStyles.body,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        '${(entry.value.size / 1024).toStringAsFixed(1)} KB',
                        style: AppTextStyles.caption,
                      ),
                      trailing: uploading
                          ? null
                          : IconButton(
                              icon: const Icon(Icons.close, size: 18),
                              onPressed: () =>
                                  _removeFile(entry.key),
                            ),
                    ),
                  ),
                ),

            const SizedBox(height: 16),

            // Upload button
            SizedBox(
              height: 52,
              child: FilledButton.icon(
                onPressed: uploading ? null : _upload,
                icon: uploading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.upload),
                label: Text(
                  uploading
                      ? 'Uploading... $uploadedCount / ${selectedFiles.length}'
                      : 'Upload ${selectedFiles.length} Resume(s)',
                ),
              ),
            ),
          ],

          // Progress
          if (uploading) ...[
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: selectedFiles.isEmpty
                  ? 0
                  : uploadedCount / selectedFiles.length,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 8),
            Text(
              'Processing resumes... $uploadedCount / ${selectedFiles.length}',
              style: AppTextStyles.bodySecondary,
            ),
          ],

          // Upload log
          if (uploadLog.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text('Upload Results', style: AppTextStyles.sectionHeader),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: uploadLog
                      .map((log) => Padding(
                            padding:
                                const EdgeInsets.symmetric(vertical: 4),
                            child: Text(
                              log,
                              style: TextStyle(
                                fontSize: 13,
                                color: log.startsWith('✓')
                                    ? AppColors.success
                                    : AppColors.error,
                              ),
                            ),
                          ))
                      .toList(),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
