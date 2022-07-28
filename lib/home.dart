import 'package:dongpakka_bluetooth/local_notification_service.dart';
import 'package:dongpakka_bluetooth/second_screen.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  LocalNotificationService service;

  @override
  void initState() {
    service = LocalNotificationService();
    service.initialize();
    listenToNotification();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
                onPressed: () async {
                  await service.showNotification(id: 0, title: 'Notification Title', body: 'Some body');
                }, child: Text('Show Local Notification')),
            ElevatedButton(
                onPressed: () async {
                  await service.showScheduledNotification(id: 0, title: 'Notification Title', body: 'Some body',seconds: 1);
                }, child: Text('Show Scheduled Notification')),
            ElevatedButton(
                onPressed: () async {
                  await service.showPayloadNotification(id: 0, title: 'Notification Title', body: 'Some body',payload: 'payload navigation');
                }, child: Text('Show Notification with Payload')),
          ],
        ),
      ),
    );
  }

  void listenToNotification() => service.onNotificationClick.stream.listen(onNotificationListener);
  void onNotificationListener(String payload) {
    if(payload != null && payload.isNotEmpty) {
      print('payload $payload');

      Navigator.push(context, MaterialPageRoute(builder: (context)=>SecondScreen(payload: payload)));
    }
  }
}