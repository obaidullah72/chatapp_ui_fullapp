import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluter_chat_app_provider/providers/chat_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/theme_provider.dart';

class ChatScreen extends StatefulWidget {
  final String? chatId;
  final String receiverId;
  // final String receivername;

  const ChatScreen({super.key, this.chatId, required this.receiverId,});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  String? chatId;
  User? loggedInUser;

  @override
  void initState() {
    super.initState();
    chatId = widget.chatId;
    getCurrentUser();
  }

  void getCurrentUser() {
    final user = _auth.currentUser;
    if (user != null) {
      setState(() {
        loggedInUser = user;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final textController = TextEditingController();

    return FutureBuilder<DocumentSnapshot>(
      future: _firestore.collection('users').doc(widget.receiverId).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          final receiverData = snapshot.data!.data() as Map<String, dynamic>;

          return Scaffold(
            backgroundColor: isDarkMode
                ? Colors.black
                : const Color(0xFFF5F5F5), // Dynamic background
            appBar: AppBar(
              elevation: 0,
              backgroundColor: isDarkMode ? Colors.grey[900] : Colors.purple[800],
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              title: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: receiverData['imageUrl'] != null &&
                        receiverData['imageUrl'].isNotEmpty
                        ? NetworkImage(receiverData['imageUrl'])
                        : const AssetImage('assets/profile_person.jpg')
                    as ImageProvider,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    receiverData['name'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            body: Column(
              children: [
                Expanded(
                  child: chatId != null && chatId!.isNotEmpty
                      ? MessageStream(
                    chatId: chatId!,
                    onReadMessages: _markMessagesAsRead,
                  )
                      : Center(
                    child: Text(
                      "No messages yet",
                      style: TextStyle(
                        color: isDarkMode ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey[850] : Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: isDarkMode ? Colors.black45 : Colors.black12,
                        blurRadius: 8,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: textController,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 15,
                            ),
                            hintText: "Enter your message...",
                            hintStyle: TextStyle(
                              color: isDarkMode ? Colors.white60 : Colors.black54,
                            ),
                            filled: true,
                            fillColor: isDarkMode
                                ? Colors.grey[800]
                                : const Color(0xFFF0F0F0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () async {
                          if (textController.text.isNotEmpty) {
                            if (chatId == null || chatId!.isEmpty) {
                              chatId = await chatProvider.createChatRoom(
                                  widget.receiverId);
                            }
                            if (chatId != null) {
                              chatProvider.sendMessage(
                                chatId!,
                                textController.text,
                                widget.receiverId,
                                // widget.receivername,
                              );
                              textController.clear();
                            }
                          }
                        },
                        child: CircleAvatar(
                          radius: 22,
                          backgroundColor: Colors.purple[600],
                          child: const Icon(
                            Icons.send,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
        return Scaffold(
          appBar: AppBar(),
          body: const Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }

  Future<void> _markMessagesAsRead() async {
    if (chatId != null) {
      await Provider.of<ChatProvider>(context, listen: false)
          .markMessagesAsRead(chatId!, loggedInUser!.uid);
    }
  }
}


class MessageStream extends StatelessWidget {
  final String chatId;
  final Function onReadMessages;

  const MessageStream({
    super.key,
    required this.chatId,
    required this.onReadMessages,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        final messages = snapshot.data!.docs;
        List<MessageBubble> messageWidgets = messages.map((message) {
          final messageData = message.data() as Map<String, dynamic>;

          // Ensure 'read' field exists, otherwise default to false
          final isRead = messageData['read'] ?? false;

          return MessageBubble(
            sender: messageData['senderId'],
            text: messageData['messageBody'],
            isMe: FirebaseAuth.instance.currentUser!.uid == messageData['senderId'],
            timestamp: messageData['timestamp'] ?? FieldValue.serverTimestamp(),
            isRead: isRead,
          );
        }).toList();

        // Check unread count for the user in the chat
        final unreadMessages = messages.where((msg) => !(msg['read'] ?? false)).toList();
        if (unreadMessages.isNotEmpty) {
          Provider.of<ChatProvider>(context, listen: false)
              .updateUnreadCount(chatId, unreadMessages.length);
        }

        return ListView(
          reverse: true,
          children: messageWidgets,
        );
      },
    );
  }
}

class MessageBubble extends StatelessWidget {
  final String sender;
  final String text;
  final bool isMe;
  final dynamic timestamp;
  final bool isRead;

  const MessageBubble({
    super.key,
    required this.sender,
    required this.text,
    required this.isMe,
    this.timestamp,
    required this.isRead,
  });

  @override
  Widget build(BuildContext context) {
    final messageTime =
    (timestamp is Timestamp) ? timestamp.toDate() : DateTime.now();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Column(
        crossAxisAlignment:
        isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: isMe ? Colors.purple[600] : Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(2, 2),
                ),
              ],
            ),
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  text,
                  style: TextStyle(
                    color: isMe ? Colors.white : Colors.black87,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  '${messageTime.hour}:${messageTime.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(
                    color: isMe ? Colors.white70 : Colors.black54,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
