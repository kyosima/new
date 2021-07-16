import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:news_flutter/Model/PostModel.dart';
import 'package:news_flutter/Network/rest_apis.dart';
import 'package:news_flutter/Utils/Colors.dart';
import 'package:news_flutter/Utils/Strings.dart';
import 'package:news_flutter/Utils/constant.dart';
import 'package:news_flutter/app_localizations.dart';
import 'package:news_flutter/components/NewsItemWidget.dart';
import 'package:news_flutter/main.dart';

class SearchFragment extends StatefulWidget {
  final bool? isTab;

  SearchFragment({this.isTab});

  @override
  _SearchFragmentState createState() => _SearchFragmentState();
}

class _SearchFragmentState extends State<SearchFragment> {
  List<PostModel> searchList = [];
  var searchCont = TextEditingController();
  var scrollController = ScrollController();
  int page = 1;
  int numPages = 0;

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    scrollController.addListener(() {
      if ((scrollController.position.pixels - 100) == (scrollController.position.maxScrollExtent - 100)) {
        if (numPages > page) {
          page++;
          appStore.setLoading(true);
          setState(() {});
          getSearchListing();
        }
      }
    });
  }

  void getSearchListing() async {
    appStore.setLoading(true);

    Map req = {
      "text": searchCont.text,
    };
    getSearchBlogList(req, page).then((res) {
      if (!mounted) return;
      appStore.setLoading(false);
      Iterable listing = res['posts'];
      numPages = int.parse(res['num_pages'].toString());
      searchList.addAll(listing.map((model) => PostModel.fromJson(model)).toList());

      if (searchList.length == 0) {
        toast(noRecord);
      }
      setState(() {});
    }).catchError((error) {
      if (!mounted) return;
      appStore.setLoading(false);
      toast(error.toString());
      setState(() {});
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
      return searchList.isNotEmpty
          ? ListView.builder(
              padding: EdgeInsets.all(8),
              itemCount: searchList.length,
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, i) {
                PostModel post = searchList[i];

                return NewsItemWidget(post, data: searchList, index: i);
              },
            )
          : Container();
    }

    Widget searchText() {
      return Container(
        child: TextField(
          textAlignVertical: TextAlignVertical.center,
          controller: searchCont,
          textInputAction: TextInputAction.done,
          onSubmitted: (String searchTxt) {
            page = 1;
            setState(() {});
            if (searchTxt.length > 0) {
              getSearchListing();
            } else {
              searchList.clear();
              toast('Please enter text');
            }
          },
          decoration: InputDecoration(
            filled: true,
            fillColor: app_Background,
            border: InputBorder.none,
            hintStyle: primaryTextStyle(color: Theme.of(context).textTheme.subtitle1!.color, size: textSizeMedium),
            hintText: appLocalization.translate('search'),
            suffixIcon: Icon(Icons.search, color: primaryColor).paddingAll(16),
            contentPadding: EdgeInsets.only(left: 16.0, bottom: 8.0, top: 8.0, right: 16.0),
          ),
        ).cornerRadiusWithClipRRect(20),
        alignment: Alignment.center,
      ).cornerRadiusWithClipRRect(10).paddingAll(16.0);
    }

    return Stack(
      children: [
        Scaffold(
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
            ).visible(widget.isTab == false),
            title: Text(
              appLocalization.translate('search')!,
              style: boldTextStyle(color: Theme.of(context).textTheme.headline6!.color, size: 18),
            ),
          ),
          backgroundColor: Theme.of(context).cardTheme.color,
          body: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              children: <Widget>[
                searchText(),
                newsList(),
              ],
            ),
          ),
        ),
        Observer(builder: (_) => CircularProgressIndicator().center().visible(appStore.isLoading)),
      ],
    );
  }
}
