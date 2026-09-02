import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String uid;
  final String currentLevel;
  final int streakCount;
  final DateTime createdAt;

  User({
    required this.uid,
    required this.currentLevel,
    required this.streakCount,
    required this.createdAt,
  });

  factory User.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return User(
      uid: doc.id,
      currentLevel: data['currentLevel'] ?? 'LEVEL_10',
      streakCount: data['streakCount'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'currentLevel': currentLevel,
      'streakCount': streakCount,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  User copyWith({
    String? uid,
    String? currentLevel,
    int? streakCount,
    DateTime? createdAt,
  }) {
    return User(
      uid: uid ?? this.uid,
      currentLevel: currentLevel ?? this.currentLevel,
      streakCount: streakCount ?? this.streakCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
