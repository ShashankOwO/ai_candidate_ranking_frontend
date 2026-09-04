// lib/features/resumes/screens/resumes_list_screen.dart

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../resumes/data/models/resume_list_model.dart';
import '../../../main.dart'; // access resumeRepository
import '../../chatbot/presentation/widgets/floating_chatbot_button.dart';

class ResumesListScreen extends StatefulWidget {
  const ResumesListScreen({super.key});

  @override
  State<ResumesListScreen> createState() => _ResumesListScreenState();
}

class _ResumesListScreenState extends State<ResumesListScreen> {
  List<ResumeListModel> _resumes = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadResumes();
  }

  Future<void> _loadResumes() async {
    setState(() => _loading = true);
    try {
      final list = await resumeRepository.getResumes();
      setState(() => _resumes = list);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load resumes: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _deleteResume(int resumeId) async {
    try {
      await resumeRepository.deleteResume(resumeId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Resume deleted')),
        );
        _loadResumes();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Delete failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Uploaded Resumes')),
      floatingActionButton: const FloatingChatbotButton(),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _resumes.isEmpty
              ? const Center(child: Text('No resumes uploaded yet'))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _resumes.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final r = _resumes[index];
                    return ListTile(
                      leading: const Icon(Icons.description, color: AppColors.primary),
                      title: Text(r.fileName, style: AppTextStyles.body),
                      subtitle: Text(
                        'Candidate: ${r.candidateName}\nUploaded: ${r.uploadedAt.toLocal().toString().split('.').first}',
                        style: AppTextStyles.caption,
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () => _deleteResume(r.resumeId),
                      ),
                    );
                  },
                ),
    );
  }
}
