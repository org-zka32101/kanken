import 'package:cloud_firestore/cloud_firestore.dart';

enum AnswerMode { normal, handwriting, weakKanjiFocus }

class UserAnswerLog {
  final String id;
  final String uid;
  final String questionId;
  final bool isCorrect;
  final AnswerMode mode;
  final DateTime answeredAt;

  UserAnswerLog({
    required this.id,
    required this.uid,
    required this.questionId,
    required this.isCorrect,
    required this.mode,
    required this.answeredAt,
  });

  factory UserAnswerLog.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserAnswerLog(
      id: doc.id,
      uid: data['uid'] ?? '',
      questionId: data['questionId'] ?? '',
      isCorrect: data['isCorrect'] ?? false,
      mode: _parseAnswerMode(data['mode']),
      answeredAt: (data['answeredAt'] as Timestamp).toDate(),
    );
  }

  static AnswerMode _parseAnswerMode(String? mode) {
    switch (mode) {
      case 'handwriting':
        return AnswerMode.handwriting;
      case 'weakKanjiFocus':
        return AnswerMode.weakKanjiFocus;
      default:
        return AnswerMode.normal;
    }
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'questionId': questionId,
      'isCorrect': isCorrect,
      'mode': mode.toString().split('.').last,
      'answeredAt': Timestamp.fromDate(answeredAt),
    };
  }
}
