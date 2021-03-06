// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, unused_import, avoid_print, avoid_returning_null_for_void

import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:junkbee_user/beever/service/api_service_status.dart';
import 'package:junkbee_user/beever/views/pages/ongoing_order/ongoing_order.dart';
import 'package:junkbee_user/beever/views/pages/ongoing_order/ongoing_order_proceed.dart';
import 'package:junkbee_user/beever/widgets/home/show_notification.dart';
import 'package:junkbee_user/user/view/pages/0.navigator.dart';
import 'package:junkbee_user/beever/const/base_url.dart';
import 'package:junkbee_user/beever/service/api_calls_get_data.dart';
import 'package:junkbee_user/beever/service/secure_storage.dart';
import 'package:junkbee_user/beever/widgets/home/homepages_widget.dart';

import '../../../../main.dart';

class HomePagesDriver extends StatefulWidget {
  const HomePagesDriver({Key? key}) : super(key: key);

  @override
  State<HomePagesDriver> createState() => _HomePagesDriverState();
}

class _HomePagesDriverState extends State<HomePagesDriver> {
  final SecureStorage secureStorage = SecureStorage();

  @override
  void initState() {
    super.initState();
    ApiServiceStatusBeever().getDataBeever();
    getRole();
    patchBeeverLocation();
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) {
      if (message != null) {
        ShowNotification().showFlushBar(context);
        print('object');
        Get.to(() => OngoingOrder());
      }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null && !kIsWeb) {
        flutterLocalNotificationsPlugin!.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel!.id,
              channel!.name,
              channelDescription: channel!.description,
              // ignore: todo
              // TODO add a proper drawable resource to android, for now using
              //      one that already exists in example app.
              icon: 'launch_background',
            ),
          ),
        );
        ShowNotification().showFlushBar(context);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
    });
  }

  getRole() async {
    var authToken = await secureStorage.readSecureData('token');
    var token = authToken;

    final userData = await http.get(
        Uri.parse(EndPoint.baseApiURL + EndPoint.getUserData),
        headers: {'Authorization': 'Bearer $token'});
    Map<String, dynamic> bodyJSON = jsonDecode(userData.body);
    var role = bodyJSON['data']['role'];
    var id = bodyJSON['data']['id'];
    await secureStorage.writeSecureData('role', role);
    await secureStorage.writeSecureData('id', id.toString());
    print(role);
  }

  Future<void> patchBeeverLocation() async {
    var authToken = await secureStorage.readSecureData('token');
    var token = authToken;
    var id = await secureStorage.readSecureData('id');
    var position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    var lat = position.latitude;
    var long = position.longitude;

    var uri = Uri.https(
        'www.staging2.junkbee.id', '/api/beever/update/location', {
      'id': id,
      'lat': lat.toString(),
      'lng': long.toString(),
      'status': 'ready'
    });
    print(lat);
    print(long);
    var response =
        await http.patch(uri, headers: {'Authorization': 'Bearer $token'});
    if (response.statusCode == 200) {
      print(response.body);
      return Future.delayed(Duration(seconds: 10))
          .then((value) => patchBeeverLocation());
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
                padding: const EdgeInsets.only(top: 10),
                height: MediaQuery.of(context).size.height / 4,
                alignment: Alignment.topCenter,
                decoration: const BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage('assets/heading.png'),
                        fit: BoxFit.fill)),
                child: WhiteSpace()),
            profileAndBalance(),
            orderPickup(context),
            NewsAPI()
          ],
        ),
      ),
    );
  }
}
