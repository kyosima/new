import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:news_flutter/Network/rest_apis.dart';
import 'package:news_flutter/Screens/DashboardScreen.dart';
import 'package:news_flutter/Utils/Colors.dart';
import 'package:news_flutter/Utils/Images.dart';
import 'package:news_flutter/Utils/Widgets.dart';
import 'package:news_flutter/Utils/constant.dart';
import 'package:news_flutter/app_localizations.dart';

import '../main.dart';

class ProfileFragment extends StatefulWidget {
  final bool? isTab;

  ProfileFragment({this.isTab});

  @override
  ProfileFragmentState createState() => ProfileFragmentState();
}

class ProfileFragmentState extends State<ProfileFragment> {
  var imageFile = '';
  File? mSelectedImage;
  String avatar = '';
  List? userDetail;

  var fNameCont = TextEditingController();
  var lNameCont = TextEditingController();
  var emailCont = TextEditingController();
  var usernameCont = TextEditingController();

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    fNameCont.text = appStore.userFirstName!;
    lNameCont.text = appStore.userLastName!;
    emailCont.text = appStore.userEmail!;
    usernameCont.text = appStore.userFirstName!;

    setState(() {});
  }

  saveUser() async {
    appStore.setLoading(true);
    setState(() {});
    hideKeyboard(context);

    var request = {'user_email': emailCont.text, 'first_name': fNameCont.text, 'last_name': lNameCont.text, 'ID': appStore.userId, 'user_login': appStore.userLogin};
    updateUser(request).then((res) async {
      if (!mounted) return;
      appStore.setLoading(false);
      setState(() {});

      await setValue(FIRST_NAME, res['data']['first_name']);
      await setValue(LAST_NAME, res['data']['last_name']);
      await setValue(USER_EMAIL, res['data']['user_email']);

      appStore.setFirstName(res['data']['first_name']);
      appStore.setLastName(res['data']['last_name']);
      appStore.setUserEmail(res['data']['user_email']);

      toast(res['message']);
      DashboardScreen().launch(context, isNewTask: true);
    }).catchError((error) {
      toast(error.toString());
      appStore.setLoading(false);
      setState(() {});
    });
  }

  pickImage(AppLocalizations? appLocalization) async {
    File image = File((await ImagePicker().getImage(source: ImageSource.gallery))!.path);

    setState(() {
      mSelectedImage = image;
    });

    if (mSelectedImage != null) {
      ConfirmAction? res = await showConfirmDialogs(context, appLocalization!.translate('conformation_upload_image'), appLocalization.translate('yes'), appLocalization.translate('no'));

      if (res == ConfirmAction.ACCEPT) {
        var base64Image = base64Encode(mSelectedImage!.readAsBytesSync());
        var request = {'base64_img': base64Image};
        appStore.setLoading(true);
        setState(() {});
        await saveProfileImage(request).then((res) async {
          if (!mounted) return;
          appStore.setLoading(false);
          if (res['profile_image'] != null) {
            await setValue(PROFILE_IMAGE, res['profile_image']);
          }

          toast(res['message']);
          setState(() {});

        }).catchError((error) {
          appStore.setLoading(false);
          setState(() {});
          toast(error.toString());
        });
      }
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    var appLocalization = AppLocalizations.of(context);

    Widget profileImage = ClipRRect(
      borderRadius: BorderRadius.circular(100),
      child: mSelectedImage == null
          ? appStore.userProfileImage!.isNotEmpty
              ? cachedImage(getStringAsync(PROFILE_IMAGE), height: 100, width: 100, fit: BoxFit.cover)
              : Image.asset(User_Profile, width: 100, height: 100, fit: BoxFit.cover)
          : Image.file(mSelectedImage!, width: 120, height: 120, fit: BoxFit.cover),
    );
    
    return Stack(
      children: [
        appStore.isLoggedIn
            ? Scaffold(
                backgroundColor: Theme.of(context).cardTheme.color,
                appBar: AppBar(
                  centerTitle: true,
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  elevation: 5.0,
                  leading: IconButton(
                      icon: Icon(Icons.arrow_back, size: 30, color: Theme.of(context).textTheme.headline6!.color),
                      onPressed: () {
                        finish(context);
                      }).visible(widget.isTab == false),
                  title: Text(
                    appLocalization!.translate('profile')!,
                    style: boldTextStyle(color: Theme.of(context).textTheme.headline6!.color, size: 18),
                  ),
                ),
                body: Container(
                  color: Theme.of(context).cardTheme.color,
                  child: SingleChildScrollView(
                    child: Observer(
                      builder: (_) => Column(
                        children: [
                          Container(
                            decoration: boxDecoration(context, bgColor: Theme.of(context).scaffoldBackgroundColor, showShadow: true),
                            child: Column(
                              children: [
                                16.height,
                                8.width,
                                Stack(alignment: Alignment.bottomRight, children: [
                                  Container(
                                    height: 140,
                                    width: 140,
                                    decoration: boxDecoration(context, radius: 80, color: primaryColor, borderWidth: 4.0, bgColor: Colors.transparent),
                                    child: profileImage.paddingAll(4.0),
                                  ),
                                  Container(
                                    height: 40,
                                    decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: primaryColor, width: 2), color: white_color),
                                    child: IconButton(
                                        icon: Icon(Icons.camera_alt, size: 20, color: primaryColor),
                                        onPressed: (() {
                                          pickImage(appLocalization);
                                        })),
                                  ).visible(appStore.isLoggedIn && !getBoolAsync(IS_SOCIAL_LOGIN)).onTap(() {
                                    pickImage(appLocalization);
                                  })
                                ]),
                                8.width,
                                16.height,
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(appLocalization.translate('first_Name')!, style: secondaryTextStyle(color: textColorSecondary, size: textSizeMedium)),
                                    EditText(
                                      iconName: Icons.supervised_user_circle,
                                      isPassword: false,
                                      mController: fNameCont,
                                      textColor: Theme.of(context).textTheme.headline6!.color,
                                      underLineColor: Theme.of(context).textTheme.headline6!.color,
                                      hintText: appLocalization.translate('first_Name'),
                                    ),
                                    16.height,
                                    Text(appLocalization.translate('last_Name')!, style: secondaryTextStyle(color: textColorSecondary, size: textSizeMedium)),
                                    EditText(
                                      iconName: Icons.supervised_user_circle,
                                      isPassword: false,
                                      mController: lNameCont,
                                      textColor: Theme.of(context).textTheme.headline6!.color,
                                      underLineColor: Theme.of(context).textTheme.headline6!.color,
                                      hintText: appLocalization.translate('last_Name'),
                                    ),
                                    16.height,
                                    Text(appLocalization.translate('userName')!, style: secondaryTextStyle(color: textColorSecondary, size: textSizeMedium)),
                                    EditText(
                                      iconName: Icons.supervised_user_circle,
                                      isPassword: false,
                                      mController: usernameCont,
                                      textColor: Theme.of(context).textTheme.headline6!.color,
                                      underLineColor: Theme.of(context).textTheme.headline6!.color,
                                      hintText: appLocalization.translate('userName'),
                                      enabled: false,
                                    ),
                                    16.height,
                                    Text(appLocalization.translate('email')!, style: secondaryTextStyle(color: textColorSecondary, size: textSizeMedium)),
                                    EditText(
                                      iconName: Icons.email,
                                      isPassword: false,
                                      mController: emailCont,
                                      textColor: Theme.of(context).textTheme.headline6!.color,
                                      underLineColor: Theme.of(context).textTheme.headline6!.color,
                                      hintText: appLocalization.translate('email'),
                                      enabled: false,
                                    ),
                                    16.height
                                  ],
                                ),
                              ],
                            ).paddingOnly(left: 16.0, right: 16.0),
                          ).paddingOnly(top: 24.0, bottom: 16.0),
                          Container(
                            width: context.width(),
                            decoration: boxDecoration(context, bgColor: Theme.of(context).scaffoldBackgroundColor, showShadow: true),
                            child: NewsButton(
                              textContent: appLocalization.translate('save'),
                              onPressed: () {
                                if (!accessAllowed) {
                                  toast(appLocalization.translate('sorry'));
                                  return;
                                }
                                if (fNameCont.text.isEmpty)
                                  toast(appLocalization.translate('first_Name')! + appLocalization.translate('field_Required')!);
                                else if (lNameCont.text.isEmpty)
                                  toast(appLocalization.translate('last_Name')! + appLocalization.translate('field_Required')!);
                                else if (emailCont.text.isEmpty)
                                  toast(appLocalization.translate('email_Address')! + appLocalization.translate('field_Required')!);
                                else {
                                  saveUser();
                                }
                              },
                            ).paddingAll(16.0),
                          )
                        ],
                      ).paddingOnly(left: 16.0, right: 16.0, bottom: 16.0),
                    ),
                  ),
                ))
            : Container(
                width: context.width(),
                height: context.height(),
                color: Theme.of(context).cardTheme.color,
              ),
        Observer(builder: (_) => CircularProgressIndicator().center().visible(appStore.isLoading)),
      ],
    );
  }

  void openGallery(BuildContext context) async {
    // ignore: deprecated_member_use
    File picture = File((await ImagePicker().getImage(source: ImageSource.gallery))!.path);
    this.setState(() {
      imageFile = picture as String;
    });
    finish(context);
  }

  Future<void> showSelectionDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "From where do you want to take the photo?",
            style: primaryTextStyle(color: Theme.of(context).textTheme.headline6!.color),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text("Gallery").onTap(() => openGallery(context)),
                Padding(padding: EdgeInsets.all(16.0)),
                GestureDetector(child: Text("Camera"), onTap: () {}),
              ],
            ),
          ),
        );
      },
    );
  }
}
