import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/index.dart';

class FirestoreService {
  final FirebaseFirestore _firestore;

  FirestoreService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // User operations
  Future<User?> getUser(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists) return null;
      return User.fromFirestore(doc);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> createUser(User user) async {
    await _firestore.collection('users').doc(user.uid).set(user.toFirestore());
  }

  Future<void> updateUser(User user) async {
    await _firestore.collection('users').doc(user.uid).update(user.toFirestore());
  }

  // KanjiQuestion operations
  Future<KanjiQuestion?> getKanjiQuestion(String id) async {
    try {
      final doc = await _firestore.collection('kanji_questions').doc(id).get();
      if (!doc.exists) return null;
      return KanjiQuestion.fromFirestore(doc);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<KanjiQuestion>> getQuestionsByLevel(String level, {int limit = 50}) async {
    try {
      final querySnapshot = await _firestore
          .collection('kanji_questions')
          .where('level', isEqualTo: level)
          .limit(limit)
          .get();
      return querySnapshot.docs.map(KanjiQuestion.fromFirestore).toList();
    } catch (e) {
      rethrow;
    }
  }

  // UserAnswerLog operations
  Future<void> addAnswerLog(UserAnswerLog log) async {
    await _firestore.collection('user_answer_logs').add(log.toFirestore());
  }

  Future<List<UserAnswerLog>> getUserAnswerLogs(String uid, {int limit = 100}) async {
    try {
      final querySnapshot = await _firestore
          .collection('user_answer_logs')
          .where('uid', isEqualTo: uid)
          .orderBy('answeredAt', descending: true)
          .limit(limit)
          .get();
      return querySnapshot.docs.map(UserAnswerLog.fromFirestore).toList();
    } catch (e) {
      rethrow;
    }
  }

  // WeakKanjiList operations
  Future<WeakKanjiList?> getWeakKanjiList(String uid, String kanjiId) async {
    try {
      final querySnapshot = await _firestore
          .collection('weak_kanji_lists')
          .where('uid', isEqualTo: uid)
          .where('kanjiId', isEqualTo: kanjiId)
          .get();
      if (querySnapshot.docs.isEmpty) return null;
      return WeakKanjiList.fromFirestore(querySnapshot.docs.first);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<WeakKanjiList>> getUserWeakKanjis(String uid, {int limit = 50}) async {
    try {
      final querySnapshot = await _firestore
          .collection('weak_kanji_lists')
          .where('uid', isEqualTo: uid)
          .orderBy('lastMissedAt', descending: true)
          .limit(limit)
          .get();
      return querySnapshot.docs.map(WeakKanjiList.fromFirestore).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> upsertWeakKanjiList(WeakKanjiList weakKanji) async {
    final existing = await getWeakKanjiList(weakKanji.uid, weakKanji.kanjiId);
    if (existing != null) {
      await _firestore
          .collection('weak_kanji_lists')
          .doc(existing.id)
          .update(weakKanji.toFirestore());
    } else {
      await _firestore.collection('weak_kanji_lists').add(weakKanji.toFirestore());
    }
  }

  // MockExam operations
  Future<MockExam?> getMockExam(String id) async {
    try {
      final doc = await _firestore.collection('mock_exams').doc(id).get();
      if (!doc.exists) return null;
      return MockExam.fromFirestore(doc);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<MockExam>> getMockExamsByLevel(String level) async {
    try {
      final querySnapshot = await _firestore
          .collection('mock_exams')
          .where('level', isEqualTo: level)
          .get();
      return querySnapshot.docs.map(MockExam.fromFirestore).toList();
    } catch (e) {
      rethrow;
    }
  }

  // MockExamResult operations
  Future<void> addMockExamResult(MockExamResult result) async {
    await _firestore.collection('mock_exam_results').add(result.toFirestore());
  }

  Future<List<MockExamResult>> getUserMockExamResults(String uid) async {
    try {
      final querySnapshot = await _firestore
          .collection('mock_exam_results')
          .where('uid', isEqualTo: uid)
          .orderBy('takenAt', descending: true)
          .get();
      return querySnapshot.docs.map(MockExamResult.fromFirestore).toList();
    } catch (e) {
      rethrow;
    }
  }

  // CollectionBadge operations
  Future<void> addCollectionBadge(CollectionBadge badge) async {
    await _firestore.collection('collection_badges').add(badge.toFirestore());
  }

  Future<List<CollectionBadge>> getUserBadges(String uid) async {
    try {
      final querySnapshot = await _firestore
          .collection('collection_badges')
          .where('uid', isEqualTo: uid)
          .orderBy('unlockedAt', descending: true)
          .get();
      return querySnapshot.docs.map(CollectionBadge.fromFirestore).toList();
    } catch (e) {
      rethrow;
    }
  }

  // ParentAccount operations
  Future<ParentAccount?> getParentAccount(String uid) async {
    try {
      final doc = await _firestore.collection('parent_accounts').doc(uid).get();
      if (!doc.exists) return null;
      return ParentAccount.fromFirestore(doc);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> createParentAccount(ParentAccount account) async {
    await _firestore
        .collection('parent_accounts')
        .doc(account.uid)
        .set(account.toFirestore());
  }

  Future<void> updateParentAccount(ParentAccount account) async {
    await _firestore
        .collection('parent_accounts')
        .doc(account.uid)
        .update(account.toFirestore());
  }

  // LearnedKanji operations
  Future<void> markAsLearned(LearnedKanji learned) async {
    try {
      // 既に学習済みかチェック
      final existing = await _firestore
          .collection('learned_kanji')
          .where('uid', isEqualTo: learned.uid)
          .where('questionId', isEqualTo: learned.questionId)
          .get();

      if (existing.docs.isEmpty) {
        await _firestore.collection('learned_kanji').add(learned.toFirestore());
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<LearnedKanji>> getUserLearnedKanjis(String uid) async {
    try {
      final querySnapshot = await _firestore
          .collection('learned_kanji')
          .where('uid', isEqualTo: uid)
          .orderBy('learnedAt', descending: true)
          .get();
      return querySnapshot.docs.map(LearnedKanji.fromFirestore).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> isQuestionLearned(String uid, String questionId) async {
    try {
      final querySnapshot = await _firestore
          .collection('learned_kanji')
          .where('uid', isEqualTo: uid)
          .where('questionId', isEqualTo: questionId)
          .get();
      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> unmarkAsLearned(String uid, String questionId) async {
    try {
      final querySnapshot = await _firestore
          .collection('learned_kanji')
          .where('uid', isEqualTo: uid)
          .where('questionId', isEqualTo: questionId)
          .get();

      for (final doc in querySnapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      rethrow;
    }
  }
}
