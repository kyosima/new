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

class NewsDetailPageVariantFirstWidget extends StatefulWidget {
  final String? newsId;
  final PostModel? post;
  final String? postContent;

  NewsDetailPageVariantFirstWidget({this.newsId, this.post, this.postContent});

  @override
  NewsDetailPageVariantFirstWidgetState createState() => NewsDetailPageVariantFirstWidgetState();
}

class NewsDetailPageVariantFirstWidgetState extends State<NewsDetailPageVariantFirstWidget> {
  bool isAdsLoad = false;
  bool isPostLoaded = false;
  String newsTitle = '';
  bool isBookMark = false;

  int fontSize = 18;

  PostType postType = PostType.HTML;
  BannerAd? myBanner;

  @override
  void initState() {
    super.initState();

    init();
  }

  Future<void> init() async {
    myBanner = buildBannerAd()..load();
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

  void afterFirstLayout(BuildContext context) {
    setStatusBarColor(Colors.transparent);
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Observer(
        builder: (_) => Stack(
          children: [
            NestedScrollView(
              headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
                return <Widget>[
                  SliverAppBar(
                    expandedHeight: context.height() * 0.55,
                    pinned: true,
                    flexibleSpace: FlexibleSpaceBar(
                      background: widget.post != null
                          ? Hero(
                              tag: widget.post != null ? widget.post!.id! : widget.post!.id!,
                              child: cachedImage(
                                widget.post != null ? widget.post!.image.validate() : widget.post!.image.validate(),
                                fit: BoxFit.cover,
                              ),
                            )
                          : SizedBox(),
                      //background: networkImage(imageUrl: post.image.validate(), height: context.height() * 0.55, width: context.width()),
                      collapseMode: CollapseMode.parallax,
                      title: widget.post != null
                          ? Text(
                              parseHtmlString(widget.post!.postTitle.validate()),
                              style: boldTextStyle(size: textSizeNormal, color: Theme.of(context).textTheme.headline6!.color),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ).visible(innerBoxIsScrolled).paddingOnly(left: isIos ? 16 : 0)
                          : SizedBox(),
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
                      },
                    ),
                  ),
                ];
              },
              body: widget.post != null
                  ? Container(
                      color: Theme.of(context).cardTheme.color,
                      height: context.height(),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            10.height,
                            Text(
                              '${parseHtmlString(widget.post!.postTitle.validate())}',
                              style: boldTextStyle(
                                size: textSizeLarge,
                                color: Theme.of(context).textTheme.headline6!.color,
                              ),
                              maxLines: 5,
                            ),
                            8.height,
                            Text(
                              '${'Author By ${parseHtmlString(widget.post!.postAuthorName.validate())}'}',
                              style: primaryTextStyle(color: Colors.blue, size: 14),
                            ).visible(widget.post!.postAuthorName.validate().isNotEmpty),
                            10.height,
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(widget.post!.readableDate.validate(), style: primaryTextStyle(color: Theme.of(context).textTheme.subtitle2!.color)),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        widget.post!.isFav.validate() ? Icons.bookmark : Icons.bookmark_border,
                                        color: Theme.of(context).textTheme.headline6!.color,
                                        size: 30,
                                      ),
                                      onPressed: () {
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
                                    IconButton(
                                      icon: Icon(Icons.share, color: Theme.of(context).textTheme.headline6!.color, size: 30),
                                      onPressed: () {
                                        onShareTap(widget.post!.shareUrl.validate());
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.play_circle_outline,
                                        color: appStore.isDarkMode ? Colors.white : Colors.black,
                                        size: 30,
                                      ),
                                      onPressed: () async {
                                        showInDialog(
                                          context,
                                          child: ReadAloudDialog(parseHtmlString(widget.post!.postContent.validate())),
                                          contentPadding: EdgeInsets.zero,
                                          barrierDismissible: false,
                                        );
                                      },
                                    ),
                                  ],
                                )
                              ],
                            ),
                            10.height,
                            buildContent(context, fontSize: 18, post: widget.post!),
                            Center(
                              child: ButtonBar(
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
                            ).visible(widget.post!.postContent != null),
                          ],
                        ).paddingAll(20.0),
                      ),
                    )
                  : SizedBox(),
            ),
            CircularProgressIndicator().center().visible(appStore.isLoading),
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
