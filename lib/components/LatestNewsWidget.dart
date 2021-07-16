import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:news_flutter/Model/PostModel.dart';
import 'package:news_flutter/Screens/LatestNewslistScreen.dart';
import 'package:news_flutter/Screens/NewsListDetailScreen.dart';
import 'package:news_flutter/Utils/Colors.dart';
import 'package:news_flutter/Utils/Common.dart';
import 'package:news_flutter/Utils/Widgets.dart';
import 'package:news_flutter/Utils/constant.dart';
import 'package:news_flutter/app_localizations.dart';

class LatestNewsWidget extends StatelessWidget {
  final AppLocalizations? appLocalization;
  final List? recentNewsListing;
  final double? width;

  LatestNewsWidget({this.appLocalization, this.recentNewsListing, this.width});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            16.height,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(appLocalization!.translate('latest_News')!, style: boldTextStyle(color: Theme.of(context).textTheme.headline6!.color, size: textSizeLargeMedium)).paddingOnly(left: 8.0),
                Text(appLocalization!.translate('see_All')!, style: primaryTextStyle(color: Theme.of(context).textTheme.subtitle2!.color, size: textSizeSmall)).paddingOnly(right: 8.0).onTap(() {
                  LatestNewsListScreen(title: appLocalization!.translate('latest_News')).launch(context);
                }),
              ],
            ),
            16.height,
            Container(
              decoration: boxDecoration(context, radius: 5.0, bgColor: Colors.transparent),
              child: Container(
                child: StaggeredGridView.countBuilder(
                  scrollDirection: Axis.vertical,
                  itemCount: recentNewsListing!.length >= 4 ? 4 : recentNewsListing!.length,
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (context, i) {
                    PostModel data = recentNewsListing![i];

                    return GestureDetector(
                      onTap: () {
                        NewsListDetailScreen(newsData: recentNewsListing as List<PostModel>?, index: i).launch(context);
                      },
                      child: Stack(
                        children: [
                          Container(
                            margin: EdgeInsets.all(8),
                            width: width,
                            child: Stack(
                              alignment: Alignment.bottomLeft,
                              children: [
                                cachedImage(recentNewsListing![i].image.toString().validate(), height: 250, width: width, radius: 10.0, fit: BoxFit.cover).cornerRadiusWithClipRRect(10),
                                Container(
                                  width: context.width(),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10.0), bottomRight: Radius.circular(10.0)),
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.black38,
                                        Colors.black12,
                                        Colors.black38,
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                  ),
                                  child: Align(
                                    alignment: Alignment.bottomCenter,
                                    child: Container(
                                      width: width,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10.0), bottomRight: Radius.circular(10.0)),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Text(
                                            parseHtmlString(data.postTitle.validate()),
                                            style: boldTextStyle(color: white_color, size: textSizeLargeMedium),
                                            maxLines: 2,
                                          ),
                                          4.height,
                                          Text(data.readableDate.validate(), style: primaryTextStyle(color: white_color, size: textSizeSMedium))
                                        ],
                                      ),
                                      padding: EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0, bottom: 8.0),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    );
                  },
                  crossAxisCount: 2,
                  staggeredTileBuilder: (index) => StaggeredTile.fit(1),
                  mainAxisSpacing: 0,
                  crossAxisSpacing: 0,
                ),
              ),
            )
          ],
        )
      ],
    );
  }
}
