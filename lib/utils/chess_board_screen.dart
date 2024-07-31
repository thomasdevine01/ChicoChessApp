import 'package:flutter/material.dart';
import 'package:flutter_chess_board/flutter_chess_board.dart';

class ChessBoardScreen extends StatefulWidget {
  final ChessBoardController controller;
  final String boardColor;
  final bool showGameState;
  final VoidCallback onSettingsPressed;
  final void Function()? onMove;

  ChessBoardScreen({
    required this.controller,
    required this.boardColor,
    required this.showGameState,
    required this.onSettingsPressed,
    required this.onMove,
  });

  @override
  _ChessBoardScreenState createState() => _ChessBoardScreenState();
}

class _ChessBoardScreenState extends State<ChessBoardScreen> {
  String player1Username = 'Player 1';
  int player1Rating = 1200;
  String player2Username = 'Player 2';
  int player2Rating = 1200;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chess Game'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: widget.onSettingsPressed,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildPlayerInfo(player2Username, player2Rating),
          Expanded(
            child: Center(
              child: ChessBoard(
                controller: widget.controller,
                onMove: widget.onMove,
                boardColor: widget.boardColor == 'green'
                    ? BoardColor.green
                    : BoardColor.brown,
              ),
            ),
          ),
          _buildPlayerInfo(player1Username, player1Rating),
          if (widget.showGameState)
            Expanded(
              child: ValueListenableBuilder<Chess>(
                valueListenable: widget.controller,
                builder: (context, game, _) {
                  return Text(
                    widget.controller.getSan().fold(
                          '',
                          (previousValue, element) =>
                              '$previousValue\n${element ?? ''}',
                        ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPlayerInfo(String username, int rating) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            username,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            'Rating: $rating',
            style: TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }
}
