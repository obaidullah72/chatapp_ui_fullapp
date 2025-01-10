import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import intl package
import '../screens/chatscreen.dart';

class ChatTile extends StatelessWidget {
  final String chatId;
  final String lastMessage;
  final DateTime timestamp;
  final Map<String, dynamic> receiverData;
  final int unreadCount; // Add unreadCount as a parameter

  const ChatTile({
    super.key,
    required this.chatId,
    required this.lastMessage,
    required this.timestamp,
    required this.receiverData,
    required this.unreadCount, // Add unreadCount as a parameter
  });

  @override
  Widget build(BuildContext context) {
    final receiverName = receiverData['name'] ?? 'Unknown';
    final receiverAvatarUrl = receiverData['imageUrl'] ?? '';

    // Format timestamp to 12-hour format with AM/PM
    final formattedTimestamp = DateFormat('hh:mm a').format(timestamp);

    return lastMessage.isNotEmpty
        ? Card(
      elevation: 5,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: receiverAvatarUrl.isNotEmpty
              ? NetworkImage(receiverAvatarUrl)
              : null,
          child: receiverAvatarUrl.isEmpty ? Text(receiverName[0]) : null,
        ),
        title: Text(
          receiverName,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          lastMessage,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (unreadCount > 0)
              CircleAvatar(
                radius: 12,
                backgroundColor: Colors.red,
                child: Text(
                  '$unreadCount',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            SizedBox(height: unreadCount > 0 ? 5 : 0),
            Text(
              formattedTimestamp,
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(
                chatId: chatId,
                receiverId: receiverData['uid'],
              ),
            ),
          );
        },
      ),
    )
        : SizedBox.shrink(); // Return SizedBox.shrink() instead of an empty container
  }
}
