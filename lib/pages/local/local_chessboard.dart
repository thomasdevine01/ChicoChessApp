import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_chess_board/flutter_chess_board.dart';
import 'package:chico_chess_connect/pages/local/local_chess_settings.dart';

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
  bool playerTurn = true; // true for White's turn, false for Black's turn
  final ScrollController _scrollController = ScrollController();

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
    prefs.setString('PGN', _currentMoveList);

    setState(() {
      playerTurn = !playerTurn; // Toggle the player turn
    });

    // Auto-scroll to the bottom of the list
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chess Game'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsPage(),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _buildPlayerInfo('Player 2', 1200, isTop: true),
            ],
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Center(
                    child: ChessBoard(
                      controller: controller,
                      onMove: _updatePGN,
                      boardColor: _boardColor == 'green'
                          ? BoardColor.green
                          : BoardColor.brown,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _buildPlayerInfo('Player 1', 1200, isTop: false),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Text(
                playerTurn ? 'White\'s Turn' : 'Black\'s Turn',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Center(
                child: _buildMoveTable(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerInfo(String username, int rating, {required bool isTop}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            username,
            style: TextStyle(fontSize: 18),
          ),
          Text(
            'Rating: $rating',
            style: TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildMoveTable() {
    final moves = _currentMoveList.split(' ')
      .where((move) => move.isNotEmpty && !RegExp(r'^\d+\.').hasMatch(move))
      .toList();
    final rows = <TableRow>[];

    for (int i = 0; i < moves.length; i += 2) {
      final moveNumber = (i ~/ 2) + 1;
      final whiteMove = moves[i];
      final blackMove = i + 1 < moves.length ? moves[i + 1] : '';

      rows.add(TableRow(
        children: [
          _buildMoveCell(moveNumber.toString()),
          _buildMoveCell(whiteMove),
          _buildMoveCell(blackMove),
        ],
      ));
    }

    return Table(
      border: TableBorder.all(color: Colors.black),
      columnWidths: {
        0: FixedColumnWidth(50), // Wider column for move numbers
        1: FlexColumnWidth(),
        2: FlexColumnWidth(),
      },
      children: rows,
    );
  }

  Widget _buildMoveCell(String text) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      alignment: Alignment.center,
      child: Text(
        text,
        style: TextStyle(fontSize: 16),
      ),
    );
  }
}
