import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class SlidingMarkdownPanel extends StatefulWidget {
  @override
  _SlidingMarkdownPanelState createState() => _SlidingMarkdownPanelState();
}

class _SlidingMarkdownPanelState extends State<SlidingMarkdownPanel> {
  final PanelController _panelController = PanelController();
  final ScrollController _scrollController = ScrollController();

  // 現在スクロールが最上部にあるかを判定
  bool get _isScrollAtTop =>
      _scrollController.hasClients &&
      _scrollController.offset <= _scrollController.position.minScrollExtent;

  @override
  void initState() {
    super.initState();
    // スクロールリスナーを追加（必要に応じて）
    _scrollController.addListener(() {
      setState(() {}); // スクロール位置の変化に応じてUIを更新
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // パネル内のジェスチャーを処理
  void _handleDragUpdate(DragUpdateDetails details) {
    if (details.delta.dy < -10) {
      // ユーザーが上にスワイプ
      if (_isScrollAtTop) {
        _panelController.close(); // パネルを閉じる
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sliding Markdown Panel'),
      ),
      body: Stack(
        children: [
          // メインコンテンツ
          Center(child: Text('Main Content')),
          SlidingUpPanel(
            controller: _panelController,
            minHeight: 100, // パネルの最小高さ
            maxHeight: MediaQuery.of(context).size.height * 0.8, // パネルの最大高さ
            panelBuilder: (ScrollController panelScrollController) {
              return GestureDetector(
                onVerticalDragUpdate: _handleDragUpdate,
                child: Column(
                  children: [
                    // パネル上部のボタン
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: () {
                          // ボタンのアクション
                        },
                        child: Text('Button'),
                      ),
                    ),
                    Flexible(
                      child: NotificationListener<ScrollNotification>(
                        onNotification: (ScrollNotification notification) {
                          // スクロールオーバーの処理
                          return false;
                        },
                        child: SingleChildScrollView(
                          controller: _scrollController,
                          child: Markdown(
                            data: '''
        # サンプルタイトル

        長いMarkdownコンテンツがここに入ります。
        ''',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(24.0)), // パネルの角を丸める
            // パネルのドラッグをカスタマイズ（必要に応じて）
            // その他のプロパティもここで設定可能
          ),
        ],
      ),
    );
  }
}
