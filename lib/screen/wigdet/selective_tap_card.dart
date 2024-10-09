import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class SelectiveTapCard extends Card {
  @override
  final Widget myChild;
  final List<GlobalKey> ignoreKeys;
  final VoidCallback onCardTap;

  SelectiveTapCard({
    super.key,
    required this.myChild,
    required this.ignoreKeys,
    required this.onCardTap,
    super.color,
    super.shadowColor,
    super.elevation,
    super.shape,
    super.borderOnForeground = true,
    super.margin,
    super.clipBehavior,
    super.semanticContainer = true,
  }) : super(
          child: _buildCardContent(myChild, ignoreKeys, onCardTap),
        );

  static Widget _buildCardContent(
      Widget child, List<GlobalKey> ignoreKeys, VoidCallback onCardTap) {
    Offset? tapPosition;

    return Stack(
      children: [
        child,
        Positioned.fill(
          // child: Container(
          //   color: Colors.red.withOpacity(0.2),
          // ),
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTapDown: (TapDownDetails details) {
              tapPosition = details.globalPosition; // タップ位置を保存
            },
            onTap: () {
              bool shouldIgnore = false;
              for (final key in ignoreKeys) {
                if (key.currentContext != null) {
                  final RenderBox box =
                      key.currentContext!.findRenderObject() as RenderBox;
                  final Offset localPosition = box.globalToLocal(tapPosition!);
                  if (box.hitTest(BoxHitTestResult(),
                      position: localPosition)) {
                    shouldIgnore = true;

                    // ウィジェットの State にアクセス
                    final w = key.currentWidget;
                    if (w is ElevatedButton) {
                      // onTapがnullでない場合にのみ呼び出す
                      w.onPressed?.call();
                    }
                    break;
                  }
                }
              }
              if (!shouldIgnore) {
                onCardTap();
              }
            },
          ),
        ),
      ],
    );
  }
}
