// ignore_for_file: file_names, unused_import

import 'package:flutter/material.dart';
import 'package:junkbee_user/beever/widgets/home/available_widget.dart';
import 'package:touchable_opacity/touchable_opacity.dart';
import 'package:junkbee_user/beever/views/pages/home/available_pickUp.dart';

class AvailableScreen extends StatefulWidget {
  const AvailableScreen({Key? key}) : super(key: key);

  @override
  AvailableState createState() => AvailableState();
}

class AvailableState extends State<AvailableScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: Column(children: [
              Container(
                  width: MediaQuery.of(context).size.width,
                  height: 230,
                  alignment: Alignment.topCenter,
                  decoration: const BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage('assets/heading.png'),
                          fit: BoxFit.fill)),
                  child: const AvailableWidget()),
              Container(
                  transform: Matrix4.translationValues(0.0, -80.0, 0.0),
                  width: 480,
                  height: 740,
                  alignment: Alignment.topCenter,
                  child: const AvailableList())
            ])));
  }
}
