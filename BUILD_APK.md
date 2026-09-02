# APK ビルドガイド

リモート環境ではビルドできないため、ローカル環境で実行してください。

## 前提条件

- Flutter 3.13+ インストール済み
- Android SDK インストール済み
- JDK 11+ インストール済み
- (オプション) Android Device Bridge (adb) 接続設定

## ビルド手順

### 1. 環境確認

```bash
flutter doctor
# すべての項目が ✓ になっていることを確認
```

### 2. 依存関係をインストール

```bash
cd /path/to/kanken
flutter pub get
```

### 3. Firebase 設定（必須）

- `android/app/google-services.json` を配置
- `firebase_options.dart` を設定

### 4. Keystore 作成（署名用）

初回のみ実行：

```bash
keytool -genkey -v -keystore ~/kanken_key.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias kanken_key
```

プロンプトで以下を入力：
- パスワード（覚えておく）
- 名前、組織、地域など

### 5. 署名設定

`android/key.properties` を作成：

```properties
storePassword=<上記のパスワード>
keyPassword=<上記のパスワード>
keyAlias=kanken_key
storeFile=/Users/<username>/kanken_key.jks
```

`android/app/build.gradle` で署名を有効化（既に設定済み）

### 6. APK ビルド

#### デバッグ版（テスト用）

```bash
flutter build apk --debug
# 出力: build/app/outputs/apk/debug/app-debug.apk
```

#### リリース版（本番用）

```bash
flutter build apk --release
# 出力: build/app/outputs/apk/release/app-release.apk
```

#### App Bundle（Google Play用）

```bash
flutter build appbundle --release
# 出力: build/app/outputs/bundle/release/app-release.aab
```

## インストール & 実行

### 実機にインストール

```bash
# USB デバッグを有効にした Android デバイスを接続

# デバッグ版
flutter run

# またはインストール
adb install build/app/outputs/apk/debug/app-debug.apk
```

### エミュレータで実行

```bash
# Android Studio でエミュレータを起動してから

flutter run
```

## ビルド結果

| ファイル | サイズ | 用途 |
|---------|--------|------|
| app-debug.apk | ~50MB | テスト・開発 |
| app-release.apk | ~35MB | Google Play |
| app-release.aab | ~20MB | Google Play Console |

## トラブルシューティング

### エラー: "Google Play Services not found"

```bash
flutter clean
flutter pub get
flutter build apk --release
```

### エラー: "Keystore not found"

- `key.properties` のパスを確認
- `keytool` で keystore 再作成

### ビルド遅い

```bash
# キャッシュをクリア
flutter clean

# 並列ビルド有効化
flutter build apk --release --split-per-abi
```

## APK 検証

```bash
# APK 情報確認
aapt dump badging build/app/outputs/apk/release/app-release.apk

# インストール前に署名確認
jarsigner -verify -verbose build/app/outputs/apk/release/app-release.apk
```

## Google Play への公開

1. Google Play Console にログイン
2. アプリを作成
3. App Bundle (`.aab`) をアップロード
4. テスト → 本番リリース

---

**ビルド コマンド早見表**

```bash
# 最も一般的な使用
flutter build apk --release

# デバッグ + 実機実行
flutter run

# 完全リビルド
flutter clean && flutter build apk --release

# 複数 ABI（arm64, armeabi-v7a）
flutter build apk --release --split-per-abi
```

**出力場所**: `build/app/outputs/apk/` または `build/app/outputs/bundle/`
