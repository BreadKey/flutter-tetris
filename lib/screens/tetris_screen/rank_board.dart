import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tetris/models/rank.dart';
import 'package:tetris/models/tetris.dart';
import 'package:tetris/screens/tetris_screen/block_renderer.dart';
import 'package:tetris/screens/tetris_screen/board.dart';

class RankBoard extends StatelessWidget {
  final Tetris tetris;

  const RankBoard(this.tetris, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Board(
          child: SizedBox.expand(
        child: StreamProvider.value(
          value: tetris.rankStream,
          initialData: null,
          child: Consumer<Rank>(
            builder: (context, rank, _) {
              return Column(
                children: [
                  Text("You"),
                  rank == null
                      ? const SizedBox()
                      : _buildRank(rank.playerRank.key, rank.playerRank.value),
                  Row(
                      children: List.generate(
                          4,
                          (index) => Expanded(
                                child: AspectRatio(
                                    aspectRatio: 1,
                                    child: BlockRenderer(
                                      Block(color: Colors.grey),
                                    )),
                              ))),
                  Expanded(
                      child: ListView(
                          children: List.generate(
                              rank?.ranks?.length ?? 0,
                              (index) =>
                                  _buildRank(rank.ranks[index], index + 1))))
                ],
              );
            },
          ),
        ),
      ));

  Widget _buildRank(RankData rankData, int ranking) => Row(
          key: ValueKey(rankData),
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildMedal(ranking),
            Flexible(child: Text("${rankData?.score ?? ""}")),
          ]);

  Widget _buildMedal(int ranking) => SizedBox(
        width: 14,
        height: 14,
        child: ranking <= 3 && ranking > 0
            ? BlockRenderer(Block(
                color: ranking == 1
                    ? Colors.yellow
                    : ranking == 2
                        ? Colors.grey
                        : Colors.brown))
            : const SizedBox(),
      );
}
