import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/theme_provider.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  // Fetch user name from Firestore
  Future<String> getUserName() async {
    User? user = FirebaseAuth.instance.currentUser;
// FirebaseMessaging.instance.subscribeToTopic('chat${user!.uid}');
    if (user == null) {
      return 'No user found';
    }

    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (userDoc.exists && userDoc.data() != null) {
      FirebaseMessaging.instance.subscribeToTopic('chat${userDoc['uid']}');
      return userDoc['name'] ?? 'Your Name';

    } else {
      return 'Your Name';
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        body: Center(
          child:
              Text('No user is logged in. Please log in to view the profile.'),
        ),
      );
    }

    return FutureBuilder<String>(
      future: getUserName(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        String userName = snapshot.data ?? 'Your Name';

        return Scaffold(
          backgroundColor:
              themeProvider.isDarkMode ? Color(0xFF212121) : Color(0xFFF8F8F8),
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Color(0xFF6A1B9A),
            title: Text(
              'Profile',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            centerTitle: true,
          ),
          body: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: 40, horizontal: 80),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF8E44AD), Color(0xFF6A1B9A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(
                        'https://via.placeholder.com/150',
                      ),
                      backgroundColor: Colors.white,
                    ),
                    SizedBox(height: 15),
                    Text(
                      userName,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      user.email ?? 'your.email@example.com',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  children: [
                    _buildListTile(
                      context,
                      icon: Icons.notifications,
                      title: 'Notifications',
                      onTap: () => _showNotificationsDialog(context),
                    ),
                    _buildDivider(),
                    _buildListTile(
                      context,
                      icon: Icons.lock,
                      title: 'Privacy',
                      onTap: () => _showBottomSheet(context, 'Privacy'),
                    ),
                    // _buildDivider(),
                    // _buildListTile(
                    //   context,
                    //   icon: Icons.music_note,
                    //   title: 'Ringtones',
                    //   onTap: () => _showBottomSheet(context, 'Ringtones'),
                    // ),
                    _buildDivider(),
                    _buildListTile(
                      context,
                      icon: Icons.language,
                      title: 'Language',
                      onTap: () => _showLanguageSelector(context),
                    ),
                    _buildDivider(),
                    _buildListTile(
                      context,
                      icon: Icons.help_outline,
                      title: 'Help & Support',
                      onTap: () => _showHelpSupportDialog(context),
                    ),
                    _buildDivider(),
                    _buildListTile(
                      context,
                      icon: Icons.info_outline,
                      title: 'About Us',
                      onTap: () => _showAboutUsDialog(context),
                    ),
                    _buildDivider(),
                    ListTile(
                      leading: Icon(
                        themeProvider.isDarkMode
                            ? Icons.dark_mode
                            : Icons.light_mode,
                        color: themeProvider.isDarkMode
                            ? Colors.yellow
                            : Colors.blueGrey,
                      ),
                      title: Text(
                        'Dark Mode',
                        style: TextStyle(
                          color: themeProvider.isDarkMode
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                      onTap: () {
                        themeProvider.toggleTheme();
                      },
                    ),
                    _buildDivider(),
                    _buildListTile(
                      context,
                      icon: Icons.logout,
                      title: 'Logout',
                      iconColor: Colors.red,
                      titleColor: Colors.red,
                      onTap: () async {
                        await FirebaseAuth.instance.signOut();
                        FirebaseMessaging.instance.unsubscribeFromTopic('chat${user.uid}');
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => LoginScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showBottomSheet(BuildContext context, String title) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      backgroundColor: Color(0xFF6A1B9A),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Details about $title will be displayed here. You can customize this content.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Color(0xFF6A1B9A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                child: Text('Close'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showLanguageSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      backgroundColor: Color(0xFF6A1B9A),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select Language',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 10),
              ...['English', 'Spanish', 'French', 'German', 'Chinese']
                  .map((lang) => ListTile(
                        title: Text(
                          lang,
                          style: TextStyle(color: Colors.white),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          // Handle language selection
                        },
                      ))
                  .toList(),
            ],
          ),
        );
      },
    );
  }

  void _showNotificationsDialog(BuildContext context) {
    bool isNotificationsEnabled = true; // This could be managed via state

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      backgroundColor: Color(0xFF6A1B9A),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Notifications',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Enable Notifications',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      Switch(
                        value: isNotificationsEnabled,
                        onChanged: (value) {
                          setState(() {
                            isNotificationsEnabled = value;
                          });
                        },
                        activeColor: Colors.white,
                        activeTrackColor: Colors.purpleAccent,
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildListTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color iconColor = const Color(0xFF8E44AD),
    Color titleColor = Colors.black,
  }) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return ListTile(
      leading: Icon(icon,
          color: themeProvider.isDarkMode ? Colors.white : iconColor),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: themeProvider.isDarkMode ? Colors.white : titleColor,
        ),
      ),
      trailing: Icon(Icons.arrow_forward_ios,
          color: themeProvider.isDarkMode ? Colors.white : Colors.grey),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return Divider(
      color: Colors.grey.shade300,
      thickness: 1,
      height: 1,
    );
  }
  void _showAboutUsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Color(0xFF8E44AD),
          title: Center(
            child: Text(
              'About Us',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
          ),
          content: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'This app is designed to provide a seamless and efficient communication experience. We aim to bring users together with easy-to-use chat features, ensuring privacy and security for all.',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          actions: [
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Color(0xFF6A1B9A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  'Close',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showHelpSupportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Color(0xFF8E44AD),
          title: Center(
            child: Text(
              'Help & Support',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Need assistance? Reach out to us through the options below:',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 15),
              _buildSupportButton(
                context,
                label: 'Contact Number: +123 456 7890',
                onPressed: () {
                  // Add action for contact number
                },
              ),
              _buildSupportButton(
                context,
                label: 'Email: support@example.com',
                onPressed: () {
                  // Add action for email
                },
              ),
              _buildSupportButton(
                context,
                label: 'Website: www.example.com',
                onPressed: () {
                  // Add action for website
                },
              ),
            ],
          ),
          actions: [
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Color(0xFF6A1B9A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  'Close',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSupportButton(BuildContext context,
      {required String label, required VoidCallback onPressed}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF6A1B9A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          elevation: 5,
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

}
