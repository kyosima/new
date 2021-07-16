import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:news_flutter/Screens/SplashScreen.dart';
import 'package:news_flutter/Utils/constant.dart';
import 'package:news_flutter/app_localizations.dart';
import 'package:news_flutter/app_theme.dart';
import 'package:news_flutter/store/AppStore.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import 'Model/LanguageModel.dart';

AppStore appStore = AppStore();
int mInterstitialAdCount = 0;

List<Language> ttsLanguage = Language.getLanguagesForTTS();




void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initialize();

  if (isMobile) {
    await Firebase.initializeApp();

    await OneSignal.shared.setAppId(mOneSignalAppId);

    OneSignal.shared.setNotificationWillShowInForegroundHandler((OSNotificationReceivedEvent event) {
      event.complete(event.notification);
    });
  }

  appStore.setDarkMode(getBoolAsync(IS_DARK_THEME));
  appStore.setLanguage(getStringAsync(LANGUAGE, defaultValue: defaultLanguage));
  appStore.setLoggedIn(getBoolAsync(IS_LOGGED_IN));
  appStore.setTTSLanguage(getStringAsync(TEXT_TO_SPEECH_LANG,defaultValue: defaultTTSLanguage));

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    setOrientationPortrait();

    return Observer(
      builder: (_) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme.copyWith(
          scaffoldBackgroundColor: Theme.of(context).cardTheme.color,
          pageTransitionsTheme: const PageTransitionsTheme(
            builders: <TargetPlatform, PageTransitionsBuilder>{
              TargetPlatform.android: ZoomPageTransitionsBuilder(),
              TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
            },
          ),
        ),
        darkTheme: AppTheme.darkTheme.copyWith(
          scaffoldBackgroundColor: Theme.of(context).cardTheme.color,
          pageTransitionsTheme: const PageTransitionsTheme(
            builders: <TargetPlatform, PageTransitionsBuilder>{
              TargetPlatform.android: ZoomPageTransitionsBuilder(),
              TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
            },
          ),
        ),
        themeMode: appStore.isDarkMode ? ThemeMode.dark : ThemeMode.light,
        supportedLocales: [
          Locale('af', ''),
          Locale('de', ''),
          Locale('en', ''),
          Locale('es', ''),
          Locale('fr', ''),
          Locale('hi', ''),
          Locale('id', ''),
          Locale('tr', ''),
          Locale('vi', ''),
          Locale('ar', ''),
          Locale('pt', ''),
          Locale('nl', '')
        ],
        localizationsDelegates: [AppLocalizations.delegate, GlobalMaterialLocalizations.delegate, GlobalWidgetsLocalizations.delegate],
        localeResolutionCallback: (locale, supportedLocales) {
          return Locale(appStore.selectedLanguageCode);
        },
        locale: Locale(appStore.selectedLanguageCode),
        

        home: SplashScreen(),
      ),
    );
  }
}
