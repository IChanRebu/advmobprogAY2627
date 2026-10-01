import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import '../models/message.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final firebase_auth.FirebaseAuth _firebaseAuth =
      firebase_auth.FirebaseAuth.instance;

  Stream<List<Map<String, dynamic>>> getUsersStream() {
    return _firestore.collection('users').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['uid'] ??= doc.id;
        return data;
      }).toList();
    });
  }

  Future<void> sendMessage(String receiverId, String message) async {
    final currentUser = _firebaseAuth.currentUser;
    if (currentUser == null || message.trim().isEmpty) return;

    final currentUserId = currentUser.uid;
    final currentUserEmail = currentUser.email ?? '';
    final timestamp = Timestamp.now();

    final chatRoomId = _chatRoomId(currentUserId, receiverId);
    final messageModel = MessageModel(
      senderId: currentUserId,
      senderEmail: currentUserEmail,
      receiverId: receiverId,
      message: message.trim(),
      timestamp: timestamp,
      status: 'sending',
    );

    final docRef = await _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .add(messageModel.toMap());

    await docRef.update({'status': 'sent'});
  }

  Stream<List<MessageModel>> getMessages(String userId, String otherUserId) {
    final chatRoomId = _chatRoomId(userId, otherUserId);

    return _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => MessageModel.fromMap(doc.data(), doc.id))
              .toList();
        });
  }

  Future<String?> getUserByEmail(String email) async {
    final result = await _firestore
        .collection('Users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (result.docs.isEmpty) return null;

    final data = result.docs.first.data();
    return data['uid'] ?? result.docs.first.id;
  }

  String _chatRoomId(String userId, String otherUserId) {
    final ids = [userId, otherUserId];
    ids.sort();
    return ids.join('_');
  }
}
