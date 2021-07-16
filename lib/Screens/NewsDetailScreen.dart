import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:news_flutter/Model/PostModel.dart';
import 'package:news_flutter/Network/rest_apis.dart';
import 'package:news_flutter/Utils/constant.dart';
import 'package:news_flutter/Utils/wordpressContent/external/HearthisAtWidget.dart';
import 'package:news_flutter/Utils/wordpressContent/external/IssuuWidget.dart';
import 'package:news_flutter/Utils/wordpressContent/external/JWPlayerWidget.dart';
import 'package:news_flutter/Utils/wordpressContent/external/SoundCloudWidget.dart';
import 'package:news_flutter/Utils/wordpressContent/external/YouTubeWidget.dart';
import 'package:news_flutter/Utils/wordpressContent/model/SimpleArticle.dart';
import 'package:news_flutter/components/NewsDetailPageVariantSecondWidget.dart';
import 'package:news_flutter/components/NewsDetailPageVariantThirdWidget.dart';
import 'package:news_flutter/components/NewsDetailPageVariantFirstWidget.dart';

import 'package:news_flutter/main.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

enum PostType { HTML, String, WordPress }

// ignore: must_be_immutable
class NewsDetailScreen extends StatefulWidget {
  final String? newsId;
  PostModel? post;

  @override
  NewsDetailScreenState createState() => NewsDetailScreenState();

  NewsDetailScreen({this.newsId, this.post});
}

class NewsDetailScreenState extends State<NewsDetailScreen> with AfterLayoutMixin<NewsDetailScreen> {
  bool isAdsLoad = false;
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
    myBanner = buildBannerAd()..load();
    fontSize = getIntAsync(FONT_SIZE, defaultValue: 18);

    if (widget.post == null) {
      fetchBlogDetailData();
    } else {
      setDetails(widget.post);
    }

    /*if (allowPreFetched) {
      String data = getStringAsync('$newsDetailData${widget.newsId}');

      if (data.isNotEmpty) {
        //setDetails(PostModel.fromJson(jsonDecode(data)));
      }
    }*/
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

  Future<void> fetchBlogDetailData() async {
    Map req = {'post_id': widget.newsId};

    await getBlogDetail(req).then((res) async {
      await setValue('$newsDetailData${widget.newsId}', jsonEncode(res));
      widget.post = PostModel.fromJson(res['data']);
      setDetails(PostModel.fromJson(res['data']));
    }).catchError((error) {
      toast(error.toString());
    });
  }

  void setDetails(PostModel? res) {
    widget.post = res!;

    postContent = widget.post!.postContent
        .validate()
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('[embed]', '<embed>')
        .replaceAll('[/embed]', '</embed>')
        .replaceAll('[caption]', '<caption>')
        // .replaceAll('[blockquote]', '<blockquote>')
        // .replaceAll('[/blockquote]', '</blockquote>')
        .replaceAll('[/caption]', '</caption>');

    isBookMark = widget.post!.isFav.validate();
    setState(() {});
  }

  void onShareTap(String url) async {
    final RenderBox box = context.findRenderObject() as RenderBox;
    Share.share('$url', subject: '', sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void afterFirstLayout(BuildContext context) {
    setStatusBarColor(Colors.transparent);
  }

  @override
  void dispose() async {
    super.dispose();
    if (!isAdsDisabled) {
      if (mInterstitialAdCount < 5) {
        mInterstitialAdCount++;
      } else {
        mInterstitialAdCount = 0;
        myInterstitial = buildInterstitialAd()..load();
      }
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
    Widget getVariant() {
      if (getIntAsync(DETAIL_PAGE_VARIANT, defaultValue: 1) == 1) {
        return NewsDetailPageVariantFirstWidget(newsId: widget.post!.id!.toString(), post: widget.post);
      } else if (getIntAsync(DETAIL_PAGE_VARIANT, defaultValue: 1) == 2) {
        return NewsDetailPageVariantSecondWidget(newsId: widget.post!.id!.toString(), post: widget.post);
      } else if (getIntAsync(DETAIL_PAGE_VARIANT, defaultValue: 1) == 3) {
        return NewsDetailPageVariantThirdWidget(newsId: widget.post!.id!.toString(), post: widget.post);
      } else {
        throw '';
      }
    }

    return Scaffold(
      body: widget.post != null
          ? Container(
              height: context.height(),
              width: context.width(),
              child: Stack(
                children: [
                  getVariant(),
                  CircularProgressIndicator().center().visible(appStore.isLoading),
                ],
              ),
            )
          : SizedBox(),
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

class YouTubeEmbedWidgets extends YouTubeWidget {
  @override
  Widget buildWithVideoId(BuildContext context, String? videoId) {
    return Container(
      padding: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 20.0),
      margin: EdgeInsets.only(bottom: 16),
      child: Container(
        height: 200,
        width: context.width(),
        child: HtmlWidget(
          '<html><iframe src="https://www.youtube.com/embed/$videoId" allow="autoplay; fullscreen" allowfullscreen="allowfullscreen"></iframe></html>',
          webView: true,
          webViewJs: true,
        ),
      ),
    ).onTap(() {
      toast('youtube');
      launch('https://www.youtube.com/embed/$videoId');
    });
  }
}

class VimeoEmbedWidgets extends YouTubeWidget {
  @override
  Widget buildWithVideoId(BuildContext context, String? videoId) {
    return Container(
      padding: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 20.0),
      child: AspectRatio(
        aspectRatio: 16 / 10,
        child: Container(
          child: HtmlWidget(
            '<iframe src="https://player.vimeo.com/video/$videoId" width="640" height="360" frameborder="0" allow="autoplay; fullscreen" allowfullscreen="allowfullscreen" mozallowfullscreen="mozallowfullscreen" msallowfullscreen="msallowfullscreen" oallowfullscreen="oallowfullscreen" webkitallowfullscreen="webkitallowfullscreen"></iframe>',
            webView: true,
          ),
        ),
      ),
    ).onTap(() {
      toast('vimeo');
      launch('https://player.vimeo.com/video/$videoId');
    });
  }
}

class IssueEmbedWidget extends IssuuWidget {
  @override
  Widget buildWithPDF(BuildContext context, SimpleArticle? pdf) {
    return Container(
      padding: EdgeInsets.all(10.0),
      child: Center(
        child: AppButton(
          padding: EdgeInsets.all(10.0),
          color: Colors.green,
          child: Container(
            padding: EdgeInsets.only(top: 5.0),
            child: Text(
              "View PDF",
              style: Theme.of(context).textTheme.bodyText2!.copyWith(color: Colors.white),
            ),
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (context) {
                  return Container(
                    child: Text(pdf!.paragraphRawContent!),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class SoundCloudEmbedWidget extends SoundCloudWidget {
  final String title;
  final String subtitle;

  SoundCloudEmbedWidget(this.title, this.subtitle);

  @override
  Widget buildWithTrackId(BuildContext context, String? trackId, String? embedCode) {
    return Container(
      padding: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 30.0),
      child: Container(
        child: Column(
          children: <Widget>[Text(title), Text(subtitle), Text(trackId!)],
        ),
      ),
    );
  }
}

class HearthisAtEmbedWidget extends HearthisAtWidget {
  final String title;
  final String subtitle;

  HearthisAtEmbedWidget(this.title, this.subtitle);

  @override
  Widget buildWithTrackId(BuildContext context, String? trackId) {
    return Container(
      padding: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 30.0),
      child: Container(
        child: Column(
          children: <Widget>[Text(title), Text(subtitle), Text(trackId!)],
        ),
      ),
    );
  }
}

class JWPlayerEmbedWidget extends JWPlayerWidget {
  @override
  Widget buildWithMediaId(BuildContext context, String? mediaId) {
    return Container(
      padding: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 20.0),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          child: Text(mediaId!),
        ),
      ),
    );
  }
}
