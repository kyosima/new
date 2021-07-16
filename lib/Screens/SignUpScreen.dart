import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:news_flutter/Network/rest_apis.dart';
import 'package:news_flutter/Screens/DashboardScreen.dart';
import 'package:news_flutter/Utils/Colors.dart';
import 'package:news_flutter/Utils/Common.dart';
import 'package:news_flutter/Utils/Widgets.dart';
import 'package:news_flutter/Utils/constant.dart';
import 'package:news_flutter/app_localizations.dart';

import '../main.dart';

class SignUpScreen extends StatefulWidget {
  final String? phoneNumber;

  SignUpScreen({this.phoneNumber});

  @override
  SignUpScreenState createState() => SignUpScreenState();
}

class SignUpScreenState extends State<SignUpScreen> {
  bool? isSelectedCheck;
  var isVisibility = true;
  bool confirmPasswordVisible = false;
  var formKey = GlobalKey<FormState>();
  var autoValidate = false;

  var fNameCont = TextEditingController();
  var lNameCont = TextEditingController();
  var emailCont = TextEditingController();
  var usernameCont = TextEditingController();
  var passwordCont = TextEditingController();

  var lNameFocus = FocusNode();
  var emailFocus = FocusNode();
  var usernameFocus = FocusNode();
  var passwordFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    isSelectedCheck = false;
    await Future.delayed(Duration(milliseconds: 2));
    setStatusBarColor(primaryColor);
  }

  validate() {
    if (formKey.currentState!.validate()) {
      signUpApi();
    } else {
      autoValidate = true;
    }
  }

  signUpApi() async {
    hideKeyboard(context);
    var request = {
      'first_name': fNameCont.text,
      'last_name': lNameCont.text,
      'user_login': widget.phoneNumber ?? usernameCont.text,
      'user_email': emailCont.text,
      'user_pass': widget.phoneNumber ?? passwordCont.text,
    };

    appStore.setLoading(true);
    setState(() {});

    createUser(request).then((res) async {
      if (!mounted) return;
      toast(AppLocalizations.of(context)!.translate('successFully_Register'));
      appStore.setLoading(false);
      setState(() {});

      Map req = {'username': widget.phoneNumber ?? emailCont.text, 'password': widget.phoneNumber ?? passwordCont.text};

      await login(req).then((value) async {
        appStore.setLoading(false);
        setState(() {});

        if (widget.phoneNumber != null) await setValue(LOGIN_TYPE, SignInTypeOTP);

        DashboardScreen().launch(context, isNewTask: true);
      }).catchError((e) {
        appStore.setLoading(false);

        setState(() {});
      });
    }).catchError((error) {
      appStore.setLoading(false);
      setState(() {});
      toast(error.toString());
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    var appLocalization = AppLocalizations.of(context)!;

    return Stack(
      children: [
        Scaffold(
          backgroundColor: primaryColor,
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      size: 30,
                      color: white_color,
                    ),
                    onPressed: () {
                      finish(context);
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.laptop_chromebook, size: 30, color: white_color),
                      8.width,
                      Text('$AppName', style: boldTextStyle(color: white_color, size: textSizeLarge)),
                    ],
                  ),
                  16.height,
                  Container(
                    //decoration: boxDecoration(context, bgColor: Theme.of(context).scaffoldBackgroundColor, radius: 10.0),
                    decoration: boxDecoration(context, bgColor: Theme.of(context).cardColor, radius: 10.0),
                    width: context.width(),
                    child: Column(
                      children: [
                        16.height,
                        Text(appLocalization.translate('getting_Started')!, style: boldTextStyle(color: Theme.of(context).textTheme.headline6!.color, size: textSizeLargeMedium)),
                        8.height,
                        Text(appLocalization.translate('create_an_Account_continue')!, style: secondaryTextStyle(color: Theme.of(context).textTheme.subtitle2!.color, size: textSizeMedium)),
                        16.height,
                        Form(
                          key: formKey,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              AppTextField(
                                controller: fNameCont,
                                textFieldType: TextFieldType.NAME,
                                decoration: inputDecoration(context, appLocalization.translate('first_Name')),
                                nextFocus: lNameFocus,
                                cursorColor: appStore.isDarkMode ? Colors.white : Colors.black,
                              ),
                              16.height,
                              AppTextField(
                                controller: lNameCont,
                                focus: lNameFocus,
                                textFieldType: TextFieldType.NAME,
                                decoration: inputDecoration(context, appLocalization.translate('last_Name')),
                                nextFocus: widget.phoneNumber != null ? emailFocus : usernameFocus,
                                cursorColor: appStore.isDarkMode ? Colors.white : Colors.black,
                              ),
                              16.height,
                              AppTextField(
                                controller: usernameCont,
                                focus: usernameFocus,
                                textFieldType: TextFieldType.NAME,
                                decoration: inputDecoration(context, appLocalization.translate('userName')),
                                nextFocus: emailFocus,
                                cursorColor: appStore.isDarkMode ? Colors.white : Colors.black,
                              ).visible(widget.phoneNumber == null),
                              16.height,
                              AppTextField(
                                controller: emailCont,
                                focus: emailFocus,
                                textFieldType: TextFieldType.EMAIL,
                                decoration: inputDecoration(context, appLocalization.translate('email_Address')),
                                errorInvalidEmail: '${appLocalization.translate('EmailToast')} + ${appLocalization.translate('field_Required')}',
                                nextFocus: widget.phoneNumber != null ? null : passwordFocus,
                                cursorColor: appStore.isDarkMode ? Colors.white : Colors.black,
                              ),
                              16.height,
                              AppTextField(
                                controller: passwordCont,
                                focus: passwordFocus,
                                textFieldType: TextFieldType.PASSWORD,
                                decoration: inputDecoration(context, appLocalization.translate('password')),
                                cursorColor: appStore.isDarkMode ? Colors.white : Colors.black,
                                textInputAction: TextInputAction.done,
                                isValidationRequired: widget.phoneNumber == null,
                              ).visible(widget.phoneNumber == null),
                            ],
                          ).paddingAll(16.0),
                        ),
                        Row(
                          children: <Widget>[
                            IconButton(
                                icon: Icon(
                                  isSelectedCheck == false ? Icons.check_box_outline_blank : Icons.check_box,
                                  size: 30,
                                  color: isSelectedCheck == false ? textColorSecondary : primaryColor,
                                ),
                                onPressed: () {
                                  isSelectedCheck = !isSelectedCheck!;
                                  setState(() {});
                                }),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    appLocalization.translate('termCondition')!,
                                    style: primaryTextStyle(color: Theme.of(context).textTheme.subtitle2!.color, size: textSizeMedium),
                                  ),
                                  4.height,
                                  GestureDetector(
                                    onTap: () async => redirectUrl(getStringAsync(TERMS_AND_CONDITIONS)),
                                    child: Text(
                                      appLocalization.translate('terms')!,
                                      style: primaryTextStyle(color: primaryColor, size: textSizeSMedium),
                                    ),
                                  )
                                ],
                              ),
                            )
                          ],
                        ).paddingAll(8.0),
                        16.height,
                        NewsButton(
                            textContent: appLocalization.translate('sign_Up'),
                            onPressed: () {
                              if (!accessAllowed) {
                                toast(appLocalization.translate('sorry'));
                                return;
                              }
                              if (isSelectedCheck!) {
                                validate();
                              } else {
                                toast(appLocalization.translate('Accept_Terms'));
                              }
                            }).paddingOnly(left: 16.0, right: 16.0),
                        16.height,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(appLocalization.translate('have_an_Account')!, style: secondaryTextStyle(color: Theme.of(context).textTheme.subtitle2!.color, size: textSizeMedium)),
                            Container(
                              margin: EdgeInsets.only(left: 4),
                              child: GestureDetector(
                                  child: Text(appLocalization.translate('sign_In')!, style: TextStyle(decoration: TextDecoration.underline, color: primaryColor, fontSize: textSizeMedium.toDouble())),
                                  onTap: () {
                                    finish(context);
                                  }),
                            )
                          ],
                        ),
                        16.height,
                      ],
                    ),
                  ).paddingAll(16.0),
                ],
              ),
            ),
          ),
        ),
        Observer(builder: (_) => CircularProgressIndicator().center().visible(appStore.isLoading)),
      ],
    );
  }
}
