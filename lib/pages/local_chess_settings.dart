import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_chess_board/flutter_chess_board.dart';

class SettingsPage extends StatelessWidget {
  // async Function getCurrentPGN (){

  // }
  // Function getCurrentFEN
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Center(
        child: Text('Settings Page'),
      ),
    );
  }
}
