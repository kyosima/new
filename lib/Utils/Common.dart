import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart' show parse;
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:url_launcher/url_launcher.dart';

import '../main.dart';
import 'Colors.dart';
import 'constant.dart';

String convertDate(date) {
  try {
    return date != null ? DateFormat(dateFormat).format(DateTime.parse(date)) : '';
  } catch (e) {
    print(e);
    return '';
  }
}

String parseHtmlString(String? htmlString) {
  return parse(parse(htmlString).body!.text).documentElement!.text;
}

void redirectUrl(url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    toast('Please check URL');
    throw 'Could not launch $url';
  }
}

void loader(bool isLoader) {
  Column(
    children: [
      CircularProgressIndicator(),
      Text('Loading...', style: primaryTextStyle(color: textPrimaryColor, size: textSizeSMedium)),
    ],
  ).visible(isLoader == true);
}

String getAppId() {
  return 'ca-app-pub-3940256099942544~3347511713';
}

String? getBannerAdUnitId() {
  if (Platform.isIOS) {
    return bannerAdIdForIos;
  } else if (Platform.isAndroid) {
    return bannerAdIdForAndroid;
  }
  return null;
}

String? getInterstitialAdUnitId() {
  if (Platform.isIOS) {
    return interstitialAdIdForIos;
  } else if (Platform.isAndroid) {
    return InterstitialAdIdForAndroid;
  }
  return null;
}

Future<void> launchUrl(String url, {bool forceWebView = false}) async {
  log(url);
  await launch(url, forceWebView: forceWebView, enableJavaScript: true).catchError((e) {
    log(e);
    toast('Invalid URL: $url');
  });
}

Future<void> setDynamicStatusBarColor() async {
  await Future.delayed(Duration(milliseconds: 200));
  setStatusBarColor(appStore.isDarkMode ? appBackGroundColor : white);
}

InputDecoration inputDecoration(BuildContext context, String? hint) {
  return InputDecoration(
    labelText: hint,
    labelStyle: primaryTextStyle(color: Theme.of(context).textTheme.headline6!.color),
    errorStyle: primaryTextStyle(color: Colors.redAccent, size: textSizeSmall),
    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: appStore.isDarkMode ? white_color : blackColor, width: 0.0)),
    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: primaryColor, width: 0.0)),
  );
}

int findMiddleFactor(int n) {
  List<int?> num = [];
  for (int i = 1; i <= n; i++) {
    if (n % i == 0 && i > 1 && i < 20) {
      num.add(i);
    }
  }
  return num[num.length ~/ 2]!;
}
