import 'package:cloud_firestore/cloud_firestore.dart';

enum QuestionType { multipleChoice, handwriting }

class KanjiQuestion {
  final String id;
  final String level; // LEVEL_10 ~ LEVEL_5
  final String kanji;
  final QuestionType questionType;
  final List<String> choices; // 選択肢（手書きの場合は空）
  final String correctAnswer;
  final Map<String, dynamic>? strokeOrderData;
  final int version;

  KanjiQuestion({
    required this.id,
    required this.level,
    required this.kanji,
    required this.questionType,
    required this.choices,
    required this.correctAnswer,
    this.strokeOrderData,
    required this.version,
  });

  factory KanjiQuestion.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return KanjiQuestion(
      id: doc.id,
      level: data['level'] ?? 'LEVEL_10',
      kanji: data['kanji'] ?? '',
      questionType: _parseQuestionType(data['questionType']),
      choices: List<String>.from(data['choices'] ?? []),
      correctAnswer: data['correctAnswer'] ?? '',
      strokeOrderData: data['strokeOrderData'],
      version: data['version'] ?? 1,
    );
  }

  static QuestionType _parseQuestionType(String? type) {
    switch (type) {
      case 'handwriting':
        return QuestionType.handwriting;
      default:
        return QuestionType.multipleChoice;
    }
  }

  Map<String, dynamic> toFirestore() {
    return {
      'level': level,
      'kanji': kanji,
      'questionType': questionType.toString().split('.').last,
      'choices': choices,
      'correctAnswer': correctAnswer,
      'strokeOrderData': strokeOrderData,
      'version': version,
    };
  }

  KanjiQuestion copyWith({
    String? id,
    String? level,
    String? kanji,
    QuestionType? questionType,
    List<String>? choices,
    String? correctAnswer,
    Map<String, dynamic>? strokeOrderData,
    int? version,
  }) {
    return KanjiQuestion(
      id: id ?? this.id,
      level: level ?? this.level,
      kanji: kanji ?? this.kanji,
      questionType: questionType ?? this.questionType,
      choices: choices ?? this.choices,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      strokeOrderData: strokeOrderData ?? this.strokeOrderData,
      version: version ?? this.version,
    );
  }
}
