import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluter_chat_app_provider/providers/chat_provider.dart';
import 'package:fluter_chat_app_provider/screens/login_screen.dart';
import 'package:fluter_chat_app_provider/screens/search_screen.dart';
import 'package:provider/provider.dart';

import '../widget/chat_tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _auth = FirebaseAuth.instance;
  User? loggedInUser;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() {
    final user = _auth.currentUser;
    if (user != null) {
      setState(() {
        loggedInUser = user;
      });
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    }
  }

  Future<Map<String, dynamic>> _fetchChatData(String chatId) async {
    try {
      final chatDoc = await FirebaseFirestore.instance.collection('chats').doc(chatId).get();
      final chatData = chatDoc.data();
      if (chatData == null) return {};

      final users = chatData['users'] as List<dynamic>;
      final receiverId = users.firstWhere((id) => id != loggedInUser!.uid);

      final userDoc = await FirebaseFirestore.instance.collection('users').doc(receiverId).get();
      final userData = userDoc.data();
      if (userData == null) return {};

      final unreadMessagesQuery = FirebaseFirestore.instance
          .collection('messages')
          .where('chatId', isEqualTo: chatId)
          .where('isRead', isEqualTo: false)
          .where('receiverId', isEqualTo: loggedInUser!.uid);

      final unreadMessages = await unreadMessagesQuery.get();
      final unreadCount = unreadMessages.size;

      return {
        'chatId': chatId,
        'lastMessage': chatData['lastMessage'] ?? '',
        'timestamp': chatData['timestamp']?.toDate() ?? DateTime.now(),
        'userData': userData,
        'unreadCount': unreadCount,
      };
    } catch (e) {
      print('Error fetching chat data: $e');
      return {};
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.purple[50],
      appBar: AppBar(
        backgroundColor: isDarkMode ? Colors.grey[900] : Colors.purple[800],
        title: Text(
          "Chats",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await _auth.signOut();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
                    (Route<dynamic> route) => false,
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: chatProvider.getChats(loggedInUser!.uid),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                final chatDocs = snapshot.data!.docs;
                return FutureBuilder<List<Map<String, dynamic>>>(
                  future: Future.wait(
                    chatDocs.map((chatDoc) => _fetchChatData(chatDoc.id)),
                  ),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(child: CircularProgressIndicator());
                    }
                    final chatDataList = snapshot.data!;
                    return ListView.builder(
                      itemCount: chatDataList.length,
                      itemBuilder: (context, index) {
                        final chatData = chatDataList[index];
                        return ChatTile(
                          chatId: chatData['chatId'] ?? '',
                          lastMessage: chatData['lastMessage'] ?? 'No message',
                          timestamp: chatData['timestamp'] ?? DateTime.now(),
                          receiverData: chatData['userData'] ?? {},
                          unreadCount: chatData['unreadCount'] ?? 0,
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SearchScreen()),
          );
        },
        backgroundColor: isDarkMode ? Colors.purple[400] : Colors.purple[600],
        child: Icon(Icons.search, size: 30, color: Colors.white),
      ),
    );
  }
}
