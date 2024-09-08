// https://blog.pentagon.tokyo/2007/
// https://pub.dev/packages/sliding_up_panel
// バージョン違いで元コードから修正が必要

import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

// void main() => runApp(SlidingUpPanelExample());

class SlidingUpPanelExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.grey[200],
      systemNavigationBarIconBrightness: Brightness.dark,
      systemNavigationBarDividerColor: Colors.black,
    ));

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SlidingUpPanel Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final double _initFabHeight = 120.0;
  double _fabHeight = 0;
  double _panelHeightOpen = 0;
  final double _panelHeightClosed = 95.0;

  @override
  void initState() {
    super.initState();

    _fabHeight = _initFabHeight;
  }

  @override
  Widget build(BuildContext context) {
    // パネルの高さを画面の高さの80%に設定
    _panelHeightOpen = MediaQuery.of(context).size.height * .80;

    return Material( // マテリアルデザインのスタイルを適用するためのウィジェットを提供します https://chatgpt.com/share/f811d628-0eb4-4b76-b551-3332dd996065
      child: Stack( // ウィジェットを重ねて配置する https://chatgpt.com/share/2ce55e74-f823-4c9f-9413-fd9c1e113b11
        alignment: Alignment.topCenter, // 子ウィジェットをStackの上端中央に配置することを意味します。
        children: <Widget>[
          // SlidingUpPanelウィジェットを表示
          SlidingUpPanel(
            maxHeight: _panelHeightOpen, // パネルの最大高さを設定
            minHeight: _panelHeightClosed, // パネルの最小高さを設定
            parallaxEnabled: true, // パララックス効果を有効にする + パララックス効果とは、異なるオブジェクトが異なる速度で移動することで、深さや距離感を生み出す視覚的効果です。通常、背景と前景の要素が異なる速度で動くことで、より立体的な感じを演出します。
            parallaxOffset: .5, // パララックス効果のオフセットを設定
            body: _body(), // パネルの下部に表示するコンテンツ
            panelBuilder: (sc) => _panel(sc), // パネルのビルダー関数
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(18.0), // パネルの左上の角を丸める
              topRight: Radius.circular(18.0), // パネルの右上の角を丸める
            ),
            onPanelSlide: (double pos) => setState(() {
              // パネルがスライドする際にFABの高さを更新
              // posは、最大高を1、最小高を0として、その間の値を取る
              // つまり、pos*(opne - closed)は現在のスライディングパネルの上端のheightを表し、
              // それに対して、初期のFABの高さ(上端からのマージン)を足すことで、FABの高さを更新している
              _fabHeight = pos * (_panelHeightOpen - _panelHeightClosed) +
                  _initFabHeight;
            }),
          ),

          // 現在地を中央にボタン、FloatingActionButton (FAB) を表示
          Positioned(
            right: 20.0, // 右から20の位置
            bottom: _fabHeight, // FABの下からの距離を設定
            child: FloatingActionButton(
              onPressed: () {}, // FABが押されたときの処理 (現在は空)
              backgroundColor: Colors.white, // FABの背景色を白に設定
              child: Icon(
                Icons.gps_fixed, // マップの中央を現在地にするボタン
                color:
                    Theme.of(context).primaryColor, // アイコンの色をテーマのプライマリーカラーに設定
              ),
            ),
          ),

          // 画面のトップにぼかし効果を適用
          Positioned(
            top: 0,
            child: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // ぼかし効果の設定
                child: Container(
                  width: MediaQuery.of(context).size.width, // 画面の幅に合わせる
                  height: MediaQuery.of(context).padding.top, // ステータスバーの高さに合わせる
                  color: Colors.transparent, // 背景色を透明に設定
                ),
              ),
            ),
          ),

          // SlidingUpPanelのタイトルを表示
          Positioned(
            top: 52.0, // 上から52の位置に配置
            child: Container(
              padding:
                  const EdgeInsets.fromLTRB(24.0, 18.0, 24.0, 18.0), // パディングを設定
              decoration: BoxDecoration(
                color: Colors.white, // 背景色を白に設定
                borderRadius: BorderRadius.circular(24.0), // 角を丸める
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, .25), // 影の色と透明度
                    blurRadius: 16.0, // ぼかし半径を設定
                  ),
                ],
              ),
              child: const Text(
                "SlidingUpPanel Example",
                style: TextStyle(fontWeight: FontWeight.w500), // フォントのスタイルを設定
              ),
            ),
          ),
        ],
      ),
    );
  }

  // パネル側のWidget
  Widget _panel(ScrollController sc) {
    return MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: ListView(
          controller: sc,
          children: <Widget>[
            SizedBox(
              height: 12.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: 30,
                  height: 5,
                  decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.all(Radius.circular(12.0))),
                ),
              ],
            ),
            SizedBox(
              height: 18.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  "Explore Pittsburgh",
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 24.0,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 36.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                _button("Popular", Icons.favorite, Colors.blue),
                _button("Food", Icons.restaurant, Colors.red),
                _button("Events", Icons.event, Colors.amber),
                _button("More", Icons.more_horiz, Colors.green),
              ],
            ),
            SizedBox(
              height: 36.0,
            ),
            Container(
              padding: const EdgeInsets.only(left: 24.0, right: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text("Images",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      )),
                  SizedBox(
                    height: 12.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      CachedNetworkImage(
                        imageUrl:
                            "https://images.fineartamerica.com/images-medium-large-5/new-pittsburgh-emmanuel-panagiotakis.jpg",
                        height: 120.0,
                        width: (MediaQuery.of(context).size.width - 48) / 2 - 2,
                        fit: BoxFit.cover,
                      ),
                      CachedNetworkImage(
                        imageUrl:
                            "https://cdn.pixabay.com/photo/2016/08/11/23/48/pnc-park-1587285_1280.jpg",
                        width: (MediaQuery.of(context).size.width - 48) / 2 - 2,
                        height: 120.0,
                        fit: BoxFit.cover,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 36.0,
            ),
            Container(
              padding: const EdgeInsets.only(left: 24.0, right: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text("About",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      )),
                  SizedBox(
                    height: 12.0,
                  ),
                  Text(
                    """（中略） """,
                    softWrap: true,
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 24,
            ),
          ],
        ));
  }

  Widget _button(String label, IconData icon, Color color) {
    return Column(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(16.0),
          child: Icon(
            icon,
            color: Colors.white,
          ),
          decoration:
              BoxDecoration(color: color, shape: BoxShape.circle, boxShadow: [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.15),
              blurRadius: 8.0,
            )
          ]),
        ),
        SizedBox(
          height: 12.0,
        ),
        Text(label),
      ],
    );
  }

  // パネル裏のマップを表示するWidget
  Widget _body() {
    return FlutterMap(
      options: MapOptions(
        center: LatLng(40.441589, -80.010948),
        zoom: 13,
        maxZoom: 15,
      ),
      // 新コード
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
        ),
        MarkerLayer(markers: [
          Marker(
            point: LatLng(40.441753, -80.011476),
            builder: (ctx) => Icon(
              Icons.location_on,
              color: Colors.blue,
              size: 48.0,
            ),
            height: 60,
          ),
        ]),
      ],
      // 元コード
      // layers: [
      //   TileLayerOptions(
      //       urlTemplate: "https://maps.wikimedia.org/osm-intl/{z}/{x}/{y}.png"),
      //   MarkerLayerOptions(markers: [
      //     Marker(
      //       point: LatLng(40.441753, -80.011476),
      //       builder: (ctx) => Icon(
      //         Icons.location_on,
      //         color: Colors.blue,
      //         size: 48.0,
      //       ),
      //       height: 60,
      //     ),
      //   ]),
      // ],
    );
  }
}
