import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:news_flutter/Network/rest_apis.dart';
import 'package:news_flutter/Screens/SignInScreen.dart';
import 'package:news_flutter/Utils/Common.dart';
import 'package:news_flutter/Utils/Widgets.dart';
import 'package:news_flutter/Utils/constant.dart';
import 'package:news_flutter/app_localizations.dart';

import '../main.dart';

class ChangePasswordScreen extends StatefulWidget {
  @override
  ChangePasswordScreenState createState() => ChangePasswordScreenState();
}

class ChangePasswordScreenState extends State<ChangePasswordScreen> {
  var formKey = GlobalKey<FormState>();

  var confirmPasswordCont = TextEditingController();
  var oldPasswordCont = TextEditingController();
  var newPasswordCont = TextEditingController();

  var newPasswordFocus = FocusNode();
  var confirmPasswordFocus = FocusNode();

  BannerAd? myBanner;

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    myBanner = buildBannerAd()..load();
  }

  BannerAd buildBannerAd() {
    return BannerAd(
      adUnitId: kReleaseMode ? bannerAdIdForAndroid : BannerAd.testAdUnitId,
      size: AdSize.banner,
      listener: AdListener(onAdLoaded: (ad) {
        //
      }),
      request: AdRequest(
        testDevices: [testDeviceId],
      ),
    );
  }

  validate() {
    if (formKey.currentState!.validate()) {
      appStore.setLoading(true);

      var request = {
        'password': oldPasswordCont.text,
        'new_password': confirmPasswordCont.text,
        'username': getStringAsync(USERNAME),
      };

      hideKeyboard(context);

      changePassword(request).then((res) {
        appStore.setLoading(false);
        toast('SuccessFully Change Your Password');
        SignInScreen().launch(context, isNewTask: true);
      }).catchError((error) {
        appStore.setLoading(false);
        toast(error.toString());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var appLocalization = AppLocalizations.of(context)!;

    return SafeArea(
      child: Scaffold(
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
          title: Text(
            appLocalization.translate('change_Password')!,
            style: boldTextStyle(color: Theme.of(context).textTheme.headline6!.color, size: 18),
          ),
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Form(
                key: formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    16.height,
                    AppTextField(
                      controller: oldPasswordCont,
                      textFieldType: TextFieldType.PASSWORD,
                      decoration: inputDecoration(context, appLocalization.translate('old_Password')),
                      nextFocus: newPasswordFocus,
                      cursorColor: appStore.isDarkMode ? Colors.white : Colors.black,
                    ),
                    16.height,
                    AppTextField(
                      controller: newPasswordCont,
                      textFieldType: TextFieldType.PASSWORD,
                      decoration: inputDecoration(context, appLocalization.translate('new_Password')),
                      focus: newPasswordFocus,
                      nextFocus: confirmPasswordFocus,
                      cursorColor: appStore.isDarkMode ? Colors.white : Colors.black,
                    ),
                    16.height,
                    AppTextField(
                      controller: confirmPasswordCont,
                      textFieldType: TextFieldType.PASSWORD,
                      decoration: inputDecoration(context, appLocalization.translate('confirm_Password')),
                      focus: confirmPasswordFocus,
                      cursorColor: appStore.isDarkMode ? Colors.white : Colors.black,
                      validator: (v) {
                        if (v!.trim().isEmpty) return appLocalization.translate('confirm_Password')! + appLocalization.translate('field_Required')!;
                        if (v.trim() != newPasswordCont.text) return 'password does not match';

                        return null;
                      },
                    ),
                    24.height,
                    NewsButton(
                      textContent: appLocalization.translate('save'),
                      height: 50,
                      onPressed: () {
                        hideKeyboard(context);
                        if (!accessAllowed) {
                          toast("Sorry");
                          return;
                        }
                        validate();
                      },
                    )
                  ],
                ).paddingAll(16.0),
              ),
            ),
            Observer(builder: (_) => CircularProgressIndicator().center().visible(appStore.isLoading)),
          ],
        ),
        bottomNavigationBar: !isAdsDisabled && myBanner != null
            ? Container(
                height: AdSize.banner.height.toDouble(),
                color: Theme.of(context).scaffoldBackgroundColor,
                child: AdWidget(ad: myBanner!),
              )
            : SizedBox(),
      ),
    );
  }
}
