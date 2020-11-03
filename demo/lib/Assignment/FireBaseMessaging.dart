import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/subjects.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

final BehaviorSubject<String> selectNotificationSubject =
    BehaviorSubject<String>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final NotificationAppLaunchDetails notificationAppLaunchDetails =
      await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('app_icon');
  final InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);
  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onSelectNotification: (String payload) async {
      if (payload != null) {
        debugPrint('notification payload: $payload');
      }
      selectNotificationSubject.add(payload);
    },
  );
  runApp(MyApp(notificationAppLaunchDetails));
}

class MyApp extends StatefulWidget {
  const MyApp(this.notificationAppLaunchDetails, {Key key}) : super(key: key);

  final NotificationAppLaunchDetails notificationAppLaunchDetails;
  bool get didNotificationLaunchApp =>
      notificationAppLaunchDetails?.didNotificationLaunchApp ?? false;
  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {
  String _message = '';
  String token;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  _register() async {
    token = token ?? await _firebaseMessaging.getToken();
  }

  @override
  void initState() {
    super.initState();
    _configureSelectNotificationSubject();
    getMessage();
  }

  Future<void> _showNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
            'your channel id', 'your channel name', 'your channel description',
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'ticker');
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(0, title ?? 'plain title',
        body ?? 'plain body', platformChannelSpecifics,
        payload: 'Tap');
  }

  bool isinitial = false;
  void _configureSelectNotificationSubject() {
    selectNotificationSubject.stream.listen((String payload) async {
      print('Selected Notification $payload');
      if (isinitial) {
        if (payload == 'Tap') {
          _key.currentState.showSnackBar(SnackBar(
            content: Text('You Taped Notification From Firebase'),
          ));
          // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          //   content: Text('You Taped Notification From Firebase'),
          // ));
        }
      } else {
        isinitial = true;
      }
    });
  }

  String serverToken =
      'AAAA-abOnps:APA91bG1Oz79suDtUGyY-NV_m6_YiomMcUfQ49_JS5Afj6v2jCHOgyhh8iY1POs1MWfeWwLUpbIZxcXpSg7EkgOpcASOJlDyUMKcsBvf01PnscG3Jq3sTLaK-Y5KF7xrUaltoVnNvYYE';
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging();

  Future sendAndRetrieveMessage() async {
    token = token ?? await _firebaseMessaging.getToken();
    http.Response resp = await http.post(
      'https://fcm.googleapis.com/fcm/send',
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=$serverToken',
      },
      body: jsonEncode(
        <String, dynamic>{
          'notification': <String, dynamic>{
            'title': 'Hi There, I\'m Anand',
            'body': '${_control.text ?? 'No Message Is Written'}'
          },
          'priority': 'high',
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'id': '1',
            'status': 'done'
          },
          'to': token
        },
      ),
    );
    print('Responce : ${resp.body}');
    responce = resp.body;
    // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    //   content: Text('FB Responce :: $responce'),
    // ));
    _key.currentState.showSnackBar(SnackBar(
      content: Text('FB Responce :: $responce'),
    ));
  }

  final GlobalKey<ScaffoldState> _key = new GlobalKey<ScaffoldState>();
  String responce;
  void getMessage() {
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print('on message $message');
        _showNotification(
            message["notification"]["title"], message["notification"]["body"]);
        setState(() => _message = message["notification"]["title"]);
      },
      onResume: (Map<String, dynamic> message) async {
        print('on resume $message');
        setState(() => _message = message["notification"]["title"]);
      },
      onLaunch: (Map<String, dynamic> message) async {
        print('on launch $message');
        setState(() => _message = message["notification"]["title"]);
      },
    );
  }

  TextEditingController _control = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        key: _key,
        appBar: AppBar(title: Text('Firebase Push')),
        body: Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text("Message: $_message"),
                SizedBox(height: 10),
                Container(
                  padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                  child: TextField(
                    controller: _control,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Write Something'),
                  ),
                ),
                SizedBox(height: 10),
                RaisedButton(
                    child: Text('Get Notification'),
                    onPressed: () async {
                      await sendAndRetrieveMessage();
                    })
              ]),
        ),
      ),
    );
  }
}
// final Completer<Map<String, dynamic>> completer =
//     Completer<Map<String, dynamic>>();

// firebaseMessaging.configure(
//   onMessage: (Map<String, dynamic> message) async {
//     completer.complete(message);
//   },
// );
// return completer.future;
// getMessage();
