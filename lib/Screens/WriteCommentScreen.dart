import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:news_flutter/Network/rest_apis.dart';
import 'package:news_flutter/Utils/Strings.dart';
import 'package:news_flutter/Utils/Widgets.dart';
import 'package:news_flutter/Utils/constant.dart';
import 'package:news_flutter/app_localizations.dart';
import 'package:news_flutter/main.dart';

class WriteCommentScreen extends StatefulWidget {
  final int? id;

  @override
  _WriteCommentScreenState createState() => _WriteCommentScreenState();

  WriteCommentScreen({this.id});
}

class _WriteCommentScreenState extends State<WriteCommentScreen> {
  var commentCont = TextEditingController();
  late BannerAd myBanner;

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

  postCommentApi() async {
    hideKeyboard(context);
    var request = {
      'comment_content': commentCont.text,
      'comment_post_ID': widget.id,
    };
    appStore.setLoading(true);
    setState(() {});

    postComment(request).then((res) {
      if (!mounted) return;

      appStore.setLoading(false);
      setState(() {});

      toast(res['message']);
      finish(context);
    }).catchError((error) {
      appStore.setLoading(false);
      setState(() {});

      toast(error.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    var appLocalization = AppLocalizations.of(context)!;

    return SafeArea(
      child: Stack(
        children: [
          Scaffold(
            appBar: AppBar(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              elevation: 5.0,
              title: Text(appLocalization.translate('write_Comment')!, style: boldTextStyle(color: Theme.of(context).textTheme.headline6!.color, size: 18)),
              centerTitle: true,
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: Theme.of(context).textTheme.headline6!.color),
                onPressed: () {
                  finish(context);
                },
              ),
            ),
            backgroundColor: Theme.of(context).cardTheme.color,
            body: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  16.height,
                  Container(
                    decoration: boxDecoration(context, bgColor: Theme.of(context).scaffoldBackgroundColor, radius: 0.0, showShadow: true),
                    height: 100,
                    child: TextField(
                      controller: commentCont,
                      scrollPadding: EdgeInsets.all(16.0),
                      style: TextStyle(color: Theme.of(context).textTheme.headline6!.color, fontSize: textSizeMedium.toDouble()),
                      textInputAction: TextInputAction.newline,
                      keyboardType: TextInputType.multiline,
                      cursorColor: Theme.of(context).textTheme.headline6!.color,
                      decoration: InputDecoration(
                        hintText: appLocalization.translate('comment'),
                        border: InputBorder.none,
                        hintStyle: primaryTextStyle(color: Theme.of(context).textTheme.headline6!.color, size: textSizeMedium),
                      ),
                      maxLines: null,
                    ).paddingOnly(left: 8.0, right: 8.0),
                  ).paddingOnly(top: 16.0, bottom: 16.0),
                  16.height,
                  Container(
                    color: Theme.of(context).cardTheme.color,
                    padding: EdgeInsets.all(0.0),
                    child: NewsButton(
                      textContent: appLocalization.translate('send'),
                      height: 50,
                      onPressed: () {
                        if (!accessAllowed) {
                          toast("Sorry");
                          return;
                        }
                        if (commentCont.text.isEmpty) {
                          toast('Comment' + Field_Required);
                        } else {
                          appStore.setLoading(true);
                          postCommentApi();
                        }
                      },
                    ),
                  )
                ],
              ).paddingAll(16.0),
            ),
            bottomNavigationBar: Container(
              height: AdSize.banner.height.toDouble(),
              color: Theme.of(context).scaffoldBackgroundColor,
              child: AdWidget(ad: myBanner),
            ).visible(!isAdsDisabled),
          ),
          Observer(builder: (_) => CircularProgressIndicator().center().visible(appStore.isLoading)),
        ],
      ),
    );
  }
}
