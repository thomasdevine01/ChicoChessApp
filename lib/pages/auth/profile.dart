import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
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
          await _firestore.collection('user_data').doc(user!.email).get();
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
        'lichess_username': _lichessController.text,
        'chess_com_username': _chessComController.text,
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
        title: const Text('Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_errorMessage != null)
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            TextField(
              controller: _lichessController,
              decoration: const InputDecoration(labelText: 'Lichess Username'),
            ),
            TextField(
              controller: _chessComController,
              decoration:
                  const InputDecoration(labelText: 'Chess.com Username'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateUserProfile,
              child: const Text('Update Profile'),
            ),
          ],
        ),
      ),
    );
  }
}
