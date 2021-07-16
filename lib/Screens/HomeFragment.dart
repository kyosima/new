import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:news_flutter/Model/CategoryModel.dart';
import 'package:news_flutter/Model/CategoryWiseResponse.dart';
import 'package:news_flutter/Model/PostModel.dart';
import 'package:news_flutter/Model/SliderModel.dart';
import 'package:news_flutter/Network/rest_apis.dart';
import 'package:news_flutter/Screens/VideoListScreen.dart';
import 'package:news_flutter/Screens/WebViewScreen.dart';
import 'package:news_flutter/Utils/Colors.dart';
import 'package:news_flutter/Utils/Common.dart';
import 'package:news_flutter/Utils/Images.dart';
import 'package:news_flutter/Utils/Strings.dart';
import 'package:news_flutter/Utils/Widgets.dart';
import 'package:news_flutter/Utils/constant.dart';
import 'package:news_flutter/app_localizations.dart';
import 'package:news_flutter/components/DrawerWidget.dart';
import 'package:news_flutter/components/LatestNewsWidget.dart';
import 'package:news_flutter/components/NewsListViewWidget.dart';
import 'package:news_flutter/shimmerScreen/NewsItemShimmer.dart';

import '../main.dart';

class HomeFragment extends StatefulWidget {
  static String tag = '/HomeFragment';

  @override
  HomeFragmentState createState() => HomeFragmentState();
}

class HomeFragmentState extends State<HomeFragment> with TickerProviderStateMixin {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

  TabController? tabController;
  var scrollController = ScrollController();
  int page = 1;

  var mCategory = [];
  List<PostModel> categoriesWiseNewListing = [];
  List<PostModel> featuredNewsListing = [];
  List<PostModel> latestNewsListing = [];
  var mSliderImages = [];
  var mProfileImage = '';

  List<Widget> tabs = [];

  bool showNoData = false;
  bool isLoadingSwipeToRefresh = false;
  int? featureNumPages = 0;
  int numPages = 0;
  int selectedTabIndex = 0;

  bool isDashboardDataLoaded = false;
  DateTime? currentBackPressTime;

  @override
  void initState() {
    super.initState();

    init();

    scrollController.addListener(() {
      if (isDashboardDataLoaded && featureNumPages! > page && (scrollController.position.pixels - 100) == (scrollController.position.maxScrollExtent - 100)) {
        page++;
        if (selectedTabIndex == 0) {
          fetchDashboardData();
          fetchCategoriesWiseNewsData(page: page);
        } else {
          fetchCategoriesWiseNewsData(id: mCategory[selectedTabIndex - 1].id, page: page);
        }
        appStore.setLoading(true);
        setState(() {});
      }
    });
  }

  Future<void> init() async {
    page = 1;
    tabs.clear();
    mCategory.clear();
    categoriesWiseNewListing.clear();
    featuredNewsListing.clear();
    latestNewsListing.clear();
    mSliderImages.clear();

    await setDataFromDB();

    fetchDashboardData();
    fetchCategoryData();

    var g = appStore.userProfileImage.validate();
    if (g.isNotEmpty) {
      mProfileImage = g;
    } else {
      mProfileImage = getStringAsync(AVATAR);
    }
    setState(() {});
  }

  Future<void> setDataFromDB() async {
    if (allowPreFetched) {
      String dashboardPref = getStringAsync(dashboardData);
      String categoryPref = getStringAsync(categoryData);

      await Future.delayed(Duration(milliseconds: 200));

      if (dashboardPref.isNotEmpty) {
        var res = jsonDecode(dashboardPref);
        await setDashboardRes(res);
      }

      if (categoryPref.isNotEmpty) {
        var res = jsonDecode(categoryPref);
        setCategoryRes(res);
      }
    }
  }

  Future<void> fetchDashboardData() async {
    appStore.setLoading(latestNewsListing.isEmpty);

    Map req = {};
    getDashboardApi(req, page).then((res) {
      appStore.setLoading(false);
      isDashboardDataLoaded = true;
      if (page == 1) {
        setValue(dashboardData, jsonEncode(res));
        featuredNewsListing.clear();
        latestNewsListing.clear();
        mSliderImages.clear();
      }
      featureNumPages = res['feature_num_pages'];
      setDashboardRes(res);
    }).catchError((error) {
      appStore.setLoading(false);
      setState(() {});
    });
  }

  Future<void> setDashboardRes(res) async {
    appStore.setLoading(false);

    Iterable listFeatured = res['feature_post'];
    featuredNewsListing.addAll(listFeatured.map((model) => PostModel.fromJson(model)).toList());

    if (page == 1) {
      if (res['social_link'] != null) {
        await setValue(WHATSAPP, res['social_link']['whatsapp'].toString());
        await setValue(FACEBOOK, res['social_link']['facebook'].toString());
        await setValue(TWITTER, res['social_link']['twitter'].toString());
        await setValue(INSTAGRAM, res['social_link']['instagram'].toString());
        await setValue(CONTACT, res['social_link']['contact'].toString());
        await setValue(PRIVACY_POLICY, res['social_link']['privacy_policy'].toString());
        await setValue(TERMS_AND_CONDITIONS, res['social_link']['term_condition'].toString());
        await setValue(COPYRIGHT_TEXT, res['social_link']['copyright_text'].toString());
      }

      /// if you want language set under the app so comment this two line other wise uncomment..

      if (!isLanguageEnable) {
        await setValue(LANGUAGE, res['app_lang'].toString());
        appStore.setLanguage(res['app_lang'].toString());
      }

      Iterable listRecent = res['recent_post'];
      latestNewsListing.addAll(listRecent.map((model) => PostModel.fromJson(model)).toList());

      Iterable sliderImg = res['banner'];
      mSliderImages.addAll(sliderImg.map((model) => SliderModel.fromJson(model)).toList());
    }
    setState(() {});
  }

  Future<void> fetchCategoryData() async {
    appStore.setLoading(mCategory.isEmpty);
    setState(() {});

    getCategories().then((res) async {
      appStore.setLoading(false);
      await setValue(categoryData, jsonEncode(res));

      tabs.clear();
      mCategory.clear();
      categoriesWiseNewListing.clear();

      setCategoryRes(res);
    }).catchError((error) {
      appStore.setLoading(false);
      toast(error.toString());

      setState(() {});
    });
  }

  void setCategoryRes(res) {
    Iterable category = res;

    category.forEach((element) {
      if (element['parent'] != null && element['parent'] == 0) {
        mCategory.add(CategoriesModel.fromJson(element));
      }
    });

    tabs.clear();
    tabs.add(
      Container(
        padding: EdgeInsets.all(16.0),
        child: Observer(
          builder: (_) => Text(
            Home,
            style: secondaryTextStyle(color: appStore.isDarkMode ? Colors.white : Colors.black, size: textSizeLargeMedium),
          ),
        ),
      ),
    );

    mCategory.forEach((element) {
      if (element.parent == 0) {
        tabs.add(
          Container(
            padding: EdgeInsets.all(16.0),
            child: Observer(
              builder: (_) => Text(
                parseHtmlString(element.name.toString().validate()),
                style: secondaryTextStyle(color: appStore.isDarkMode ? Colors.white : Colors.black, size: textSizeLargeMedium),
              ),
            ),
          ),
        );
      }
    });

    //mCategory.add(CategoriesModel());

    tabController = TabController(length: tabs.length, vsync: this, initialIndex: selectedTabIndex);
    setState(() {});
  }

  Future<void> fetchCategoriesWiseNewsData({int? id, int? page}) async {
    appStore.setLoading(true);

    setState(() {});

    Map req = {
      'category': id,
      'filter': 'by_category',
      'paged': page,
    };

    /*if (allowPreFetched) {
      String data = getStringAsync('$categoryWisePostData$id');

      if (data.isNotEmpty) {
        setCategoryWiseData(jsonDecode(data));
      }
    }*/

    await getBlogList(req).then((res) async {
      appStore.setLoading(false);
      //await setValue('$categoryWisePostData$id', jsonEncode(res));
      featureNumPages = res.num_pages;

      if (page == 1) {
        categoriesWiseNewListing.clear();
      }

      setCategoryWiseData(res);
    }).catchError((error) {
      setState(() {
        appStore.setLoading(false);
        toast(error.toString());
      });
    });
  }

  void setCategoryWiseData(CategoryWiseResponse res) {
    categoriesWiseNewListing.clear();
    categoriesWiseNewListing.addAll(res.posts!);

    if (selectedTabIndex != 0) {
      showNoData = categoriesWiseNewListing.isEmpty;
    } else {
      showNoData = false;
    }

    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
    tabController?.dispose();
    scrollController.dispose();
  }

  @override
  void setState(fn) {
    if (!mounted) return;
    super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    var appLocalization = AppLocalizations.of(context);
    var width = context.width();

    Widget carousel() {
      return mSliderImages.isNotEmpty
          ? Container(
              height: 200,
              child: PageView(
                children: mSliderImages.map((i) {
                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 1.0, vertical: 2.0),
                    child: cachedImage(i.image.toString().validate(), height: 180, width: width, fit: BoxFit.cover).cornerRadiusWithClipRRect(10),
                  ).onTap(() {
                    WebViewScreen(videoUrl: i.url, title: i.desc).launch(context);
                  });
                }).toList(),
              ),
            )
          : SizedBox();
    }

    Widget newsList(int index) {
      if (index == 0) {
        return Container(
          color: Theme.of(context).cardTheme.color,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(8),
            controller: scrollController,
            physics: AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    4.height,
                    Text(appLocalization!.translate('dash_Title')!, style: boldTextStyle(color: Theme.of(context).textTheme.headline6!.color, size: textSizeLarge)).fit(),
                    16.height,
                    carousel(),
                  ],
                ).paddingAll(8),
                LatestNewsWidget(appLocalization: appLocalization, recentNewsListing: latestNewsListing, width: width),
                16.height,
                Text(
                  appLocalization.translate('featured_News')!,
                  style: boldTextStyle(color: Theme.of(context).textTheme.headline6!.color, size: textSizeLargeMedium),
                ).paddingOnly(left: 8.0, bottom: 16).visible(featuredNewsListing.isNotEmpty),
                featuredNewsListing.isNotEmpty ? NewsListViewWidget(featureNewListing: featuredNewsListing) : Container(),
              ],
            ),
          ),
        );
      } else {
        return Container(
          child: SingleChildScrollView(
            controller: scrollController,
            physics: AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.only(bottom: 30, top: 8),
            child: NewsListViewWidget(featureNewListing: categoriesWiseNewListing),
          ),
        );
      }
    }

    return WillPopScope(
      onWillPop: () async {
        DateTime now = DateTime.now();
        if (currentBackPressTime == null || now.difference(currentBackPressTime!) > Duration(seconds: 2)) {
          currentBackPressTime = now;
          toast('Press back again to exit app.');
          return Future.value(false);
        }
        return Future.value(true);
      },
      child: DefaultTabController(
        length: tabs.length,
        child: Observer(
          builder:(_) => Scaffold(
            backgroundColor: Theme.of(context).cardColor,
            key: scaffoldKey,
            appBar: AppBar(
              centerTitle: true,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              leading: IconButton(
                icon: Icon(Icons.menu, color: Theme.of(context).textTheme.headline6!.color),
                onPressed: () {
                  scaffoldKey.currentState!.openDrawer();
                },
              ),
              title: Text('$AppName', style: boldTextStyle(color: Theme.of(context).textTheme.headline6!.color, size: textSizeLarge)),
              actions: [
                IconButton(
                  icon: Image.asset(ic_video, color: Theme.of(context).textTheme.headline6!.color),
                  onPressed: () {
                    VideoListScreen().launch(context);
                  },
                ),
              ],
              bottom: tabs.isNotEmpty
                  ? TabBar(
                      labelPadding: EdgeInsets.only(left: 0, right: 0),
                      controller: tabController,
                      indicatorWeight: 4.0,
                      indicatorSize: TabBarIndicatorSize.label,
                      indicatorColor: primaryColor,
                      isScrollable: true,
                      tabs: tabs,
                      onTap: (i) {
                        if (appStore.isLoading) {
                          toast('Please wait');
                          tabController!.animateTo(selectedTabIndex, duration: Duration(seconds: 1), curve: Curves.linear);
                          return;
                        }
                        page = 1;
                        appStore.setLoading(true);
                        showNoData = false;
                        categoriesWiseNewListing.clear();
                        featuredNewsListing.clear();
                        selectedTabIndex = i;

                        setState(() {});
                        tabController!.animateTo(i, duration: Duration(seconds: 1), curve: Curves.linear);

                        if (selectedTabIndex == 0) {
                          init();
                        } else {
                          fetchCategoriesWiseNewsData(id: mCategory[i - 1].id, page: page);
                        }
                      },
                    )
                  : null,
            ),
            drawer: DrawerWidget(),
            body: Stack(
              fit: StackFit.expand,
              children: [
                TabBarView(
                  physics: NeverScrollableScrollPhysics(),
                  controller: tabController,
                  children: tabs.map((e) {
                    int index = tabs.indexOf(e);

                    return RefreshIndicator(
                      child: newsList(index),
                      color: primaryColor,
                      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                      onRefresh: () async {
                        page = 1;
                        showNoData = false;
                        isLoadingSwipeToRefresh = true;
                        // setState(() {});
                        if (index == 0) {
                          await fetchCategoriesWiseNewsData(id: mCategory[0].id);
                        } else {
                          await fetchCategoriesWiseNewsData(id: mCategory[index - 1].id, page: page);
                        }
                        isLoadingSwipeToRefresh = false;
                      },
                    );
                  }).toList(),
                ).visible(tabs.length > 0),
                Container(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(ic_NoRecord, height: 80, width: 80, fit: BoxFit.cover, color: Theme.of(context).textTheme.headline6!.color),
                        8.height,
                        Text(
                          appLocalization!.translate("noRecord")!,
                          style: primaryTextStyle(color: Theme.of(context).textTheme.headline6!.color, size: textSizeMedium),
                        )
                      ],
                    ),
                  ),
                ).visible(showNoData && selectedTabIndex != 0),
                CircularProgressIndicator().center().visible(appStore.isLoading && page != 1),
                NewsItemShimmer().visible(appStore.isLoading && page == 1 && featuredNewsListing.isEmpty && !isLoadingSwipeToRefresh),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
