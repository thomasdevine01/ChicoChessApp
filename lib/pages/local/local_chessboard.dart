import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_chess_board/flutter_chess_board.dart';
import 'package:chico_chess_connect/pages/local/local_chess_settings.dart';
import 'package:chico_chess_connect/utils/chess_board_screen.dart';

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

  _updatePGN() async {
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
    return ChessBoardScreen(
      controller: controller,
      boardColor: _boardColor,
      showGameState: showGameState,
      onSettingsPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const SettingsPage(),
          ),
        ).then((_) {
          _loadSettings();
        });
      },
      onMove: _updatePGN,
    );
  }
}
