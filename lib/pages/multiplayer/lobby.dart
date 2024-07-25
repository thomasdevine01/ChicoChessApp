import 'package:flutter/material.dart';
import 'package:chico_chess_connect/pages/multiplayer.dart';
import 'package:uuid/uuid.dart';

class Lobby extends StatelessWidget {
  final TextEditingController _gameIdController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Multiplayer Chess'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _gameIdController,
              decoration: const InputDecoration(
                labelText: 'Enter Game ID to Join',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (_gameIdController.text.isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MultiplayerChessBoardScreen(
                        gameId: _gameIdController.text,
                      ),
                    ),
                  );
                }
              },
              child: const Text('Join Game'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final newGameId = const Uuid().v4();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MultiplayerChessBoardScreen(
                      gameId: newGameId,
                    ),
                  ),
                );
              },
              child: const Text('Create New Game'),
            ),
          ],
        ),
      ),
    );
  }
}
