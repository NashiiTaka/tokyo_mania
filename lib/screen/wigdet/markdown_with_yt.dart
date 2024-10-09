import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:tokyo_mania/util/supabase_util.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart' as yt;
import 'package:youtube_player_iframe/youtube_player_iframe.dart' as yi;

class CustomMarkdownWidget extends StatelessWidget {
  final String data;
  final ScrollController? controller;

  const CustomMarkdownWidget({super.key, required this.data, this.controller});

  @override
  Widget build(BuildContext context) {
    return Markdown(
      data: data,
      controller: controller,
      extensionSet: md.ExtensionSet([
        const md.FencedCodeBlockSyntax(),
      ], [
        ...md.ExtensionSet.commonMark.inlineSyntaxes,
        YouTubeSyntax(),
      ]),
      builders: {
        'youtube': YouTubeBuilder(context: context),
        'h1': CenteredH1Builder(fontSize: 22),
      },
      onTapLink: (text, href, title) {
        if (href != null) {
          launchUrl(Uri.parse(href));
        }
      },
      styleSheet: MarkdownStyleSheet(
          a: const TextStyle(color: Colors.blue),
          p: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }
}

class YouTubeSyntax extends md.InlineSyntax {
  YouTubeSyntax()
      : super(
            r'\[youtube\]\((https?:\/\/www\.youtube\.com\/watch\?v=[\w-&=]+)\)');

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    final url = match[1]!;
    final element = md.Element.text('youtube', url);
    parser.addNode(element);
    return true;
  }
}

class YouTubeBuilder extends MarkdownElementBuilder {
  final BuildContext context;
  // late yt.YoutubePlayerController controller;
  // late yt.YoutubePlayer player;
  bool isFullScreen = false;

  YouTubeBuilder({required this.context}) {
    // controller = yt.YoutubePlayerController(
    //   initialVideoId: '', // 初期化は空にしておきます
    //   flags: const yt.YoutubePlayerFlags(autoPlay: false),
    // );

    // player = yt.YoutubePlayer(
    //   controller: controller,
    //   showVideoProgressIndicator: true,
    // );
  }

  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final url = element.textContent;
    final videoId = yt.YoutubePlayer.convertUrlToId(url);
    if (videoId == null) return null;

    // If the requirement is just to play a single video.
    final yiController = yi.YoutubePlayerController.fromVideoId(
      videoId: videoId,
      autoPlay: false,
      params: const yi.YoutubePlayerParams(
        showFullscreenButton: true,
        mute: false,
        showControls: true,
      ),
    );

    final yts = yi.YoutubePlayerScaffold(
      controller: yiController,
      aspectRatio: 16 / 9,
      builder: (context, player) {
        return Column(
          children: [
            player,
          ],
        );
      },
    );

    yiController.setFullScreenListener((isFullScreen) {
      if (isFullScreen) {
        
      }
    });
    return null;

    // yiController.setFullScreenListener((isFullScreen) {
    //   print('isFullScreen: $isFullScreen');

    //   if (isFullScreen) {
    //     // If the requirement is just to play a single video.
    //     final yiController2 = yi.YoutubePlayerController.fromVideoId(
    //       videoId: videoId,
    //       autoPlay: false,
    //       params: const yi.YoutubePlayerParams(
    //         showFullscreenButton: true,
    //         mute: false,
    //         showControls: true,
    //       ),
    //     );

    //     yiController2.setFullScreenListener((isFullScreen) {
    //       print('isFullScreen: $isFullScreen');
    //       if (!isFullScreen) {
    //         Navigator.pop(context);
    //       }
    //     });

    //     Navigator.push(
    //       context,
    //       MaterialPageRoute(builder: (context) {
    //         return yi.YoutubePlayerScaffold(
    //           controller: yiController2,
    //           aspectRatio: 16 / 9,
    //           builder: (context, player) {
    //             return Column(
    //               children: [
    //                 player,
    //               ],
    //             );
    //           },
    //         );
    //       }),
    //     );
    //   }
    // });

    // return yts;

    // final controller = yt.YoutubePlayerController(
    //   initialVideoId: videoId,
    //   flags: const yt.YoutubePlayerFlags(autoPlay: false),
    // );

    // final player = yt.YoutubePlayer(
    //     controller: controller,
    //     showVideoProgressIndicator: true,
    //   );

    // return yt.YoutubePlayerBuilder(
    //   player: player,
    //   builder: (context, player) {
    //     return Column(
    //       children: [
    //         player,
    //       ],
    //     );
    //   },
    //   onEnterFullScreen: () {
    //     if (!isFullScreen) {
    //       isFullScreen = true;
    //       Navigator.push(
    //         context,
    //         MaterialPageRoute(builder: (context) {
    //           return yt.YoutubePlayerBuilder(
    //             player: player,
    //             builder: (context, player) {
    //               return Column(
    //                 children: [
    //                   player,
    //                 ],
    //               );
    //             },
    //             onExitFullScreen: () {
    //               if (isFullScreen) {
    //                 Navigator.pop(context);
    //                 isFullScreen = false;
    //               }
    //             },
    //           );
    //         }),
    //       );
    //     }
    //   },
    // );
  }
}

class CenteredH1Builder extends MarkdownElementBuilder {
  final double fontSize;
  final FontWeight fontWeight;

  CenteredH1Builder({
    this.fontSize = 24.0,
    this.fontWeight = FontWeight.bold,
  });

  @override
  Widget visitText(md.Text text, TextStyle? preferredStyle) {
    return Center(
      child: Text(
        text.text,
        style: preferredStyle?.copyWith(
          fontSize: fontSize,
          fontWeight: fontWeight,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

// 使用例
class MarkdownExample extends StatelessWidget {
  const MarkdownExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Markdown Example')),
      body: FutureBuilder(
        future: SupabaseUtil.getPublicUrl('meiji_jingu/kiku_gomon.png'),
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // データ読み込み中
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            // エラーが発生した場合
            return Text('Error: ${snapshot.error}');
          } else {
            print(snapshot.data);
            // データが読み込まれた場合
            return CustomMarkdownWidget(
              data: '''
# Welcome to Flutter Markdown

Here's an image:


![神明鳥居](https://otent-nankai.jp/system/upload/basic/2023/02/shrine-torii-gate/shrine-torii-gate003.jpg)
![菊の御紋](${snapshot.data})

And here's a YouTube video:

[youtube](https://www.youtube.com/watch?v=dQw4w9WgXcQ)
''',
            );
          }
        },
      ),
    );
  }
}
