import 'package:flutter/material.dart';
import 'package:news_flutter/Model/PostModel.dart';
import 'package:news_flutter/Screens/NewsDetailScreen.dart';

class NewsListDetailScreen extends StatefulWidget {
  static String tag = '/NewsListDetailScreen';
  final List<PostModel>? newsData;
  final int index;

  NewsListDetailScreen({this.newsData, this.index = 0});

  @override
  NewsListDetailScreenState createState() => NewsListDetailScreenState();
}

class NewsListDetailScreenState extends State<NewsListDetailScreen> {
  PageController? pageController;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    pageController = PageController(initialPage: widget.index);
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: pageController,
      children: widget.newsData!.map((e) => NewsDetailScreen(post: e, newsId: e.id.toString())).toList(),
    );
  }
}
