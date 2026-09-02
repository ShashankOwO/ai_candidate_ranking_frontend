class ResumeModel {
  final int resumeId;
  final int candidateId;
  final String? candidateName;
  final String? candidateEmail;
  final String fileName;
  final String fileType;
  final int fileSize;
  final DateTime? uploadedAt;
  final String? rawText;

  const ResumeModel({
    required this.resumeId,
    required this.candidateId,
    this.candidateName,
    this.candidateEmail,
    required this.fileName,
    required this.fileType,
    required this.fileSize,
    this.uploadedAt,
    this.rawText,
  });

  factory ResumeModel.fromJson(Map<String, dynamic> json) {
    DateTime? parsedDate;
    if (json['uploaded_at'] != null) {
      try {
        parsedDate = DateTime.parse(json['uploaded_at'].toString()).toLocal();
      } catch (_) {
        parsedDate = null;
      }
    }

    return ResumeModel(
      resumeId: json['resume_id'] ?? 0,
      candidateId: json['candidate_id'] ?? 0,
      candidateName: json['candidate_name']?.toString(),
      candidateEmail: json['candidate_email']?.toString(),
      fileName: json['file_name']?.toString() ?? 'resume',
      fileType: json['file_type']?.toString() ?? 'application/pdf',
      fileSize: json['file_size'] ?? 0,
      uploadedAt: parsedDate,
      rawText: json['raw_text']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'resume_id': resumeId,
      'candidate_id': candidateId,
      'candidate_name': candidateName,
      'candidate_email': candidateEmail,
      'file_name': fileName,
      'file_type': fileType,
      'file_size': fileSize,
      'uploaded_at': uploadedAt?.toIso8601String(),
      'raw_text': rawText,
    };
  }

  String get formattedFileSize {
    if (fileSize < 1024) {
      return '$fileSize B';
    } else if (fileSize < 1024 * 1024) {
      return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(fileSize / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
  }

  String get fileExtension {
    final dot = fileName.lastIndexOf('.');
    if (dot != -1 && dot < fileName.length - 1) {
      return fileName.substring(dot + 1).toUpperCase();
    }
    if (fileType.contains('pdf')) return 'PDF';
    if (fileType.contains('word') || fileType.contains('document')) return 'DOCX';
    return 'FILE';
  }

  String get dateGroupKey {
    if (uploadedAt == null) return 'Unknown Date';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final uploadDay = DateTime(uploadedAt!.year, uploadedAt!.month, uploadedAt!.day);

    final diffDays = today.difference(uploadDay).inDays;
    if (diffDays == 0) {
      return 'Today';
    } else if (diffDays == 1) {
      return 'Yesterday';
    } else if (diffDays < 7 && diffDays > 1) {
      const weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
      return weekdays[uploadedAt!.weekday - 1];
    } else {
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${months[uploadedAt!.month - 1]} ${uploadedAt!.day.toString().padLeft(2, '0')}, ${uploadedAt!.year}';
    }
  }

  String get formattedDateTime {
    if (uploadedAt == null) return 'Unknown';
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final m = months[uploadedAt!.month - 1];
    final d = uploadedAt!.day.toString().padLeft(2, '0');
    final y = uploadedAt!.year;

    final hour = uploadedAt!.hour;
    final minute = uploadedAt!.minute.toString().padLeft(2, '0');
    final ampm = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;

    return '$m $d, $y • ${displayHour.toString().padLeft(2, '0')}:$minute $ampm';
  }

  String get timeOnly {
    if (uploadedAt == null) return '';
    final hour = uploadedAt!.hour;
    final minute = uploadedAt!.minute.toString().padLeft(2, '0');
    final ampm = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;
    return '${displayHour.toString().padLeft(2, '0')}:$minute $ampm';
  }
}
