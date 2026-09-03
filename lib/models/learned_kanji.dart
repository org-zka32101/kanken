import 'package:cloud_firestore/cloud_firestore.dart';

class LearnedKanji {
  final String id;
  final String uid;
  final String questionId;
  final String kanji;
  final String level;
  final DateTime learnedAt;

  LearnedKanji({
    required this.id,
    required this.uid,
    required this.questionId,
    required this.kanji,
    required this.level,
    required this.learnedAt,
  });

  factory LearnedKanji.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return LearnedKanji(
      id: doc.id,
      uid: data['uid'] ?? '',
      questionId: data['questionId'] ?? '',
      kanji: data['kanji'] ?? '',
      level: data['level'] ?? '',
      learnedAt: (data['learnedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'questionId': questionId,
      'kanji': kanji,
      'level': level,
      'learnedAt': Timestamp.fromDate(learnedAt),
    };
  }

  LearnedKanji copyWith({
    String? id,
    String? uid,
    String? questionId,
    String? kanji,
    String? level,
    DateTime? learnedAt,
  }) {
    return LearnedKanji(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      questionId: questionId ?? this.questionId,
      kanji: kanji ?? this.kanji,
      level: level ?? this.level,
      learnedAt: learnedAt ?? this.learnedAt,
    );
  }
}
