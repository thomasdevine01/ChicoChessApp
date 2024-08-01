import 'package:flutter/material.dart';
import 'package:chico_chess_connect/pages/multiplayer/multiplayer.dart';
import 'package:uuid/uuid.dart';

class Lobby extends StatelessWidget {
  final TextEditingController _gameIdController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Multiplayer Chess', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.grey[850], // Grey background for the AppBar
        iconTheme: IconThemeData(color: Colors.white), // White icons
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _gameIdController,
              decoration: InputDecoration(
                labelText: 'Enter Game ID to Join',
                labelStyle: TextStyle(color: Colors.white), // White label text
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white), // White border
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white), // White focused border
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white), // White enabled border
                ),
              ),
              style: TextStyle(color: Colors.white), // White input text
              cursorColor: Colors.white, // White cursor color
            ),
            const SizedBox(height: 16),
            _buildButton(context, 'Join Game'),
            const SizedBox(height: 16),
            _buildButton(context, 'Create New Game'),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context, String text) {
    return SizedBox(
      width: double.infinity, // Make the button full width
      child: ElevatedButton(
        onPressed: () {
          if (text == 'Join Game' && _gameIdController.text.isNotEmpty) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MultiplayerChessBoardScreen(
                  gameId: _gameIdController.text,
                ),
              ),
            );
          } else if (text == 'Create New Game') {
            final newGameId = const Uuid().v4();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MultiplayerChessBoardScreen(
                  gameId: newGameId,
                ),
              ),
            );
          }
        },
        child: Text(
          text,
          style: TextStyle(color: Colors.white), // White text
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey[850], // Grey background
          padding: EdgeInsets.symmetric(vertical: 16), // Make the button taller
        ),
      ),
    );
  }
}
