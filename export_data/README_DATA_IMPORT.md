# Firestore データ投入ガイド

本番レベルのコンテンツデータ（漢字問題＆模擬試験）を Firestore に投入するためのガイド

## ファイル構成

```
export_data/
├── kanji_questions_production.jsonl    # 漢字問題データ（JSONL 形式）
├── mock_exams_production.jsonl         # 模擬試験セットデータ（JSONL 形式）
└── README_DATA_IMPORT.md               # このファイル
```

## コンテンツ規模

### 漢字問題データ
- **レベル 10**（小1～2）: 80 問
- **レベル 9**（小2～3）: 80 問
- **レベル 8**（小3～4）: 90 問
- **レベル 7**（小4～5）: 100 問
- **レベル 6**（小5～6）: 110 問
- **レベル 5**（小6）: 120 問

**合計: 580 問以上**

### 模擬試験セット
- **全 6 レベル × 3 セット = 18 セット**
- 各セット 50 問 / 10 分制限
- 合格基準: 80 点以上

## 投入方法

### 方法 1: Firebase CLI を使用（推奨）

#### 前提条件
```bash
# Firebase CLI をインストール
npm install -g firebase-tools

# Firebase ログイン
firebase login

# プロジェクトを初期化
firebase init
```

#### JSONL ファイルから投入

```bash
# Firestore にインポート
firebase firestore:import --export-auth-mode=unauthenticated \
  --database-id=<your-project-id> \
  export_data/
```

#### または個別に投入

```bash
# 漢字問題を投入
firebase firestore:import export_data/kanji_questions_production.jsonl

# 模擬試験セットを投入
firebase firestore:import export_data/mock_exams_production.jsonl
```

### 方法 2: Dart コード（アプリ内）を使用

`lib/data/seed_firestore.dart` にある `FirestoreSeed` クラスを使用

#### 実装例

```dart
// main.dart で Firebase 初期化後に呼び出し
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 本番データを投入（1 回のみ）
  // 注意: 本番環境では実行しない
  if (kDebugMode) {
    await FirestoreSeed.seedKanjiQuestions();
    await MockExamSeed.seedMockExams();
  }

  runApp(const MyApp());
}
```

### 方法 3: Firebase Console UI から手動投入

1. **Firebase Console にログイン**
   - https://console.firebase.google.com

2. **Firestore Database を選択**

3. **「コレクション」→「kanji_questions」**
   - 右上「ドキュメント追加」
   - JSON ペースト（または手動入力）

4. **各レベルの問題を投入**

## データ構造

### kanji_questions コレクション

```json
{
  "level": "LEVEL_10",
  "kanji": "一",
  "questionType": "multipleChoice",
  "meaning": "ひとつ",
  "choices": ["一", "二", "十", "人"],
  "correctAnswer": "一",
  "reading": "いち",
  "example": "一番目（いちばんめ）",
  "version": 1
}
```

**フィールド説明:**
- `level`: 漢字検定レベル（LEVEL_10 ～ LEVEL_5）
- `kanji`: 漢字（1 文字）
- `questionType`: 問題タイプ
  - `multipleChoice`: 選択肢問題
  - `fillInTheBlank`: 空白埋め
  - `handwriting`: 手書き判定
- `meaning`: 漢字の意味
- `choices`: 選択肢リスト（4 項目）
- `correctAnswer`: 正解
- `reading`: 読み方
- `example`: 使用例
- `version`: データバージョン

### mock_exams コレクション

```json
{
  "level": "LEVEL_10",
  "setNumber": 1,
  "title": "小1 模擬試験 第1セット",
  "timeLimitSec": 600,
  "passScore": 80,
  "totalQuestions": 50,
  "description": "小学1年生向け基礎的な漢字問題",
  "difficulty": "easy"
}
```

**フィールド説明:**
- `level`: レベル（LEVEL_10 ～ LEVEL_5）
- `setNumber`: セット番号（1, 2, 3）
- `title`: 試験のタイトル
- `timeLimitSec`: 制限時間（秒）
- `passScore`: 合格点
- `totalQuestions`: 問題数
- `description`: 説明
- `difficulty`: 難度（easy, normal, hard）

## セキュリティルール確認

投入前に、Firestore のセキュリティルールが正しく設定されていることを確認してください。

```firestore
rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {
    // 問題データ: 誰でも読み取り可能（作成/編集は管理者のみ）
    match /kanji_questions/{document=**} {
      allow read: if true;
      allow write: if false;
    }

    // 模擬試験: 誰でも読み取り可能
    match /mock_exams/{document=**} {
      allow read: if true;
      allow write: if false;
    }
  }
}
```

## 投入後の確認

### Firebase Console で確認
1. **Firestore Database** を開く
2. **コレクション「kanji_questions」** をクリック
3. ドキュメント数が 580 以上であることを確認
4. **コレクション「mock_exams」** で 18 セットが投入されていることを確認

### アプリで確認
```dart
// Firestore から問題データを取得テスト
final firestore = FirebaseFirestore.instance;
final questionsSnapshot = await firestore
    .collection('kanji_questions')
    .where('level', isEqualTo: 'LEVEL_10')
    .limit(10)
    .get();

print('レベル 10 の問題数: ${questionsSnapshot.docs.length}');
```

## トラブルシューティング

### エラー: "Permission denied"
- Firestore セキュリティルールが設定されているか確認
- Firebase Console → Firestore Database → セキュリティルール
- テストモード（すべてアクセス可能）に変更してテスト

### エラー: "Invalid argument: Invalid collection path"
- `kanji_questions` / `mock_exams` コレクション名が正しいか確認
- Firebase CLI コマンドが正しいか確認

### データが投入されない
1. Firebase CLI の認証を確認
   ```bash
   firebase auth:list
   ```
2. プロジェクト ID が正しいか確認
   ```bash
   firebase projects:list
   ```
3. ネットワーク接続を確認

## 本番環境への投入

### 推奨フロー

1. **開発環境（localhost）で投入テスト**
   ```bash
   firebase emulators:start --import=export_data/
   ```

2. **ステージング環境で確認**
   ```bash
   firebase deploy --project staging-project-id
   ```

3. **本番環境に投入（1 回のみ）**
   ```bash
   firebase firestore:import --project production-project-id export_data/
   ```

### 注意事項

⚠️ **本番環境では以下に注意:**
- データは 1 回のみ投入（重複投入は避ける）
- 投入前に必ずバックアップを取得
- セキュリティルールを確認してから投入
- テストモードでの投入は避ける

## 今後の拡張

### さらに問題を追加する場合

1. `lib/data/seed_firestore.dart` の `_generateLevel*Questions()` を拡張
2. または新しい JSONL ファイルを作成
3. Firebase CLI で再投入

### 問題データの更新

```dart
// 既存問題を更新（version をインクリメント）
await firestore
    .collection('kanji_questions')
    .doc(questionId)
    .update({
      'meaning': '新しい意味',
      'version': 2,
    });
```

---

**サポート:** FIREBASE_SETUP.md で Firebase 環境設定を確認
