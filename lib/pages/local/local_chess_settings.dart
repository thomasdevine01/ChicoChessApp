import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
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
        title: const Text('Settings', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.grey[850], // Grey background for the AppBar
        iconTheme: const IconThemeData(color: Colors.white), // White icons
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Board Color Dropdown
            Text(
              'Board Color:',
              style: const TextStyle(color: Colors.white, fontSize: 24),
            ),
            const SizedBox(height: 16), // Space between text and dropdown
            Container(
              width: 350, // Set the width of the dropdown
              child: DropdownButtonFormField<String>(
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
                    child: Text(
                      value,
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                }).toList(),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[850], // Background color for the dropdown before click
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4.0),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
                ),
                dropdownColor: Colors.grey[850], // Dropdown background color when clicked
                iconEnabledColor: Colors.white, // Dropdown icon color
              ),
            ),
            const SizedBox(height: 32), // Space between dropdown and button
            ElevatedButton(
              onPressed: () async {
                String pgnList = await _getPGN();
                await Clipboard.setData(ClipboardData(text: pgnList));
              },
              child: const Text('Copy PGN', style: TextStyle(color: Colors.white)), // Text color
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[850], // Button background color
                minimumSize: const Size(350, 36), // Button width and height
              ),
            ),
          ],
        ),
      ),
    );
  }
}
