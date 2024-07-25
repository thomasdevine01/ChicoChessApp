import 'package:chico_chess_connect/pages/local/local_chess_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chess_board/flutter_chess_board.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalChessBoardScreen extends StatefulWidget {
  const LocalChessBoardScreen({super.key});

  @override
  _LocalChessBoardScreenState createState() => _LocalChessBoardScreenState();
}

class _LocalChessBoardScreenState extends State<LocalChessBoardScreen> {
  ChessBoardController controller = ChessBoardController();
  bool showGameState = true;
  String _boardColor = 'green';
  String _currentMoveList = "";

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _boardColor = prefs.getString('boardColor') ?? 'green';
    });
  }

  _updatePGN(ChessBoardController controller) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _currentMoveList = controller.getSan().fold(
          '',
          (previousValue, element) =>
              previousValue + (element != null ? ' $element' : ''),
        );
    _currentMoveList = _currentMoveList;
    prefs.setString('PGN', _currentMoveList);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Local Chess'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsPage(),
                  maintainState: true,
                ),
              ).then((_) {
                _loadSettings();
              });
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
                onMove: () async {
                  await _updatePGN(controller);
                },
                boardColor: _boardColor == 'green'
                    ? BoardColor.green
                    : BoardColor.brown,
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
                              '$previousValue\n${element ?? ''}',
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
