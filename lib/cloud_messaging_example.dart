import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    MaterialApp(
      home: CloudMessagingHome(),
    ),
  );
}

class CloudMessagingHome extends StatefulWidget {
  @override
  _CloudMessagingHomeState createState() => _CloudMessagingHomeState();
}

class _CloudMessagingHomeState extends State<CloudMessagingHome> {
  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("SALUT"),
      ),
    );
  }

  void _init() async {
    final FirebaseMessaging messaging = FirebaseMessaging.instance;

    final NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    print('User granted permission: ${settings.authorizationStatus}');

    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: false,
    );

    _lookForMessagingToken();
    _initLocalNotifications();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) => _onMessage(message, onForeground: true));
    FirebaseMessaging.onMessageOpenedApp.listen(_onNotificationOpenedApp);
  }

  void _lookForMessagingToken() async {
    String? token = await FirebaseMessaging.instance.getToken();
    print("Firebase Messaging Token : $token");
    FirebaseMessaging.instance.onTokenRefresh.listen((String token) {
      print("Firebase Messaging Token : $token");
    });
  }

  void _onNotificationOpenedApp(RemoteMessage message) async {
    print("Une notification a ouvert l'application ! ${message.notification?.title}");
  }

  void _onMessage(RemoteMessage message, {bool onForeground = false}) async {
    final AndroidNotification? android = message.notification?.android;
    final RemoteNotification? notification = message.notification;

    if (notification != null && android != null && onForeground) {
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'high_importance_channel',
        'High Importance Notifications',
        'This channel is used for important notifications.',
        importance: Importance.max,
      );

      final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channel.description,
            icon: android.smallIcon,
          ),
        ),
      );
    }
  }

  void _initLocalNotifications() async {
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onSelectNotification: _onNotificationClicked,
    );
  }

  Future<dynamic> _onNotificationClicked(String? payload) {
    print("Notification clicked with payload = $payload");
    return Future.value();
  }
}
