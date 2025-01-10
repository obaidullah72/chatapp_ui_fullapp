import 'dart:convert';
import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PushNotificationService with ChangeNotifier {
  final _firebaseMessaging = FirebaseMessaging.instance;

  // var localDbController = Get.put(LocalDbController());
  // var groupController = Get.put(GroupChatController());
  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> clearNotifications() async {
    log('i am cleaning');
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  Future<void> requestNotificationPermissions() async {
    final PermissionStatus status = await Permission.notification.request();
    if (status.isGranted) {
      // Notification permissions granted
    } else if (status.isDenied) {
      // Notification permissions denied
    } else if (status.isPermanentlyDenied) {
      // Notification permissions permanently denied, open app settings
      await openAppSettings();
    }
  }

  Future<void> initNotifications() async {
    await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: true,
        badge: true,
        carPlay: false,
        criticalAlert: true,
        provisional: false,
        sound: true);

    // fcmToken = await _firebaseMessaging.getToken();
    // SecureStorage().saveFCMToken(fcmToken: fcmToken);
    // log('FCM --> ${fcmToken}');
    // _firebaseMessaging.onTokenRefresh.listen((newToken) async {
    //   fcmToken = newToken;
    //   SecureStorage().saveFCMToken(fcmToken: fcmToken);
    // });

    // await userApiProvider.updateFCMToken(fcmToken: fcmToken!);
    initPushNotifications();
  }

  static Future localNotiInit() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings();

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
      // Handle notification tap
      log('Notification tapped: ${response.payload}');
    });
  }

  static void onNtificationTap(NotificationResponse response) {}

  static Future<void> createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'chatappChannel', // ID of the channel
      'Trade Chat Notifications', // Name of the channel (shown to users)
      description: 'This channel is used for trade chat notifications',
      // Description
      importance: Importance.high, // Importance level
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  Future<void> showNotification(
      RemoteMessage message, bool fromWhereForg) async {
    AndroidNotificationChannel channel = const AndroidNotificationChannel(
      'chatappChannel',
      'Trade Chat Notifications',
      description: 'Notifications for Trade Chat app',
      importance: Importance.max,
      showBadge: true,
      playSound: true,
    );

    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
            channel.id.toString(), channel.name.toString(),
            channelDescription: 'your channel description',
            importance: Importance.high,
            priority: Priority.high,
            playSound: true,
            ticker: 'ticker',
            sound: channel.sound);

    const DarwinNotificationDetails darwinNotificationDetails =
        DarwinNotificationDetails(
            presentAlert: true, presentBadge: true, presentSound: true);

    NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails, iOS: darwinNotificationDetails);

    Future.delayed(Duration.zero, () async {
      flutterLocalNotificationsPlugin.show(
          0,
          message.notification!.title.toString(),
          message.notification!.body.toString(),
          notificationDetails,
          payload: jsonEncode(message.data));
      // final chat = GroupChatModel.fromJson3(message.data);
      //
      // if(chat.groupId!=null)
      //   {
      //
      //   await localDbController.updateChatFromNotify(groupId: chat.groupId??'', msg: chat);
      //   }
    });
  }

  // final SecureStorage secureStorage = SecureStorage();
  late final fcmToken;

  // final UserApiProvider userApiProvider;

  // PushNotificationService() : userApiProvider = UserApiHttpProvider();

  void handleMessages(RemoteMessage? message) {
    if (message == null) return;
    // navigatorKey.currentState?.pushNamed(AppRoutes.chatPage);
  }

  Future initPushNotifications() async {
    FirebaseMessaging.instance.getInitialMessage().then(handleMessages);
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessages);
  }

  Future updateFCMTokenToDB() async {
    // await userApiProvider.updateFCMToken(fcmToken: fcmToken);
  }

  static const String _tokenKey = 'fcm_access_token';
  static const String _expiryKey = 'fcm_token_expiry';

  Future<void> sendPushNotification(
      {required String token,
      required String title,
      required String body,
      // required int createdAt,
      // required int senderId,
      // required String senderName,
      // required String senderImage,
      // required String messageType,
      // required String sendMessage,
      // required GroupChatModel chat,
      // required String chatId,
      }) async {
    try {
      String serveerKey = await getValidToken();
      // String serveerKey = await generateAccessToken();
      log('Sending notifications ${serveerKey}');
      // final groupData = {
      //   'created_at': "${chat.createdAt??0}",
      //   'group_admin_id': "${chat.groupAdminId??0}",
      //   'memberIds': jsonEncode(chat.memberIds ?? []),
      //   'group_last_message': chat.groupLastMessage ?? '',
      //   'group_id': chat.groupId,
      //   'group_image': chat.groupImage ?? '',
      //   'group_members': jsonEncode(chat.groupMembers ?? []),
      //   'group_name': chat.groupName ?? '',
      //   'type': chat.type ?? '',
      //   'statusMembers': jsonEncode(chat.membersStatusList ?? ''),
      //   'isFav': jsonEncode(chat.isFav ?? []),
      //   'isAllDeleteMainChat': jsonEncode(chat.isAllDeleteMainChat ?? []),
      //   'counterMessageNo': jsonEncode(chat.counterMessageNo ?? []),
      //   'allowOthersToAddMembersOrNot': "${chat.allowOthersToAddMembersOrNot ?? 0}"
      // };
      final Map<String, dynamic> notificationData = {
        'message': {
          'topic': '$token',
          'notification': {
            'title': '$title',
            'body': body,
          },
          'android': {
            'priority': 'high',
            'notification': {
              'click_action': 'TOP_STORY_ACTIVITY',
              'channel_id': 'chatappChannel',
              'sound': 'default'
            }
          },
          // 'data':groupData
        },
      };

      // logger.i('Notufy $notificationData');
      final response = await http.post(
        Uri.parse(
            'https://fcm.googleapis.com/v1/projects/flutter-chatapp-f7ffb/messages:send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $serveerKey', // Add your server key here
        },
        body: jsonEncode(notificationData),
      );

      log('response.statusCode ${response.reasonPhrase}');
      if (response.statusCode == 200) {
        print('Notification sent successfully');
      } else {
        print('Failed to send notification: ${response.body}');
      }
    } catch (e) {
      print('Error sending push notification: $e');
    }
  }

  Future forgroundMessage() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<String> generateAccessToken() async {
    // Load the service account key file
    final serviceAccountKey = await _loadServiceAccountKey();

    // Create credentials using the service account key
    var accountCredentials =
        ServiceAccountCredentials.fromJson(serviceAccountKey);

    // Define the required scopes for Firebase Cloud Messaging
    const scopes = ['https://www.googleapis.com/auth/cloud-platform'];

    // Request an OAuth 2.0 access token
    var client = http.Client();
    AccessCredentials credentials =
        await obtainAccessCredentialsViaServiceAccount(
      accountCredentials,
      scopes,
      client,
    );

    client.close();
    await _storeToken(
        credentials.accessToken.data, credentials.accessToken.expiry);

    print('Expiry Date ${credentials.accessToken.expiry}');
    // Return the access token
    return credentials.accessToken.data;
  }

  Future<Map<String, dynamic>> _loadServiceAccountKey() async {
    const String serviceAccountJson = '''
{
  "type": "service_account",
  "project_id": "flutter-chatapp-f7ffb",
  "private_key_id": "262c16b7c458844e4ca714c9ca06170ebfc3d1f3",
  "private_key": "-----BEGIN PRIVATE KEY-----\\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQCy7GkkmRYm74Rb\\nbFaq5780Nu4nEHll9wKDFIOwjCWuTTDIvT8hIlacEUJPTt16F7FL1wvkrZ9sK34W\\nJNNTAmYjday3SVYu9VR3t9hn0TfwJAnpudTel3BBWpb2phwO8yb7GWnvPjhNwInY\\nJvcYs0e4fLujfPSmVbmF6EdwvixR89NzrmEkFHL8Kodbnid31cOWLJwMbwt1idCh\\nVHqVuiPlCysDvsMq//PdLrDPcHba9TYnBsaBRzvqK2TFtVfHzX74pqVxdqag0Yi8\\nuy0pYd795ZPF3Ps8qE1htDPfr95mpo2DJVbLzYEtVXxMQAJK/Jxu8zbLWj6c4VBF\\ndulqCT4VAgMBAAECggEADpgxmGJjV/A0HensztqB8m6jnOyfVmWgXxRSjJlV7oKN\\n3uXu6xM7uNXAkKsIbk/V7q9/IRtXdHGUwpYk5bG9pplP6hBxlvl8dxp4LLm4ZB5w\\nb4/wsOpt5erPgxV4FvEXBibjyPfMjG0O4WKGR83B5SbJgHOuGg5GiIlyoFvmzhVg\\nRZl5k6l+nEZAS5iFd/pGBd+9cp5tZGxzd3qAeWbKoPS1NiyBClHwwpLWo3DXNY1L\\nxTq9YNM6i3S6XNj6CN+283mkpf9RamMFZAnvYfRYpECC7hPWesumLtNgbwNvy6rN\\nrt+7w+huVsaopNyT0zgyGjjVGjN1OiSSCqfhaCfFqQKBgQDcHvYtqXMAHTMJTiWI\\n4KcaOxn50nDi4q0K/W9g+cMuOAWQAug0RrKBVrR3lU/mcSsNdjwF96NYmP5O5W3L\\nlbcn3RKvVXYd0CUNPSm8AT+XlZIQVUkg/KWcAZNd8DyFTbhkDr/Bop+XoCxPtYcT\\nIbTNHp2VZb0aHNUjGldRcmcP7QKBgQDQFmSOLF2Nv1rhtDc8kyXl3ietYRyaY0rr\\nvShZiHYaKsLRIoqSorI5kr6AnY6FWyvlW66BM7YLP0z2xNXIOyZzfxwXK2+OX1Mf\\nAsFMYjlCxQTiPiZsr8zRv9Sh9SfQJKuUg05crnrGBStnomJ2a4uUoWB/Yexs6i2e\\nI3oZk2sRyQKBgQDX3LEUlGDHktry3CTo905H5f+SQ3Iavapu5ZwtIKHsmFm0IXWv\\nlkkFl47A2rcRSJesyu8P9wrEHrz9h/bFOFv2BtGFCi0cDXvYYMulqB/BupcT118w\\nrzKFK/Jlo+rl2xLhZKld7enN2vC5dk4xT9Ord8OXt77bdbz6gKFyqNsy/QKBgF+Q\\niSnKMkTxBrn1XBDTu2nwNuSnXs2AoF3Xh3pm82ZdEQ+e/2kMkzFhtV+3/EY+ctBo\\n5KGtsANGVQBXsZ69m5EbZTk214rZOIFbcI615XpGpVGKHXd43WXO5cZjop8y2CHi\\nk9B4ySW8Jgz4RKQCDB58ZqbZwAzdF4oy3NZ2H4wRAoGAT/vLr7u8IvjiljIr5hzn\\nH7TvTwey6e769ugiFKTTrTIRijPrOdOzccNJeieWGXn5M5iAUW/DIKF3NChlCFBH\\nXLg1DfDwhFXOBSLqIPe93sbFYe7bsRgznKl3Agmy0uohn1IAREdPo2iZPfqGc78b\\nvUy7Rf9TI/cLcmkqAwm2ZAk=\\n-----END PRIVATE KEY-----\\n",
  "client_email": "firebase-adminsdk-kglxp@flutter-chatapp-f7ffb.iam.gserviceaccount.com",
  "client_id": "101420951047318390839",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-kglxp%40flutter-chatapp-f7ffb.iam.gserviceaccount.com",
  "universe_domain": "googleapis.com"
}
''';

    return jsonDecode(serviceAccountJson);
  }

  Future<void> _storeToken(String token, DateTime expiryTime) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_expiryKey, expiryTime.toIso8601String());
  }

  Future<AuthToken?> _retrieveToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString(_tokenKey);
    String? expiryString = prefs.getString(_expiryKey);

    if (token != null && expiryString != null) {
      DateTime expiryTime = DateTime.parse(expiryString);
      return AuthToken(token: token, expiryTime: expiryTime);
    }
    return null;
  }

  Future<String> getValidToken() async {
    AuthToken? storedToken = await _retrieveToken();
    if (storedToken == null ||
        DateTime.now()
            .isAfter(storedToken.expiryTime.subtract(Duration(minutes: 2)))) {
      // Token is missing or about to expire, generate a new one
      return await generateAccessToken();
    }
    // Return the existing token
    return storedToken.token;
  }
}

class AuthToken {
  final String token;
  final DateTime expiryTime;

  AuthToken({required this.token, required this.expiryTime});

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'expiryTime': expiryTime.toIso8601String(),
    };
  }

  factory AuthToken.fromJson(Map<String, dynamic> json) {
    return AuthToken(
      token: json['token'],
      expiryTime: DateTime.parse(json['expiryTime']),
    );
  }
}

//
// import 'dart:convert';
// import 'dart:developer';
// import 'package:flutter/foundation.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:http/http.dart' as http;
// import 'package:path_provider/path_provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:googleapis_auth/auth_io.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:provider/provider.dart';
//
// class PushNotificationService with ChangeNotifier {
//   final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
//   final FlutterLocalNotificationsPlugin _localNotificationsPlugin = FlutterLocalNotificationsPlugin();
//
//   String? _fcmToken;
//   String? get fcmToken => _fcmToken;
//
//   PushNotificationService() {
//     _initNotifications();
//   }
//
//   Future<void> _initNotifications() async {
//     await _requestNotificationPermissions();
//     await _initializeLocalNotifications();
//     await _setupFirebaseMessaging();
//   }
//
//   Future<void> _requestNotificationPermissions() async {
//     final status = await Permission.notification.request();
//     if (status.isDenied || status.isPermanentlyDenied) {
//       await openAppSettings();
//     }
//   }
//
//   Future<void> _initializeLocalNotifications() async {
//     const AndroidInitializationSettings androidInitSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
//     final DarwinInitializationSettings iOSInitSettings = DarwinInitializationSettings();
//     final InitializationSettings initSettings = InitializationSettings(
//       android: androidInitSettings,
//       iOS: iOSInitSettings,
//     );
//
//     await _localNotificationsPlugin.initialize(initSettings,
//         onDidReceiveNotificationResponse: (response) {
//           log('Notification tapped: ${response.payload}');
//         });
//   }
//
//   Future<void> _setupFirebaseMessaging() async {
//     await _firebaseMessaging.requestPermission(
//       alert: true,
//       announcement: true,
//       badge: true,
//       sound: true,
//     );
//
//     _fcmToken = await _firebaseMessaging.getToken();
//     log('FCM Token: $_fcmToken');
//     notifyListeners();
//
//     FirebaseMessaging.onMessage.listen(_onMessage);
//     FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedApp);
//     FirebaseMessaging.instance.getInitialMessage().then(_handleInitialMessage);
//   }
//
//   void _onMessage(RemoteMessage message) {
//     log('Foreground message received: ${message.notification?.title}');
//     _showNotification(message);
//   }
//
//   void _onMessageOpenedApp(RemoteMessage message) {
//     log('Notification opened from background: ${message.notification?.title}');
//     // Handle navigation or other logic here
//   }
//
//   void _handleInitialMessage(RemoteMessage? message) {
//     if (message != null) {
//       log('App opened from terminated state via notification: ${message.notification?.title}');
//       // Handle navigation or other logic here
//     }
//   }
//
//   Future<void> _showNotification(RemoteMessage message) async {
//     const AndroidNotificationChannel channel = AndroidNotificationChannel(
//       'high_importance_channel',
//       'High Importance Notifications',
//       description: 'This channel is used for important notifications.',
//       importance: Importance.high,
//     );
//
//     final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
//       channel.id,
//       channel.name,
//       channelDescription: channel.description,
//       importance: Importance.high,
//       priority: Priority.high,
//     );
//
//     const DarwinNotificationDetails iOSDetails = DarwinNotificationDetails();
//
//     final NotificationDetails notificationDetails = NotificationDetails(
//       android: androidDetails,
//       iOS: iOSDetails,
//     );
//
//     await _localNotificationsPlugin.show(
//       0,
//       message.notification?.title,
//       message.notification?.body,
//       notificationDetails,
//       payload: jsonEncode(message.data),
//     );
//   }
//
//   Future<void> sendPushNotification({
//     required String token,
//     required String title,
//     required String body,
//     Map<String, dynamic>? data,
//   }) async {
//     try {
//       String serverKey = await _getValidToken();
//       final payload = {
//         'to': token,
//         'notification': {
//           'title': title,
//           'body': body,
//         },
//         'data': data ?? {},
//       };
//
//       final response = await http.post(
//         Uri.parse('https://fcm.googleapis.com/fcm/send'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $serverKey',
//         },
//         body: jsonEncode(payload),
//       );
//
//       if (response.statusCode == 200) {
//         log('Notification sent successfully');
//       } else {
//         log('Failed to send notification: ${response.body}');
//       }
//     } catch (e) {
//       log('Error sending push notification: $e');
//     }
//   }
//
//   Future<String> _getValidToken() async {
//     final tokenData = await _retrieveToken();
//     if (tokenData == null || tokenData.isExpired) {
//       return await _generateAccessToken();
//     }
//     return tokenData.token;
//   }
//
//   Future<AuthToken?> _retrieveToken() async {
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString(_tokenKey);
//     final expiryString = prefs.getString(_expiryKey);
//
//     if (token != null && expiryString != null) {
//       final expiryTime = DateTime.parse(expiryString);
//       return AuthToken(token: token, expiryTime: expiryTime);
//     }
//     return null;
//   }
//
//   Future<String> _generateAccessToken() async {
//     final serviceAccountKey = await _loadServiceAccountKey();
//     final credentials = ServiceAccountCredentials.fromJson(serviceAccountKey);
//
//     final client = http.Client();
//     final scopes = ['https://www.googleapis.com/auth/cloud-platform'];
//     final accessCredentials = await obtainAccessCredentialsViaServiceAccount(
//       credentials,
//       scopes,
//       client,
//     );
//     client.close();
//
//     await _storeToken(accessCredentials.accessToken);
//     return accessCredentials.accessToken.data;
//   }
//
//   Future<Map<String, dynamic>> _loadServiceAccountKey() async {
//     const serviceAccountJson = '';
//     return jsonDecode(serviceAccountJson);
//   }
//
//   Future<void> _storeToken(AccessToken accessToken) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString(_tokenKey, accessToken.data);
//     await prefs.setString(_expiryKey, accessToken.expiry.toIso8601String());
//   }
//
//   static const _tokenKey = 'fcm_access_token';
//   static const _expiryKey = 'fcm_token_expiry';
// }
//
// class AuthToken {
//   final String token;
//   final DateTime expiryTime;
//
//   AuthToken({required this.token, required this.expiryTime});
//
//   bool get isExpired => DateTime.now().isAfter(expiryTime);
// }
