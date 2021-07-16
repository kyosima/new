import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:news_flutter/Screens/BookmarkFragment.dart';
import 'package:news_flutter/Screens/CategoryFragment.dart';
import 'package:news_flutter/Screens/HomeFragment.dart';
import 'package:news_flutter/Screens/NewsDetailScreen.dart';
import 'package:news_flutter/Screens/ProfileFragment.dart';
import 'package:news_flutter/Screens/SearchFragment.dart';
import 'package:news_flutter/Screens/SignInScreen.dart';
import 'package:news_flutter/Screens/WebViewScreen.dart';
import 'package:news_flutter/Utils/Colors.dart';
import 'package:news_flutter/Utils/Images.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import '../main.dart';

class DashboardScreen extends StatefulWidget {
  @override
  DashboardScreenState createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> with AfterLayoutMixin<DashboardScreen>, TickerProviderStateMixin {
  int selectedIndex = 0;

  List<Widget> pages = [
    HomeFragment(),
    BookmarkFragment(),
    CategoryFragment(isTab: true),
    SearchFragment(isTab: true),
    ProfileFragment(isTab: true),
  ];

  @override
  void initState() {
    super.initState();
    init();
  }


  init() async {
    //
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  void afterFirstLayout(BuildContext context) {
    if (isMobile) {
      OneSignal.shared.setNotificationOpenedHandler((openedResult) {
        String id = openedResult.notification.additionalData!.containsKey('id') ? openedResult.notification.additionalData!['id'] : '';

        if (id.isNotEmpty) {
          NewsDetailScreen(newsId: id,post: null).launch(context);
        } else {
          if (openedResult.notification.additionalData!.containsKey('video_url')) {
            String? videoUrl = openedResult.notification.additionalData!['video_url'];
            String? videoType = openedResult.notification.additionalData!['video_type'];

            WebViewScreen(videoUrl: videoUrl, videoType: videoType).launch(context);
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) {
          if ((index != 1 || (index == 1 && appStore.isLoggedIn)) && (index != 4 || (index == 4 && appStore.isLoggedIn))) {
            selectedIndex = index;
            setState(() {});
          } else {
            SignInScreen().launch(context);
          }
        },
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        currentIndex: selectedIndex,
        type: BottomNavigationBarType.fixed,
        unselectedFontSize: 14,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        selectedFontSize: 14,
        items: [
          BottomNavigationBarItem(
            label: '',
            icon: Image.asset(Home_Tab, width: 20, height: 20, color: Theme.of(context).textTheme.headline6!.color),
            activeIcon: Container(
              padding: EdgeInsets.all(10),
              alignment: Alignment.center,
              decoration: BoxDecoration(shape: BoxShape.circle, color: primaryColor.withOpacity(0.2)),
              child: Image.asset(Home_Tab, width: 20, height: 20, color: primaryColor),
            ),
          ),
          BottomNavigationBarItem(
            label: '',
            icon: Image.asset(WishList_Tab, width: 20, height: 20, color: Theme.of(context).textTheme.headline6!.color),
            activeIcon: Container(
              padding: EdgeInsets.all(10),
              alignment: Alignment.center,
              decoration: BoxDecoration(shape: BoxShape.circle, color: primaryColor.withOpacity(0.2)),
              child: Image.asset(WishList_Tab, width: 20, height: 20, color: primaryColor),
            ),
          ),
          BottomNavigationBarItem(
            label: '',
            icon: Image.asset(Category_Tab, width: 20, height: 20, color: Theme.of(context).textTheme.headline6!.color),
            activeIcon: Container(
              padding: EdgeInsets.all(10),
              alignment: Alignment.center,
              decoration: BoxDecoration(shape: BoxShape.circle, color: primaryColor.withOpacity(0.2)),
              child: Image.asset(Category_Tab, width: 20, height: 20, color: primaryColor),
            ),
          ),
          BottomNavigationBarItem(
            icon: Image.asset(Search_Tab, width: 20, height: 20, color: Theme.of(context).textTheme.headline6!.color),
            label: '',
            activeIcon: Container(
              padding: EdgeInsets.all(10),
              alignment: Alignment.center,
              decoration: BoxDecoration(shape: BoxShape.circle, color: primaryColor.withOpacity(0.2)),
              child: Image.asset(Search_Tab, width: 20, height: 20, color: primaryColor),
            ),
          ),
          BottomNavigationBarItem(
            label: '',
            icon: Image.asset(User_Tab, width: 20, height: 20, color: Theme.of(context).textTheme.headline6!.color),
            activeIcon: Container(
              padding: EdgeInsets.all(10),
              alignment: Alignment.center,
              decoration: BoxDecoration(shape: BoxShape.circle, color: primaryColor.withOpacity(0.2)),
              child: Image.asset(User_Tab, width: 20, height: 20, color: primaryColor),
            ),
          ),
        ],
      ),
      body: SafeArea(child: pages[selectedIndex]),


    );
  }
}
