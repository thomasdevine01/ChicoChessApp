import 'package:chico_chess_connect/pages/local_chess_settings.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chess_board/flutter_chess_board.dart';

class LocalChessBoardScreen extends StatefulWidget {
  const LocalChessBoardScreen({super.key});

  @override
  _LocalChessBoardScreenState createState() => _LocalChessBoardScreenState();
}

class _LocalChessBoardScreenState extends State<LocalChessBoardScreen> {
  ChessBoardController controller = ChessBoardController();

  bool showGameState = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Local Chess'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsPage(),
                  maintainState: true,
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: ChessBoard(
                controller: controller,
                boardColor: BoardColor.green,
                boardOrientation: PlayerColor.white,
              ),
            ),
          ),
          if (showGameState)
            Expanded(
              child: ValueListenableBuilder<Chess>(
                valueListenable: controller,
                builder: (context, game, _) {
                  return Text(
                    controller.getSan().fold(
                          '',
                          (previousValue, element) =>
                              previousValue + '\n' + (element ?? ''),
                        ),
                  );
                },
              ),
            ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                showGameState = !showGameState;
              });
            },
            child: Text(showGameState ? 'Hide Moves' : 'Show Moves'),
          ),
        ],
      ),
    );
  }
}
