import 'package:cloud_firestore/cloud_firestore.dart';

Future<DocumentReference> createGame() async {
  CollectionReference games = FirebaseFirestore.instance.collection('games');
  return await games.add({
    'pgn': '',
    'players': [
      {'id': 'player1', 'color': 'white'},
      {'id': 'player2', 'color': 'black'}
    ],
    'currentTurn': 'white',
    'status': 'ongoing',
    'createdAt': FieldValue.serverTimestamp(),
    'updatedAt': FieldValue.serverTimestamp(),
  });
}

Future<DocumentSnapshot> getGame(String gameId) async {
  DocumentReference gameRef =
      FirebaseFirestore.instance.collection('games').doc(gameId);
  return await gameRef.get();
}

Future<void> updateGame(String gameId, Map<String, dynamic> data) async {
  DocumentReference gameRef =
      FirebaseFirestore.instance.collection('games').doc(gameId);
  return await gameRef.update(data);
}

void listenToGameUpdates(String gameId) {
  DocumentReference gameRef =
      FirebaseFirestore.instance.collection('games').doc(gameId);
  gameRef.snapshots().listen((snapshot) {
    if (snapshot.exists) {
      final data = snapshot.data() as Map<String, dynamic>;
    }
  });
}
