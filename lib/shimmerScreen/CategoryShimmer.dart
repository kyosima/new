import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:shimmer/shimmer.dart';

class CategoryShimmer extends StatefulWidget {
  static String tag = '/CategoryShimmer';

  @override
  CategoryShimmerState createState() => CategoryShimmerState();
}

class CategoryShimmerState extends State<CategoryShimmer> {
  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    //
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Shimmer.fromColors(
        child: ListView.builder(
          padding: EdgeInsets.only(bottom: 30, top: 8),
          itemBuilder: (_, i) => Container(
            margin: EdgeInsets.only(left: 8, right: 8),
            padding: EdgeInsets.all(8),
            child: Container(
              height: 100,
              width: context.width(),
              color: Colors.white30,
              child: Stack(
                alignment: Alignment.centerLeft,
                children: [
                  Row(
                    children: [
                      16.width,
                      Container(width: 50, height: 1, color: Colors.white30),
                      16.width,
                      Container(width: 100, height: 24, color: Colors.white30),
                    ],
                  ),
                ],
              ),
            ).cornerRadiusWithClipRRect(8),
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
