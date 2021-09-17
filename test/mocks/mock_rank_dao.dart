import 'package:tetris/dao/rank_dao.dart';
import 'package:tetris/models/rank.dart';

class MockRankDao extends RankDao {
  final _data = <RankData?>[];

  @override
  Future<RankData?> getRankByPlayerId(int playerId) async {
    return _data.firstWhere((element) => element!.playerId == playerId,
        orElse: () => null);
  }

  @override
  Future<List<RankData?>> getRankOrderByDesc(int count) async {
    return (_data..sort((a, b) => a!.score!)).take(count).toList();
  }

  @override
  Future<void> insert(RankData rankData) async {
    _data.add(rankData);
  }
}
