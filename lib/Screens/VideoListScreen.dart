import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:news_flutter/Model/VideoListModel.dart';
import 'package:news_flutter/Network/rest_apis.dart';
import 'package:news_flutter/Utils/constant.dart';
import 'package:news_flutter/app_localizations.dart';
import 'package:news_flutter/components/VideoItemWidget.dart';
import 'package:news_flutter/main.dart';
import 'package:news_flutter/shimmerScreen/VideoShimmer.dart';

class VideoListScreen extends StatefulWidget {
  @override
  VideoListScreenState createState() => VideoListScreenState();
}

class VideoListScreenState extends State<VideoListScreen> {
  List<VideoListModel> videoListing = [];
  var scrollController = ScrollController();

  var searchTextCont = TextEditingController();

  int page = 1;
  int numPages = 0;

  bool mIsLastPage = false;
  bool mIsVideoLoaded = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    scrollController.addListener(() {
      if (mIsVideoLoaded && (scrollController.position.pixels - 100) == (scrollController.position.maxScrollExtent - 100)) {
        if (!mIsLastPage) {
          page++;
          appStore.setLoading(true);
          setState(() {});
          getVideoListData();
        }
      }
    });
    if (allowPreFetched) {
      String data = getStringAsync(videoListData);
      if (data.isNotEmpty) {
        setData(jsonDecode(data));
      }
    }
    getVideoListData();
  }

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
  }

  void getVideoListData({String? search}) async {
    appStore.setLoading(videoListing.isEmpty);

    setState(() {});
    Map req = {
      'search': search.validate(),
    };
    getVideoList(req, page).then((res) async {
      if (!mounted) return;
      mIsVideoLoaded = true;
      hideKeyboard(context);

      if (page == 1) {
        await setValue(videoListData, jsonEncode(res));

        videoListing.clear();
      }

      setData(res);
    }).catchError((error) {
      if (!mounted) return;
      toast(error.toString());
    }).whenComplete(() {
      appStore.setLoading(false);
    });
  }

  void setData(res) {
    appStore.setLoading(false);
    Iterable listVideo = res['data'];

    mIsLastPage = listVideo.length != 5;

    videoListing.addAll(listVideo.map((model) => VideoListModel.fromJson(model)).toList());

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var appLocalization = AppLocalizations.of(context)!;

    Widget videoList() {
      return Container(
        color: appStore.isDarkMode ? Theme.of(context).cardColor : Colors.white,
        child: ListView.builder(
          itemCount: videoListing.length,
          shrinkWrap: true,
          scrollDirection: Axis.vertical,
          padding: EdgeInsets.only(bottom: 16, right: 8, left: 8),
          physics: NeverScrollableScrollPhysics(),
          itemBuilder: (context, i) {
            VideoListModel video = videoListing[i];

            return VideoItemWidget(videoData: video);
          },
        ),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).cardColor,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 5.0,
        title: Text(
          appLocalization.translate('Videos')!,
          style: boldTextStyle(color: Theme.of(context).textTheme.headline6!.color, size: 18),
        ),
      ),
      body: Observer(
        builder: (_) => Stack(
          children: [
            SingleChildScrollView(
              controller: scrollController,
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.all(16),
                    child: TextField(
                      cursorColor: Theme.of(context).textTheme.headline6!.color,
                      controller: searchTextCont,
                      style: primaryTextStyle(color: Theme.of(context).textTheme.headline6!.color),
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(borderRadius: radius(16), borderSide: BorderSide(color: Theme.of(context).textTheme.subtitle2!.color!)),
                        focusedBorder: OutlineInputBorder(borderRadius: radius(16), borderSide: BorderSide(color: Theme.of(context).textTheme.subtitle2!.color!)),
                        labelText: 'Search Videos',
                        labelStyle: primaryTextStyle(color: Theme.of(context).textTheme.headline6!.color),
                        suffixIcon: Icon(Icons.clear, color: Theme.of(context).textTheme.headline6!.color).onTap(() {
                          if (searchTextCont.text.isEmpty) {
                            hideKeyboard(context);
                          } else {
                            searchTextCont.text = '';

                            page = 1;
                            videoListing.clear();
                            getVideoListData();
                          }
                        }),
                      ),
                      maxLines: 1,
                      onSubmitted: (s) {
                        page = 1;
                        videoListing.clear();
                        getVideoListData(search: s);
                      },
                    ),
                  ),
                  videoList(),
                ],
              ),
            ),
            Container(child: VideoShimmer(), margin: EdgeInsets.only(top: 70)).visible(appStore.isLoading && page == 1),
            CircularProgressIndicator().center().visible(appStore.isLoading && page != 1),
            Text('No data found', style: secondaryTextStyle()).center().visible(!appStore.isLoading && videoListing.isEmpty),
          ],
        ),
      ),
    );
  }
}
