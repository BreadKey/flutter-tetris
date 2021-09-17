import 'package:tetris/dao/local/database.dart';
import 'package:tetris/dao/rank_dao.dart';
import 'package:tetris/models/rank.dart';

class LocalRankDao extends RankDao {
  @override
  Future<RankData?> getRankByPlayerId(int playerId) async {
    final db = await database;

    final result = await db.query("rank",
        where: "player_id = ?",
        whereArgs: [playerId],
        orderBy: "score DESC",
        limit: 1);

    if (result.isEmpty) return null;

    return RankData.fromJson(result.first);
  }

  @override
  Future<List<RankData?>> getRankOrderByDesc(int count) async {
    final db = await database;

    final result = await db.query("rank", orderBy: "score DESC", limit: count);

    return result.map((json) => RankData.fromJson(json)).toList();
  }

  @override
  Future<void> insert(RankData rankData) async {
    final db = await database;

    final json = rankData.toJson();

    await db.insert("rank", json);
  }
}
