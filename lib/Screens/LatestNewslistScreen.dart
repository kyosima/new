import 'dart:core';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:news_flutter/Model/PostModel.dart';
import 'package:news_flutter/Network/rest_apis.dart';
import 'package:news_flutter/Screens/NewsListDetailScreen.dart';
import 'package:news_flutter/Utils/Common.dart';
import 'package:news_flutter/Utils/constant.dart';
import 'package:news_flutter/components/NewsItemWidget.dart';
import 'package:news_flutter/main.dart';
import 'package:news_flutter/shimmerScreen/NewsItemShimmer.dart';

import 'SearchFragment.dart';

class LatestNewsListScreen extends StatefulWidget {
  final String? title;

  @override
  LatestNewsListScreenState createState() => LatestNewsListScreenState();

  LatestNewsListScreen({this.title});
}

class LatestNewsListScreenState extends State<LatestNewsListScreen> {
  int page = 1;
  int recentNumPages = 1;
  List<PostModel> recentNewsListing = [];
  var scrollController = ScrollController();

  late BannerAd myBanner;

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    myBanner = buildBannerAd()..load();

    fetchLatestData();
    scrollController.addListener(() {
      if ((scrollController.position.pixels - 100) == (scrollController.position.maxScrollExtent - 100)) {
        if (recentNumPages > page) {
          page++;
          appStore.setLoading(true);
          setState(() {});
          fetchLatestData();
        }
      }
    });
  }

  BannerAd buildBannerAd() {
    return BannerAd(
      adUnitId: kReleaseMode ? bannerAdIdForAndroid : BannerAd.testAdUnitId,
      size: AdSize.largeBanner,
      listener: AdListener(onAdLoaded: (ad) {
        //
      }),
      request: AdRequest(
        testDevices: [testDeviceId],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
  }

  void fetchLatestData() async {
    appStore.setLoading(true);

    Map req = {};
    getDashboardApi(req, page).then((res) {
      if (!mounted) return;
      appStore.setLoading(false);

      setState(() {
        Iterable listRecent = res['recent_post'];
        recentNewsListing.addAll(listRecent.map((model) => PostModel.fromJson(model)).toList());

        if (page == 1) {
          recentNumPages = int.parse(res['recent_num_pages'].toString());
        }
      });
    }).catchError((error) {
      if (!mounted) return;
      appStore.setLoading(false);
      toast(error.toString());
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget listing() {
      return ListView(
        controller: scrollController,
        padding: EdgeInsets.all(8),
        children: List<Widget>.generate(
          recentNewsListing.length,
          (int i) => GestureDetector(
            onTap: () {
              NewsListDetailScreen(newsData: recentNewsListing, index: i).launch(context);
            },
            child: Container(
              width: context.width(),
              padding: EdgeInsets.all(8),
              child: Column(
                children: [
                  NewsItemWidget(recentNewsListing[i], data: recentNewsListing, index: i),
                  i == Random.secure().nextInt(recentNewsListing.length) && !isAdsDisabled
                      ? Container(
                          height: recentNewsListing.length.toDouble(),
                          padding: EdgeInsets.only(top: 8, bottom: 8),
                          width: context.width(),
                          //child: AdmobBanner(adUnitId: getBannerAdUnitId(), adSize: AdmobBannerSize.LARGE_BANNER),
                          child: AdWidget(ad: myBanner),
                        )
                      : SizedBox(),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
        title: Text(parseHtmlString(widget.title), style: boldTextStyle(color: Theme.of(context).textTheme.headline6!.color, size: 18)),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search, size: 30.0, color: Theme.of(context).textTheme.headline6!.color),
            onPressed: () {
              SearchFragment(isTab: false).launch(context);
            },
          )
        ],
      ),
      body: Observer(
        builder: (_) => Stack(
          children: [
            Container(color: Theme.of(context).cardTheme.color, child: listing()),
            NewsItemShimmer().visible(appStore.isLoading && page == 1),
            CircularProgressIndicator().center().visible(appStore.isLoading && page != 1),
          ],
        ),
      ),
    );
  }
}
