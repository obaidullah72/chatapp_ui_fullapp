import 'dart:convert';
import 'dart:developer';

import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fluter_chat_app_provider/providers/auth_provider.dart';
import 'package:fluter_chat_app_provider/providers/chat_provider.dart';
import 'package:fluter_chat_app_provider/providers/theme_provider.dart';
import 'package:fluter_chat_app_provider/screens/login_screen.dart';
import 'package:fluter_chat_app_provider/screens/main_screens.dart';
import 'package:fluter_chat_app_provider/screens/splash%20screen.dart';
import 'package:fluter_chat_app_provider/widget/push_notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
// import 'package:timezone/timezone.dart' as tz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: 'AIzaSyAHvTa1AOQKrMc76ZWlVtP3IvF-3D5CGA0',
      appId: '1:779747078401:android:eac2d55dba449638402b00',
      messagingSenderId: '779747078401',
      projectId: 'flutter-chatapp-f7ffb',
    ),
  );

  await PushNotificationService().initNotifications();
  await PushNotificationService.createNotificationChannel();

  // await PushNotificationService().requestNotificationPermissions();
  PushNotificationService().forgroundMessage();

  PushNotificationService.localNotiInit();
  PushNotificationService().clearNotifications();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // FirebaseAppCheck firebaseAppCheck = FirebaseAppCheck.instance.;
  FirebaseAuth.instance.setSettings(
    appVerificationDisabledForTesting: true,
  );
  // FirebaseAuth.instance.fi.forceRecaptchaFlowForTesting(true)

  FirebaseMessaging.onMessage.listen((RemoteMessage event) {
    String payload = jsonEncode(event.data);

    if (event.notification != null) {
      print(payload);
      PushNotificationService().showNotification(event,true);
    }
  });

  final RemoteMessage? message =
  await FirebaseMessaging.instance.getInitialMessage();

  if (message != null) {
    print('launch for terminated state');
    Future.delayed(const Duration(seconds: 1));
  }

  await FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.playIntegrity,
      appleProvider: AppleProvider.debug);

  // FirebaseMessaging.onBackgroundMessage((message) {
  //   return PushNotificationService().backgroundMessageHandler(message);
  // },);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  ));
  // tz.initializeTimeZones();

  // await initServices();

  runApp(const MyApp());
}


@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  log('New message notify ${message.notification!.title}');
  if(message.notification!=null && message.notification!.title!=null){
    // PushNotificationService().showNotification(message,false);

  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProviders()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Flutter Chat App',
            debugShowCheckedModeBanner: false,
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
            themeMode:
            themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: SplashScreen(),
          );
        },
      ),
    );
  }
}

class AuthenticationWrapper extends StatelessWidget {
  const AuthenticationWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProviders>(builder: (
        context,
        authProvider,
        child,
        ) {
      if (authProvider.isSignedIn) {
        return MainScreen();
      } else {
        return LoginScreen();
      }
    });
  }
}
