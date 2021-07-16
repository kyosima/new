import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:news_flutter/Utils/Colors.dart';
import 'package:news_flutter/Utils/Common.dart';
import 'package:news_flutter/Utils/Images.dart';
import 'package:news_flutter/Utils/Widgets.dart';
import 'package:news_flutter/Utils/constant.dart';
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app_localizations.dart';

class AboutUsScreen extends StatefulWidget {
  static String tag = '/AboutUsScreen';

  @override
  AboutUsScreenState createState() => AboutUsScreenState();
}

class AboutUsScreenState extends State<AboutUsScreen> {
  SharedPreferences? pref;
  var darkMode = false;
  PackageInfo? package;
  var copyrightText = '';

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    if (getStringAsync(COPYRIGHT_TEXT).isNotEmpty) {
      copyrightText = getStringAsync(COPYRIGHT_TEXT);
    }
    setState(() {});
    await Future.delayed(Duration(milliseconds: 2));
    setStatusBarColor(Theme.of(context).scaffoldBackgroundColor);
  }

  @override
  void dispose() {
    setDynamicStatusBarColor();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var appLocalization = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Theme.of(context).cardColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        leading: IconButton(
          onPressed: () {
            finish(context);
          },
          icon: Icon(Icons.arrow_back, size: 30),
        ),
        title: Text(
          appLocalization.translate('about')!,
          style: boldTextStyle(size: textSizeLargeMedium),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            16.height,
            Center(
              child: Container(
                alignment: Alignment.center,
                width: 120,
                height: 120,
                padding: EdgeInsets.all(0.0),
                decoration:
                    boxDecoration(context, radius: 10.0, showShadow: true),
                child: Image.asset(
                  appLogo,
                ).cornerRadiusWithClipRRect(10.0),
              ),
            ),
            16.height,
            Text(
              '$AppName',
              style: boldTextStyle(
                  color: Theme.of(context).textTheme.headline6!.color,
                  size: textSizeNormal),
            ),
            8.height,
            Text(
              appLocalization.translate('version')!,
              style: secondaryTextStyle(
                  color: Theme.of(context).textTheme.headline6!.color,
                  size: textSizeSMedium),
            ),
            8.height,
            Text(
              copyrightText,
              style: secondaryTextStyle(
                  color: Theme.of(context).textTheme.headline6!.color,
                  size: textSizeLargeMedium),
            ),
            16.height,
            GestureDetector(
              onTap: () async {
                await launch('mailto:contact@mevivu.com');
              },
              child: Text(appLocalization.translate('contact_us')!,
                  style: boldTextStyle(
                      color: primaryColor, size: textSizeLargeMedium)),
            )
          ],
        ),
      ),
      bottomNavigationBar: Container(
        width: context.width(),
        height: context.height() * 0.2,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              appLocalization.translate('follow_us')!,
              style: boldTextStyle(
                  color: Theme.of(context).textTheme.subtitle2!.color,
                  size: textSizeMedium),
            ).visible(getStringAsync(WHATSAPP).isNotEmpty),
            16.height,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                InkWell(
                  onTap: () =>
                      redirectUrl('https://wa.me/${getStringAsync(WHATSAPP)}'),
                  child: Container(
                    margin: EdgeInsets.only(left: 16.toDouble()),
                    padding: EdgeInsets.all(10),
                    child: Image.asset(ic_WhatsUp, height: 35, width: 35),
                  ),
                ).visible(getStringAsync(WHATSAPP).isNotEmpty),
                InkWell(
                  onTap: () => redirectUrl(getStringAsync(INSTAGRAM)),
                  child: Container(
                    padding: EdgeInsets.all(10),
                    child: Image.asset(ic_Inst, height: 35, width: 35),
                  ),
                ).visible(getStringAsync(INSTAGRAM).isNotEmpty),
                InkWell(
                  onTap: () => redirectUrl(getStringAsync(TWITTER)),
                  child: Container(
                    padding: EdgeInsets.all(10),
                    child: Image.asset(ic_Twitter, height: 35, width: 35),
                  ),
                ).visible(getStringAsync(TWITTER).isNotEmpty),
                InkWell(
                  onTap: () => redirectUrl(getStringAsync(FACEBOOK)),
                  child: Container(
                    padding: EdgeInsets.all(10),
                    child: Image.asset(ic_Fb, height: 35, width: 35),
                  ),
                ).visible(getStringAsync(FACEBOOK).isNotEmpty),
                InkWell(
                  onTap: () => redirectUrl('tel:${getStringAsync(CONTACT)}'),
                  child: Container(
                    margin: EdgeInsets.only(right: 16.toDouble()),
                    padding: EdgeInsets.all(10),
                    child: Image.asset(ic_CallRing,
                        height: 35, width: 35, color: primaryColor),
                  ),
                ).visible(getStringAsync(CONTACT).isNotEmpty)
              ],
            )
          ],
        ),
      ),
    );
  }
}
