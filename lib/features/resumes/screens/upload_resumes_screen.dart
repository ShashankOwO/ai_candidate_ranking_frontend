import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../main.dart';
import '../../candidates/screens/candidate_detail_screen.dart';
import '../data/models/resume_model.dart';
import '../data/models/resume_upload_model.dart';

class UploadResumesScreen extends StatefulWidget {
  final int initialTabIndex;

  const UploadResumesScreen({
    super.key,
    this.initialTabIndex = 0,
  });

  @override
  State<UploadResumesScreen> createState() => _UploadResumesScreenState();
}

class _UploadResumesScreenState extends State<UploadResumesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Upload state
  List<PlatformFile> selectedFiles = [];
  bool uploading = false;
  int uploadedCount = 0;
  final List<String> uploadLog = [];
  int successCount = 0;
  int failCount = 0;

  // Resumes list state
  List<ResumeModel> resumes = [];
  bool loadingResumes = true;
  String? resumesError;
  String searchQuery = '';
  bool sortNewestFirst = true;

  static const _allowedExtensions = ['pdf', 'doc', 'docx'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
    _loadResumes();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadResumes() async {
    setState(() {
      loadingResumes = true;
      resumesError = null;
    });

    try {
      final fetched = await resumeRepository.getResumes();
      if (!mounted) return;
      setState(() {
        resumes = fetched;
        loadingResumes = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        resumesError = e.toString().replaceFirst('Exception: ', '');
        loadingResumes = false;
      });
    }
  }

  // ── Upload Methods ─────────────────────────────────────────

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
            content: Text(
                '${rejectedFiles.length} file(s) rejected: ${rejectedFiles.first}'),
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
            uploadResult = await resumeRepository.uploadResumeBytes(
              bytes: file.bytes!,
              fileName: file.name,
              mimeType: mime,
            );
          } else if (file.path != null) {
            uploadResult = await resumeRepository.uploadResume(file.path!);
          } else {
            throw Exception('No file data available');
          }

          if (!mounted) return;
          setState(() {
            uploadedCount = i + 1;
            successCount++;
            uploadLog.add(
              '✓ ${file.name} → Candidate #${uploadResult.candidateId} (${uploadResult.textLength ?? 0} chars extracted)',
            );
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

      // Refresh resumes list after upload
      _loadResumes();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Done: $successCount uploaded, $failCount failed.'),
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

  // ── Delete Resume ──────────────────────────────────────────

  Future<void> _deleteResume(ResumeModel resume) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Resume'),
        content: Text(
          'Are you sure you want to delete "${resume.fileName}"?'
          '${resume.candidateName != null ? '\n(Associated candidate: ${resume.candidateName})' : ''}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await resumeRepository.deleteResume(resume.resumeId);
      await _loadResumes();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('"${resume.fileName}" deleted'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete resume: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  // ── Preview Extracted Text Dialog ──────────────────────────

  void _showTextPreview(ResumeModel resume) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.description_outlined, color: AppColors.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                resume.fileName,
                style: AppTextStyles.label,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: resume.rawText != null && resume.rawText!.isNotEmpty
              ? SingleChildScrollView(
                  child: SelectableText(
                    resume.rawText!,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                )
              : const Center(
                  child: Text('No extracted text available for this resume.'),
                ),
        ),
        actions: [
          if (resume.candidateId > 0)
            TextButton.icon(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CandidateDetailScreen(
                      candidateId: resume.candidateId,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.person),
              label: const Text('View Candidate'),
            ),
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // ── Date-wise Grouping ─────────────────────────────────────

  List<ResumeModel> get _filteredResumes {
    var list = resumes;
    if (searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      list = list.where((r) {
        final matchesFile = r.fileName.toLowerCase().contains(q);
        final matchesCandidate =
            (r.candidateName ?? '').toLowerCase().contains(q);
        final matchesEmail = (r.candidateEmail ?? '').toLowerCase().contains(q);
        return matchesFile || matchesCandidate || matchesEmail;
      }).toList();
    }

    list = List.of(list);
    list.sort((a, b) {
      final dateA = a.uploadedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final dateB = b.uploadedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return sortNewestFirst ? dateB.compareTo(dateA) : dateA.compareTo(dateB);
    });

    return list;
  }

  Map<String, List<ResumeModel>> get _groupedResumes {
    final Map<String, List<ResumeModel>> grouped = {};
    for (final resume in _filteredResumes) {
      final key = resume.dateGroupKey;
      grouped.putIfAbsent(key, () => []).add(resume);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resumes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _loadResumes,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              icon: const Icon(Icons.folder_shared_outlined),
              text: 'Uploaded Resumes (${resumes.length})',
            ),
            const Tab(
              icon: Icon(Icons.cloud_upload_outlined),
              text: 'Upload Resumes',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildUploadedResumesTab(),
          _buildUploadTab(),
        ],
      ),
    );
  }

  // ── Tab 1: Uploaded Resumes (Date-wise) ────────────────────

  Widget _buildUploadedResumesTab() {
    if (loadingResumes) {
      return const Center(child: CircularProgressIndicator());
    }

    if (resumesError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: 16),
              Text(
                'Failed to load resumes: $resumesError',
                style: AppTextStyles.body,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _loadResumes,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (resumes.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.upload_file_outlined,
                  size: 40,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 20),
              Text('No Resumes Uploaded Yet', style: AppTextStyles.title),
              const SizedBox(height: 8),
              Text(
                'Upload resumes in PDF or Word format to automatically extract candidate details and start ranking.',
                style: AppTextStyles.bodySecondary,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => _tabController.animateTo(1),
                icon: const Icon(Icons.cloud_upload_outlined),
                label: const Text('Upload Resumes Now'),
              ),
            ],
          ),
        ),
      );
    }

    final grouped = _groupedResumes;

    return RefreshIndicator(
      onRefresh: _loadResumes,
      child: Column(
        children: [
          // Filter & Search bar
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            color: AppColors.surface,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search by file or candidate name…',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onChanged: (v) => setState(() => searchQuery = v),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.outlined(
                  tooltip: sortNewestFirst
                      ? 'Sorting: Newest First'
                      : 'Sorting: Oldest First',
                  icon: Icon(
                    sortNewestFirst
                        ? Icons.arrow_downward
                        : Icons.arrow_upward,
                    size: 20,
                  ),
                  onPressed: () =>
                      setState(() => sortNewestFirst = !sortNewestFirst),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Date-wise list
          Expanded(
            child: grouped.isEmpty
                ? Center(
                    child: Text(
                      'No resumes match "$searchQuery"',
                      style: AppTextStyles.bodySecondary,
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    itemCount: grouped.length,
                    itemBuilder: (context, index) {
                      final dateKey = grouped.keys.elementAt(index);
                      final items = grouped[dateKey]!;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Date Header
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.calendar_today_outlined,
                                  size: 16,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  dateKey,
                                  style: AppTextStyles.label.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryLight
                                        .withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${items.length} ${items.length == 1 ? 'file' : 'files'}',
                                    style: AppTextStyles.caption.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Resumes in this date group
                          ...items.map((resume) => _buildResumeCard(resume)),
                          const SizedBox(height: 8),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildResumeCard(ResumeModel resume) {
    final isPdf = resume.fileExtension == 'PDF';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showTextPreview(resume),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // File Icon / Badge
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isPdf
                      ? Colors.red.withValues(alpha: 0.1)
                      : Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Icon(
                    isPdf ? Icons.picture_as_pdf : Icons.description,
                    color: isPdf ? Colors.red : Colors.blue,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      resume.fileName,
                      style: AppTextStyles.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Candidate Info
                    if (resume.candidateName != null &&
                        resume.candidateName!.isNotEmpty)
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CandidateDetailScreen(
                                candidateId: resume.candidateId,
                              ),
                            ),
                          );
                        },
                        child: Row(
                          children: [
                            const Icon(
                              Icons.person_outline,
                              size: 14,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                resume.candidateName!,
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Text(
                        'Candidate #${resume.candidateId}',
                        style: AppTextStyles.caption,
                      ),

                    const SizedBox(height: 4),

                    // Metadata row: Time & Size
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 12,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          resume.timeOnly.isNotEmpty
                              ? resume.timeOnly
                              : resume.formattedDateTime,
                          style: AppTextStyles.caption,
                        ),
                        const SizedBox(width: 12),
                        const Icon(
                          Icons.storage,
                          size: 12,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          resume.formattedFileSize,
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Actions Popup Menu
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, size: 20),
                onSelected: (action) {
                  if (action == 'preview') {
                    _showTextPreview(resume);
                  } else if (action == 'candidate') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CandidateDetailScreen(
                          candidateId: resume.candidateId,
                        ),
                      ),
                    );
                  } else if (action == 'delete') {
                    _deleteResume(resume);
                  }
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(
                    value: 'preview',
                    child: ListTile(
                      dense: true,
                      leading: Icon(Icons.visibility_outlined),
                      title: Text('View Text'),
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'candidate',
                    child: ListTile(
                      dense: true,
                      leading: Icon(Icons.person_outline),
                      title: Text('View Candidate'),
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: ListTile(
                      dense: true,
                      leading: Icon(Icons.delete_outline, color: AppColors.error),
                      title: Text(
                        'Delete Resume',
                        style: TextStyle(color: AppColors.error),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Tab 2: Upload Tab ──────────────────────────────────────

  Widget _buildUploadTab() {
    return ListView(
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
                Icon(
                  Icons.cloud_upload_outlined,
                  size: 48,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 12),
                Text(
                  'Select Resumes to Upload',
                  style: AppTextStyles.label.copyWith(color: AppColors.primary),
                ),
                const SizedBox(height: 6),
                Text(
                  'Supported formats: PDF, DOC, DOCX',
                  style: AppTextStyles.caption,
                ),
                Text('Max file size: 10MB per file',
                    style: AppTextStyles.caption),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Selected files list
        if (selectedFiles.isNotEmpty) ...[
          Row(
            children: [
              Text(
                '${selectedFiles.length} file(s) selected',
                style: AppTextStyles.label,
              ),
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
            final ext = file.extension?.toLowerCase() ?? 'pdf';
            final isPdf = ext == 'pdf';

            return ListTile(
              dense: true,
              leading: Icon(
                isPdf ? Icons.picture_as_pdf : Icons.description,
                color: isPdf ? Colors.red : AppColors.primary,
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
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.upload),
              label: Text(
                uploading
                    ? 'Uploading $uploadedCount / ${selectedFiles.length}…'
                    : 'Upload ${selectedFiles.length} Resume(s)',
              ),
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

        // Upload log & Summary
        if (uploadLog.isNotEmpty) ...[
          const SizedBox(height: 20),
          Row(
            children: [
              Text('Upload Results', style: AppTextStyles.sectionHeader),
              const Spacer(),
              if (!uploading && successCount > 0)
                FilledButton.tonalIcon(
                  onPressed: () => _tabController.animateTo(0),
                  icon: const Icon(Icons.list_alt, size: 18),
                  label: const Text('View All Resumes'),
                ),
            ],
          ),
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

          // Summary badges
          if (!uploading) ...[
            const SizedBox(height: 12),
            if (successCount > 0)
              _InfoRow(
                icon: Icons.check_circle_outline,
                color: AppColors.success,
                text:
                    '$successCount resume(s) uploaded successfully with date & time recorded. '
                    'Check "Uploaded Resumes" tab or Candidates section.',
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
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;

  const _InfoRow({
    required this.icon,
    required this.color,
    required this.text,
  });

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
            child: Text(
              text,
              style: AppTextStyles.body.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}
