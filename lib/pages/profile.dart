import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _lichessController = TextEditingController();
  final TextEditingController _chessComController = TextEditingController();
  User? user;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    user = _auth.currentUser;
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    if (user != null) {
      DocumentSnapshot userProfile =
          await _firestore.collection('users').doc(user!.uid).get();
      if (userProfile.exists) {
        Map<String, dynamic> data = userProfile.data() as Map<String, dynamic>;
        _lichessController.text = data['lichessUsername'] ?? '';
        _chessComController.text = data['chessComUsername'] ?? '';
      }
    }
  }

  Future<void> _updateUserProfile() async {
    try {
      await _firestore.collection('users').doc(user!.uid).set({
        'lichessUsername': _lichessController.text,
        'chessComUsername': _chessComController.text,
      }, SetOptions(merge: true));
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_errorMessage != null)
              Text(
                _errorMessage!,
                style: TextStyle(color: Colors.red),
              ),
            TextField(
              controller: _lichessController,
              decoration: InputDecoration(labelText: 'Lichess Username'),
            ),
            TextField(
              controller: _chessComController,
              decoration: InputDecoration(labelText: 'Chess.com Username'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateUserProfile,
              child: Text('Update Profile'),
            ),
          ],
        ),
      ),
    );
  }
}
