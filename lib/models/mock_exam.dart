import 'package:cloud_firestore/cloud_firestore.dart';

class MockExam {
  final String id;
  final String level; // LEVEL_10 ~ LEVEL_5
  final List<String> questionIds;
  final int timeLimitSec;
  final int passScore;

  MockExam({
    required this.id,
    required this.level,
    required this.questionIds,
    required this.timeLimitSec,
    required this.passScore,
  });

  factory MockExam.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MockExam(
      id: doc.id,
      level: data['level'] ?? 'LEVEL_10',
      questionIds: List<String>.from(data['questionIds'] ?? []),
      timeLimitSec: data['timeLimitSec'] ?? 600,
      passScore: data['passScore'] ?? 80,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'level': level,
      'questionIds': questionIds,
      'timeLimitSec': timeLimitSec,
      'passScore': passScore,
    };
  }
}
