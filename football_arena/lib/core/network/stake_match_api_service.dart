import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../../shared/models/stake_match_model.dart';

part 'stake_match_api_service.g.dart';

@RestApi()
abstract class StakeMatchApiService {
  factory StakeMatchApiService(Dio dio, {String baseUrl}) = _StakeMatchApiService;

  /// Create a new stake match
  @POST('/stake-matches')
  Future<StakeMatchModel> createStakeMatch(
    @Body() Map<String, dynamic> data,
  );

  /// Get all available stake matches (waiting status)
  @GET('/stake-matches/available')
  Future<List<StakeMatchModel>> getAvailableMatches(
    @Query('limit') int? limit,
  );

  /// Get user's stake match history
  @GET('/stake-matches/my-matches/{userId}')
  Future<List<StakeMatchModel>> getUserStakeMatches(
    @Path('userId') String userId,
  );

  /// Get stake match by ID
  @GET('/stake-matches/{id}')
  Future<StakeMatchModel> getStakeMatchById(
    @Path('id') String id,
  );

  /// Join a stake match
  @POST('/stake-matches/join')
  Future<StakeMatchModel> joinStakeMatch(
    @Body() Map<String, dynamic> data,
  );

  /// Complete a stake match
  @POST('/stake-matches/complete')
  Future<StakeMatchModel> completeStakeMatch(
    @Body() Map<String, dynamic> data,
  );

  /// Cancel a stake match
  @DELETE('/stake-matches/{id}')
  Future<StakeMatchModel> cancelStakeMatch(
    @Path('id') String id,
    @Body() Map<String, dynamic> data,
  );
}

