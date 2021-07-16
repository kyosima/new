import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:news_flutter/Model/PostModel.dart';
import 'package:news_flutter/Network/rest_apis.dart';
import 'package:news_flutter/Screens/SignInScreen.dart';
import 'package:news_flutter/Screens/ViewCommentScreen.dart';
import 'package:news_flutter/Screens/WriteCommentScreen.dart';
import 'package:news_flutter/Utils/Colors.dart';
import 'package:news_flutter/Utils/Common.dart';
import 'package:news_flutter/Utils/Widgets.dart';
import 'package:news_flutter/Utils/constant.dart';
import 'package:news_flutter/components/ReadAloudDialog.dart';
import 'package:share/share.dart';

import '../main.dart';

// ignore: must_be_immutable
class NewsDetailPageVariantSecondWidget extends StatefulWidget {
  final String? newsId;
  PostModel? post;
  final String? postContent;

  NewsDetailPageVariantSecondWidget({this.newsId, this.post, this.postContent});

  @override
  _NewsDetailPageVariantSecondWidgetState createState() => _NewsDetailPageVariantSecondWidgetState();
}

class _NewsDetailPageVariantSecondWidgetState extends State<NewsDetailPageVariantSecondWidget> {
  bool isAdsLoad = false;
  bool isPostLoaded = false;
  String newsTitle = '';

  InterstitialAd? myInterstitial;
  BannerAd? myBanner;

  int fontSize = 18;

  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    setStatusBarColor(Colors.transparent);
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

  void onShareTap(String url) async {
    final RenderBox box = context.findRenderObject() as RenderBox;
    Share.share('$url', subject: '', sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
  }

  Future<void> addInWishList() async {
    Map req = {
      'post_id': widget.post!.id,
    };

    if (!widget.post!.isFav.validate()) {
      addWishList(req).then((res) {
        appStore.setLoading(false);
        toast(res.message);
      }).catchError((error) {
        appStore.isLoading = false;
        toast(error.toString());
      });
    } else {
      removeWishList(req).then((res) {
        appStore.setLoading(false);
        toast(res['message']);

        LiveStream().emit(bookmarkChanged, widget.post);

        setState(() {});
      }).catchError((error) {
        appStore.isLoading = false;
        toast(error.toString());
      });
    }

    widget.post!.isFav = !widget.post!.isFav.validate();
    setState(() {});
  }

  void afterFirstLayout(BuildContext context) {
    setStatusBarColor(Colors.transparent);
  }

  void dispose() async {
    super.dispose();
    if (mInterstitialAdCount < 5) {
      mInterstitialAdCount++;
    } else {
      mInterstitialAdCount = 0;
      myInterstitial = buildInterstitialAd()..load();
    }
  }

  InterstitialAd buildInterstitialAd() {
    return InterstitialAd(
      adUnitId: kReleaseMode ? InterstitialAdIdForAndroid : InterstitialAd.testAdUnitId,
      listener: AdListener(onAdLoaded: (ad) {
        //
      }),
      request: AdRequest(testDevices: []),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Observer(
        builder: (_) => Stack(
          children: [
            widget.post != null
                ? Hero(
                    tag: widget.post != null ? widget.post!.id! : widget.post!.id!,
                    child: cachedImage(
                      widget.post != null ? widget.post!.image.validate() : widget.post!.image.validate(),
                      fit: BoxFit.cover,
                    ),
                  )
                : SizedBox(),
            widget.post != null
                ? SingleChildScrollView(
                    child: Container(
                      padding: EdgeInsets.all(8.0),
                      decoration: boxDecorationWithRoundedCorners(
                        backgroundColor: Theme.of(context).cardTheme.color!,
                        boxShadow: defaultBoxShadow(),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(32.0),
                          topRight: Radius.circular(32.0),
                        ),
                      ),
                      child: SingleChildScrollView(
                        physics: NeverScrollableScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            10.height,
                            Text('${parseHtmlString(widget.post!.postTitle.validate())}', style: boldTextStyle(size: textSizeLarge, color: Theme.of(context).textTheme.headline6!.color), maxLines: 5),
                            16.height,
                            Text(
                              widget.post!.readableDate.validate(),
                              style: primaryTextStyle(color: Theme.of(context).textTheme.subtitle2!.color),
                            ),
                            12.height,
                            buildContent(context, fontSize: 18, post: widget.post!),
                            10.height,
                            ButtonBar(
                              mainAxisSize: MainAxisSize.min,
                              alignment: MainAxisAlignment.center,
                              layoutBehavior: ButtonBarLayoutBehavior.constrained,
                              buttonPadding: EdgeInsets.all(16.0),
                              buttonAlignedDropdown: true,
                              children: [
                                TextButton(
                                  style: TextButton.styleFrom(backgroundColor: primaryColor),
                                  child: FittedBox(
                                    child: Text('Write comment', style: secondaryTextStyle(color: white_color)),
                                  ),
                                  onPressed: () async {
                                    appStore.isLoggedIn ? WriteCommentScreen(id: widget.post!.id).launch(context) : SignInScreen().launch(context);
                                  },
                                ),
                                TextButton(
                                  style: TextButton.styleFrom(backgroundColor: primaryColor),
                                  child: FittedBox(
                                    child: Text('View comment', style: secondaryTextStyle(color: white_color)),
                                  ),
                                  onPressed: () {
                                    ViewCommentScreen(id: widget.post!.id).launch(context);
                                  },
                                ),
                              ],
                            ).paddingOnly(top: 16.0, bottom: 16.0),
                          ],
                        ).visible(widget.post!.postContent != null).paddingAll(10.0),
                      ),
                    ).paddingTop(430.0),
                  )
                : SizedBox(),
            CircleAvatar(
              child: BackButton(
                color: appStore.isDarkMode ? Colors.white : Colors.black,
                onPressed: () async {
                  finish(context);
                },
              ),
              backgroundColor: appStore.isDarkMode ? Theme.of(context).scaffoldBackgroundColor : Colors.white,
            ).paddingOnly(top: 30.0, left: 20.0),
            Positioned(
              right: 16,
              top: 16,
              child: CircleAvatar(
                radius: 20.0,
                backgroundColor: appStore.isDarkMode ? Theme.of(context).scaffoldBackgroundColor : Colors.white,
                child: Theme(
                  data: Theme.of(context).copyWith(buttonColor: appStore.isDarkMode ? Colors.white : Colors.black),
                  child: PopupMenuButton<int>(
                    itemBuilder: (context) {
                      return [
                        PopupMenuItem(
                          value: 1,
                          child: Container(
                            child: Row(
                              children: <Widget>[
                                Icon(
                                  widget.post!.isFav.validate() ? Icons.bookmark : Icons.bookmark_border,
                                  color: appStore.isDarkMode ? Colors.white : Colors.black,
                                ),
                                8.width,
                                Text('Bookmark', style: primaryTextStyle(size: 16)),
                              ],
                            ).onTap(
                              () {
                                finish(context);
                                if (!isPostLoaded) {
                                  isPostLoaded = true;
                                  toast('Please wait');

                                  return;
                                }
                                if (appStore.isLoggedIn) {
                                  addInWishList();
                                } else {
                                  SignInScreen().launch(context);
                                }
                                setState(() {});
                              },
                            ),
                          ),
                        ),
                        PopupMenuItem(
                          value: 2,
                          child: Container(
                            child: Row(
                              children: <Widget>[
                                Icon(Icons.share, color: appStore.isDarkMode ? Colors.white : Colors.black),
                                8.width,
                                Text('Share', style: primaryTextStyle(size: 16)),
                              ],
                            ).onTap(() {
                              finish(context);
                              onShareTap(widget.post!.shareUrl.validate());
                            }),
                          ),
                        ),
                        PopupMenuItem(
                          value: 3,
                          child: Container(
                            child: Row(
                              children: <Widget>[
                                Icon(
                                  Icons.play_circle_outline,
                                  color: appStore.isDarkMode ? Colors.white : Colors.black,
                                ),
                                8.width,
                                Text('Play', style: primaryTextStyle(size: 16)),
                              ],
                            ).onTap(
                              () async {
                                finish(context);
                                showInDialog(
                                  context,
                                  child: ReadAloudDialog(parseHtmlString(widget.post!.postContent)),
                                  contentPadding: EdgeInsets.zero,
                                  barrierDismissible: false,
                                );
                              },
                            ),
                          ),
                        )
                      ];
                    },
                  ),
                ),

              ).paddingOnly(top: 16, left: 20),
            ),
          ],
        ),
      ),
      bottomNavigationBar: isAdsLoad
          ? Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              height: 60,
              child: Column(
                children: [
                  myBanner != null ? AdWidget(ad: myBanner!) : SizedBox(),
                ],
              ),
            )
          : SizedBox(),
    );
  }
}
