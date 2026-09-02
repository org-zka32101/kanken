import 'package:cloud_firestore/cloud_firestore.dart';

class MockExamResult {
  final String id;
  final String uid;
  final String examId;
  final int score;
  final bool passed;
  final DateTime takenAt;

  MockExamResult({
    required this.id,
    required this.uid,
    required this.examId,
    required this.score,
    required this.passed,
    required this.takenAt,
  });

  factory MockExamResult.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MockExamResult(
      id: doc.id,
      uid: data['uid'] ?? '',
      examId: data['examId'] ?? '',
      score: data['score'] ?? 0,
      passed: data['passed'] ?? false,
      takenAt: (data['takenAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'examId': examId,
      'score': score,
      'passed': passed,
      'takenAt': Timestamp.fromDate(takenAt),
    };
  }

  int getScoreNeededToPass(int passScore) {
    return passScore - score;
  }
}
