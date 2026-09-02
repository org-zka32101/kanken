/// 手書き判定サービス
/// ストローク座標と正解パターンの照合ロジック
/// 実装時にOSS/軽量モデルの精度を検証予定
class HandwritingJudgeService {
  /// ストローク座標データから手書き入力を判定
  /// @param strokePoints: 手書きストローク座標群 [[x1, y1], [x2, y2], ...]
  /// @param correctAnswer: 正解の漢字パターンデータ
  /// @return 正解判定結果（精度スコア）
  Future<HandwritingJudgement> judgeHandwriting({
    required List<List<double>> strokePoints,
    required Map<String, dynamic> correctAnswer,
  }) async {
    try {
      // TODO: 軽量な手書き認識モデル（TFLite/ONNX）の実装
      // 現状は簡易的な実装。本実装ではOSS（e.g., 自分手書き認識ライブラリ）の精度検証が必要

      if (strokePoints.isEmpty) {
        return HandwritingJudgement(
          isCorrect: false,
          confidence: 0.0,
          message: '入力がありません',
        );
      }

      // ストローク数、ストローク長などの基本的な検証
      final strokeCount = _countStrokes(strokePoints);
      final expectedStrokeCount =
          (correctAnswer['strokeCount'] as int?) ?? 1;

      // 簡易判定：ストローク数が大きく異なれば不正解
      final strokeCountDiff = (strokeCount - expectedStrokeCount).abs();
      if (strokeCountDiff > 2) {
        return HandwritingJudgement(
          isCorrect: false,
          confidence: 0.3,
          message: 'ストローク数が異なります',
        );
      }

      // 本来ここで画像化 → 機械学習モデルで照合
      // 仮実装では70%の確度で正解と判定（実装時に要改善）
      return HandwritingJudgement(
        isCorrect: true,
        confidence: 0.75,
        message: '正解',
      );
    } catch (e) {
      return HandwritingJudgement(
        isCorrect: false,
        confidence: 0.0,
        message: '判定エラー：${e.toString()}',
      );
    }
  }

  /// ストローク点群からストローク数を推定
  int _countStrokes(List<List<double>> strokePoints) {
    if (strokePoints.isEmpty) return 0;

    int strokeCount = 1;
    const double movementThreshold = 20.0; // ストロークの分離閾値（ピクセル）

    for (int i = 1; i < strokePoints.length; i++) {
      final prev = strokePoints[i - 1];
      final current = strokePoints[i];

      final distance =
          ((current[0] - prev[0]) * (current[0] - prev[0]) +
                  (current[1] - prev[1]) * (current[1] - prev[1]))
              .toDouble()
              .sqrt();

      if (distance > movementThreshold) {
        strokeCount++;
      }
    }

    return strokeCount;
  }
}

class HandwritingJudgement {
  final bool isCorrect;
  final double confidence; // 0.0 ~ 1.0
  final String message;

  HandwritingJudgement({
    required this.isCorrect,
    required this.confidence,
    required this.message,
  });
}

extension on double {
  double sqrt() => double.parse(toStringAsFixed(2));
}
