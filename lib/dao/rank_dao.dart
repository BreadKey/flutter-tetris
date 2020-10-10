import 'package:tetris/models/rank.dart';

abstract class RankDao {
  Future<void> insert(RankData rankData);
  Future<List<RankData>> getRankOrderByDesc(int count);
  Future<RankData> getRankByPlayerId(int playerId);
}
