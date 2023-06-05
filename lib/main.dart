import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _firebaseMessaging.requestPermission();
    _firebaseMessaging.getToken();
    listenNoti();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(onPressed: (){
              checkPermissions();
            }, child: Text("Xin quyen")),
            ElevatedButton(onPressed: (){
              setupToken();
            }, child: Text("get Token")),
          ],
        ),
      ),
    );
  }

  void checkPermissions() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }
  }

  void setupToken() {
    _firebaseMessaging.getToken().then((value) => {
      print('Token: $value')
    });
  }

  void listenNoti() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("On Mess: ${message.notification?.title}");
      showNotification(message);

    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("onMessageOpenedApp: ${message.notification?.body}");
      showNotification(message);
    });
  }
  void showNotification(RemoteMessage message) {
    AndroidNotificationChannel channel = const AndroidNotificationChannel(
        'channel_id', 'channel_title',
        importance: Importance.high);

    AndroidNotificationDetails details = AndroidNotificationDetails(
        channel.id, channel.name,
        icon: '@mipmap/ic_launcher');

    FlutterLocalNotificationsPlugin plugin = FlutterLocalNotificationsPlugin();
    int id = message.notification.hashCode;
    String? title = message.notification?.title;
    String? body = message.notification?.body;

    plugin.show(id, title, body, NotificationDetails(android: details,iOS: DarwinNotificationDetails()));
  }
}
