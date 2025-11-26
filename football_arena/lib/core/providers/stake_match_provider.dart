import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../network/stake_match_api_service.dart';
import '../network/api_client.dart';
import '../../shared/models/stake_match_model.dart';

// Provider for StakeMatchApiService
final stakeMatchApiProvider = Provider<StakeMatchApiService>((ref) {
  final dio = ref.watch(dioProvider);
  return StakeMatchApiService(dio);
});

// Provider for available stake matches
final availableStakeMatchesProvider = FutureProvider<List<StakeMatchModel>>((ref) async {
  final api = ref.watch(stakeMatchApiProvider);
  return await api.getAvailableMatches(20);
});

// Provider for user's stake match history
final userStakeMatchesProvider = FutureProvider.family<List<StakeMatchModel>, String>(
  (ref, userId) async {
    final api = ref.watch(stakeMatchApiProvider);
    return await api.getUserStakeMatches(userId);
  },
);

// Provider for creating stake match
class StakeMatchNotifier extends StateNotifier<AsyncValue<StakeMatchModel?>> {
  StakeMatchNotifier(this.api) : super(const AsyncValue.data(null));
  
  final StakeMatchApiService api;

  Future<void> createMatch({
    required String userId,
    required int stakeAmount,
    int numberOfQuestions = 10,
    String difficulty = 'mixed',
  }) async {
    state = const AsyncValue.loading();
    try {
      final match = await api.createStakeMatch({
        'userId': userId,
        'stakeAmount': stakeAmount,
        'numberOfQuestions': numberOfQuestions,
        'difficulty': difficulty,
      });
      state = AsyncValue.data(match);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> joinMatch({
    required String userId,
    required String matchId,
  }) async {
    state = const AsyncValue.loading();
    try {
      final match = await api.joinStakeMatch({
        'userId': userId,
        'matchId': matchId,
      });
      state = AsyncValue.data(match);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> completeMatch({
    required String matchId,
    required int creatorScore,
    required int opponentScore,
  }) async {
    state = const AsyncValue.loading();
    try {
      final match = await api.completeStakeMatch({
        'matchId': matchId,
        'creatorScore': creatorScore,
        'opponentScore': opponentScore,
      });
      state = AsyncValue.data(match);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> cancelMatch({
    required String matchId,
    required String userId,
  }) async {
    state = const AsyncValue.loading();
    try {
      final match = await api.cancelStakeMatch(matchId, {'userId': userId});
      state = AsyncValue.data(match);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final stakeMatchNotifierProvider = StateNotifierProvider<StakeMatchNotifier, AsyncValue<StakeMatchModel?>>(
  (ref) => StakeMatchNotifier(ref.watch(stakeMatchApiProvider)),
);

