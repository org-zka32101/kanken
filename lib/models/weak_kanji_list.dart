import 'package:cloud_firestore/cloud_firestore.dart';

class WeakKanjiList {
  final String id;
  final String uid;
  final String kanjiId;
  final int missCount;
  final DateTime lastMissedAt;
  final DateTime? masteredAt;

  WeakKanjiList({
    required this.id,
    required this.uid,
    required this.kanjiId,
    required this.missCount,
    required this.lastMissedAt,
    this.masteredAt,
  });

  factory WeakKanjiList.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return WeakKanjiList(
      id: doc.id,
      uid: data['uid'] ?? '',
      kanjiId: data['kanjiId'] ?? '',
      missCount: data['missCount'] ?? 0,
      lastMissedAt: (data['lastMissedAt'] as Timestamp).toDate(),
      masteredAt: data['masteredAt'] != null
          ? (data['masteredAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'kanjiId': kanjiId,
      'missCount': missCount,
      'lastMissedAt': Timestamp.fromDate(lastMissedAt),
      if (masteredAt != null) 'masteredAt': Timestamp.fromDate(masteredAt!),
    };
  }

  WeakKanjiList copyWith({
    String? id,
    String? uid,
    String? kanjiId,
    int? missCount,
    DateTime? lastMissedAt,
    DateTime? masteredAt,
  }) {
    return WeakKanjiList(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      kanjiId: kanjiId ?? this.kanjiId,
      missCount: missCount ?? this.missCount,
      lastMissedAt: lastMissedAt ?? this.lastMissedAt,
      masteredAt: masteredAt ?? this.masteredAt,
    );
  }
}
