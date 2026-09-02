import '../models/index.dart';
import 'firestore_service.dart';

class AIWeakAnalysisService {
  final FirestoreService _firestoreService;

  AIWeakAnalysisService(this._firestoreService);

  /// ユーザーの誤答パターンから苦手漢字を分析・更新
  /// petit_ai経由でCloud Functionsから呼ばれる想定
  Future<void> analyzeWeakKanjis(String uid) async {
    try {
      // ユーザーの全答ログを取得
      final answerLogs = await _firestoreService.getUserAnswerLogs(uid);

      // 誤答のみフィルタ
      final incorrectAnswers = answerLogs.where((log) => !log.isCorrect).toList();

      // 誤答漢字のカウント
      final weakMap = <String, int>{};
      for (final log in incorrectAnswers) {
        weakMap[log.questionId] = (weakMap[log.questionId] ?? 0) + 1;
      }

      // WeakKanjiListを更新
      for (final entry in weakMap.entries) {
        final existingWeak =
            await _firestoreService.getWeakKanjiList(uid, entry.key);

        final updatedWeak = WeakKanjiList(
          id: existingWeak?.id ?? '',
          uid: uid,
          kanjiId: entry.key,
          missCount: entry.value,
          lastMissedAt: DateTime.now(),
          masteredAt: existingWeak?.masteredAt,
        );

        await _firestoreService.upsertWeakKanjiList(updatedWeak);
      }
    } catch (e) {
      rethrow;
    }
  }

  /// 苦手集中モード用の問題セットを取得
  /// 最近の誤答が多い漢字から出題
  Future<List<KanjiQuestion>> getWeakKanjiFocusQuestions(
    String uid, {
    int limit = 10,
  }) async {
    try {
      final weakKanjis =
          await _firestoreService.getUserWeakKanjis(uid, limit: limit);

      final questions = <KanjiQuestion>[];
      for (final weak in weakKanjis) {
        final question = await _firestoreService.getKanjiQuestion(weak.kanjiId);
        if (question != null) {
          questions.add(question);
        }
      }

      return questions;
    } catch (e) {
      rethrow;
    }
  }

  /// 苦手漢字を習得済みとしてマーク
  Future<void> markAsMatured(String uid, String kanjiId) async {
    final weak = await _firestoreService.getWeakKanjiList(uid, kanjiId);
    if (weak != null) {
      final updated = weak.copyWith(masteredAt: DateTime.now());
      await _firestoreService.upsertWeakKanjiList(updated);
    }
  }

  /// ユーザーの苦手漢字数を取得（Dashboard用）
  Future<int> getWeakKanjiCount(String uid) async {
    final weakKanjis = await _firestoreService.getUserWeakKanjis(uid, limit: 1000);
    final notMastered = weakKanjis.where((w) => w.masteredAt == null).length;
    return notMastered;
  }
}
