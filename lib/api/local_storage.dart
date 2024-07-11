import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:core';
import 'dart:convert';

class FileStorage {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/input.txt');
  }

  Future<void> writeSetting(String setting, String option) async {
    try {
      final file = await _localFile;
      String jsonString = json.encode({setting: option});
      await file.writeAsString(jsonString);
    } catch (e) {
      if (kDebugMode) {
        print('writeCounter error: $e');
      }
    }
  }

  Future<int> readSetting(String setting) async {
    try {
      final file = await _localFile;
      final contents = await file.readAsString();
      var counterData = json.decode(contents);
      return counterData['counter'];
    } catch (e) {
      return 0;
    }
  }
}
