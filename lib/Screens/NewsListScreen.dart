import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:news_flutter/Model/CategoryModel.dart';
import 'package:news_flutter/Model/PostModel.dart';
import 'package:news_flutter/Network/rest_apis.dart';
import 'package:news_flutter/Screens/SearchFragment.dart';
import 'package:news_flutter/Utils/Colors.dart';
import 'package:news_flutter/Utils/Common.dart';
import 'package:news_flutter/Utils/Images.dart';
import 'package:news_flutter/Utils/constant.dart';
import 'package:news_flutter/app_localizations.dart';
import 'package:news_flutter/components/NewsItemWidget.dart';
import 'package:news_flutter/shimmerScreen/NewsItemShimmer.dart';

import '../main.dart';

class NewsListScreen extends StatefulWidget {
  static String tag = '/NewsListScreen';

  final String? title;
  final int? id;
  final List? recentPost;

  @override
  NewsListScreenState createState() => NewsListScreenState();

  NewsListScreen({this.id, this.title, this.recentPost});
}

class NewsListScreenState extends State<NewsListScreen> {
  var scrollController = ScrollController();

  List<PostModel> categoriesWiseNewListing = [];
  List<CategoriesModel> mSubCategory = [];
  List<String> subCategories = [];

  int page = 1;
  int numPages = 0;
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    init();

    scrollController.addListener(() {
      if ((scrollController.position.pixels - 100) == (scrollController.position.maxScrollExtent - 100)) {
        if (numPages > page) {
          page++;
          appStore.setLoading(true);
          fetchCategoriesWiseNewsData(widget.id);
        }
      }
    });
  }

  init() {
    fetchCategoriesWiseNewsData(widget.id);
    fetchSubCategoriesData();
  }

  void fetchSubCategoriesData() {
    getSubCategoriesList(widget.id!).then((res) {
      if (!mounted) return;
      mSubCategory = res;

      if (mSubCategory.length > 0) {
        subCategories.clear();
        subCategories.add('All');

        mSubCategory.forEach((element) {
          subCategories.add(element.name.toString());
        });

        setState(() {});
      }
    }).catchError((error) {
      if (!mounted) return;
      toast(error.toString());
    });
  }

  void fetchCategoriesWiseNewsData(int? id, {int? subCatId}) {
    appStore.setLoading(true);

    Map req = {
      'category': id,
      'filter': 'by_category',
      'paged': page,
    };

    if (subCatId != null) {
      req.putIfAbsent('subcategory', () => subCatId);
    }

    getBlogList(req).then((res) {
      if (!mounted) return;
      appStore.setLoading(false);

      numPages = res.num_pages!.toInt();

      categoriesWiseNewListing.addAll(res.posts!);
      setState(() {});
    }).catchError((error) {
      if (!mounted) return;
      appStore.setLoading(false);
      toast(error.toString());
    });
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
      return Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: ListView.builder(
          itemCount: categoriesWiseNewListing.length,
          shrinkWrap: true,
          scrollDirection: Axis.vertical,
          padding: EdgeInsets.all(8),
          physics: NeverScrollableScrollPhysics(),
          itemBuilder: (context, i) {
            PostModel post = categoriesWiseNewListing[i];

            return NewsItemWidget(post, data: categoriesWiseNewListing, index: i);
          },
        ),
      );
    }

    Widget subCatList() {
      return Container(
        height: 50,
        child: ListView.builder(
          itemCount: subCategories.length,
          scrollDirection: Axis.horizontal,
          itemBuilder: (_, index) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedIndex = index;
                  page = 1;
                  if (index == 0) {
                    categoriesWiseNewListing.clear();
                    fetchCategoriesWiseNewsData(widget.id);
                  } else {
                    categoriesWiseNewListing.clear();
                    fetchCategoriesWiseNewsData(widget.id, subCatId: mSubCategory[index - 1].id);
                  }
                });
              },
              child: Container(
                alignment: Alignment.center,
                padding: EdgeInsets.only(left: 24, right: 24),
                margin: EdgeInsets.only(left: 8, right: 8, top: 4, bottom: 4),
                decoration: BoxDecoration(
                  color: selectedIndex == index ? primaryColor : Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.all(Radius.circular(30)),
                  border: Border.all(color: appStore.isDarkMode ? Colors.white : Colors.black, width: 0.5),
                ),
                clipBehavior: Clip.antiAliasWithSaveLayer,
                child: Text(
                  parseHtmlString(subCategories[index]),
                  style: primaryTextStyle(size: 14, color: selectedIndex == index ? Colors.white : Theme.of(context).textTheme.headline6!.color),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          },
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 5.0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            size: 30,
            color: Theme.of(context).textTheme.headline6!.color,
          ),
          onPressed: () {
            finish(context);
          },
        ),
        title: Text(parseHtmlString(widget.title.validate()), style: boldTextStyle(color: Theme.of(context).textTheme.headline6!.color, size: 18)),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.search,
              size: 30.0,
              color: Theme.of(context).textTheme.headline6!.color,
            ),
            onPressed: () {
              SearchFragment(isTab: false).launch(context);
            },
          )
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: scrollController,
            physics: BouncingScrollPhysics(),
            padding: EdgeInsets.only(top: 8),
            child: Stack(
              children: [
                Column(
                  children: [
                    subCatList().visible(subCategories.length > 0),
                    newsList().visible(categoriesWiseNewListing.isNotEmpty),
                  ],
                ),
                Container(
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
                ).visible(!appStore.isLoading && categoriesWiseNewListing.isEmpty),
              ],
            ),
          ),
          CircularProgressIndicator().center().visible(appStore.isLoading && page != 1),
          Container(margin: EdgeInsets.only(top: subCategories.length > 0 ? 46 : 0), child: NewsItemShimmer().center().visible(appStore.isLoading && page == 1)),
        ],
      ),
    );
  }
}
