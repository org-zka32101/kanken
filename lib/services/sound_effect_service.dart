/// 効果音（SE）管理サービス
/// 実装時に audioplayers パッケージを使用
class SoundEffectService {
  static const String _correctSoundPath = 'sounds/correct.mp3';
  static const String _incorrectSoundPath = 'sounds/incorrect.mp3';
  static const String _badgeUnlockedSoundPath = 'sounds/badge_unlocked.mp3';
  static const String _comboSoundPath = 'sounds/combo.mp3';

  bool _isMuted = false;
  double _volume = 0.7; // デフォルト音量（初回は控えめ）

  /// SE再生（正解）
  Future<void> playCorrectSound() async {
    if (_isMuted) return;
    await _playSoundFile(_correctSoundPath);
  }

  /// SE再生（不正解）
  Future<void> playIncorrectSound() async {
    if (_isMuted) return;
    await _playSoundFile(_incorrectSoundPath);
  }

  /// SE再生（バッジ獲得）
  Future<void> playBadgeUnlockedSound() async {
    if (_isMuted) return;
    await _playSoundFile(_badgeUnlockedSoundPath);
  }

  /// SE再生（コンボ）
  Future<void> playComboSound() async {
    if (_isMuted) return;
    await _playSoundFile(_comboSoundPath);
  }

  /// ミュート状態を設定
  void setMuted(bool muted) {
    _isMuted = muted;
  }

  /// 音量を設定（0.0 ~ 1.0）
  void setVolume(double volume) {
    _volume = volume.clamp(0.0, 1.0);
  }

  /// 音量取得
  double getVolume() => _volume;

  /// ミュート状態取得
  bool isMuted() => _isMuted;

  /// ファイルから音声再生（内部用）
  /// 実装時：audioplayers.AudioPlayer を使用
  Future<void> _playSoundFile(String path) async {
    // TODO: 実装
    // final audioPlayer = AudioPlayer();
    // await audioPlayer.play(AssetSource(path), volume: _volume);
  }

  /// 初期化（1タップでミュート設定）
  static Future<void> initializeWithUserPreference() async {
    // リモートコンフィグから初期SE音量設定を取得
    // Remote Config: 'se_initial_muted' → true なら起動時ミュート
  }
}
