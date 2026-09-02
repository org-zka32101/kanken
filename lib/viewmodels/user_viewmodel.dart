import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/index.dart';
import '../services/index.dart';
import 'services_provider.dart';

// ユーザー情報Provider
final userProvider = FutureProvider.family<User?, String>((ref, uid) async {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return await firestoreService.getUser(uid);
});

// 現在ログイン中のUID（仮：AuthServiceが必要）
final currentUserIdProvider = StateProvider<String?>((ref) => null);

// 現在のユーザー情報
final currentUserProvider = FutureProvider<User?>((ref) async {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) return null;
  return ref.watch(userProvider(uid)).when(
        data: (user) => user,
        loading: () => null,
        error: (err, stack) => null,
      );
});

// ストリーク継続状態
final streakCountProvider = FutureProvider<int>((ref) async {
  final user = await ref.watch(currentUserProvider.future);
  return user?.streakCount ?? 0;
});

// 現在の受験級
final currentLevelProvider = StateProvider<String>((ref) => 'LEVEL_10');
