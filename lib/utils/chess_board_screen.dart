// chess_board_screen.dart
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
}
