import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

class MarkdownLinkExample extends StatelessWidget {
  const MarkdownLinkExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Markdown Link Example')),
      body: Markdown(
        data: '''
# Welcome to Flutter Markdown

This is a [link to Flutter website](https://flutter.dev).

You can also create [internal links](#section1) within your document.

a
a  
a  
aa  
  
aa  
  
a  
a  
a  
a  
a  
a  
a  
a  
a  
a  
a  
a  
a  
a  
a  
a  
a  
a  
  
  
  
a  
a  
a  
a  
a  
a  
a  
a  
  
a  
a  
a  
a  
a  
a  
  
  
  
a  
a  
a  
a  
a  
a  
a  
a  
  
a  
a  
a  
a  
a  
a  
  
  
  
a  
a  
a  
a  
a  
a  
a  
a  
  
a  
a  
a  
a  

## Section 1 {#section1}

This is the content of Section 1.
''',
        onTapLink: (text, href, title) {
          _handleLinkTap(context, text, href, title);
        },
      ),
    );
  }

  void _handleLinkTap(BuildContext context, String text, String? href, String? title) {
    if (href != null) {
      if (href.startsWith('http')) {
        // 外部リンクの場合、URL を開く
        launchUrl(Uri.parse(href));
      } else if (href.startsWith('#')) {
        // 内部リンクの場合、スクロール位置を調整するなどの処理を行う
        // この例では単純に通知を表示
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Internal link to: ${href.substring(1)}')),
        );
      }
    }
  }
}