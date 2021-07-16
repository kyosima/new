import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:news_flutter/Model/PostModel.dart';
import 'package:news_flutter/Network/rest_apis.dart';
import 'package:news_flutter/Screens/NewsDetailScreen.dart';
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

class NewsDetailPageVariantThirdWidget extends StatefulWidget {
  final String? newsId;
  final PostModel? post;

  NewsDetailPageVariantThirdWidget({
    this.newsId,
    this.post,
  });

  @override
  NewsDetailPageVariantThirdWidgetState createState() => NewsDetailPageVariantThirdWidgetState();
}

class NewsDetailPageVariantThirdWidgetState extends State<NewsDetailPageVariantThirdWidget> {
  PostModel? post;
  bool isAdsLoad = false;
  bool isPostLoaded = false;
  String newsTitle = '';
  bool isBookMark = false;

  BannerAd? myBanner;
  InterstitialAd? myInterstitial;

  int fontSize = 18;

  PostType postType = PostType.HTML;

  String postContent = '';

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    // fetchBlogDetailData();
    myBanner = buildBannerAd()..load();
    post = widget.post;
    log(widget.post.toString());
    fontSize = getIntAsync(FONT_SIZE, defaultValue: 18);

    setState(() {});

    if (widget.post == null) {
      fetchBlogDetailData();
    } else {
      setDetails(widget.post);
    }

    if (allowPreFetched) {
      String data = getStringAsync('$newsDetailData${widget.newsId}');

      if (data.isNotEmpty) {
        //setDetails(PostModel.fromJson(jsonDecode(data)));
      }
    }
    setState(() {});
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

  void fetchBlogDetailData() {
    appStore.setLoading(true);
    // log()

    Map req = {'post_id': widget.newsId};
    // log(req.toString());

    getBlogDetail(req).then((res) async {
      appStore.setLoading(false);
      isPostLoaded = true;

      await setValue('$newsDetailData${widget.newsId}', jsonEncode(res));

      setDetails(PostModel.fromJson(res['data']));
    }).catchError(
      (error) {
        toast(error.toString());

        appStore.setLoading(false);
      },
    );
  }

  void setDetails(PostModel? res) {
    isPostLoaded = true;
    post = res;

    postContent = post!.postContent
        .validate()
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('[embed]', '<embed>')
        .replaceAll('[/embed]', '</embed>')
        .replaceAll('[caption]', '<caption>')
        .replaceAll('[/caption]', '</caption>');

    if (postContent.contains("div").validate() || postContent.contains("ol").validate() || postContent.contains("html").validate() || postContent.contains("wp:paragraph").validate()) {
      postType = PostType.HTML;
    } else {
      postType = PostType.String;
    }
    isBookMark = post!.isFav.validate();

    setState(() {});
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
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    setStatusBarColor(Colors.transparent);

    return Scaffold(
      body: Observer(
        builder: (_) => Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomRight,
          children: <Widget>[
            NestedScrollView(
              headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
                return <Widget>[
                  SliverAppBar(
                    pinned: true,
                    expandedHeight: context.height() * 0.50,
                    flexibleSpace: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        FlexibleSpaceBar(
                          background: post != null
                              ? Hero(
                                  tag: post != null ? post!.id! : post!.id!,
                                  child: cachedImage(
                                    post != null ? post!.image.validate() : post!.image.validate(),
                                    fit: BoxFit.cover,
                                  ).cornerRadiusWithClipRRect(20.0),
                                )
                              : SizedBox(),
                          title: post != null
                              ? Text(
                                  parseHtmlString(post!.postTitle.validate()),
                                  style: boldTextStyle(size: textSizeNormal, color: Theme.of(context).textTheme.headline6!.color),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ).visible(innerBoxIsScrolled).paddingOnly(left: isIos ? 16 : 0)
                              : SizedBox(),
                        ),
                        Positioned(
                          bottom: -16,
                          right: 24,
                          child: innerBoxIsScrolled == false
                              ? CircleAvatar(
                                  child: IconButton(
                                    icon: Icon(Icons.play_circle_outline, size: 30, color: white),
                                    onPressed: () async {
                                      showInDialog(
                                        context,
                                        child: ReadAloudDialog(parseHtmlString(postContent)),
                                        contentPadding: EdgeInsets.zero,
                                        barrierDismissible: false,
                                      );
                                    },
                                  ),
                                  radius: 22.0,
                            backgroundColor: primaryColor


                                )
                              : Container(),
                        ),
                      ],
                    ),
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    leading: BackButton(
                        color: innerBoxIsScrolled
                            ? appStore.isDarkMode
                                ? Colors.white
                                : Colors.black
                            : Colors.white,
                        onPressed: () async {
                          finish(context);
                        }),
                  )
                ];
              },
              body: post != null
                  ? Container(
                      color: Theme.of(context).cardColor,
                      child: SingleChildScrollView(
                        physics: NeverScrollableScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                12.height,
                                Row(
                                  children: [
                                    Text(
                                      post!.readableDate.validate(),
                                      style: primaryTextStyle(color: Theme.of(context).textTheme.subtitle2!.color),
                                    ).expand(),
                                    IconButton(
                                      icon: Icon(Icons.share, color: appStore.isDarkMode ? Colors.white : Colors.black, size: 30),
                                      onPressed: () {
                                        onShareTap(post!.shareUrl.validate());
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        widget.post!.isFav.validate() ? Icons.bookmark : Icons.bookmark_border,
                                        color: appStore.isDarkMode ? Colors.white : Colors.black,
                                        size: 30,
                                      ),
                                      onPressed: () {
                                        if (!isPostLoaded) {
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
                                    )
                                  ],
                                ),
                              ],
                            ),
                            16.height,
                            Text(
                              '${parseHtmlString(post!.postTitle.validate())}',
                              style: boldTextStyle(size: textSizeLarge, color: Theme.of(context).textTheme.headline6!.color),
                              maxLines: 5,
                            ),
                            10.height,
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
                                  child: FittedBox(
                                    child: Text('Write comment', style: secondaryTextStyle(color: white_color)),
                                  ),
                                  style: TextButton.styleFrom(backgroundColor: primaryColor),
                                  onPressed: () async {
                                    appStore.isLoggedIn ? WriteCommentScreen(id: post!.id).launch(context) : SignInScreen().launch(context);
                                  },
                                ),
                                TextButton(
                                  child: FittedBox(
                                    child: Text('View comment', style: secondaryTextStyle(color: white_color)),
                                  ),
                                  style: TextButton.styleFrom(backgroundColor: primaryColor),
                                  onPressed: () {
                                    ViewCommentScreen(id: post!.id).launch(context);
                                  },
                                ),
                              ],
                            ).paddingOnly(top: 16.0, bottom: 16.0),
                          ],
                        ).visible(post!.postContent != null).paddingAll(16.0),
                      ),
                    ).paddingTop(0)
                  : SizedBox(),
            )
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
