import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_login_facebook/flutter_login_facebook.dart';
import 'package:junkbee_user/user/constant/base_url.dart';
import 'package:junkbee_user/user/constant/constant.dart';
import 'package:junkbee_user/user/service/storage/secure_storage.dart';
import 'package:junkbee_user/user/view/login_signup/signup_screen.dart';

GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId:
        '1057154394115-lmbtvrv1k9kvs3o2fflgr992hfohmoab.apps.googleusercontent.com');

class SignInUser extends StatefulWidget {
  const SignInUser({Key? key}) : super(key: key);

  @override
  SignInUserState createState() => SignInUserState();
}

class SignInUserState extends State<SignInUser> {
  final TextEditingController _logincont = TextEditingController();
  final TextEditingController _passwordcont = TextEditingController();

  bool _obsecureText = true;
  final bool _validate = false;
  bool loading = false;

  final SecureStorage secureStorage = SecureStorage();

  @override
  void initState() {
    super.initState();
    checkToken();
  }

  checkToken() async {
    final authToken = await secureStorage.readSecureData('token');
    final token = authToken;

    if (token == null) {
      if (kDebugMode) {
        print('token is null');
      }
    } else {
      if (kDebugMode) {
        print('token is not null');
      }
    }
  }

  void _toggle() {
    setState(() {
      _obsecureText = !_obsecureText;
    });
  }

  void _loginUser() async {
    setState(() => loading = true);
    try {
      final response = await http
          .post(Uri.parse(EndPoint.baseApiURL + EndPoint.loginURL), body: {
        'email': _logincont.text.trim(),
        'password': _passwordcont.text.trim(),
      });
      String? fcmToken = await FirebaseMessaging.instance.getToken();

      if (response.statusCode == 200) {
        Map<String, dynamic> output = jsonDecode(response.body);
        await secureStorage.writeSecureData('token', output['data']['token']);

        final resp = await http.put(
            Uri.parse(EndPoint.baseApiURL + EndPoint.deviceToken),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer ${output['data']['token']}'
            },
            body: json.encode({'device_token': fcmToken}));
        Map<String, dynamic> updateToken = jsonDecode(resp.body);
        if (updateToken['message'] == 'data has been updated') {
          setState(() => loading = false);
          //! Rizky ini perubahan di FLUTTER 3.0, dimana Navigator.pop() digunakan dengan synchronous karena menggunakan metode buildcontext. kalau ada error if(!mounted) return; dihapus aja ya
          if (!mounted) return;
          Navigator.pop(context, 'back');
        }
        if (kDebugMode) {
          print(response.body);
        }
      } else {
        Map<String, dynamic> output = jsonDecode(response.body);
        setState(() => loading = false);
        var errorMessage = output['message'];
        Get.defaultDialog(
            textCancel: 'Ok',
            middleText: errorMessage,
            title: 'Please Try Again');
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  _onFacebookSignIn() async {
    final fb = FacebookLogin();

    final res = await fb.logIn(permissions: [
      FacebookPermission.publicProfile,
      FacebookPermission.email
    ]);
    switch (res.status) {
      case FacebookLoginStatus.success:
        final profile = await fb.getUserProfile();
        final email = await fb.getUserEmail();
        if (profile != null) {
          final response = await http.post(
              Uri.parse(EndPoint.baseApiURL + EndPoint.loginFacebook),
              body: {
                'facebook_id': profile.userId,
                'email': '$email',
                'full_name': '${profile.name}'
              });
          Map<String, dynamic> bodyJSON = jsonDecode(response.body);
          if (response.statusCode == 200) {
            setState(() => loading = false);
            await secureStorage.writeSecureData(
                'token', bodyJSON['data']['token']);
            //! Rizky ini perubahan di FLUTTER 3.0, dimana Navigator.pop() digunakan dengan synchronous karena menggunakan metode buildcontext. kalau ada error if(!mounted) return; dihapus aja ya
            if (!mounted) return;
            Navigator.pop(context, 'back');
          }
        }
        break;
      case FacebookLoginStatus.cancel:
        if (kDebugMode) {
          print('You cancel Facebook login');
        }
        break;
      case FacebookLoginStatus.error:
        if (kDebugMode) {
          print('Facebook login error');
        }
        break;
    }
  }

  _onGoogleSigninSuccess(GoogleSignInAccount account) async {
    setState(() => loading = true);
    final response = await http
        .post(Uri.parse(EndPoint.baseApiURL + EndPoint.loginGoogle), body: {
      'google_id': account.id,
      'email': account.email,
      'full_name': '${account.displayName}'
    });
    Map<String, dynamic> bodyJSON = jsonDecode(response.body);
    if (response.statusCode == 200) {
      setState(() => loading = false);
      await secureStorage.writeSecureData('token', bodyJSON['data']['token']);
      //! Rizky ini perubahan di FLUTTER 3.0, dimana Navigator.pop() digunakan dengan synchronous karena menggunakan metode buildcontext. kalau ada error if(!mounted) return; dihapus aja ya
      if (!mounted) return;
      Navigator.pop(context, 'back');
    }
  }

  _onGoogleSignIn() async {
    try {
      final account = await _googleSignIn.signIn();
      _onGoogleSigninSuccess(account!);
    } catch (error) {
      if (kDebugMode) {
        print(error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: GestureDetector(
            onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
            child: SingleChildScrollView(
                child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    child: Stack(children: [
                      Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                                height:
                                    MediaQuery.of(context).size.height / 30),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets_signscreen/logo.png',
                                  height:
                                      MediaQuery.of(context).size.height / 7,
                                ),
                                const Text('User App',
                                    style: onboardingTextStyleSkipDone),
                              ],
                            ),
                            SizedBox(
                                height:
                                    MediaQuery.of(context).size.height / 20),
                            Column(
                              children: [
                                Padding(
                                  padding: defaultPadding10,
                                  child: TextFormField(
                                    keyboardType: TextInputType.emailAddress,
                                    controller: _logincont,
                                    style: const TextStyle(fontSize: 22),
                                    decoration: InputDecoration(
                                        labelStyle: signScreenTextStyle,
                                        labelText: 'Email',
                                        errorText: (_validate)
                                            ? "Username cannot be empty"
                                            : null),
                                  ),
                                ),
                                Padding(
                                  padding: defaultPadding10,
                                  child: TextFormField(
                                    controller: _passwordcont,
                                    style: const TextStyle(fontSize: 22),
                                    obscureText: (_obsecureText) ? true : false,
                                    decoration: InputDecoration(
                                        labelStyle: signScreenTextStyle,
                                        labelText: 'Password',
                                        errorText: (_validate)
                                            ? "Password Cannot be Empty"
                                            : null,
                                        suffixIcon: IconButton(
                                            onPressed: () => _toggle(),
                                            icon: Icon((_obsecureText)
                                                ? Icons.visibility
                                                : Icons.visibility_off))),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                                height:
                                    MediaQuery.of(context).size.height / 30),
                            Padding(
                              padding: defaultPadding10,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(),
                                  const Text('Forgot Password?',
                                      style: signScreenTextStyle)
                                ],
                              ),
                            ),
                            SizedBox(
                                height:
                                    MediaQuery.of(context).size.height / 30),
                            SizedBox(
                                width: MediaQuery.of(context).size.width / 1.4,
                                height: MediaQuery.of(context).size.height / 13,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      primary: Colors.amber,
                                      shape: roundedRectBor),
                                  child: const Text('Sign In',
                                      style: onboardingGetStarted),
                                  onPressed: () => _loginUser(),
                                )),
                            SizedBox(
                              height: MediaQuery.of(context).size.height / 20,
                            ),
                            Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  GestureDetector(
                                      onTap: () => _onFacebookSignIn(),
                                      child: Image.asset(
                                        'assets_signscreen/facebook_icon.png',
                                        height:
                                            MediaQuery.of(context).size.height /
                                                18,
                                      )),
                                  SizedBox(
                                      width: MediaQuery.of(context).size.width /
                                          6),
                                  GestureDetector(
                                      onTap: () => _onGoogleSignIn(),
                                      child: Image.asset(
                                          'assets_signscreen/google_icon.png',
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height /
                                              18))
                                ]),
                            SizedBox(
                                height:
                                    MediaQuery.of(context).size.height / 20),
                            Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  const Text('Dont have account yet?',
                                      style: signScreenTextStyle),
                                  SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height /
                                              50),
                                  GestureDetector(
                                      onTap: () =>
                                          Get.to(() => const SignUpUser()),
                                      child: const Text('Sign Up',
                                          style: onboardingSkip))
                                ])
                          ]),
                      (loading)
                          ? Container(
                              color: const Color.fromRGBO(0, 0, 0, 0.5),
                              alignment: Alignment.center,
                              child: Lottie.asset(
                                  "assets/animation/bee_loading.json",
                                  width: MediaQuery.of(context).size.width,
                                  height:
                                      MediaQuery.of(context).size.height * 1,
                                  animate: true))
                          : Container()
                    ])))));
  }
}
