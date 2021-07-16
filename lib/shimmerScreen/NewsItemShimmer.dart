import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:shimmer/shimmer.dart';

class NewsItemShimmer extends StatelessWidget {
  static String tag = '/NewsItemShimmer';

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Shimmer.fromColors(
        child: ListView.builder(
          padding: EdgeInsets.only(bottom: 30, top: 8),
          itemBuilder: (_, i) => Container(
            margin: EdgeInsets.all(8),
            padding: EdgeInsets.all(8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 150.0, width: 150, color: Colors.white30).cornerRadiusWithClipRRect(8),
                8.width,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(height: 20, color: Colors.white30).cornerRadiusWithClipRRect(4),
                    8.height,
                    Container(height: 10, color: Colors.white30).cornerRadiusWithClipRRect(4),
                    4.height,
                    Container(height: 10, color: Colors.white30).cornerRadiusWithClipRRect(4),
                    4.height,
                    Container(height: 10, color: Colors.white30).cornerRadiusWithClipRRect(4),
                    4.height,
                    Container(height: 10, color: Colors.white30).cornerRadiusWithClipRRect(4),
                    4.height,
                    Container(height: 10, color: Colors.white30).cornerRadiusWithClipRRect(4),
                    8.height,
                    Align(child: Container(height: 20, width: 50, color: Colors.white30).cornerRadiusWithClipRRect(4), alignment: Alignment.centerRight),
                  ],
                ).expand(flex: 7),
              ],
            ),
          ),
          itemCount: 5,
        ),
        baseColor: Colors.grey,
        highlightColor: Colors.black12,
        enabled: true,
        direction: ShimmerDirection.ltr,
        period: Duration(seconds: 1),
      ),
    );
  }
}
