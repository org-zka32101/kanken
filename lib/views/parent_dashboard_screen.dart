import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/index.dart';
import '../services/index.dart';
import '../viewmodels/index.dart';

/// 保護者ダッシュボード画面
class ParentDashboardScreen extends ConsumerStatefulWidget {
  const ParentDashboardScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ParentDashboardScreen> createState() =>
      _ParentDashboardScreenState();
}

class _ParentDashboardScreenState extends ConsumerState<ParentDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uid = ref.watch(currentUserIdProvider);

    if (uid == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('保護者ダッシュボード')),
        body: const Center(child: Text('ユーザーログインが必要です')),
      );
    }

    // 親アカウント情報を取得
    final parentAccountAsync = ref.watch(
      FutureProvider((async) async {
        final firestoreService = ref.watch(firestoreServiceProvider);
        return await firestoreService.getParentAccount(uid);
      }),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('保護者ダッシュボード'),
        backgroundColor: Colors.indigo,
        elevation: 0,
      ),
      body: parentAccountAsync.when(
        data: (parentAccount) {
          if (parentAccount == null || parentAccount.childUserIds.isEmpty) {
            return _buildNoChildScreen(context);
          }

          return Column(
            children: [
              // タブバー
              Container(
                color: Colors.indigo[50],
                child: TabBar(
                  controller: _tabController,
                  labelColor: Colors.indigo,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Colors.indigo,
                  tabs: const [
                    Tab(text: '進捗'),
                    Tab(text: '成績'),
                    Tab(text: '弱点'),
                    Tab(text: '設定'),
                  ],
                ),
              ),

              // タブコンテンツ
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildProgressTab(context, ref, parentAccount),
                    _buildGradesTab(context, ref, parentAccount),
                    _buildWeakPointsTab(context, ref, parentAccount),
                    _buildSettingsTab(context, ref, parentAccount),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('エラー: $err')),
      ),
    );
  }

  Widget _buildNoChildScreen(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.child_care,
              size: 80,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              '子どもアカウントが連携されていません',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showLinkChildDialog(context),
              icon: const Icon(Icons.qr_code_2),
              label: const Text('QRコードで連携'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressTab(
    BuildContext context,
    WidgetRef ref,
    ParentAccount parentAccount,
  ) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 子ども選択ドロップダウン
            _buildChildSelector(context, ref, parentAccount),
            const SizedBox(height: 24),

            // 学習時間の目安
            _buildStudyTimeCard(),
            const SizedBox(height: 16),

            // 日次進捗バー
            _buildDailyProgressCard(),
            const SizedBox(height: 16),

            // 週次サマリー
            _buildWeeklyProgressCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildGradesTab(
    BuildContext context,
    WidgetRef ref,
    ParentAccount parentAccount,
  ) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '級別成績',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // レベル別成績カード
            _buildGradeCard('10級', 85, true),
            const SizedBox(height: 12),
            _buildGradeCard('9級', 78, false),
            const SizedBox(height: 12),
            _buildGradeCard('8級', 0, false, locked: true),
            const SizedBox(height: 12),
            _buildGradeCard('7級', 0, false, locked: true),
          ],
        ),
      ),
    );
  }

  Widget _buildWeakPointsTab(
    BuildContext context,
    WidgetRef ref,
    ParentAccount parentAccount,
  ) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '苦手漢字分析',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // 苦手漢字リスト
            _buildWeakKanjiItem('彩', 'さい', 3),
            const SizedBox(height: 12),
            _buildWeakKanjiItem('掲', 'けい', 2),
            const SizedBox(height: 12),
            _buildWeakKanjiItem('窒', 'ちっ', 2),
            const SizedBox(height: 12),

            // 分析結果サマリー
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    '分析結果',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '画数の多い漢字が苦手です。\nストローク練習をお勧めします。',
                    style: TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTab(
    BuildContext context,
    WidgetRef ref,
    ParentAccount parentAccount,
  ) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '通知設定',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // 通知設定スイッチ
            _buildNotificationToggle(
              '学習完了時に通知',
              parentAccount.notifyOnCompletion,
              (value) {},
            ),
            const SizedBox(height: 8),
            _buildNotificationToggle(
              '苦手が発見されたら通知',
              parentAccount.notifyOnWeakDiscovered,
              (value) {},
            ),
            const SizedBox(height: 8),
            _buildNotificationToggle(
              'ストリーク切れそうなら通知',
              parentAccount.notifyOnStreakAtRisk,
              (value) {},
            ),

            const SizedBox(height: 32),

            // 子どもアカウント管理
            const Text(
              '子どもアカウント',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            ElevatedButton.icon(
              onPressed: () => _showLinkChildDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('別の子どもを追加'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ヘルパーウィジェット

  Widget _buildChildSelector(
    BuildContext context,
    WidgetRef ref,
    ParentAccount parentAccount,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: DropdownButton<String>(
        isExpanded: true,
        underline: const SizedBox(),
        value: parentAccount.childUserIds.first,
        items: parentAccount.childUserIds.map((childId) {
          return DropdownMenuItem(
            value: childId,
            child: Text('子ども: $childId'),
          );
        }).toList(),
        onChanged: (value) {},
      ),
    );
  }

  Widget _buildStudyTimeCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '今日の学習時間',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      '実績',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '15分',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: const [
                    Text(
                      '目標',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '30分',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: 0.5,
                minHeight: 8,
                backgroundColor: Colors.grey[300],
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyProgressCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '今週の学習日数',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildDayBadge('月', true),
                _buildDayBadge('火', true),
                _buildDayBadge('水', true),
                _buildDayBadge('木', false),
                _buildDayBadge('金', false),
                _buildDayBadge('土', false),
                _buildDayBadge('日', false),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyProgressCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              '週次サマリー',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            Text(
              '✅ 3日連続学習中\n✅ 今週10問正解\n✅ ストリーク：5日',
              style: TextStyle(fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayBadge(String day, bool completed) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: completed ? Colors.green[100] : Colors.grey[200],
        border: Border.all(
          color: completed ? Colors.green : Colors.grey[300]!,
        ),
      ),
      child: Center(
        child: Text(
          day,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: completed ? Colors.green[700] : Colors.grey[600],
          ),
        ),
      ),
    );
  }

  Widget _buildGradeCard(
    String level,
    int score,
    bool passed, {
    bool locked = false,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  level,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  locked ? '未受験' : passed ? '合格' : '未合格',
                  style: TextStyle(
                    fontSize: 12,
                    color: locked
                        ? Colors.grey
                        : passed
                            ? Colors.green
                            : Colors.red,
                  ),
                ),
              ],
            ),
            if (!locked)
              Text(
                '$score点',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              )
            else
              const Icon(Icons.lock, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildWeakKanjiItem(String kanji, String reading, int missCount) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                kanji,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                reading,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.red[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '間違い: $missCount',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.red[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationToggle(
    String label,
    bool value,
    Function(bool) onChanged,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.indigo,
        ),
      ],
    );
  }

  void _showLinkChildDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.qr_code_2,
                size: 80,
                color: Colors.indigo,
              ),
              const SizedBox(height: 16),
              const Text(
                'QRコードで連携',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text(
                    'QR Code\nPlaceholder',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '子どものデバイスで\nこのQRコードをスキャンしてください',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                ),
                child: const Text(
                  '完了',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
