import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:news_flutter/Utils/constant.dart';
import 'package:news_flutter/main.dart';
import 'package:news_flutter/videoPlayer/chewie_player.dart';
import 'package:video_player/video_player.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../Utils/Common.dart';

class WebViewScreen extends StatefulWidget {
  final String? title;
  final String? videoUrl;
  final String? videoType;

  @override
  _WebViewScreenState createState() => _WebViewScreenState();

  WebViewScreen({this.title, this.videoUrl, this.videoType});
}

class _WebViewScreenState extends State<WebViewScreen> with AfterLayoutMixin<WebViewScreen> {
  VideoPlayerController? videoPlayerController;

  //YoutubePlayerController youtubeVideoController;
  VideoPlayerController? customController;
  ChewieController? _chewieController;
  double height = 300;
  bool onclickBack = false;

  bool mShowingAppBar = true;
  String url = '';

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    await Future.delayed(Duration(seconds: 2));
    mShowingAppBar = false;
    setState(() {});
  }

  @override
  void afterFirstLayout(BuildContext context) async {
    if (context.width() >= desktopBreakpointGlobal) {
      height = 400;
    }

    setState(() {});
    await Future.delayed(Duration(seconds: 2));
    mShowingAppBar = false;
    setState(() {});

    /*await Future.delayed(Duration(seconds: 4));
    youtubeVideoController.play();*/

    if (widget.videoType.validate() == VideoTypeYouTube) {
      url = widget.videoUrl.validate().convertYouTubeUrlToId();

      //youtubeVideoController = YoutubePlayerController(initialVideoId: url, flags: YoutubePlayerFlags(autoPlay: true));

      //youtubeVideoController.play();
    } else if (widget.videoType.validate() == VideoTypeIFrame) {
      url = widget.videoUrl.validate();

      videoPlayerController = VideoPlayerController.network(url)
        ..initialize().then((_) {
          setState(() {});
        });
      videoPlayerController!.play();
    } else if (widget.videoType.validate() == VideoCustomUrl) {
      url = widget.videoUrl.validate();

      customController = VideoPlayerController.network(url);
      customController!.play();
    } else {
      mShowingAppBar = true;

      url = widget.videoUrl.validate();
    }

    appStore.setLoading(false);
    setState(() {});
  }

  @override
  void dispose() {
    videoPlayerController?.dispose();
    //youtubeVideoController?.dispose();
    customController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget player() {
      if (appStore.isLoading) {
        return CircularProgressIndicator();
      }
      /*else if (youtubeVideoController != null && widget.videoType.validate() == VideoTypeYouTube) {
        log(widget.videoUrl.validate());
        return YouTubeEmbedWidget(widget.videoUrl.validate().convertYouTubeUrlToId()).center();
      }*/
      else if (widget.videoType.validate() == VideoTypeIFrame || widget.videoType.validate() == VideoTypeYouTube) {
        log(widget.videoUrl.validate());
        return InkWell(
          onTap: () {
            launchUrl('https://www.youtube.com/embed/${widget.videoUrl.convertYouTubeUrlToId()}', forceWebView: true);
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              Image.network(widget.videoUrl.getYouTubeThumbnail(), height: 300),
              Icon(Icons.play_circle_outline_rounded, color: Colors.white, size: 50),
            ],
          ),
        );
      } else if (customController != null && widget.videoType.validate() == VideoCustomUrl) {
        log(widget.videoUrl.validate());
        _chewieController = ChewieController(
          videoPlayerController: customController!,
          aspectRatio: 3 / 2,
          autoPlay: true,
          looping: false,
          placeholder: Container(color: Colors.grey),
        );
        return Center(child: Chewie(controller: _chewieController!));
      } else {
        return WebView(initialUrl: widget.videoUrl.validate(), javascriptMode: JavascriptMode.unrestricted);
      }
    }

    return WillPopScope(
      onWillPop: () async {
        SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

        return true;
      },
      child: SafeArea(
        child: Scaffold(
          body: Stack(
            children: [
              Center(child: player()),
              BackButton().paddingAll(8),
            ],
          ),
        ),
      ),
    );
  }
}
