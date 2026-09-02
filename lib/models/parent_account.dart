import 'package:cloud_firestore/cloud_firestore.dart';

class ParentAccount {
  final String uid;
  final String linkedChildUid;
  final Map<String, dynamic> notifyPrefs; // 通知設定
  final DateTime createdAt;

  ParentAccount({
    required this.uid,
    required this.linkedChildUid,
    required this.notifyPrefs,
    required this.createdAt,
  });

  factory ParentAccount.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ParentAccount(
      uid: doc.id,
      linkedChildUid: data['linkedChildUid'] ?? '',
      notifyPrefs: data['notifyPrefs'] ?? {},
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'linkedChildUid': linkedChildUid,
      'notifyPrefs': notifyPrefs,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  ParentAccount copyWith({
    String? uid,
    String? linkedChildUid,
    Map<String, dynamic>? notifyPrefs,
    DateTime? createdAt,
  }) {
    return ParentAccount(
      uid: uid ?? this.uid,
      linkedChildUid: linkedChildUid ?? this.linkedChildUid,
      notifyPrefs: notifyPrefs ?? this.notifyPrefs,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
