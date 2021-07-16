import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:news_flutter/Model/PostModel.dart';
import 'package:news_flutter/Screens/NewsListDetailScreen.dart';
import 'package:news_flutter/Utils/Common.dart';
import 'package:news_flutter/Utils/Images.dart';
import 'package:news_flutter/Utils/Widgets.dart';
import 'package:news_flutter/Utils/constant.dart';

class NewsItemWidget extends StatefulWidget {
  static String tag = '/NewsItemWidget';
  final PostModel post;
  final int index;
  final List<PostModel>? data;

  NewsItemWidget(this.post, {this.data, this.index = 0});

  @override
  _NewsItemWidgetState createState() => _NewsItemWidgetState();
}

class _NewsItemWidgetState extends State<NewsItemWidget> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        bool? res = await NewsListDetailScreen(newsData: widget.data, index: widget.index).launch(context);
        if (res ?? false) {
          setState(() {});
        }
      },
      child: Container(
        padding: EdgeInsets.all(8),
        width: context.width(),
        //decoration: boxDecoration(context, bgColor: white_color, showShadow: true),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Hero(
              tag: widget.post.id!,
              child: cachedImage(widget.post.image.validate(), height: 150, width: 150, fit: BoxFit.cover)
                  .cornerRadiusWithClipRRect(10)
                  .visible(widget.post.image.validate().isNotEmpty, defaultWidget: Image.asset(greyImage, fit: BoxFit.cover, height: 150, width: 150).cornerRadiusWithClipRRect(10)),
            ),
            8.width,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Text(
                    parseHtmlString(widget.post.postTitle.validate()),
                    style: boldTextStyle(color: Theme.of(context).textTheme.headline6!.color, size: textSizeMedium),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  4.height,
                  Text(
                    parseHtmlString(widget.post.postContent.validate()),
                    style: secondaryTextStyle(size: textSizeSMedium),
                    maxLines: 5,
                    overflow: TextOverflow.ellipsis,
                  ),
                  4.height,
                  Align(
                    child: Text(widget.post.readableDate.validate(), style: secondaryTextStyle(size: 11)),
                    alignment: Alignment.centerRight,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
