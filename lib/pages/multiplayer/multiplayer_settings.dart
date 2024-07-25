import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

class MultiplayerSettingsPage extends StatefulWidget {
  const MultiplayerSettingsPage({super.key});
  @override
  _MultiplayerSettingsPageState createState() =>
      _MultiplayerSettingsPageState();
}

class _MultiplayerSettingsPageState extends State<MultiplayerSettingsPage> {
  late String _boardColor = 'green';

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

  _saveSettings(String color) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('boardColor', color);
    setState(() {
      _boardColor = color;
    });
  }

  Future<String> _getPGN() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String pgnList = prefs.getString('PGN') ?? 'Null';
    if (pgnList == 'Null' || pgnList.isEmpty) {
      return "Null";
    }
    final String pgn = pgnList;
    return pgn;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Multiplayer Settings'),
      ),
      body: Column(
        children: [
          ListTile(
            title: Text('Board Color'),
            trailing: DropdownButton<String>(
              value: _boardColor,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  _saveSettings(newValue);
                }
              },
              items: <String>[
                'green',
                'brown',
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
          ElevatedButton(
              onPressed: () async {
                String pgnList = await _getPGN();
                await Clipboard.setData(ClipboardData(text: pgnList));
              },
              child: const Text('Copy PGN'))
        ],
      ),
    );
  }
}
