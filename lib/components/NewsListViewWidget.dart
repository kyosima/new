import 'package:flutter/material.dart';
import 'package:news_flutter/Model/PostModel.dart';

import 'NewsItemWidget.dart';

class NewsListViewWidget extends StatelessWidget {
  final List<PostModel>? featureNewListing;

  NewsListViewWidget({this.featureNewListing});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: featureNewListing!.length,
      shrinkWrap: true,
      padding: EdgeInsets.all(8),
      scrollDirection: Axis.vertical,
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (context, i) {
        if (featureNewListing!.isEmpty) return SizedBox();
        PostModel post = featureNewListing![i];

        return NewsItemWidget(post,data: featureNewListing,index: i);
      },
    );
  }
}
