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
  int get hashCode => _JenkinsSmiHash.hash2(playerId.hashCode, score.hashCode);
}

class _JenkinsSmiHash {
  static int combine(int hash, int value) {
    hash = 0x1fffffff & (hash + value);
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }

  static int hash2(int a, int b) => finish(combine(combine(0, a), b));

  static int hash4(int a, int b, int c, int d) =>
      finish(combine(combine(combine(combine(0, a), b), c), d));
}
