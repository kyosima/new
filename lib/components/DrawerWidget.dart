import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:news_flutter/Network/rest_apis.dart';
import 'package:news_flutter/Screens/AboutUsScreen.dart';
import 'package:news_flutter/Screens/CategoryFragment.dart';
import 'package:news_flutter/Screens/LatestNewslistScreen.dart';
import 'package:news_flutter/Screens/ProfileFragment.dart';
import 'package:news_flutter/Screens/SettingScreen.dart';
import 'package:news_flutter/Screens/SignInScreen.dart';
import 'package:news_flutter/Screens/VideoListScreen.dart';
import 'package:news_flutter/Utils/Common.dart';
import 'package:news_flutter/Utils/Images.dart';
import 'package:news_flutter/Utils/Widgets.dart';
import 'package:news_flutter/Utils/constant.dart';
import 'package:package_info/package_info.dart';

import '../app_localizations.dart';
import '../main.dart';

class DrawerWidget extends StatefulWidget {
  static String tag = '/DrawerWidget';

  @override
  DrawerWidgetState createState() => DrawerWidgetState();
}

class DrawerWidgetState extends State<DrawerWidget> {
  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    //
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    var appLocalization = AppLocalizations.of(context);

    Widget mSideMenu(var text, var icon) {
      return Container(
        child: Row(
          children: [
            Container(
              padding:
                  EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0, bottom: 8.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Image.asset(icon,
                          height: 20,
                          width: 20,
                          color: Theme.of(context).textTheme.subtitle2!.color),
                      12.width,
                      Text(text,
                          style: secondaryTextStyle(
                              color:
                                  Theme.of(context).textTheme.headline6!.color,
                              size: textSizeMedium)),
                    ],
                  ),
                  Divider(color: Colors.grey.withOpacity(0)),
                ],
              ),
            ).paddingAll(4.0)
          ],
        ),
      );
    }

    return Drawer(
      child: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Observer(
          builder: (_) => SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: context.width(),
                  height: context.height() * 0.12,
                  child: appStore.isLoggedIn
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            appStore.userProfileImage!.isEmpty
                                ? Image.asset(User_Profile,
                                        height: 60,
                                        width: 60,
                                        fit: BoxFit.cover)
                                    .cornerRadiusWithClipRRect(30)
                                : cachedImage(getStringAsync(PROFILE_IMAGE),
                                        usePlaceholderIfUrlEmpty: true,
                                        height: 60,
                                        width: 60,
                                        fit: BoxFit.cover)
                                    .cornerRadiusWithClipRRect(30),
                            8.width,
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                      '${appStore.userFirstName} ${appStore.userLastName}',
                                      style: primaryTextStyle(
                                          color: Theme.of(context)
                                              .textTheme
                                              .headline6!
                                              .color,
                                          size: textSizeMedium)),
                                  4.width,
                                  Text(appStore.userEmail!,
                                          style: primaryTextStyle(
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .subtitle2!
                                                  .color,
                                              size: textSizeMedium),
                                          maxLines: 1)
                                      .fit(),
                                ],
                              ),
                            )
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(appLocalization!.translate('login')!,
                                style: primaryTextStyle(
                                    color: Theme.of(context)
                                        .textTheme
                                        .headline6!
                                        .color,
                                    size: textSizeLargeMedium)),
                          ],
                        ),
                ).onTap(() {
                  Scaffold.of(context).openEndDrawer();
                  appStore.isLoggedIn
                      ? ProfileFragment(isTab: false).launch(context)
                      : SignInScreen().launch(context);
                }),
                Divider(color: lightGrey),
                8.height,
                mSideMenu(appLocalization!.translate('home'), ic_home)
                    .onTap(() {
                  Scaffold.of(context).openEndDrawer();
                }),
                mSideMenu(appLocalization.translate('latest'), ic_News)
                    .onTap(() {
                  Scaffold.of(context).openEndDrawer();
                  LatestNewsListScreen(
                          title: appLocalization.translate('latest'))
                      .launch(context);
                }),
                mSideMenu(
                        appLocalization.translate('categories'), ic_Categories)
                    .onTap(() {
                  Scaffold.of(context).openEndDrawer();
                  CategoryFragment(isTab: false).launch(context);
                }),
                mSideMenu(appLocalization.translate('Videos'), ic_video)
                    .onTap(() {
                  Scaffold.of(context).openEndDrawer();
                  VideoListScreen().launch(context);
                }),
                Container(
                  padding: EdgeInsets.only(
                      left: 8.0, right: 8.0, top: 8.0, bottom: 8.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Image.asset(
                              appStore.isDarkMode ? ic_mode : ic_lightMode,
                              height: 20,
                              width: 20,
                              color:
                                  Theme.of(context).textTheme.subtitle2!.color),
                          12.width,
                          Text(
                              appStore.isDarkMode
                                  ? appLocalization.translate('light_Mode')!
                                  : appLocalization.translate('night_Mode')!,
                              style: secondaryTextStyle(
                                  color: Theme.of(context)
                                      .textTheme
                                      .headline6!
                                      .color,
                                  size: textSizeMedium))
                        ],
                      ),
                      Divider(color: Colors.grey.withOpacity(0)),
                    ],
                  ),
                ).paddingAll(4.0).onTap(() async {
                  // appStore.setDarkMode(!appStore.isDarkMode);
                  appStore.setDarkMode(!appStore.isDarkMode);

                  await Future.delayed(Duration(seconds: 1));
                  finish(context);
                  setState(() {});
                }),
                mSideMenu(appLocalization.translate("settings"), ic_Setting)
                    .onTap(() {
                  Scaffold.of(context).openEndDrawer();
                  SettingScreen().launch(context);
                }),
                mSideMenu(appLocalization.translate("ratting"), ic_Ratting)
                    .onTap(() {
                  Scaffold.of(context).openEndDrawer();
                  PackageInfo.fromPlatform().then((value) {
                    launchUrl('$playStoreBaseURL${value.packageName}');
                  });
                }),
                mSideMenu(appLocalization.translate('share'), ic_Share)
                    .onTap(() {
                  Scaffold.of(context).openEndDrawer();
                  onShareTap(context);
                }),
                mSideMenu(appLocalization.translate('help_and_support')!,
                        ic_helps)
                    .onTap(() {
                  Scaffold.of(context).openEndDrawer();
                  launchUrl(helpSupport, forceWebView: true);
                }),
                mSideMenu(appLocalization.translate('aboutus')!, ic_helps)
                    .onTap(() {
                  Scaffold.of(context).openEndDrawer();
                  launchUrl(aBoutus, forceWebView: true);
                }),
                mSideMenu(appLocalization.translate('about'), ic_Contact_us)
                    .onTap(() async {
                  Scaffold.of(context).openEndDrawer();
                  AboutUsScreen().launch(context);
                }),
                mSideMenu(appLocalization.translate('logout'), ic_Logout)
                    .onTap(() async {
                  ConfirmAction? res = await showConfirmDialogs(
                      context,
                      appLocalization.translate('logout_confirmation'),
                      appLocalization.translate('yes'),
                      appLocalization.translate('no'));

                  if (res == ConfirmAction.ACCEPT) {
                    Scaffold.of(context).openEndDrawer();
                    logout(context);
                  }
                }).visible(appStore.isLoggedIn),
              ],
            ).paddingOnly(left: 16, right: 16),
          ),
        ),
      ),
    );
  }
}
