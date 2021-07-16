import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:news_flutter/Network/rest_apis.dart';
import 'package:news_flutter/Screens/DashboardScreen.dart';
import 'package:news_flutter/Utils/Images.dart';
import 'package:news_flutter/Utils/constant.dart';

import '../main.dart';

class SplashScreen extends StatefulWidget {
  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    allowPreFetched = getBoolAsync(allowPreFetchedPref, defaultValue: true);
    setStatusBarColor(Colors.transparent);

    await Future.delayed(Duration(milliseconds: 2000));

    if (!getBoolAsync(IS_REMEMBERED,defaultValue: true)) {
      logout(context);
    } else {
      if (appStore.isLoggedIn) {
        appStore.setUserProfile(getStringAsync(PROFILE_IMAGE));
        appStore.setUserId(getIntAsync(USER_ID));
        appStore.setUserEmail(getStringAsync(USER_EMAIL));
        appStore.setFirstName(getStringAsync(FIRST_NAME));
        appStore.setLastName(getStringAsync(LAST_NAME));
        appStore.setUserLogin(getStringAsync(USER_LOGIN));
      }
      DashboardScreen().launch(context, isNewTask: true);
    }
  }
  @override
  void dispose() {

    super.dispose();


  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: context.height(),
      width: context.width(),
      color: Colors.white,
      child: Image.asset(Splash_Img, height: 150, fit: BoxFit.fitHeight).center(),
    );
  }
}
