import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/html_parser.dart';
import 'package:flutter_html/style.dart';
import 'package:html/dom.dart' as dom;
import 'package:nb_utils/nb_utils.dart';
import 'package:news_flutter/Model/PostModel.dart';
import 'package:news_flutter/Screens/NewsDetailScreen.dart';
import 'package:news_flutter/Screens/ZoomImageScreen.dart';
import 'package:news_flutter/Utils/Colors.dart';
import 'package:news_flutter/Utils/constant.dart';
import 'package:news_flutter/components/TweetWidget.dart';
import 'package:news_flutter/components/VimeoEmbedWidget.dart';
import 'package:news_flutter/components/YouTubeEmbedWidget.dart';
import 'package:share/share.dart';

import 'Common.dart';
import 'Images.dart';
import 'Strings.dart';

void onShareTap(BuildContext context) async {
  final RenderBox box = context.findRenderObject() as RenderBox;
  Share.share('My App Name', subject: 'Share $App_Name App', sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
}

BoxDecoration boxDecoration(BuildContext context, {double radius = 1.0, Color color = Colors.transparent, Color? bgColor = white_color, double borderWidth = 0.0, Color shadowColor = shadow_color, var showShadow = false}) {
  return BoxDecoration(
      color: bgColor == white_color ? Theme.of(context).cardTheme.color : bgColor,
      //gradient: LinearGradient(colors: [bgColor, whiteColor]),
      boxShadow: showShadow ? [BoxShadow(color: Theme.of(context).hoverColor.withOpacity(0.2), blurRadius: 10, spreadRadius: 3)] : [BoxShadow(color: Colors.transparent)],
      border: Border.all(color: color, width: borderWidth),
      borderRadius: BorderRadius.all(Radius.circular(radius)));
}

// ignore: must_be_immutable
class EditText extends StatefulWidget {
  var isPassword;
  var isSecure;
  int fontSize;
  Color? textColor;
  var fontFamily;
  var iconName;
  var text;
  var maxLine;
  var hintText;
  Color? underLineColor;
  bool enabled;
  TextEditingController? mController;

  VoidCallback? onPressed;

  EditText(
      {var this.fontSize = textSizeMedium,
      var this.textColor = textColorSecondary,
      var this.isPassword = true,
      var this.isSecure = false,
      var this.text = "",
      var this.mController,
      var this.maxLine = 1,
      var this.iconName = '',
      var this.hintText = '',
      var this.enabled = true,
      this.underLineColor = Colors.black12});

  @override
  State<StatefulWidget> createState() {
    return EditTextState();
  }
}

class EditTextState extends State<EditText> {
  @override
  Widget build(BuildContext context) {
    if (!widget.isSecure) {
      return TextFormField(
        controller: widget.mController,
        obscureText: widget.isPassword,
        cursorColor: primaryColor,
        maxLines: widget.maxLine,
        enabled: widget.enabled,
        style: TextStyle(fontSize: widget.fontSize.toDouble(), color: widget.textColor),
        decoration: InputDecoration(
          hintText: widget.hintText,
          prefixIcon: Icon(
            widget.iconName,
            size: 30,
            color: textColorSecondary,
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: widget.enabled ? widget.underLineColor! : widget.underLineColor!),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: primaryColor),
          ),
        ),
      );
    } else {
      return TextFormField(
        controller: widget.mController,
        obscureText: widget.isPassword,
        cursorColor: primaryColor,
        enabled: widget.enabled,
        style: TextStyle(color: widget.textColor, fontSize: widget.fontSize.toDouble()),
        decoration: InputDecoration(
          suffixIcon: GestureDetector(
            onTap: () {
              setState(() {
                widget.isPassword = !widget.isPassword;
              });
            },
            child: Icon(
              widget.isPassword ? Icons.visibility_off : Icons.visibility,
              color: primaryColor,
            ),
          ),
          prefixIcon: Icon(
            widget.iconName,
            size: 30,
            color: textColorSecondary,
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: widget.enabled ? widget.underLineColor! : widget.underLineColor!),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: primaryColor),
          ),
        ),
        autofocus: false,
      );
    }
  }

  State<StatefulWidget>? createState() {
    return null;
  }
}

// ignore: must_be_immutable
class NewsButton extends StatefulWidget {
  static String tag = '/NewsButton';
  var textContent;
  VoidCallback onPressed;
  var isStroked = false;
  double height = 50.0;
  double? width;
  Color backGroundColor;

  NewsButton({required this.textContent, required this.onPressed, this.isStroked = false, this.height = 45.0, this.backGroundColor = primaryColor});

  @override
  NewsButtonState createState() => NewsButtonState();
}

class NewsButtonState extends State<NewsButton> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onPressed,
      child: Container(
        height: widget.height,
        width: widget.width,
        padding: EdgeInsets.fromLTRB(16, 4, 16, 4),
        alignment: Alignment.center,
        child: FittedBox(
          child: Text(
            widget.textContent,
            textAlign: TextAlign.center,
            style: primaryTextStyle(color: white_color, size: textSizeLargeMedium),
          ),
        ),
        decoration: widget.isStroked ? boxDecoration(context, bgColor: Colors.transparent, color: widget.backGroundColor) : boxDecoration(context, bgColor: widget.backGroundColor, radius: 4),
      ),
    );
  }
}

Container editText1(BuildContext context, var hintText, {TextEditingController? controller, isPassword = false}) {
  return Container(
    decoration: boxDecoration(context, radius: 0.0, showShadow: true, bgColor: white_color),
    child: TextFormField(
      style: TextStyle(color: textColorPrimary, fontSize: textSizeMedium.toDouble()),
      obscureText: isPassword,
      controller: controller,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.fromLTRB(24, 18, 24, 18),
        hintText: hintText,
        filled: true,
        fillColor: white_color,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(40),
          borderSide: const BorderSide(color: white_color, width: 0.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(40),
          borderSide: const BorderSide(color: white_color, width: 0.0),
        ),
      ),
    ),
  );
}

enum ConfirmAction { CANCEL, ACCEPT }

Future<ConfirmAction?> showConfirmDialogs(context, msg, positiveText, negativeText) async {
  return showDialog<ConfirmAction>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(msg, style: primaryTextStyle(color: Theme.of(context).textTheme.headline6!.color)),
        actions: <Widget>[
          TextButton(
            child: Text(negativeText, style: primaryTextStyle(color: Theme.of(context).textTheme.headline6!.color)),
            onPressed: () {
              Navigator.of(context).pop(ConfirmAction.CANCEL);
            },
          ),
          TextButton(
            child: Text(positiveText, style: primaryTextStyle(color: Theme.of(context).textTheme.headline6!.color)),
            onPressed: () {
              Navigator.of(context).pop(ConfirmAction.ACCEPT);
            },
          )
        ],
      );
    },
  );
}

Widget getLoadingProgress(loadingProgress) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Center(
      child: CircularProgressIndicator(
        value: loadingProgress.expectedTotalBytes != null ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes : null,
      ),
    ),
  );
}

class FutureWidget<T> extends StatefulWidget {
  static String tag = '/Future';
  final Future<T> future;
  final Widget child;

  FutureWidget({required this.future, required this.child});

  @override
  FutureWidgetState createState() => FutureWidgetState();
}

class FutureWidgetState<T> extends State<FutureWidget> {
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
    return FutureBuilder<T>(
      builder: (_, snap) {
        if (snap.hasData) {
          return widget.child;
        }
        return SizedBox();
      },
      future: widget.future as Future<T>?,
    );
  }
}

Widget placeHolderWidget({double? height, double? width, BoxFit? fit, AlignmentGeometry? alignment, double? radius}) {
  return Image.asset(greyImage, height: height, width: width, fit: fit ?? BoxFit.cover, alignment: alignment ?? Alignment.center).cornerRadiusWithClipRRect(radius ?? defaultRadius);
}

Widget cachedImage(String url, {double? height, double? width, BoxFit? fit, AlignmentGeometry? alignment, bool usePlaceholderIfUrlEmpty = true, double? radius}) {
  if (url.validate().isEmpty) {
    return placeHolderWidget(height: height, width: width, fit: fit, alignment: alignment, radius: radius);
  } else if (url.validate().startsWith('http')) {
    return CachedNetworkImage(
      imageUrl: url,
      height: height,
      width: width,
      fit: fit,
      alignment: alignment as Alignment? ?? Alignment.center,
      errorWidget: (_, s, d) {
        return placeHolderWidget(height: height, width: width, fit: fit, alignment: alignment, radius: radius);
      },
      placeholder: (_, s) {
        if (!usePlaceholderIfUrlEmpty) return SizedBox();
        return placeHolderWidget(height: height, width: width, fit: fit, alignment: alignment, radius: radius);
      },
    );
  } else {
    return Image.asset(url, height: height, width: width, fit: fit, alignment: alignment ?? Alignment.center).cornerRadiusWithClipRRect(radius ?? defaultRadius);
  }
}

Widget buildContent(BuildContext context, {required PostModel post, int fontSize = 18}) {
  PostType postType = PostType.HTML;
  String postContent = '';

  postContent = post.postContent
      .validate()
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&quot;', '"')
      .replaceAll('[embed]', '<embed>')
      .replaceAll('[/embed]', '</embed>')
      .replaceAll('[caption]', '<caption>')
      .replaceAll('[blockquote]', '<blockquote>')
      .replaceAll('[/blockquote]', '</blockquote>')
      .replaceAll('[/caption]', '</caption>');

  if (postContent.contains('<script')) {
    String start = postContent.splitBefore('<script');
    String end = postContent.splitAfter('</script>');

    postContent = start + end;
  }
  if (postContent.contains('<blockquote')) {
    String start = postContent.splitBefore('<blockquote');
    String end = postContent.splitAfter('</blockquote>');

    postContent = start + end;
  }
  /*if (post.postContent!.contains("div").validate() || post.postContent!.contains("ol").validate() || post.postContent!.contains("html").validate() || post.postContent!.contains("wp:paragraph").validate()) {
    postType = PostType.HTML;
  } else if (post.postContent!.contains('&lt;').validate() || post.postContent!.contains("&gt").validate() || post.postContent!.contains("&quot").validate()) {
    //postType = PostType.WordPress;
  } else {
    postType = PostType.String;
  }*/

  /*if (postType == PostType.WordPress) {
    return WPContent(
      postContent.validate().replaceAll('&lt;', '<').replaceAll('&gt;', '>').replaceAll('&quot;', '"'),
      fontSize: fontSize.toDouble(),
      youtubeEmbedWidget: YouTubeEmbedWidgets(),
      soundcloudEmbedWidget: SoundCloudEmbedWidget('', ''),
      issuuEmbedWidget: IssueEmbedWidget(),
      hearthisAtWidget: HearthisAtEmbedWidget('', ''),
      jwPlayerWidget: JWPlayerEmbedWidget(),
    );
  } else*/
  if (postType == PostType.HTML) {
    return Html(
      data: postContent,
      onLinkTap: (String? url, RenderContext context, Map<String, String> attributes, dom.Element? element) {
        launchUrl(url!);
      },
      onImageTap: (String? url, RenderContext context, Map<String, String> attributes, dom.Element? element) async {
        ZoomImageScreen(mProductImage: url).launch(context.buildContext);
      },

      style: {
        'embed': Style(color: transparentColor, fontStyle: FontStyle.italic, fontWeight: FontWeight.bold, fontSize: FontSize(getIntAsync(FONT_SIZE, defaultValue: 16).toDouble())),
        'strong': Style(color: textPrimaryColorGlobal, fontSize: FontSize(getIntAsync(FONT_SIZE, defaultValue: 16).toDouble())),
        'a': Style(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: FontSize(getIntAsync(FONT_SIZE, defaultValue: 16).toDouble())),
        'div': Style(color: textPrimaryColorGlobal, fontSize: FontSize(getIntAsync(FONT_SIZE, defaultValue: 16).toDouble())),
        'figure': Style(color: textPrimaryColorGlobal, fontSize: FontSize(getIntAsync(FONT_SIZE, defaultValue: 16).toDouble()), margin: EdgeInsets.zero, padding: EdgeInsets.zero),
        'h1': Style(color: textPrimaryColorGlobal, fontSize: FontSize(getIntAsync(FONT_SIZE, defaultValue: 16).toDouble())),
        'h2': Style(color: textPrimaryColorGlobal, fontSize: FontSize(getIntAsync(FONT_SIZE, defaultValue: 16).toDouble())),
        'h3': Style(color: textPrimaryColorGlobal, fontSize: FontSize(getIntAsync(FONT_SIZE, defaultValue: 16).toDouble())),
        'h4': Style(color: textPrimaryColorGlobal, fontSize: FontSize(getIntAsync(FONT_SIZE, defaultValue: 16).toDouble())),
        'h5': Style(color: textPrimaryColorGlobal, fontSize: FontSize(getIntAsync(FONT_SIZE, defaultValue: 16).toDouble())),
        'h6': Style(color: textPrimaryColorGlobal, fontSize: FontSize(getIntAsync(FONT_SIZE, defaultValue: 16).toDouble())),
        'ol': Style(color: textPrimaryColorGlobal, fontSize: FontSize(getIntAsync(FONT_SIZE, defaultValue: 16).toDouble())),
        'ul': Style(color: textPrimaryColorGlobal, fontSize: FontSize(getIntAsync(FONT_SIZE, defaultValue: 16).toDouble())),
        'strike': Style(color: textPrimaryColorGlobal, fontSize: FontSize(getIntAsync(FONT_SIZE, defaultValue: 16).toDouble())),
        'u': Style(color: textPrimaryColorGlobal, fontSize: FontSize(getIntAsync(FONT_SIZE, defaultValue: 16).toDouble())),
        'b': Style(color: textPrimaryColorGlobal, fontSize: FontSize(getIntAsync(FONT_SIZE, defaultValue: 16).toDouble())),
        'i': Style(color: textPrimaryColorGlobal, fontSize: FontSize(getIntAsync(FONT_SIZE, defaultValue: 16).toDouble())),
        'hr': Style(color: textPrimaryColorGlobal, fontSize: FontSize(getIntAsync(FONT_SIZE, defaultValue: 16).toDouble())),
        'header': Style(color: textPrimaryColorGlobal, fontSize: FontSize(getIntAsync(FONT_SIZE, defaultValue: 16).toDouble())),
        'code': Style(color: textPrimaryColorGlobal, fontSize: FontSize(getIntAsync(FONT_SIZE, defaultValue: 16).toDouble())),
        'data': Style(color: textPrimaryColorGlobal, fontSize: FontSize(getIntAsync(FONT_SIZE, defaultValue: 16).toDouble())),
        'body': Style(color: textPrimaryColorGlobal, fontSize: FontSize(getIntAsync(FONT_SIZE, defaultValue: 16).toDouble())),
        'big': Style(color: textPrimaryColorGlobal, fontSize: FontSize(getIntAsync(FONT_SIZE, defaultValue: 16).toDouble())),
        'audio': Style(color: textPrimaryColorGlobal, fontSize: FontSize(getIntAsync(FONT_SIZE, defaultValue: 16).toDouble())),
        'img': Style(width: context.width(), padding: EdgeInsets.only(bottom: 8), fontSize: FontSize(getIntAsync(FONT_SIZE, defaultValue: 16).toDouble())),
        // 'blockquote': Style(width: context.width(), padding: EdgeInsets.only(bottom: 8), fontSize: FontSize(getIntAsync(FONT_SIZE, defaultValue: 16).toDouble())),
      },
      customRender: {
        // "blockquote": (RenderContext renderContext, Widget child, attributes, _) {
        //   return SizedBox();
        // },
        "embed": (RenderContext renderContext, Widget child, attributes, _) {
          var videoLink = renderContext.parser.htmlData.splitBetween('<embed>', '</embed');

          if (videoLink.contains('yout')) {
            return YouTubeEmbedWidget(videoLink.replaceAll('<br>', '').convertYouTubeUrlToId());
          } else if (videoLink.contains('vimeo')) {
            return VimeoEmbedWidget(videoLink.replaceAll('<br>', ''));
          } else {
            return child;
          }
        },
        "figure": (RenderContext renderContext, Widget child, attributes, _) {
          if (_!.innerHtml.contains('yout')) {
            return YouTubeEmbedWidget(_.innerHtml.splitBetween('<div class="wp-block-embed__wrapper">', "</div>").replaceAll('<br>', '').convertYouTubeUrlToId());
          } else if (_.innerHtml.contains('vimeo')) {
            return VimeoEmbedWidget(_.innerHtml.splitBetween('<div class="wp-block-embed__wrapper">', "</div>").replaceAll('<br>', '').splitAfter('com/'));
          } else if (_.innerHtml.contains('twitter')) {
            String t = _.innerHtml.splitAfter('<div class="wp-block-embed__wrapper">').splitBefore('</div>');
            return TweetWebView.tweetUrl(t);
          } else if (_.innerHtml.contains('audio controls')) {
            return Theme(
              data: ThemeData(),
              child: child,
            );
          } else {
            return child;
          }
        },
      },
    );
  } else {
    return Text(
      postContent.validate(),
      style: primaryTextStyle(color: Theme.of(context).textTheme.headline6!.color, size: fontSize),
    );
  }
}
