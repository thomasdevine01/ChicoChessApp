import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _errorMessage;

  void _signIn() async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _saveUserProfile() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        await _firestore.collection('users').doc(user.email).set({
          'lichessUsername': "",
          'chessComUsername': "",
        });
        setState(() {
          _errorMessage = null;
        });
      } catch (e) {
        setState(() {
          _errorMessage = "Failed to save profile: $e";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign In', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.grey[850], // Grey background for the AppBar
        iconTheme: const IconThemeData(color: Colors.white), // White icons
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle: TextStyle(color: Colors.white), // White label text
                filled: true,
                fillColor: Colors.transparent, // Transparent background
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
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                labelStyle: TextStyle(color: Colors.white), // White label text
                filled: true,
                fillColor: Colors.transparent, // Transparent background
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
              obscureText: true,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity, // Make the button full width
              child: ElevatedButton(
                onPressed: () {
                  _saveUserProfile();
                  _signIn();
                },
                child: const Text('Sign In', style: TextStyle(color: Colors.white)), // White text
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[850], // Grey background for the button
                  padding: EdgeInsets.symmetric(vertical: 16), // Make the button taller
                ),
              ),
            ),
            if (_errorMessage != null)
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
          ],
        ),
      ),
    );
  }
}
