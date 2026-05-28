import 'package:cloud_firestore/cloud_firestore.dart';

class ReportModel {
  final String    postId;
  final String    reporterId;
  final Timestamp reportedAt;

  const ReportModel({
    required this.postId,
    required this.reporterId,
    required this.reportedAt,
  });

  /// معرّف الوثيقة: {postId}_{reporterId}
  String get docId => '${postId}_$reporterId';

  Map<String, dynamic> toFirestore() => {
    'postId':     postId,
    'reporterId': reporterId,
    'reportedAt': reportedAt,
  };
}
