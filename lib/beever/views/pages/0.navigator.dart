import 'package:flutter/material.dart';
import 'package:touchable_opacity/touchable_opacity.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:junkbee_user/beever/views/pages/home/homepages.dart';
import 'package:junkbee_user/beever/views/pages/ongoing_order/ongoing_order.dart';
import 'package:junkbee_user/beever/views/pages/ongoing_message/3.ongoing_message.dart';
import 'package:junkbee_user/beever/views/pages/profile/beever_profile.dart';

class NavigatorPages extends StatefulWidget {
  const NavigatorPages({Key? key}) : super(key: key);
  @override
  NavigatorPagesState createState() => NavigatorPagesState();
}

class NavigatorPagesState extends State<NavigatorPages> {
  DateTime timeBackPressed = DateTime.now();
  int index = 0;
  List<Widget> pagesBeever = [
    const HomePagesDriver(),
    const OngoingOrder(),
    const OngoingMessages(),
    const BeeverProfile()
  ];
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          final difference = DateTime.now().difference(timeBackPressed);
          final isExitWarning = difference >= const Duration(seconds: 2);
          timeBackPressed = DateTime.now();
          if (isExitWarning) {
            Fluttertoast.showToast(
                msg: 'Tekan lagi untuk keluar',
                toastLength: Toast.LENGTH_SHORT,
                backgroundColor: const Color(0xFFF8C503));
            return false;
          } else {
            Fluttertoast.cancel();
            return true;
          }
        },
        child: ClipRRect(
          child: Scaffold(
              extendBody: true,
              body: pagesBeever[index],
              bottomNavigationBar: Container(
                padding: const EdgeInsets.only(bottom: 30, left: 60, right: 60),
                color: Colors.transparent,
                child: Container(
                  height: 65,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(36),
                      boxShadow: const [
                        BoxShadow(
                            color: Colors.grey,
                            blurRadius: 2,
                            spreadRadius: 0,
                            offset: Offset(0, 1))
                      ]),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      TouchableOpacity(
                          onTap: () => setState(() => index = 0),
                          child: Image.asset('icons/h_0.png',
                              width: 26,
                              height: 26,
                              color: index == 0
                                  ? const Color(0xFFF7D345)
                                  : const Color(0xFF707070))),
                      TouchableOpacity(
                          onTap: () => setState(() => index = 1),
                          child: Image.asset(
                              index == 1 ? 'icons/cb_1.png' : 'icons/cb_0.png',
                              width: 26,
                              height: 26)),
                      TouchableOpacity(
                          onTap: () => setState(() => index = 2),
                          child: Image.asset('icons/i_0.png',
                              width: 26,
                              height: 26,
                              color: index == 2
                                  ? const Color(0xFFF7D345)
                                  : const Color(0xFF707070))),
                      TouchableOpacity(
                          onTap: () => setState(() => index = 3),
                          child: Image.asset('icons/p_0.png',
                              width: 26,
                              height: 26,
                              color: index == 3
                                  ? const Color(0xFFF7D345)
                                  : const Color(0xFF707070))),
                    ],
                  ),
                ),
              )),
        ));
  }
}
