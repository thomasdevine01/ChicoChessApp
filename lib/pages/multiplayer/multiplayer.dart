import 'package:flutter/material.dart';
import 'package:flutter_chess_board/flutter_chess_board.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chico_chess_connect/pages/multiplayer/multiplayer_settings.dart';

class MultiplayerChessBoardScreen extends StatefulWidget {
  final String gameId;
  const MultiplayerChessBoardScreen({super.key, required this.gameId});

  @override
  _MultiplayerChessBoardScreenState createState() =>
      _MultiplayerChessBoardScreenState();
}

class _MultiplayerChessBoardScreenState
    extends State<MultiplayerChessBoardScreen> {
  ChessBoardController controller = ChessBoardController();
  bool showGameState = true;
  String _boardColor = 'green';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late DocumentReference _gameDocRef;
  late String _gameId;
  late String _playerId;
  late String _playerColor = "white";
  bool _isPlayerTurn = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _createOrJoinGame(widget.gameId);
  }

  _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _boardColor = prefs.getString('boardColor') ?? 'green';
    });
  }

  Future<void> _createOrJoinGame(String gameId) async {
    _gameId = gameId;
    _gameDocRef = _firestore.collection('games').doc(_gameId);
    _playerId = 'player1';

    try {
      DocumentSnapshot doc = await _gameDocRef.get();
      if (!doc.exists) {
        await _gameDocRef.set({
          'pgn': '',
          'players': [
            {'id': 'player1', 'color': 'white'},
            {'id': 'player2', 'color': 'black'}
          ],
          'currentTurn': 'white',
          'status': 'ongoing',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        List players = doc['players'];
        _playerColor =
            players.firstWhere((player) => player['id'] == _playerId)['color'];
      }
    } catch (e) {
      // Handle errors
      print('Error creating or joining game: $e');
    }

    // Listen to game updates
    _gameDocRef.snapshots().listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        if (data.containsKey('pgn')) {
          controller.loadPGN(data['pgn']);
        }
        if (data.containsKey('currentTurn')) {
          setState(() {
            _isPlayerTurn = data['currentTurn'] == _playerColor;
          });
        }
      }
    });
  }

  _updatePGN() async {
    final pgn = controller.getSan().fold(
          '',
          (previousValue, element) =>
              previousValue + (element != null ? ' ' + element : ''),
        );
    await _gameDocRef.update({
      'pgn': pgn,
      'currentTurn': _playerColor == 'white' ? 'black' : 'white',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Multiplayer Chess'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MultiplayerSettingsPage(),
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
                onMove: _isPlayerTurn
                    ? () async {
                        await _updatePGN();
                      }
                    : null,
                boardColor: _boardColor == 'green'
                    ? BoardColor.green
                    : BoardColor.brown,
                boardOrientation: _playerColor == 'white'
                    ? PlayerColor.white
                    : PlayerColor.black,
                enableUserMoves: _isPlayerTurn,
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
