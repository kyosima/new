import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:news_flutter/Model/VideoListModel.dart';
import 'package:news_flutter/Screens/WebViewScreen.dart';
import 'package:news_flutter/Utils/Widgets.dart';
import 'package:news_flutter/Utils/constant.dart';
import 'package:news_flutter/app_localizations.dart';

class VideoItemWidget extends StatefulWidget {
  static String tag = '/VideoItemWidget';

  final VideoListModel? videoData;


  VideoItemWidget({this.videoData});

  @override
  VideoItemWidgetState createState() => VideoItemWidgetState();
}

class VideoItemWidgetState extends State<VideoItemWidget> {

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async{
    //
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    var appLocalization = AppLocalizations.of(context);

    Widget imageWidget() {
      if (widget.videoData!.imageUrl.validate().isNotEmpty) {
        return cachedImage(widget.videoData!.imageUrl.validate(),width: context.width(),height: 200, fit: BoxFit.cover).cornerRadiusWithClipRRect(defaultRadius - 4);
      } else if (widget.videoData!.videoType.validate() == VideoTypeYouTube) {
        return cachedImage(widget.videoData!.videoUrl.validate().getYouTubeThumbnail(),width: context.width(),height: 200, fit: BoxFit.cover).cornerRadiusWithClipRRect(defaultRadius - 4);
      }
      return Container(decoration: BoxDecoration(borderRadius: radius(defaultRadius), color: Colors.grey));
    }

    return GestureDetector(
      onTap: () {
        if (widget.videoData!.videoUrl!.isNotEmpty && widget.videoData!.videoUrl.validateURL()) {
          hideKeyboard(context);
          WebViewScreen(videoType: widget.videoData!.videoType.validate(), videoUrl: widget.videoData!.videoUrl.validate()).launch(context);
        } else {
          toast(appLocalization!.translate('invalidURL'));
        }
      },
      child: Container(
        decoration: boxDecoration(context, bgColor: Theme.of(context).scaffoldBackgroundColor, radius: 10.0, showShadow: true),
        padding: EdgeInsets.all(2),
        margin: EdgeInsets.all(8),
        width: context.width(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  imageWidget().cornerRadiusWithClipRRectOnly(topLeft: 10, topRight: 10),
                  Center(child: Icon(Icons.play_circle_outline, color: whiteColor, size: 50)),
                ],
              ),
            ).cornerRadiusWithClipRRect(8.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                8.height,
                Text(widget.videoData!.title!, style: primaryTextStyle(size: textSizeLargeMedium, color: Theme.of(context).textTheme.headline6!.color), maxLines: 2),
                4.height,
                Text('${widget.videoData!.createdAt} ago', style: primaryTextStyle(size: textSizeMedium, color: Theme.of(context).textTheme.subtitle2!.color)),
                8.height,
              ],
            ).paddingOnly(left: 16, right: 16),
          ],
        ),
      ),
    );
  }
}