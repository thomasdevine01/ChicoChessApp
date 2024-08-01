import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _lichessController = TextEditingController();
  String? _errorMessage;
  Map<String, dynamic>? _playerData;
  String _currentAction = ''; // Track the action (Player 1 or Player 2)

  Future<void> _fetchPlayerData(String username) async {
    try {
      final response = await http.get(Uri.parse('https://lichess.org/api/user/$username'));
      if (response.statusCode == 200) {
        setState(() {
          _playerData = json.decode(response.body);
          _errorMessage = null;
        });

        // Save username to SharedPreferences based on the action
        SharedPreferences prefs = await SharedPreferences.getInstance();
        if (_currentAction == 'Player1') {
          await prefs.setString('player1Username', username);
        } else if (_currentAction == 'Player2') {
          await prefs.setString('player2Username', username);
        }
      } else {
        throw Exception('Failed to load player data.');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _playerData = null;
      });
    }
  }

  String _formatRating(int? rating) {
    return rating != null ? rating.toString() : 'N/A';
  }

  void _handleConnectPlayer(String player) {
    setState(() {
      _currentAction = player;
    });
    _fetchPlayerData(_lichessController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.grey[850],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_errorMessage != null)
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            TextField(
              controller: _lichessController,
              decoration: InputDecoration(
                labelText: 'Lichess Username',
                labelStyle: const TextStyle(color: Colors.white),
                filled: true,
                fillColor: Colors.transparent,
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
              style: const TextStyle(color: Colors.white),
              cursorColor: Colors.white,
              onSubmitted: (username) => _handleConnectPlayer('Player1'),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 350,
              child: ElevatedButton(
                onPressed: () => _handleConnectPlayer('Player1'),
                child: const Text('Connect Player 1', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[850],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 350,
              child: ElevatedButton(
                onPressed: () => _handleConnectPlayer('Player2'),
                child: const Text('Connect Player 2', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[850],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (_playerData != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Rapid Rating: ${_formatRating(_playerData?['perfs']?['rapid']?['rating'])}', style: const TextStyle(color: Colors.white)),
                  Text('Blitz Rating: ${_formatRating(_playerData?['perfs']?['blitz']?['rating'])}', style: const TextStyle(color: Colors.white)),
                  Text('Bullet Rating: ${_formatRating(_playerData?['perfs']?['bullet']?['rating'])}', style: const TextStyle(color: Colors.white)), // Added Bullet Rating
                ],
              ),
          ],
        ),
      ),
    );
  }
}
