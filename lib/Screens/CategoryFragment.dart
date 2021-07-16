import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:news_flutter/Model/CategoryModel.dart';
import 'package:news_flutter/Network/rest_apis.dart';
import 'package:news_flutter/Screens/NewsListScreen.dart';
import 'package:news_flutter/Utils/Colors.dart';
import 'package:news_flutter/Utils/Common.dart';
import 'package:news_flutter/Utils/Images.dart';
import 'package:news_flutter/Utils/Widgets.dart';
import 'package:news_flutter/Utils/constant.dart';
import 'package:news_flutter/app_localizations.dart';
import 'package:news_flutter/main.dart';
import 'package:news_flutter/shimmerScreen/CategoryShimmer.dart';

class CategoryFragment extends StatefulWidget {
  final bool? isTab;

  CategoryFragment({this.isTab});

  @override
  _CategoryFragmentState createState() => _CategoryFragmentState();
}

class _CategoryFragmentState extends State<CategoryFragment> {
  var categoryList = [];
  var scrollController = ScrollController();

  bool isLastPage = false;

  int page = 1;

  BannerAd? myBanner;

  @override
  void initState() {
    super.initState();
    myBanner = buildBannerAd()..load();
    init();
    appStore.setLoading(true);
    fetchCategoryData(page: 1, perPageItem: perPageItemInCategory);
    scrollController.addListener(() {
      if (!isLastPage && (scrollController.position.pixels - 100 == scrollController.position.maxScrollExtent - 100)) {
        page++;
        appStore.setLoading(true);
        setState(() {});
        fetchCategoryData(page: page);
      }
    });
  }

  init() async {
    if (allowPreFetched) {
      String res = getStringAsync(categoryData);
      if (res.isNotEmpty) {
        setData(jsonDecode(res));
      }
    }

    if (await isNetworkAvailable()) {
      fetchCategoryData(page: 1, perPageItem: perPageItemInCategory);
    }
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

  Future<void> fetchCategoryData({int page = 1, int perPageItem = perPageItemInCategory}) async {
    setState(() {
      /*isLoading = categoryList.isEmpty;*/
    });
    await getCategories(page: page, perPage: perPageItem).then((res) async {
      if (!mounted) return;
      appStore.setLoading(false);

      if (page == 1) {
        categoryList.clear();
      }

      setData(res);
    }).catchError((error) {
      if (!mounted) return;
      appStore.setLoading(false);

      toast(error.toString());
      setState(() {});
    });
  }

  void setData(res) {
    Iterable mCategory = res;
    List<CategoriesModel> m = mCategory.map((model) => CategoriesModel.fromJson(model)).toList();

    isLastPage = m.length != perPageCategory;

    categoryList.addAll(m);
    appStore.setLoading(false);
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var appLocalization = AppLocalizations.of(context)!;

    Widget newsList() {
      return ListView.builder(
        itemCount: categoryList.length,
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
        physics: NeverScrollableScrollPhysics(),
        itemBuilder: (context, i) {
          CategoriesModel data = categoryList[i];

          return GestureDetector(
            onTap: () {
              NewsListScreen(title: data.name, id: data.id).launch(context);
            },
            child: Container(
              height: context.height() * 0.15,
              width: context.width(),
              decoration: boxDecoration(context, bgColor: isColorImgCat ? Colors.transparent : getColorFromHex(categoryColors[i % categoryColors.length]), radius: 10.0),
              child: Stack(
                children: [
                  Image.asset(
                    catImg[i % catImg.length],
                    height: context.height(),
                    width: context.width(),
                    filterQuality: FilterQuality.high,
                    fit: BoxFit.cover,
                  ).cornerRadiusWithClipRRect(10.0).visible(isColorImgCat == true),
                  Container(
                    height: context.height(),
                    width: context.width(),
                    decoration: boxDecoration(context, bgColor: isColorImgCat ? blackColor.withOpacity(0.4) : Colors.transparent, radius: 10.0),
                    child: Row(
                      children: [
                        Center(
                          child: Container(height: 1.0, width: context.width() * 0.1, color: white_color),
                        ).paddingOnly(left: 16.0),
                        8.width,
                        Text(parseHtmlString(data.name), style: secondaryTextStyle(color: white_color, size: textSizeNormal)).expand(),
                      ],
                    ),
                  )
                ],
              ),
            ).paddingOnly(left: 16, right: 16, top: 6, bottom: 6),
          );
        },
      );
    }

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 5.0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back,size: 30,color: appStore.isDarkMode?white:Colors.black,),
             //icon: Icon(Icons.arrow_back, size: 30, color: Theme.of(context).textTheme.headline6!.color),
            onPressed: () {
              finish(context);
            },
          ).visible(widget.isTab == false),
          title: Text(appLocalization.translate('category')!, style: boldTextStyle(color: Theme.of(context).textTheme.headline6!.color, size: 18)),
        ),
        backgroundColor: Theme.of(context).cardColor,
        body: Observer(
          builder: (_) => Stack(
            children: [
              RefreshIndicator(
                onRefresh: () {
                  return fetchCategoryData();
                },
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: EdgeInsets.only(top: 16, bottom: 32),
                  child: newsList(),
                ),
              ),
              Container(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(ic_NoRecord, height: 80, width: 80, fit: BoxFit.fill, color: Theme.of(context).textTheme.headline6!.color),
                      8.height,
                      Text(appLocalization.translate("noRecord")!, style: primaryTextStyle(color: Theme.of(context).textTheme.headline6!.color, size: textSizeMedium))
                    ],
                  ),
                ),
              ).visible(!appStore.isLoading && categoryList.isEmpty),
              50.height,
              Align(alignment: Alignment.bottomCenter, child: CircularProgressIndicator().visible(appStore.isLoading && page != 1)),
              Observer(builder: (_) => CategoryShimmer().visible(appStore.isLoading && page == 1)),
            ],
          ),
        ),
        bottomNavigationBar: !isAdsDisabled && !widget.isTab!
            ? Container(
                height: AdSize.banner.height.toDouble(),
                color: Theme.of(context).scaffoldBackgroundColor,
                child: myBanner != null
                    ? AdWidget(
                        ad: myBanner!,
                      )
                    : SizedBox())
            : SizedBox(),
      ),
    );
  }
}
