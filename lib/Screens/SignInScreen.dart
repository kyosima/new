import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:news_flutter/Network/AuthService.dart';
import 'package:news_flutter/Network/rest_apis.dart';
import 'package:news_flutter/Screens/DashboardScreen.dart';
import 'package:news_flutter/Screens/SignUpScreen.dart';
import 'package:news_flutter/Utils/Colors.dart';
import 'package:news_flutter/Utils/Common.dart';
import 'package:news_flutter/Utils/Images.dart';
import 'package:news_flutter/Utils/OvalBottomBorderClipper.dart';
import 'package:news_flutter/Utils/Strings.dart';
import 'package:news_flutter/Utils/Widgets.dart';
import 'package:news_flutter/Utils/constant.dart';
import 'package:news_flutter/app_localizations.dart';
import 'package:news_flutter/components/OTPDialogBox.dart';
import 'package:news_flutter/main.dart';
import 'package:the_apple_sign_in/the_apple_sign_in.dart';

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  bool? isSelectedCheck = false;
  var isVisibility = true;
  var formKey = GlobalKey<FormState>();
  var autoValidate = false;

  var emailCont = TextEditingController();
  var passwordCont = TextEditingController();

  var passwordFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    if (isIos) {
      TheAppleSignIn.onCredentialRevoked!.listen((_) {
        log("Credentials revoked");
      });
    }
    setStatusBarColor(primaryColor);
  }

  Future<void> signInApi(req) async {
    await login(req).then((res) async {
      appStore.setLoading(false);

      await setValue(IS_REMEMBERED, getBoolAsync(IS_REMEMBERED));
      DashboardScreen().launch(context, isNewTask: true);
    }).catchError((error) {
      appStore.setLoading(false);
      toast(error.toString());
    });
  }

  void validate() {
    hideKeyboard(context);
    if (!accessAllowed) {
      toast("Sorry");
      return;
    }

    if (formKey.currentState!.validate()) {
      var request = {
        "username": "${emailCont.text}",
        "password": "${passwordCont.text}",
      };

      if (emailCont.text.isEmpty)
        toast(Email_Address + Field_Required);
      else if (passwordCont.text.isEmpty)
        toast(Password + Field_Required);
      else {
        appStore.setLoading(true);
        signInApi(request);
      }
      setState(() {});
    } else {
      autoValidate = true;
    }

    setState(() {});
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
      //setDynamicStatusBarColor();
    setStatusBarColor(Colors.transparent);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var appLocalization = AppLocalizations.of(context);

    Widget socialButtons = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        GoogleLogoWidget().onTap(() async {
          appStore.setLoading(true);

          await LogInWithGoogle().then((user) async {
            appStore.setLoading(false);

            DashboardScreen().launch(context, isNewTask: true);
          }).catchError((e) {
            toast(e.toString());
            appStore.setLoading(false);
          });
        }),
        16.width,
        Container(
          padding: EdgeInsets.all(8),
          child: Image.asset(ic_CallRing, color: appStore.isDarkMode ? white : Colors.lightGreen, width: 30, height: 30),
        ).onTap(() async {
          await showInDialog(context, child: OTPDialogBox(), shape: dialogShape(), barrierDismissible: false).catchError((e) {
            toast(e.toString());
          });
        }),
        16.width,
        Container(
          padding: EdgeInsets.all(8),
          child: Image.asset(ic_Apple, color: appStore.isDarkMode ? white : black, width: 30, height: 30),
        ).onTap(
          () async {
            appStore.setLoading(true);

            await appleSignIn().then((value) {
              appStore.setLoading(false);

              DashboardScreen().launch(context, isNewTask: true);
            }).catchError((e) {
              toast(e.toString());
              appStore.setLoading(false);
              setState(() {});
            });
          },
        ).visible(isIos),
      ],
    );

    return Scaffold(
      backgroundColor: Theme.of(context).cardColor,
      body: Observer(
        builder: (_) => Stack(
          children: [
            SingleChildScrollView(
              child: Form(
                key: formKey,
                // ignore: deprecated_member_use
                autovalidate: autoValidate,
                child: Column(
                  children: <Widget>[
                    Stack(
                      children: [
                        ClipPath(clipper: OvalBottomBorderClipper(), child: Container(height: 250, color: primaryColor)),
                        Image.asset(SignInLogo, height: 200, width: context.width()).paddingTop(24),
                        IconButton(
                            icon: Icon(
                              Icons.arrow_back,
                              color: white_color,
                            ),
                            onPressed: () {
                              finish(context);
                            }).paddingOnly(top: 20, left: 8)
                      ],
                    ),
                    16.height,
                    Text(appLocalization!.translate('title_For_Sign_In')!, style: boldTextStyle(color: Theme.of(context).textTheme.headline6!.color, size: textSizeLarge)),
                    8.height,
                    Text(appLocalization.translate('welcome_Msg_for_SignIn')!, style: secondaryTextStyle(color: Theme.of(context).textTheme.subtitle2!.color, size: textSizeSMedium)),
                    16.height,
                    Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          AppTextField(
                            controller: emailCont,
                            textFieldType: TextFieldType.EMAIL,
                            decoration: inputDecoration(context, appLocalization.translate('username_or_Email')),
                            errorInvalidEmail: '${appLocalization.translate('username_or_Email')} + ${appLocalization.translate('field_Required')}',
                            nextFocus: passwordFocus,
                            cursorColor: appStore.isDarkMode ? Colors.white : Colors.black,
                          ),
                          16.height,
                          AppTextField(
                            controller: passwordCont,
                            textFieldType: TextFieldType.PASSWORD,
                            decoration: inputDecoration(context, appLocalization.translate('password')),
                            focus: passwordFocus,
                            cursorColor: appStore.isDarkMode ? Colors.white : Colors.black,
                            textInputAction: TextInputAction.done,
                            errorMinimumPasswordLength: '${appLocalization.translate('PasswordToast')}',
                            onFieldSubmitted: (s) {
                              validate();
                            },
                          ),
                        ],
                      ).paddingAll(20.0),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: <Widget>[
                            Checkbox(
                              value: getBoolAsync(IS_REMEMBERED, defaultValue: true),
                              activeColor: primaryColor,
                              checkColor: white,
                              onChanged: (v) {
                                isSelectedCheck = v;
                                setValue(IS_REMEMBERED, v);
                                setState(() {});
                              },
                            ),
                            Text(
                              appLocalization.translate('Remember')!,
                              style: primaryTextStyle(color: Theme.of(context).textTheme.subtitle2!.color, size: textSizeSMedium),
                            ).onTap(() {
                              setValue(IS_REMEMBERED, !getBoolAsync(IS_REMEMBERED));
                              isSelectedCheck = !isSelectedCheck!;
                              setState(() {});
                            }).expand()
                          ],
                        ).expand(),
                        Text(appLocalization.translate('forgot')!, style: primaryTextStyle(color: Theme.of(context).textTheme.subtitle2!.color, size: textSizeMedium)).paddingRight(16.0).onTap(() {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) => CustomDialog(),
                          );
                        }),
                      ],
                    ).paddingOnly(left: 8, right: 8, bottom: 8),
                    16.height,
                    NewsButton(
                      textContent: appLocalization.translate('sign_In'),
                      onPressed: () {
                        validate();
                      },
                    ).paddingOnly(left: 16.0, right: 16.0),
                    16.height,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          appLocalization.translate('don_t_have_account')!,
                          style: secondaryTextStyle(color: Theme.of(context).textTheme.subtitle2!.color, size: textSizeMedium),
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 4),
                          child: GestureDetector(
                            child: Text(SignUp, style: TextStyle(decoration: TextDecoration.underline, color: primaryColor, fontSize: textSizeMedium.toDouble())),
                            onTap: () {
                              SignUpScreen().launch(context);
                            },
                          ),
                        )
                      ],
                    ),
                    16.height,
                    socialButtons,
                    16.height,
                  ],
                ),
              ),
            ),
            CircularProgressIndicator().center().visible(appStore.isLoading),
          ],
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class CustomDialog extends StatelessWidget {
  var email = TextEditingController();

  @override
  Widget build(BuildContext context) {
    forgotPwdApi() async {
      hideKeyboard(context);

      var request = {
        'email': email.text,
      };

      forgotPassword(request).then((res) {
        appStore.setLoading(false);

        toast('Successfully Send Email');
        finish(context);
      }).catchError((error) {
        appStore.setLoading(false);
        toast(error.toString());
      });
    }

    var appLocalization = AppLocalizations.of(context)!;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width,
        decoration: boxDecoration(context, color: white_color, radius: 10.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min, // To make the card compact
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  16.height,
                  Text(appLocalization.translate('forgot_Password')!, style: boldTextStyle(color: Theme.of(context).textTheme.headline6!.color, size: textSizeLargeMedium)),
                  24.height,
                  AppTextField(
                    controller: email,
                    textFieldType: TextFieldType.NAME,
                    decoration: inputDecoration(context, appLocalization.translate('email_Address')),
                    autoFocus: true,
                    cursorColor: appStore.isDarkMode ? Colors.white : Colors.black,
                  ),
                ],
              ).paddingOnly(left: 16.0, right: 16.0, bottom: 16.0),
              Container(
                width: MediaQuery.of(context).size.width,
                child: NewsButton(
                  textContent: appLocalization.translate('send'),
                  height: 50,
                  onPressed: () {
                    if (!accessAllowed) {
                      toast("Sorry");
                      return;
                    }
                    if (email.text.isEmpty)
                      toast(Email + Field_Required);
                    else
                      appStore.setLoading(true);
                    forgotPwdApi();
                  },
                ),
              ).paddingAll(16.0),
            ],
          ),
        ),
      ),
    );
  }
}
