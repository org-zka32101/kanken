import 'package:cloud_firestore/cloud_firestore.dart';

class CollectionBadge {
  final String id;
  final String uid;
  final String level; // LEVEL_10 ~ LEVEL_5
  final DateTime unlockedAt;

  CollectionBadge({
    required this.id,
    required this.uid,
    required this.level,
    required this.unlockedAt,
  });

  factory CollectionBadge.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CollectionBadge(
      id: doc.id,
      uid: data['uid'] ?? '',
      level: data['level'] ?? 'LEVEL_10',
      unlockedAt: (data['unlockedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'level': level,
      'unlockedAt': Timestamp.fromDate(unlockedAt),
    };
  }
}
