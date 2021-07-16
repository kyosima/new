import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:news_flutter/Model/LanguageModel.dart';
import 'package:news_flutter/Screens/ChangePasswordScreen.dart';
import 'package:news_flutter/Utils/Colors.dart';
import 'package:news_flutter/Utils/constant.dart';
import 'package:news_flutter/app_localizations.dart';
import 'package:news_flutter/Screens/ChooseDetailPageVariantScreen.dart';

import '../main.dart';

class SettingScreen extends StatefulWidget {
  @override
  SettingScreenState createState() => SettingScreenState();
}

class SettingScreenState extends State<SettingScreen> {
  List<int> fontSizeList = [8, 10, 12, 14, 16, 18, 20, 22, 24, 26, 28, 30, 32, 34];
  int? fontSize = 18;
  bool isAdsLoading = false;
  int selectedLanguage = 0;
  int selectedTTsLang = 0;
  String? language;
  String? ttsLang;

  late BannerAd myBanner;

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    myBanner = buildBannerAd()..load();
    fontSize = getIntAsync(FONT_SIZE, defaultValue: 18);
    selectedLanguage = getIntAsync(SELECTED_LANGUAGE_INDEX);
    language = Language.getLanguages()[selectedLanguage].name;
    ttsLang = Language.getLanguagesForTTS()[selectedTTsLang].name;

    if (await isNetworkAvailable()) {
      setState(
        () {
          isAdsLoading = isAdsLoading;
        },
      );
    }
    setState(() {});
  }

  BannerAd buildBannerAd() {
    return BannerAd(
      adUnitId: kReleaseMode ? bannerAdIdForAndroid : BannerAd.testAdUnitId,
      size: AdSize.banner,
      listener: AdListener(
        onAdLoaded: (ad) {
          //
        },
      ),
      request: AdRequest(testDevices: []),
    );
  }

  @override
  Widget build(BuildContext context) {
    var appLocalization = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Theme.of(context).cardTheme.color,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 5.0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: 30, color: Theme.of(context).textTheme.headline6!.color),
          onPressed: () {
            finish(context);
          },
        ),
        title: Text(appLocalization.translate("setting")!, style: boldTextStyle(color: Theme.of(context).textTheme.headline6!.color, size: 18)),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  SettingItemWidget(
                    title: '${appLocalization.translate('change_Password')!}',
                    trailing: Icon(Icons.keyboard_arrow_right, size: 30, color: Theme.of(context).textTheme.subtitle2!.color),
                    onTap: () {
                      ChangePasswordScreen().launch(context);
                    },
                    padding: EdgeInsets.all(8.0),
                  ).visible(appStore.isLoggedIn),
                  SettingItemWidget(
                    title: '${appLocalization.translate('font_size')!}',
                    padding: EdgeInsets.all(8.0),
                    trailing: DropdownButton<int>(
                      value: fontSize,
                      underline: 0.height,
                      dropdownColor: appStore.isDarkMode ? card_background_black : white_color,
                      icon: Icon(Icons.arrow_drop_down, color: appStore.isDarkMode ? white_color : blackColor).paddingLeft(10),
                      onChanged: (int? newValue) {
                        setState(() {
                          fontSize = newValue;
                          setValue(FONT_SIZE, fontSize);
                        });
                      },
                      items: fontSizeList.map(
                        (font) {
                          return DropdownMenuItem(
                            child: Text(font.toString(), style: primaryTextStyle(color: Theme.of(context).textTheme.headline6!.color)).paddingOnly(left: 8),
                            value: font,
                          );
                        },
                      ).toList(),
                    ),
                  ),
                  SettingItemWidget(
                    title: '${appLocalization.translate('language')!}',
                    padding: EdgeInsets.all(8.0),
                    trailing: DropdownButton(
                      isDense: true,
                      value: Language.getLanguages()[selectedLanguage].name,
                      dropdownColor: Theme.of(context).scaffoldBackgroundColor,
                      onChanged: (dynamic newValue) async {
                        for (var i = 0; i < Language.getLanguages().length; i++) {
                          if (newValue == Language.getLanguages()[i].name) {
                            selectedLanguage = i;
                          }
                        }

                        await setValue(SELECTED_LANGUAGE_CODE, Language.getLanguages()[selectedLanguage].languageCode);
                        await setValue(SELECTED_LANGUAGE_INDEX, selectedLanguage);

                        await setValue(LANGUAGE, selectedLanguage.toString());
                        appStore.setLanguage(Language.getLanguages()[selectedLanguage].languageCode.toString().validate());
                        setState(() {});
                      },
                      items: Language.getLanguages().map(
                        (language) {
                          return DropdownMenuItem(
                            child: Row(
                              children: <Widget>[
                                Image.asset(language.flag, width: 24, height: 24),
                                SizedBox(width: 10),
                                Text(language.name, style: primaryTextStyle(color: Theme.of(context).textTheme.subtitle2!.color)),
                              ],
                            ),
                            value: language.name,
                          );
                        },
                      ).toList(),
                    ),
                  ).visible(isLanguageEnable),
                  SettingItemWidget(
                    title: '${appLocalization.translate('pre_fetching')!}',
                    padding: EdgeInsets.all(8.0),
                    trailing: Switch(
                      value: allowPreFetched,
                      onChanged: (v) async {
                        handlePreFetching(v);
                      },
                    ),
                    onTap: () async {
                      handlePreFetching(!allowPreFetched);
                    },
                  ),
                  Observer(
                    builder: (_) => SettingItemWidget(
                      title: '${appStore.isNotificationOn ? appLocalization.translate('disable') : appLocalization.translate('enable')} ${appLocalization.translate('push_notification')}',
                      trailing: Switch(
                        value: appStore.isNotificationOn,
                        onChanged: (v) async {
                          appStore.setNotification(v);
                        },
                      ).withHeight(20),
                      padding: EdgeInsets.all(8.0),
                      onTap: () async {
                        appStore.setNotification(
                          !getBoolAsync(IS_NOTIFICATION_ON, defaultValue: false),
                        );
                      },
                    ),
                  ),
                  8.height,
                  SettingItemWidget(
                    title: '${appLocalization.translate('text_to_speech')!}',
                    padding: EdgeInsets.all(12.0),
                    trailing: DropdownButton(
                      isDense: true,
                      value: Language.getLanguagesForTTS()[selectedTTsLang].name,
                      dropdownColor: Theme.of(context).scaffoldBackgroundColor,
                      onChanged: (dynamic newValue) async {
                        for (var i = 0; i < Language.getLanguagesForTTS().length; i++) {
                          if (newValue == Language.getLanguagesForTTS()[i].name) {
                            selectedTTsLang = i;
                          }
                        }

                        await setValue(SELECTED_LANGUAGE_CODE, Language.getLanguagesForTTS()[selectedTTsLang].languageCode);
                        await setValue(SELECTED_LANGUAGE_INDEX, selectedTTsLang);
                        await setValue(LANGUAGE, selectedTTsLang.toString());

                        setState(() {});
                        toast("${Language.getLanguagesForTTS()[selectedTTsLang].name} is Default language for Text to Speech");
                      },
                      items: Language.getLanguagesForTTS().map(
                        (ttsLanguage) {
                          return DropdownMenuItem(
                            child: Row(
                              children: <Widget>[
                                SizedBox(width: 10),
                                Text(ttsLanguage.name, style: primaryTextStyle(color: Theme.of(context).textTheme.subtitle2!.color)),
                              ],
                            ),
                            value: ttsLanguage.name,
                          );
                        },
                      ).toList(),
                    ),
                  ),
                  SettingItemWidget(
                    title: '${appLocalization.translate('choose_detail_page_variant')!}',
                    padding: EdgeInsets.all(12.0),
                    trailing: Text('Variant ${getIntAsync(DETAIL_PAGE_VARIANT)}', style: boldTextStyle()),
                    onTap: () async {
                      bool res = await ChooseDetailPageVariantScreen().launch(context);
                      if (res) {
                        setState(() {});
                      }
                    },
                  )
                ],
              ),
            ),
            Positioned(bottom: 0, child: isAdsLoading ? AdWidget(ad: myBanner) : SizedBox()),
          ],
        ),
      ),
    );
  }

  void handlePreFetching(bool v) async {
    allowPreFetched = v;

    await setValue(allowPreFetchedPref, allowPreFetched);

    if (!allowPreFetched) {
      await removeKey(dashboardData);
      await removeKey(categoryData);
      await removeKey(videoListData);
      await removeKey(bookmarkData);
    }

    setState(() {});
  }
}
