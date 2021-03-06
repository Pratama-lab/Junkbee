// ignore_for_file: unnecessary_string_interpolations, sized_box_for_whitespace, camel_case_types, library_private_types_in_public_api, unused_import

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:junkbee_user/beever/service/api_service_status.dart';
import 'package:junkbee_user/beever/views/pages/home/withdraw.dart';
import 'package:junkbee_user/beever/widgets/home/show_notification.dart';
import 'package:junkbee_user/services/notification_services.dart';
import 'package:junkbee_user/user/view/pages/0.navigator.dart';
import 'package:lottie/lottie.dart';
import 'package:touchable_opacity/touchable_opacity.dart';
import 'package:intl/intl.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:junkbee_user/beever/const/base_url.dart';
import 'package:junkbee_user/beever/const/const.dart';
import 'package:junkbee_user/beever/service/api_calls_get_data.dart';
import 'package:junkbee_user/beever/views/pages/home/topUp.dart';
import 'package:junkbee_user/beever/views/pages/home/available_pickUp.dart';
import 'package:junkbee_user/beever/views/pages/home/current_pickUp.dart';
import 'package:junkbee_user/beever/views/pages/home/history_pickUp.dart';
import 'package:junkbee_user/beever/views/pages/home/news.dart';
import 'package:timezone/data/latest.dart' as tz;

class WhiteSpace extends StatefulWidget {
  const WhiteSpace({Key? key}) : super(key: key);

  @override
  State<WhiteSpace> createState() => _WhiteSpaceState();
}

class _WhiteSpaceState extends State<WhiteSpace> {
  @override
  void initState() {
    tz.initializeTimeZones();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: MediaQuery.of(context).size.width / 1.1,
        height: MediaQuery.of(context).size.height / 8,
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const SizedBox(height: 20),
          GestureDetector(
              onTap: () {
                Get.offAll(() => const NavigatorUser());
              },
              child: Text('Be a User',
                  style: titleBodyMini.copyWith(color: Colors.white)))
        ]));
  }
}

class profileAndBalance extends StatefulWidget {
  const profileAndBalance({Key? key}) : super(key: key);

  @override
  _profileAndBalanceState createState() => _profileAndBalanceState();
}

class _profileAndBalanceState extends State<profileAndBalance> {
  final format = NumberFormat.simpleCurrency(locale: 'id_ID');

  @override
  Widget build(BuildContext context) {
    return Container(
      transform: Matrix4.translationValues(0, -70, 0),
      width: MediaQuery.of(context).size.width / 1.1,
      child: FutureBuilder(
        future: ApiCallsGetDataBeever().getData(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          var beever = snapshot.data;
          if (snapshot.connectionState == ConnectionState.done) {
            return Center(
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(90),
                    child: beever?.data.image == null
                        ? Image.asset('assets/beever_image.png',
                            height: MediaQuery.of(context).size.height / 8)
                        : Image.network(
                            '${EndPoint.baseURL}storage/profile-images/${beever?.data.image}',
                            width: 90,
                            height: 90,
                            fit: BoxFit.cover,
                          ),
                  ),
                  Text('${beever?.data.fullName}', style: titleBodyMini),
                  (beever?.data.active == '1')
                      ? Card(
                          shape: roundedRectBor,
                          child: SizedBox(
                              width: Get.width / 8,
                              height: Get.height / 20,
                              child: Center(
                                child: Lottie.asset(
                                    'assets/animation/beever_active.json'),
                              )))
                      : GestureDetector(
                          onTap: () {
                            ApiServiceStatusBeever().patchStatusReady();
                          },
                          child: Card(
                              shape: roundedRectBor,
                              child: SizedBox(
                                  width: Get.width / 7,
                                  height: Get.height / 20,
                                  child: Center(
                                    child: Lottie.asset(
                                        'assets/animation/beever_non.json'),
                                  ))),
                        ),
                  SizedBox(
                    width: 100,
                    height: 50,
                    child: Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                      child: Padding(
                        padding: defaultPadding2,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Image.asset('assets/star_icon.png', height: 30),
                            const Text('(4.5)', style: signScreenTextStyle)
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 1,
                    child: Card(
                      shape: roundedRectBor,
                      child: Column(
                        children: [
                          Padding(
                            padding: defaultPadding2,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: const [
                                Text('Balance', style: textProfileBold),
                                Text(
                                    // '${format.format(int.parse(beever?.data.balance))}',
                                    'Coming Soon',
                                    style: textProfileBold),
                              ],
                            ),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width / 1.2,
                            decoration: const BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(
                                        width: 1, color: Color(0xFFDEDEDE)))),
                          ),
                          const SizedBox(height: 25),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              TouchableOpacity(
                                onTap: () async {
                                  final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const WithdrawScreen()));
                                  if (result == 'back') {
                                    await ApiCallsGetDataBeever().getData();
                                    setState(() {});
                                  }
                                },
                                child: Column(
                                  children: [
                                    Image.asset('assets/withdraw_icon.png',
                                        height:
                                            MediaQuery.of(context).size.height /
                                                25),
                                    const SizedBox(height: 5),
                                    const Text('Withdraw', style: bodySlimBody),
                                  ],
                                ),
                              ),
                              TouchableOpacity(
                                onTap: () async {
                                  final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => const TopUp()));
                                  if (result == 'back') {
                                    await ApiCallsGetDataBeever().getData();
                                    setState(() {});
                                  }
                                },
                                child: Column(
                                  children: [
                                    Image.asset('assets/topup_icon.png',
                                        height:
                                            MediaQuery.of(context).size.height /
                                                25),
                                    const SizedBox(height: 5),
                                    const Text('Topup', style: bodySlimBody),
                                  ],
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 25),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else {
            return const Center(
                child: SpinKitWave(color: Colors.white, size: 50));
          }
        },
      ),
    );
  }
}

Container orderPickup(BuildContext context) {
  return Container(
    transform: Matrix4.translationValues(0, -50, 0),
    width: MediaQuery.of(context).size.width / 1.1,
    padding: defaultPadding0,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: defaultPadding8,
          child: Text('Order', style: textProfileBoldMed),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            availablePickUp(context),
            currentPickUp(context),
            pickUpHistory(context),
          ],
        )
      ],
    ),
  );
}

SizedBox pickUpHistory(BuildContext context) {
  return SizedBox(
      width: MediaQuery.of(context).size.width / 3.5,
      child: TouchableOpacity(
        onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const HistoryScreen())),
        child: Card(
          shape: roundedRectBor,
          child: Column(
            children: [
              Padding(
                padding: defaultPadding0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('0', style: titleBodyMini),
                    Image.asset('assets/arrow_forward.png',
                        width: MediaQuery.of(context).size.width / 40)
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(left: 8, right: 8, bottom: 8),
                child: Text('Picked Up History', style: bodySlimBody),
              ),
              Container(
                  padding: const EdgeInsets.only(top: 5, bottom: 7.5),
                  child: Container(
                    width: MediaQuery.of(context).size.width / 5,
                    decoration: BoxDecoration(
                        border: Border.all(width: 2, color: Colors.greenAccent),
                        borderRadius: BorderRadius.circular(20)),
                  ))
            ],
          ),
        ),
      ));
}

SizedBox currentPickUp(BuildContext context) {
  return SizedBox(
      width: MediaQuery.of(context).size.width / 3.5,
      child: TouchableOpacity(
        onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const CurrentScreen())),
        child: Card(
          shape: roundedRectBor,
          child: Column(
            children: [
              Padding(
                padding: defaultPadding0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('0', style: titleBodyMini),
                    Image.asset('assets/arrow_forward.png',
                        width: MediaQuery.of(context).size.width / 40)
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(left: 8, right: 8, bottom: 8),
                child: Text('Current Pick Up', style: bodySlimBody),
              ),
              Container(
                  padding: const EdgeInsets.only(top: 5, bottom: 7.5),
                  child: Container(
                    width: MediaQuery.of(context).size.width / 5,
                    decoration: BoxDecoration(
                        border: Border.all(width: 2, color: Colors.blueAccent),
                        borderRadius: BorderRadius.circular(20)),
                  ))
            ],
          ),
        ),
      ));
}

SizedBox availablePickUp(BuildContext context) {
  return SizedBox(
      width: MediaQuery.of(context).size.width / 3.5,
      child: TouchableOpacity(
        onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AvailableScreen())),
        child: Card(
          shape: roundedRectBor,
          child: Column(
            children: [
              Padding(
                padding: defaultPadding0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('0', style: titleBodyMini),
                    Image.asset('assets/arrow_forward.png',
                        width: MediaQuery.of(context).size.width / 40)
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(left: 8, right: 8, bottom: 8),
                child: Text('Available Pick Up', style: bodySlimBody),
              ),
              Container(
                  padding: const EdgeInsets.only(top: 5, bottom: 7.5),
                  child: Container(
                    width: MediaQuery.of(context).size.width / 5,
                    decoration: BoxDecoration(
                        border: Border.all(width: 2, color: Colors.amber),
                        borderRadius: BorderRadius.circular(20)),
                  ))
            ],
          ),
        ),
      ));
}

class NewsAPI extends StatelessWidget {
  const NewsAPI({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        transform: Matrix4.translationValues(0, -35, 0),
        width: MediaQuery.of(context).size.width / 1.1,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Padding(
            padding: defaultPadding6,
            child: Text('News for you', style: textProfileBoldMed),
          ),
          Padding(
              padding: defaultPadding0,
              child: SizedBox(
                  width: MediaQuery.of(context).size.width / 1,
                  height: MediaQuery.of(context).size.height / 3,
                  child: FutureBuilder(
                      future: ApiCallsGetNews().getNews(),
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        var news = snapshot.data;

                        if (snapshot.connectionState == ConnectionState.done &&
                            news.data.length != 0) {
                          return ListView.builder(
                              shrinkWrap: true,
                              scrollDirection: Axis.horizontal,
                              itemCount: news.data.length,
                              itemBuilder: (_, index) {
                                return Padding(
                                    padding: defaultPaddingHorizontal,
                                    child: GestureDetector(
                                        onTap: () async {
                                          final launchNews =
                                              EndPoint.finalNewsData +
                                                  news?.data[index].slug;
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      NewsScreen(
                                                          url: launchNews)));
                                        },
                                        child: SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                2.3,
                                            child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  SizedBox(
                                                      child: Column(children: [
                                                    ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(20),
                                                        child: AspectRatio(
                                                            aspectRatio:
                                                                11 / 10,
                                                            child: Image.network(
                                                                '${EndPoint.bannerForNews}${news?.data[index].banner}',
                                                                fit: BoxFit
                                                                    .cover)))
                                                  ])),
                                                  Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 5),
                                                      child: Text(
                                                          '${news?.data[index].judul}',
                                                          style: bodySlimBody,
                                                          maxLines: 2,
                                                          overflow: TextOverflow
                                                              .ellipsis))
                                                ]))));
                              });
                        } else if (snapshot.connectionState ==
                                ConnectionState.done &&
                            news.data.length == 0) {
                          return Container(
                              padding: const EdgeInsets.only(top: 10),
                              width: MediaQuery.of(context).size.width / 1.1,
                              child: const Text('Tidak ada News untuk kamu',
                                  style: TextStyle(
                                      color: Color(0xFF707070),
                                      fontWeight: FontWeight.w500,
                                      fontSize: 18),
                                  textAlign: TextAlign.center));
                        }
                        return const Center(
                            child: SpinKitWave(
                                color: Colors.amberAccent, size: 50));
                      })))
        ]));
  }
}
