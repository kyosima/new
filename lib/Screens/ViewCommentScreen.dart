import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:news_flutter/Model/ViewCommentModel.dart';
import 'package:news_flutter/Network/rest_apis.dart';
import 'package:news_flutter/Utils/Colors.dart';
import 'package:news_flutter/Utils/Common.dart';
import 'package:news_flutter/Utils/Images.dart';
import 'package:news_flutter/Utils/Strings.dart';
import 'package:news_flutter/Utils/Widgets.dart';
import 'package:news_flutter/Utils/constant.dart';
import 'package:news_flutter/app_localizations.dart';
import 'package:news_flutter/main.dart';

class ViewCommentScreen extends StatefulWidget {
  final int? id;

  @override
  _ViewCommentScreenState createState() => _ViewCommentScreenState();

  ViewCommentScreen({this.id});
}

class _ViewCommentScreenState extends State<ViewCommentScreen> {
  var commentLists = [];

  late BannerAd myBanner;
  @override
  void initState() {
    super.initState();
    getCommentData();
    init();
  }

  init() async {
    myBanner = buildBannerAd()..load();

    /*if (await isNetworkAvailable()) {
      await Future.delayed(Duration(seconds: 1));
      setState(() {
        isLoadAds = isAdsLoading;
      });
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

  void getCommentData() async {
    appStore.setLoading(true);
    setState(() {});
    await getCommentList(widget.id!).then((res) {
      if (!mounted) return;
      appStore.setLoading(false);
      setState(() {
        Iterable commentList = res;
        commentLists = commentList.map((model) => ViewCommentModel.fromJson(model)).toList();
        if (commentLists.length == 0) {
          toast(noRecord);
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
    var width = context.width();
    var appLocalization = AppLocalizations.of(context)!;

    Widget commentList(List<ViewCommentModel> list) {
      return Container(
        color: Theme.of(context).cardTheme.color,
        child: ListView.builder(
          itemCount: list.length,
          shrinkWrap: true,
          scrollDirection: Axis.vertical,
          physics: NeverScrollableScrollPhysics(),
          itemBuilder: (context, i) {
            return GestureDetector(
              onTap: () {},
              child: Container(
                width: width,
                child: Column(
                  children: <Widget>[
                    4.height,
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          height: 20,
                          width: 20,
                          decoration: boxDecoration(context, bgColor: getColorFromHex(categoryColors[i % categoryColors.length]), radius: 10.0),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text(
                                    list[i].authorName!,
                                    style: boldTextStyle(color: Colors.blueAccent, size: textSizeMedium),
                                    maxLines: 2,
                                  ),
                                  Text(
                                    list[i].date != null ? convertDate(list[i].date) : '',
                                    style: primaryTextStyle(color: Theme.of(context).textTheme.subtitle2!.color, size: textSizeMedium),
                                  ),
                                ],
                              ),
                              4.height,
                              Text(
                                parseHtmlString(
                                  list[i].content!.rendered != null ? list[i].content!.rendered : '',
                                ),
                                style: secondaryTextStyle(color: Theme.of(context).textTheme.headline6!.color, size: textSizeMedium),
                                maxLines: 2,
                              ),
                            ],
                          ).paddingOnly(left: 8.0, right: 4.0),
                        )
                      ],
                    ),
                    Divider(
                      color: light_grayColor,
                      thickness: 1.5,
                    )
                  ],
                ).paddingOnly(left: 8.0, right: 8.0),
              ).paddingAll(4.0),
            );
          },
        ).paddingOnly(top: 8.0, bottom: 8.0),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).cardTheme.color,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 5.0,
        title: Text(appLocalization.translate('comment')!, style: boldTextStyle(color: Theme.of(context).textTheme.headline6!.color, size: 18)),
        centerTitle: true,
        leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Theme.of(context).textTheme.headline6!.color),
            onPressed: () {
              finish(context);
            }),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: commentLists.isNotEmpty
                ? commentList(commentLists as List<ViewCommentModel>)
                : Container(
                    width: context.width(),
                    height: context.height() * 0.5,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            ic_NoRecord,
                            height: 80,
                            width: 80,
                            fit: BoxFit.fill,
                            color: Theme.of(context).textTheme.headline6!.color,
                          ),
                          8.height,
                          Text(
                            appLocalization.translate("noRecord")!,
                            style: primaryTextStyle(color: Theme.of(context).textTheme.headline6!.color, size: textSizeMedium),
                          )
                        ],
                      ),
                    ),
                  ).visible(!appStore.isLoading && commentLists.length == 0),
          ),
          Observer(builder: (_) => CircularProgressIndicator().center().visible(appStore.isLoading)),
        ],
      ),
      bottomNavigationBar: !isAdsDisabled ? Container(height: AdSize.banner.height.toDouble(), color: Theme.of(context).scaffoldBackgroundColor, child: AdWidget(ad: myBanner)) : SizedBox(),
    );
  }
}
