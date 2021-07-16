import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:news_flutter/Model/BookmarkNewsResponse.dart';
import 'package:news_flutter/Model/PostModel.dart';
import 'package:news_flutter/Network/rest_apis.dart';
import 'package:news_flutter/Utils/Images.dart';
import 'package:news_flutter/Utils/constant.dart';
import 'package:news_flutter/app_localizations.dart';
import 'package:news_flutter/components/NewsItemWidget.dart';
import 'package:news_flutter/main.dart';
import 'package:news_flutter/shimmerScreen/NewsItemShimmer.dart';

class BookmarkFragment extends StatefulWidget {
  @override
  BookmarkFragmentState createState() => BookmarkFragmentState();
}

class BookmarkFragmentState extends State<BookmarkFragment> {
  List<PostModel> bookMarkListing = [];
  var scrollController = ScrollController();

  bool isLoadAds = false;
  bool isLastPage = false;
  int page = 1;
  int? numPages = 0;

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    scrollController.addListener(() {
      if ((scrollController.position.pixels - 100) == (scrollController.position.maxScrollExtent - 100)) {
        if (numPages! > page) {
          page++;
          appStore.setLoading(true);

          setState(() {});
          getWishListData();
        }
      }
    });

    if (allowPreFetched) {
      String res = getStringAsync(bookmarkData);

      if (res.isNotEmpty) {
        setData(BookmarkNewsResponse.fromJson(jsonDecode(res)));
      } else {
        appStore.setLoading(true);
      }
    } else {
      appStore.setLoading(true);
    }
    getWishListData();

    LiveStream().on(bookmarkChanged, (data) {
      bookMarkListing.remove(data);

      setState(() {});
    });
  }

  void getWishListData() async {
    Map req = {};

    getWishList(req, page).then((res) async {
      if (!mounted) return;
      await setValue(bookmarkData, jsonEncode(res));

      setData(res);
    }).catchError((error) {
      if (!mounted) return;

      log(error.toString());
      toast(error.toString());
    }).whenComplete(() {
      appStore.setLoading(false);
    });
  }

  void setData(BookmarkNewsResponse res) {
    appStore.setLoading(false);

    if (page == 1) numPages = res.num_pages;

    bookMarkListing.clear();
    bookMarkListing.addAll(res.posts!);

    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();

    LiveStream().dispose(bookmarkChanged);
  }

  @override
  Widget build(BuildContext context) {
    var appLocalization = AppLocalizations.of(context)!;

    Widget newsList() {
      return Container(
        color: Theme.of(context).cardTheme.color,
        child: bookMarkListing.isNotEmpty
            ? ListView.builder(
                itemCount: bookMarkListing.length,
                shrinkWrap: true,
                padding: EdgeInsets.all(8),
                scrollDirection: Axis.vertical,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, i) {
                  PostModel post = bookMarkListing[i];

                  return NewsItemWidget(post, data: bookMarkListing, index: i);
                },
              ).paddingOnly(top: 8.0, bottom: 16.0)
            : Container(
                width: context.width(),
                height: context.height() * 0.5,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(ic_NoRecord, height: 80, width: 80, fit: BoxFit.fill, color: Theme.of(context).textTheme.headline6!.color),
                      8.height,
                      Text(
                        appLocalization.translate("noRecord")!,
                        style: primaryTextStyle(color: Theme.of(context).textTheme.headline6!.color, size: textSizeMedium),
                      )
                    ],
                  ),
                ),
              ).visible(!appStore.isLoading && bookMarkListing.length == 0),
      );
    }

    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).cardTheme.color,
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 5.0,
          title: Text(
            appLocalization.translate('WishList')!,
            style: boldTextStyle(color: Theme.of(context).textTheme.headline6!.color, size: 18),
          ),
        ),
        body: Observer(
          builder: (_) => Stack(
            children: [
              SingleChildScrollView(
                controller: scrollController,
                child: newsList(),
              ),
              NewsItemShimmer().visible(appStore.isLoading && page == 1),
              CircularProgressIndicator().center().visible(appStore.isLoading && page != 1),
            ],
          ),
        ),
      ),
    );
  }
}
