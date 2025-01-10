import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluter_chat_app_provider/widget/push_notification_service.dart';
import 'package:flutter/material.dart';

class ChatProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream to get all chats for a user
  Stream<QuerySnapshot> getChats(String userId) {
    return _firestore
        .collection("chats")
        .where('users', arrayContains: userId)
        .snapshots();
  }

  // Stream to search users based on query
  Stream<QuerySnapshot> searchUsers(String query) {
    return _firestore
        .collection("users")
        .where('email', isGreaterThanOrEqualTo: query)
        .where('email', isLessThanOrEqualTo: query + '\uf8ff')
        .snapshots();
  }

  Future<void> sendMessage(String chatId, String message, String receiverId) async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      // Assuming the displayName is always set for the user
      final senderName = currentUser.displayName ?? 'Anonymous';

      // Send message to the chat collection with 'read' initialized to false
      await _firestore.collection('chats').doc(chatId).collection('messages').add({
        'senderId': currentUser.uid,
        'receiverId': receiverId,
        'messageBody': message,
        'timestamp': FieldValue.serverTimestamp(),
        'read': false,  // Initialize 'read' as false for new messages
      });

      // Send push notification to the receiver with the sender's name as the title
      await PushNotificationService().sendPushNotification(
        token: 'chat$receiverId', // Adjust token logic based on your implementation
        title: senderName, // Use current user's name as the title
        body: message, // Message content
      );

      // Update chat document with last message and timestamp
      await _firestore.collection('chats').doc(chatId).set({
        'users': [currentUser.uid, receiverId],
        'lastMessage': message,
        'timestamp': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Increment unread count for the receiver (implementation required)
    }
  }




  // Get or create a chat room between the current user and receiver
  Future<String?> getChatRoom(String receiverId) async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      final chatQuery = await _firestore.collection('chats').where('users', arrayContains: currentUser.uid).get();
      final chats = chatQuery.docs.where((chat) => chat['users'].contains(receiverId)).toList();

      if (chats.isNotEmpty) {
        return chats.first.id;
      }
    }
    return null;
  }

  // Create a new chat room if it doesn't exist, and initialize unread count fields
  Future<String> createChatRoom(String receiverId) async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      final chatRoom = await _firestore.collection('chats').add({
        'users': [currentUser.uid, receiverId],
        'lastMessage': '',
        'timestamp': FieldValue.serverTimestamp(),
        'unreadCount_${currentUser.uid}': 0,  // Initialize unread count for current user
        'unreadCount_$receiverId': 0,  // Initialize unread count for receiver
      });
      return chatRoom.id;
    }
    throw Exception('Current User is Null');
  }

// // Update unread count when the receiver has not read the message
//   Future<void> updateUnreadCount(String chatId, String receiverId) async {
//     final currentUser = _auth.currentUser;
//     if (currentUser != null) {
//       final currentUserId = currentUser.uid;
//
//       // Increment unread count for the receiver
//       await _firestore.collection('chats').doc(chatId).update({
//         'unreadCount_$receiverId': FieldValue.increment(1),  // Increment unread count for receiver
//       });
//
//       // Increment unread count for the current user (if they haven't read it yet)
//       await _firestore.collection('chats').doc(chatId).update({
//         'unreadCount_$currentUserId': FieldValue.increment(1),  // Increment unread count for current user
//       });
//     }
//   }
//
// // Fetch the unread count for the user
//   Future<int> getUnreadCount(String chatId, String userId) async {
//     final chatDoc = await _firestore.collection('chats').doc(chatId).get();
//     final unreadCount = chatDoc.data()?['unreadCount_$userId'] ?? 0;
//     return unreadCount;
//   }


  // Store the unread count for chats
  Map<String, int> _unreadCounts = {};

  // Get unread count for a specific chat
  int getUnreadCount(String chatId) {
    return _unreadCounts[chatId] ?? 0;
  }

  // Update unread count for a chat
  void updateUnreadCount(String chatId, int count) {
    _unreadCounts[chatId] = count;
    notifyListeners();
  }

  // Mark messages as read and update the unread count
  Future<void> markMessagesAsRead(String chatId, String userId) async {
    // Mark messages as read in Firestore
    final chatRef = FirebaseFirestore.instance.collection('chats').doc(chatId);
    final messagesRef = chatRef.collection('messages');
    final unreadMessages = await messagesRef
        .where('read', isEqualTo: false)
        .where('senderId', isNotEqualTo: userId)
        .get();

    for (var message in unreadMessages.docs) {
      await message.reference.update({'read': true});
    }

    updateUnreadCount(chatId, 0); // Reset unread count after marking as read
  }

}

