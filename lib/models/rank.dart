class Rank {
  final MapEntry<RankData?, int> playerRank;
  final List<RankData?> ranks;

  Rank(this.playerRank, this.ranks);
}

class RankData {
  final int? playerId;
  final int? score;

  RankData(this.playerId, this.score);

  Map<String, dynamic> toJson() => {"player_id": playerId, "score": score};
  factory RankData.fromJson(Map<String, dynamic> json) =>
      RankData(json["player_id"] as int?, json["score"] as int?);

  bool operator ==(Object other) =>
      other is RankData && playerId == other.playerId && score == other.score;

  @override
  int get hashCode => Object.hash(playerId, score);
}
