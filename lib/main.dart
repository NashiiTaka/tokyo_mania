import 'dart:ui';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:tokyo_mania/get_marker_image.dart';
import 'package:tokyo_mania/markdown.dart';
import 'package:tokyo_mania/markdown_with_yt.dart';
import 'package:tokyo_mania/scroll.dart';
import 'package:tokyo_mania/map_route.dart';
import 'package:tokyo_mania/map_route_gpt.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
// import 'package:cached_network_image/cached_network_image.dart';
import 'package:tokyo_mania/src/SupabaseUtil.dart';
import 'package:tokyo_mania/src/features.dart';
import 'package:tokyo_mania/src/explanations.dart';
import 'package:tokyo_mania/src/language_infos.dart';
import 'package:tokyo_mania/src/route.dart';
import 'package:tokyo_mania/youtube.dart';
// import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math' as math;
import 'package:flutter/rendering.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SupabaseUtil.initialize();
  // WidgetsFlutterBinding.ensureInitialized();
  // SystemChrome.setSystemUIOverlayStyle(
  //   const SystemUiOverlayStyle(
  //     statusBarColor: Colors.blueAccent,
  //   ),
  // );
  // runApp(const YoutubePlayerDemoApp());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MapScreen(),
      // home: MarkdownLinkExample(),
      // home: GetMarkerImage()
      // home: SlidingUpPanelExample(),
      // home: MarkdownExample(),
      // home: SlidingMarkdownPanel()
      // home: RouteMapScreen(),
      // home: MapScreenGPT(),
    );
  }
}

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  PanelController _panelController = PanelController();

  /// GoogleMapsのコントローラー
  GoogleMapController? _mapController;

  /// 地図上に表示するマーカー
  final Map<String, Marker> _markers = {};
  final Map<String, dynamic> _remainGuideFeatures = {};
  final Set<Polyline> _polylines = {};
  double _panelHeightOpen = 0;
  final double _panelHeightClosed = 0;
  int _currentFeatureId = 0;
  Language _currentLanguage = Language.JP; // 初期言語
  final FlutterTts _flutterTts = FlutterTts();
  bool _isSoundPlaying = false;
  int _soundPlayingFeatureId = 0;
  Position? _currentPosition;
  bool _centerOnLocation = true;
  StreamSubscription<Position>? _positionStreamSubscription;
  List<Marker> _popupedMarkers = [];

  // 目的地の位置（例：近所の場所）
  final LatLng _destination = LatLng(35.584036, 139.547407);
  // 目的地に到達したかどうかのフラグ

  final GoogleMapsPlaces _googleMapsPlaces =
      GoogleMapsPlaces(apiKey: const String.fromEnvironment('googleMapApiKey'));

  late ScrollController _scrollController;
  bool _canPanelMove = true;

  @override
  void initState() {
    super.initState();
    _addMarkersFromFeatureInfos();

    _getCurrentLocation();
    _startListeningToLocationChanges();

    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);

    // 再生開始時のハンドラー
    _flutterTts.setStartHandler(() {
      setState(() {
        _soundPlayingFeatureId = _currentFeatureId;
        _isSoundPlaying = true;
      });
    });

    // 再生完了時のハンドラー
    _flutterTts.setCompletionHandler(() {
      setState(() {
        _soundPlayingFeatureId = 0;
        _isSoundPlaying = false;
      });
    });

    // エラー時のハンドラー
    _flutterTts.setErrorHandler((msg) {
      setState(() {
        _isSoundPlaying = false;
      });
      showDialog(
          context: context,
          builder: (context) => AlertDialog(content: Text('Error: $msg')));
    });
  }

  void _scrollListener() {
    print(_scrollController.offset);
    if (_scrollController.offset <= 0) {
      setState(() {
        _canPanelMove = true;
      });
    } else {
      setState(() {
        _canPanelMove = false;
      });
    }
  }

  @override
  void dispose() {
    debugPrint('Dispose method called for ${widget.runtimeType}');
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _positionStreamSubscription?.cancel();
    super.dispose();
  }

  void _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are permanently denied
      return;
    }

    Position position = await Geolocator.getCurrentPosition();
    _updatePosition(position);
  }

  void _startListeningToLocationChanges() {
    // https://chatgpt.com/share/f3a83b58-3d9c-4c50-afee-c0125baee1d8
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5,
    );

    _positionStreamSubscription =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen(_updatePosition);
  }

  void _updatePosition(Position position) async {
    setState(() {
      _currentPosition = position;
    });

    if (_centerOnLocation && _mapController != null) {
      final currentZoomLevel = await _mapController!.getZoomLevel();
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(position.latitude, position.longitude),
            zoom: currentZoomLevel,
          ),
        ),
      );
    }

    // 各マーカーとの距離をチェック
    for (dynamic feature in List.from(_remainGuideFeatures.values)) {
      double distanceInMeters = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        feature['Lat-Guide'],
        feature['Lng-Guide'],
      );

      print('Distance to ${feature['FeatureName-JP']}: $distanceInMeters M');

      if (distanceInMeters <= feature['GuideWithinMeters']) {
        // マーカーのonTapイベントを呼び出す
        // _remainGuideFeaturesからの削除処理は、タップイベント内で実施
        _markers[feature['FeatureID'].toString()]!.onTap?.call();
      }
    }
  }

  // Place IDsからマーカーを追加する非同期メソッド
  Future<void> _addMarkersFromFeatureInfos() async {
    var numOfGuidance = 0;
    for (var i = 0; i < features.length; i++) {
      final feature = features[i];
      final myExplanations = explanations
          .where((e) => e['FeatureID'] == feature['FeatureID'])
          .toList();
      feature['explanations'] = myExplanations;

      final containsGuidanceRequired =
          myExplanations.any((e) => e['IsGuidanceRequired'] == 1);

      double? lat;
      double? lng;
      BitmapDescriptor? customIconPre;
      BitmapDescriptor? customIconAft;

      if (!containsGuidanceRequired) {
        customIconPre =
            await _createIcon('assets/images/markers/information.png');
        customIconAft = customIconPre;
      } else {
        numOfGuidance++;
        customIconPre = await _createIcon(
            'assets/images/markers/red${numOfGuidance.toString().padLeft(2, '0')}.png');
        customIconAft = await _createIcon(
            'assets/images/markers/gray${numOfGuidance.toString().padLeft(2, '0')}.png');
      }

      if (feature['Lat-Main'] == '' || feature['Lng-Main'] == '') {
        // Google Maps APIからPlace IDを使って場所の詳細情報を取得
        final placeDetails = await _googleMapsPlaces.getDetailsByPlaceId(
          feature['GoogleMapPlaceID'],
          language: 'ja', // 日本語で詳細情報を取得
        );

        lat = placeDetails.result.geometry!.location.lat; // 緯度を設定
        lng = placeDetails.result.geometry!.location.lng; // 経度を設定

        print(feature['GoogleMapPlaceID'] +
            '\t' +
            lat.toString() +
            '\t' +
            lng.toString());
      } else {
        lat = double.parse(feature['Lat-Main'].toString());
        lng = double.parse(feature['Lng-Main'].toString());
      }

      final featureId = feature['FeatureID'].toString();

      // マーカーを作成し、取得した場所の緯度・経度を設定
      final marker = Marker(
        markerId: MarkerId(
          featureId,
        ), // Place IDをMarker IDとして設定
        position: LatLng(
          lat, // 緯度を設定
          lng, // 経度を設定
        ),
        // infoWindowは表示させない
        // infoWindow: InfoWindow(
        //   title: feature['FeatureName-JP'], // マーカーのタイトルを場所の名前に設定
        // ),
        icon: customIconPre,
        // マーカーがタップされた時の処理
        onTap: () {
          setState(() {
            final tappedMarker = _markers[featureId];
            if (tappedMarker != null && tappedMarker.icon != customIconAft) {
              _markers[featureId] = tappedMarker.copyWith(
                iconParam: customIconAft,
              );
              // 案内予定のマーカーをリストから削除
              _remainGuideFeatures.remove(featureId);
            }
            _currentFeatureId = feature['FeatureID'];
          });

          _panelController.animatePanelToPosition(1);
        },
      );

      // setStateでマーカーリストと、残案内リストに追加し、UIを更新
      setState(() {
        _markers[featureId] = marker; // 新しいマーカーをリストに追加
        _remainGuideFeatures[featureId] = feature;
      });
    }

    setState(() {
      _createPolylines();
    });
  }

  Future<AssetMapBitmap> _createIcon(String path) {
    return BitmapDescriptor.asset(
      const ImageConfiguration(
        size: Size(28, 28),
      ),
      path,
    );
  }

  void _createPolylines() {
    setState(() {
      final List<LatLng> points = [];

      route.forEach((element) {
        points.add(LatLng(element['Lat'], element['Lng']));
      });

      _polylines.add(
        Polyline(
          polylineId: PolylineId('route'),
          color: Colors.blue.withOpacity(0.5),
          width: 5,
          points: points,
        ),
      );
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    if (_currentPosition != null) {
      _updatePosition(_currentPosition!);
    }
  }

  void _onCameraMove(CameraPosition position) {
    // If the map is moved manually, stop centering on location
    _centerOnLocation = false;
  }

  void _onReturnToCurrentLocation() {
    if (_currentPosition != null) {
      _centerOnLocation = true;
      _updatePosition(_currentPosition!);
    }
  }

  @override
  Widget build(BuildContext context) {
    // https://chatgpt.com/share/f5a1368e-6390-47d9-b625-27e81b8067e6

    // パネルの高さを画面の高さの80%に設定
    _panelHeightOpen = MediaQuery.of(context).size.height * 0.85;

    return Material(
      // マテリアルデザインのスタイルを適用するためのウィジェットを提供します https://chatgpt.com/share/f811d628-0eb4-4b76-b551-3332dd996065
      child: Stack(
        // ウィジェットを重ねて配置する https://chatgpt.com/share/2ce55e74-f823-4c9f-9413-fd9c1e113b11
        alignment: Alignment.topCenter, // 子ウィジェットをStackの上端中央に配置することを意味します。
        children: <Widget>[
          // SlidingUpPanelウィジェットを表示
          SlidingUpPanel(
            controller: _panelController,
            maxHeight: _panelHeightOpen, // パネルの最大高さを設定
            minHeight: _panelHeightClosed, // パネルの最小高さを設定
            parallaxEnabled:
                true, // パララックス効果を有効にする + パララックス効果とは、異なるオブジェクトが異なる速度で移動することで、深さや距離感を生み出す視覚的効果です。通常、背景と前景の要素が異なる速度で動くことで、より立体的な感じを演出します。
            parallaxOffset: .5, // パララックス効果のオフセットを設定
            body: _body(), // パネルの下部に表示するコンテンツ
            panelBuilder: (sc) => _panel(sc), // パネルのビルダー関数
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(18.0), // パネルの左上の角を丸める
              topRight: Radius.circular(18.0), // パネルの右上の角を丸める
            ),
            // panel: GestureDetector(
            //   onVerticalDragUpdate: (details) {
            //     // スクロールが上端の場合のみパネルをドラッグ可能にする
            //     if (_canPanelMove) {
            //       _panelController.panelPosition += details.primaryDelta! / MediaQuery.of(context).size.height;
            //       print('_panelController.panelPosition: ' + _panelController.panelPosition.toString());
            //     }
            //   },
            //   child: _panel(null),
            // ),
          ),
          // 上からのパネル
          Transform(
            alignment: Alignment.topCenter,
            transform: Matrix4.identity()..rotateX(3.14159), // 180度回転して上からスライド
            child: SlidingUpPanel(
              panel: Center(child: Text('Top Panel')),
              minHeight: 100,
              maxHeight: 400,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
              parallaxEnabled: true,
              parallaxOffset: 0.2,
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
          // Positioned(
          //   top: 52.0, // 上から52の位置に配置
          //   child: Container(
          //     padding:
          //         const EdgeInsets.fromLTRB(24.0, 18.0, 24.0, 18.0), // パディングを設定
          //     decoration: BoxDecoration(
          //       color: Colors.white, // 背景色を白に設定
          //       borderRadius: BorderRadius.circular(24.0), // 角を丸める
          //       boxShadow: const [
          //         BoxShadow(
          //           color: Color.fromRGBO(0, 0, 0, .25), // 影の色と透明度
          //           blurRadius: 16.0, // ぼかし半径を設定
          //         ),
          //       ],
          //     ),
          //     child: const Text(
          //       SlidingUpPanel Example,
          //       style: TextStyle(fontWeight: FontWeight.w500), // フォントのスタイルを設定
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  // パネル裏のマップを表示するWidget
  Widget _body() {
    return Scaffold(
      // アプリの基本的な構造を提供するためのウィジェットです。
      // appBar: AppBar(
      //   title: Text('Google Maps Example'),
      // ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: const CameraPosition(
              target: LatLng(35.6585, 139.7010), // Shibuya Station
              zoom: 16.0,
            ),
            markers: Set<Marker>.of(_markers.values),
            polylines: _polylines,
            myLocationEnabled: true, //現在位置をマップ上に表示
            myLocationButtonEnabled: false,
            onCameraMove: _onCameraMove,
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              child: Icon(Icons.my_location),
              onPressed: _onReturnToCurrentLocation,
            ),
          ),
        ],
      ),
    );
  }

  Widget _panel(ScrollController? sc) {
    final txt = _generateText();

    // return CustomMarkdownWidget(controller: sc, data: txt);

    // return ListView.builder(
    //   controller: sc,
    //   itemCount: 50,
    //   itemBuilder: (BuildContext context, int i) {
    //     return Container(
    //       padding: const EdgeInsets.all(12.0),
    //       child: Text("$i"),
    //     );
    //   },
    // );

    return CustomScrollView(
      // controller: sc,
      slivers: [
        SliverPersistentHeader(
          pinned: true,
          delegate: DynamicSliverPersistentHeaderDelegate(
            // child: Container(
            //   color: Colors.lightBlue,
            child: _buildButtonArea(txt),
            // ),
          ),
        ),
        // SliverToBoxAdapter(
        //   child: _buildButtonArea(txt),
        // ),
        SliverFillRemaining(
          child: CustomMarkdownWidget(data: txt, controller: sc),
        ),
      ],
    );
  }

  // Widget _panel(ScrollController? sc) {
  //   final (caption, txt) = _generateText();
  //   return NotificationListener<ScrollNotification>(
  //     onNotification: (scrollNotification) {
  //       if (scrollNotification is ScrollUpdateNotification) {
  //         print(scrollNotification.metrics.pixels);

  //         if (scrollNotification.metrics.pixels <= 0) {
  //           setState(() {
  //             _canPanelMove = true;
  //           });
  //         } else {
  //           setState(() {
  //             _canPanelMove = false;
  //           });
  //         }
  //       }

  //       // イベントのキャンセルをしないのでfalseを返却
  //       return false;
  //     },
  //     child: CustomScrollView(
  //       controller: sc,
  //       slivers: [
  //         SliverToBoxAdapter(
  //           child: _buildButtonArea(txt),
  //         ),
  //         SliverFillRemaining(
  //           child: CustomMarkdownWidget(data: txt),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  String _generateText() {
    String txt = '';
    String sufix = languageInfos[_currentLanguage]!.sufix;
    if (_currentFeatureId == 0) {
      return '';
    }

    final String caption = features.firstWhere(
        (v) => v['FeatureID'] == _currentFeatureId)['FeatureName-$sufix'];
    if (_currentFeatureId != 0) {
      explanations
          .where((e) => e['FeatureID'] == _currentFeatureId)
          .forEach((e) {
        txt += e['Explanation-$sufix'] + '  　  　\n\n';
      });
    }
    return '# $caption  \n' + txt.replaceAll('\n', '　  　  \n');
  }

  Widget _buildButtonArea(String txt) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),

      // constraints: BoxConstraints(minHeight: 100), // 最小高さを設定
      child: Column(
        // mainAxisSize: MainAxisSize.min, // これを追加
        children: [
          SizedBox(height: 8),
          // Container(
          //   height: 5,
          //   width: 100,
          //   margin: EdgeInsets.only(top: 10),
          //   decoration: BoxDecoration(
          //     color: Colors.grey[400],
          //     borderRadius: BorderRadius.circular(5),
          //   ),
          // ),
          // SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLanguageButton(Language.JP),
              SizedBox(width: 10),
              _buildLanguageButton(Language.English),
              SizedBox(width: 10),
              _buildSpeakButton(txt),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageButton(Language language) {
    return ElevatedButton(
      onPressed: () => _handleLanguageChange(language),
      style: ElevatedButton.styleFrom(
        backgroundColor:
            _currentLanguage == language ? Colors.blue : Colors.grey,
      ),
      child: Text(
        languageInfos[language]!.display,
        style: TextStyle(
          color: _currentLanguage == language ? Colors.white : Colors.black,
        ),
      ),
    );
  }

  Widget _buildSpeakButton(String txt) {
    return ElevatedButton(
      onPressed: () {
        _isSoundPlaying ? _stopSpeak() : _startSpeak(txt);
      },
      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
      child: Text(
        _isSoundPlaying ? 'Stop' : 'Speak',
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  Future _startSpeak(String value) async {
    if (_isSoundPlaying) {
      await _stopSpeak();
    }

    value = value.replaceAll(RegExp(r'\[.*?\]\(.*?\)'), '');

    await _flutterTts
        .setLanguage(languageInfos[_currentLanguage]!.languageCode); // 英語の設定
    await _flutterTts.setSpeechRate(0.5); // 速度調整
    await _flutterTts.setPitch(1.00); // 音程
    await _flutterTts.speak(value); // 読み上げるテキスト
  }

  Future _stopSpeak() async {
    await _flutterTts.stop(); // 再生を中止
    setState(() {
      _soundPlayingFeatureId = 0;
      _isSoundPlaying = false; // 中止した場合も再生状態を false に更新
    });
  }

  void _handleLanguageChange(Language language) {
    setState(() {
      _currentLanguage = language;
    });
    // 言語変更の処理をここに記述
    print('選択された言語: ${languageInfos[language]!.display}');
    // ここで必要な処理を追加
  }
}

class DynamicSliverPersistentHeaderDelegate
    extends SliverPersistentHeaderDelegate {
  final Widget child;
  double _height = 60; // 初期高さ
  VoidCallback? _triggerRebuild;

  DynamicSliverPersistentHeaderDelegate({required this.child});

  void updateHeight(Size size) {
    if (_height != size.height) {
      _height = size.height;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _triggerRebuild?.call();
      });
    }
  }

  @override
  double get minExtent => _height;

  @override
  double get maxExtent => _height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        _triggerRebuild = () {
          if (constraints.biggest.height != _height) {
            (context as Element).markNeedsBuild();
          }
        };
        return SizeReportingWidget(
          onSizeChange: updateHeight,
          child: child,
        );
      },
    );
  }

  @override
  bool shouldRebuild(
      covariant DynamicSliverPersistentHeaderDelegate oldDelegate) {
    return child != oldDelegate.child || _height != oldDelegate._height;
  }
}

class SizeReportingWidget extends SingleChildRenderObjectWidget {
  final void Function(Size size) onSizeChange;

  const SizeReportingWidget({
    Key? key,
    required this.onSizeChange,
    required Widget child,
  }) : super(key: key, child: child);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return SizeReportingRenderObject(onSizeChange);
  }
}

class SizeReportingRenderObject extends RenderProxyBox {
  final void Function(Size size) onSizeChange;
  Size? _oldSize;

  SizeReportingRenderObject(this.onSizeChange);

  @override
  void performLayout() {
    super.performLayout();
    Size newSize = child!.size;
    if (_oldSize != newSize) {
      _oldSize = newSize;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        onSizeChange(newSize);
      });
    }
  }
}
