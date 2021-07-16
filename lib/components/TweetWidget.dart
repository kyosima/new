import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:nb_utils/nb_utils.dart';
import 'package:news_flutter/Utils/Common.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PlatformViewVerticalGestureRecognizer extends VerticalDragGestureRecognizer {
  PlatformViewVerticalGestureRecognizer({PointerDeviceKind? kind}) : super(kind: kind);

  Offset _dragDistance = Offset.zero;

  @override
  void addPointer(PointerEvent event) {
    startTrackingPointer(event.pointer);
  }

  @override
  void handleEvent(PointerEvent event) {
    _dragDistance = _dragDistance + event.delta;
    if (event is PointerMoveEvent) {
      final double dy = _dragDistance.dy.abs();
      final double dx = _dragDistance.dx.abs();

      if (dy > dx && dy > kTouchSlop) {
        // vertical drag - accept
        resolve(GestureDisposition.accepted);
        _dragDistance = Offset.zero;
      } else if (dx > kTouchSlop && dx > dy) {
        resolve(GestureDisposition.accepted);
        // horizontal drag - stop tracking
        stopTrackingPointer(event.pointer);
        _dragDistance = Offset.zero;
      }
    }
  }

  @override
  String get debugDescription => 'horizontal drag (platform view)';

  @override
  void didStopTrackingLastPointer(int pointer) {}
}

class TweetWebView extends StatefulWidget {
  final String? tweetUrl;

  final String? tweetID;

  TweetWebView({this.tweetUrl, this.tweetID});

  TweetWebView.tweetID(String tweetID)
      : this.tweetID = tweetID,
        this.tweetUrl = null;

  TweetWebView.tweetUrl(String tweetUrl)
      : this.tweetUrl = tweetUrl,
        this.tweetID = null;

  @override
  _TweetWebViewState createState() => new _TweetWebViewState();
}

class _TweetWebViewState extends State<TweetWebView> {
  String? _tweetHTML;

  WebViewController? webViewController;
  double height = 500.0;

  @override
  void initState() {
    super.initState();

    _requestTweet();
  }

  @override
  Widget build(BuildContext context) {
    Widget child;

    if (_tweetHTML != null && _tweetHTML!.length > 0) {
      String downloadUrl = Uri.dataFromString(_tweetHTML!, mimeType: 'text/html', encoding: Encoding.getByName('utf-8')).toString();

      if (!isMobile) return SizedBox();
      // Create the WebView to contain the tweet HTML
      Widget webView = WebView(
        initialUrl: downloadUrl,
        javascriptMode: JavascriptMode.unrestricted,
        gestureRecognizers: {
          Factory<PlatformViewVerticalGestureRecognizer>(
            () => PlatformViewVerticalGestureRecognizer()..onUpdate = (_) {},
          ),
        },
        onWebViewCreated: (c) async {
          webViewController = c;

          try {
            //height = double.parse(await c.evaluateJavascript("document.documentElement.scrollHeight;"));
          } on Exception catch (e) {
            log(e);
            height = 500.0;
          }

          setState(() {});
        },
      );

      child = LimitedBox(
        maxHeight: height,
        child: Stack(
          children: [
            webView,
            Container().onTap(() {
              launchUrl(widget.tweetUrl!, forceWebView: true);
            }),
          ],
        ),
      );
    } else {
      child = Text('Loading...', style: primaryTextStyle());
    }

    return Container(child: child);
  }

  /// Download the embedded tweet.
  /// See Twitter docs: https://developer.twitter.com/en/docs/twitter-for-websites/embedded-tweets/overview
  void _requestTweet() async {
    String? tweetUrl = widget.tweetUrl;
    String? tweetID;

    if (tweetUrl == null || tweetUrl.isEmpty) {
      if (widget.tweetID == null || widget.tweetID!.isEmpty) {
        throw new ArgumentError('Missing tweetUrl or tweetID property.');
      }
      tweetUrl = _formTweetURL(widget.tweetID);
      tweetID = widget.tweetID;
    }

    if (tweetID == null) {
      //tweetID = _tweetIDFromUrl(tweetUrl);
    }

    // Example: https://publish.twitter.com/oembed?url=https://twitter.com/Interior/status/463440424141459456
    final downloadUrl = "https://publish.twitter.com/oembed?url=$tweetUrl";
    print("TweetWebView._requestTweet: $downloadUrl");

    final jsonString = await _loadTweet(downloadUrl);
    final html = _parseTweet(jsonString);
    if (html != null) {
      setState(() {
        _tweetHTML = html;
      });
    }
  }

  /* String _tweetIDFromUrl(String tweetUrl) {
    final uri = Uri.parse(tweetUrl);
    if (uri.pathSegments.length > 0) {
      return uri.pathSegments[uri.pathSegments.length - 1];
    }
    return null;
  }*/

  String _formTweetURL(String? tweetID) {
    return "https://twitter.com/Interior/status/$tweetID";
  }

  /*Future<String> _saveTweetToFile(String tweetID, String html) async {
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;
    final filename = '$tempPath/tweet-$tweetID.html';
    File(filename).writeAsString(html);
    return filename;
  }*/

  String? _parseTweet(String jsonString) {
    if (jsonString.isEmpty) {
      print('TweetWebView._parseTweet: empty jsonString');
      return null;
    }

    var item;
    try {
      item = json.decode(jsonString);
    } catch (e) {
      print(e);
      print('error parsing tweet json: $jsonString');
      return '<p>error loading tweet</p>';
    }

    final String? html = item['html'];

    if (html == null || html.isEmpty) {
      print('TweetWebView._parseTweet: empty html');
    }

    return html;
  }

  Future<String> _loadTweet(String tweetUrl) async {
    http.Response result = await _downloadTweet(tweetUrl);

    return result.body;
  }

  Future<http.Response> _downloadTweet(String tweetUrl) {
    return http.get(Uri.parse(tweetUrl));
  }
}
