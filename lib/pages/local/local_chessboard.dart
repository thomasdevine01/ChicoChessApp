import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_chess_board/flutter_chess_board.dart';
import 'package:chico_chess_connect/pages/local/local_chess_settings.dart';
import 'dart:async'; // Import this for the Timer class
import 'package:http/http.dart' as http;
import 'dart:convert';

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
  late Stopwatch whiteTimer;
  late Stopwatch blackTimer;
  late String whiteTimerString = "00:00";
  late String blackTimerString = "00:00";
  String player1Username = 'Player 1'; // Default username
  String player2Username = 'Player 2'; // Default username
  String whitePlayerRating = 'Unknown'; // Default rating
  String blackPlayerRating = 'Unknown'; // Default rating

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _initializeTimers();
    _loadUsernames(); // Load usernames from SharedPreferences
  }

  _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _boardColor = prefs.getString('boardColor') ?? 'green';
    });
  }

  _loadUsernames() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      player1Username = prefs.getString('player1Username') ?? 'Player 1';
      player2Username = prefs.getString('player2Username') ?? 'Player 2';
      _fetchPlayerData(player1Username, 'white');
      _fetchPlayerData(player2Username, 'black');
    });
  }

  Future<void> _fetchPlayerData(String username, String color) async {
    if (username == 'Player 1' || username == 'Player 2') return; // Skip if default usernames

    try {
      final response = await http.get(Uri.parse('https://lichess.org/api/user/$username'));
      if (response.statusCode == 200) {
        final playerData = json.decode(response.body);
        final rapidRating = playerData['perfs']?['rapid']?['rating'] ?? 'Unknown';

        setState(() {
          if (color == 'white') {
            whitePlayerRating = rapidRating.toString();
            player1Username = username;
          } else if (color == 'black') {
            blackPlayerRating = rapidRating.toString();
            player2Username = username;
          }
        });
      }
    } catch (e) {
      setState(() {
        if (color == 'white') {
          whitePlayerRating = 'Unknown';
        } else if (color == 'black') {
          blackPlayerRating = 'Unknown';
        }
      });
    }
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
      _toggleTimers();
    });

    // Auto-scroll to the bottom
    _scrollToBottom();
  }

  void _initializeTimers() {
    whiteTimer = Stopwatch();
    blackTimer = Stopwatch();
    whiteTimer.start();
    _startTimer();
  }

  void _startTimer() {
    Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (playerTurn) {
          whiteTimerString = _formatDuration(whiteTimer.elapsed);
        } else {
          blackTimerString = _formatDuration(blackTimer.elapsed);
        }
      });
    });
  }

  void _toggleTimers() {
    if (playerTurn) {
      blackTimer.stop();
      whiteTimer.start();
    } else {
      whiteTimer.stop();
      blackTimer.start();
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  void _scrollToBottom() {
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
        title: const Text('Chess Game', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.grey[850], // Grey background for the AppBar
        iconTheme: IconThemeData(color: Colors.white), // White icons
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
      body: Container(
        color: Colors.blueGrey, // Midnight Blue background
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildPlayerInfo(player2Username, blackPlayerRating, isTop: true),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    blackTimerString,
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildPlayerInfo(player1Username, whitePlayerRating, isTop: false),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    whiteTimerString,
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Text(
                  playerTurn ? "White's Turn" : "Black's Turn",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Padding(
                  padding: const EdgeInsets.only(top: 4.0), // Adjust top padding to fit the thick line
                  child: Column(
                    children: [
                      Center(
                        child: _buildMoveTable(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerInfo(String username, String rating, {required bool isTop}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            username,
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          Text(
            'Rating: $rating',
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildMoveTable() {
    final moves = _currentMoveList
        .split(' ')
        .where((move) => move.isNotEmpty && !RegExp(r'^\d+\.').hasMatch(move))
        .toList();
    final rows = <TableRow>[];

    // Add the initial row to ensure there is at least one row with three cells
    if (moves.isEmpty) {
      rows.add(TableRow(children: [
        _buildMoveCell('1.'),
        _buildMoveCell(''),
        _buildMoveCell(''),
      ]));
    } else {
      // Add actual moves
      for (int i = 0; i < moves.length; i += 2) {
        final whiteMove = moves[i];
        final blackMove = i + 1 < moves.length ? moves[i + 1] : '';

        rows.add(TableRow(
          children: [
            _buildMoveCell('${(i / 2 + 1).ceil()}.'),
            _buildMoveCell(whiteMove),
            _buildMoveCell(blackMove),
          ],
        ));
      }
    }

    return Table(
      columnWidths: {
        0: FixedColumnWidth(60), // Adjust the width for move numbers
        1: FlexColumnWidth(),
        2: FlexColumnWidth(),
      },
      border: TableBorder.all(color: Colors.grey[850]!, width: 1), // Grey[850] border color
      children: rows,
    );
  }

  Widget _buildMoveCell(String move) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        move,
        style: TextStyle(color: Colors.white, fontSize: 16),
        textAlign: TextAlign.center,
      ),
    );
  }
}
