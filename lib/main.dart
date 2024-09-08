import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:tokyo_mania/get_marker_image.dart';
import 'package:tokyo_mania/sliding_up_panel.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:cached_network_image/cached_network_image.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const googleMapsApiKey = String.fromEnvironment('googleMapsApiKey');
    print(googleMapsApiKey); // 'dev'

    return MaterialApp(
      home: MapScreen(),
      // home: GetMarkerImage()
      // home: SlidingUpPanelExample(),
    );
  }
}

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  PanelController _panelController = PanelController();
  GoogleMapController? mapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  double _panelHeightOpen = 0;
  final double _panelHeightClosed = 0;
  String _currentPlaceId = '';
  String _currentLanguage = '日本語'; // 初期言語
  final FlutterTts _flutterTts = FlutterTts();
  bool _isSoundPlaying = false;
  String _soundPlayingPlaceId = '';

  final GoogleMapsPlaces _googleMapsPlaces =
      GoogleMapsPlaces(apiKey: 'AIzaSyAX69oZWYzbY_ZRyMwHkcKseEZvw3Jiz-M');

  final Map<String, Map<String, dynamic>> _markerInfos = {
        'ChIJ__-ru7qMGGARO4TqjNgbWpo': {
      'nameJP': 'CAFÉ 杜のテラス',
      'nameENG': '',
      'descJP':
          '''来てくれてありがとう。
私はまりぃです。こちらはなっしーです。
わたしたちは観光案内のテストサービスをしています。よろしくお願いします！
お名前を伺ってよろしいですか？

これから、明治神宮の主要なスポットを案内していきます。
所要時間は約1時間です。私達はあまり英語が上手ではないので、英語の説明が難しい場所は、アプリを使って説明します。もし質問があれば、ゆっくり話してください。写真を撮りたい場所があったらいつでも言ってください！ガイド中の様子を撮らせて頂きたいのですが、SNSにアップロードしてもよろしいでしょうか？ガイドが終わったら、簡単なアンケートにご記入いただきフィードバックを頂けますでしょうか。
初めてのガイドのため、上手にできないところがあったらすいません！

では、いきましょう！''',
      'descENG':
          '''Thank you for coming.
I'm Marii, and this is Nasshi.
We are testing a tour guide service.
Thank you in advance!
Can you tell me your names?

I'll be showing you the main spots of Meiji Shrine from now.
The tour will take about an hour.
Since we're not very good at English, we'll use an app to explain difficult parts.
If you have any questions, please speak slowly.
If you'd like to take photos anywhere, feel free to let us know!
We'd also like to take photos during the tour. Is it okay to upload them to social media?
After the tour, could you please fill out a short survey and give us your feedback?
Since this is our first time guiding, we're sorry if there are any parts we don't do well!
OK! Let'go.''',
    },


    'ChIJJzR9pLqMGGARn__Fp9eG3sg': {
      'nameJP': '明治神宮 一の鳥居',
      'nameENG': 'Meiji Jingu Ichino Torii',
      'descJP':
          '''明治神宮は、明治天皇と昭憲皇太后に奉納された東京の神社です。静かな森に囲まれており、人々は幸運を祈ったり、日本文化を学んだりするために訪れます。

明治神宮の一の鳥居は、高さ約12メートル、幅約9.1メートルの巨大な木造鳥居で、参拝者が最初に通る重要な門です。樹齢1500年の台湾産ヒノキで作られ、1975年に建て替えられました。鳥居は神聖な領域と俗世を分ける役割を持ち、明治神宮の威厳と格式を象徴しています。一の鳥居をくぐると、緑豊かな参道が続きます。''',
      'descENG':
          '''Meiji Jingu is a shrine in Tokyo dedicated to Emperor Meiji and Empress Shoken. It's surrounded by a peaceful forest where people visit to pray for good luck or learn about Japanese culture.

The first torii gate is a huge wooden gate, about 12 meters tall and 9.1 meters wide. Made from 1,500-year-old Taiwanese cypress, it was rebuilt in 1975. The gate separates the sacred area from the everyday world and shows the shrine's importance. After passing through it, you'll walk along a lush, green path.''',
    },

    'ChIJzfzeJtiNGGARoTnuEtnUtCQ': {
      'nameJP': '神橋',
      'nameENG': 'Meiji Jingu Shinkyo (Sacred Bridge)',
      'descJP':
          '''明治神宮の神橋（しんきょう）は、明治神宮の参道にある朱塗りの木製の橋です。神橋は、明治神宮の内苑にある清正井（きよまさのいど）から流れる小川を渡るために架けられています。

この橋は、神聖な場所への入り口とされており、参拝者が渡ることで、心身を清めるという意味が込められています。また、神橋のデザインはシンプルでありながらも美しく、自然の景観と調和しています。橋の両側には大きな木々が生い茂り、四季折々の風景を楽しむことができます。

神橋は明治神宮の静謐な雰囲気を保つ一部であり、訪れる人々にとって特別な体験を提供します。''',
      'descENG':
          '''Shinkyō Bridge at Meiji Shrine is a vermilion-painted wooden bridge located along the shrine’s approach. It spans a stream that flows from Kiyomasa’s Well in the inner garden of Meiji Shrine.

This bridge is regarded as an entrance to a sacred area, and crossing it symbolizes the purification of the mind and body for worshippers. The design of the bridge, while simple, is elegant and harmonizes beautifully with the surrounding natural scenery. Large trees grow on both sides of the bridge, allowing visitors to enjoy the seasonal landscapes.

Shinkyō Bridge is part of the serene atmosphere of Meiji Shrine, offering a special experience to those who visit.''',
    },

    'ChIJw-yvkzeNGGARjGUxRzKNPKQ': {
      'nameJP': '明治神宮ミュージアム',
      'nameENG': 'Meiji Jingu Museum',
      'descJP':
          '''明治神宮ミュージアムは、2019年に開館し、明治神宮の歴史や明治天皇と昭憲皇太后に関する貴重な資料を展示する博物館です。隈研吾氏設計の自然と調和した建物が特徴で、常設展示に加え、特別展やイベントも開催されています。''',
      'descENG':
          '''The Meiji Shrine Museum opened in 2019. It is a museum that displays valuable materials about the history of Meiji Shrine and Emperor Meiji and Empress Shoken. The building, designed by Kengo Kuma, is known for its harmony with nature. In addition to the permanent exhibits, special exhibitions and events are also held.''',
    },

    'ChIJq6qaE7qMGGAR2GNDRLN-dlc': {
      'nameJP': 'フォレストテラス明治神宮',
      'nameENG': '',
      'descJP':
          '''「フォレストテラス明治神宮」は、東京の明治神宮内にある静かな休憩スポットです。豊かな緑に囲まれたこの場所は、参拝の合間にひと息つくのに最適です。テラスにはカフェやショップもあり、神宮の自然を感じながら、リラックスした時間を過ごすことができます。また、季節ごとに変わる景色が楽しめるのも魅力です。都会の喧騒を忘れ、心を落ち着かせるひとときを提供してくれる場所です。''',
      'descENG':
          '''''',
    },

    'ChIJPfm-ilONGGARmj2X4hbsxQ8': {
      'nameJP': '代々木',
      'nameENG': '',
      'descJP':
          '''明治神宮参道に立つ「代々木」の地名の由来となったとされている樹木。江戸時代に彦根藩井伊家下屋敷であった当地には代々樅の巨木があり、「代々大きな木があった」という意味で「代々木」との地名が発祥したそうです。なお、当時の木は、太平洋戦争末期の昭和２０年（１９４５年）５月、アメリカ軍による空襲の際、高射砲で撃墜されたＢ－２９が直撃して焼失したそうです。''',
      'descENG':
          '''''',
    },

    'ChIJg54kYcGNGGARBAR_zttpZuw': {
      'nameJP': '奉献酒樽',
      'nameENG': '',
      'descJP':
          '''「奉献酒樽」は明治神宮の参道に並ぶ酒樽で、全国の酒造メーカーから奉納され、日本の伝統文化と酒造りを象徴しています。また、フランス産のワイン樽もあり、国際文化交流も示しています。日本の神社で酒樽が並ぶ習慣は、神道の信仰に由来し、江戸時代以降、神社への奉納が広まりました。全国の神社で見られる酒樽は、地域社会との結びつきを象徴しています。''',
      'descENG':
          '''The 'Offering Sake Barrels' are lined up along the path to Meiji Shrine. They are donated by sake makers from all over Japan and show traditional Japanese culture. There are also wine barrels from France, showing international exchange. This practice started in the Edo period and shows the connection between shrines and local communities.''',
    },

    'ChIJdxIIoMqNGGARcuXbPfj1GTk': {
      'nameJP': '奉献葡萄酒樽',
      'nameENG': '',
      'descJP':
          '''明治神宮には、フランスブルゴーニュから奉納された空のワイン樽が並んでいます。樽にはドメーヌ名や銘柄（例：ロマネコンティ）が記され、2006年から毎年増えて現在は60樽。明治天皇のワイン愛好がきっかけで、ブルゴーニュ名誉市民の佐多保彦氏が献納を提案しました。フランス人観光客は、このワイン樽を誇りに思っているそうです。''',
      'descENG':
          '''At Meiji Shrine, there are empty wine barrels from Burgundy, France. Each barrel has a winery name, like 'Romanée-Conti.' Since 2006, the number has grown to 60. This started because Emperor Meiji loved wine, and a French citizen suggested the donation. French tourists are very proud of these barrels.''',
    },

    'ChIJsyv0pLqMGGARO-cDLT1bCeU': {
      'nameJP': '大鳥居',
      'nameENG': '',
      'descJP':
          '''「大鳥居」は高さ12メートル、幅17.1メートルの日本最大の木造明神鳥居で、南参道と北参道の合流地点に立っています。1920年に台湾の檜で建立されましたが、1966年に落雷で破壊。現在の鳥居は樹齢1500年の檜から作られ、1975年に完成しました。檜は台湾の丹大山で発見され、再建には多くの支援がありました。''',
      'descENG':
          '''The 'Otorii' is the largest wooden torii gate in Japan, 12 meters tall and 17.1 meters wide. It stands where the South and North paths meet. The first one, built in 1920 from Taiwanese cypress, was struck by lightning in 1966. The current gate, made from 1,500-year-old cypress, was finished in 1975. Many people helped rebuild it.''',
    },

    'ChIJiVvc68aNGGARC42Rkxw8GlY': {
      'nameJP': '明治神宮 三の鳥居',
      'nameENG': 'Meiji Jingu Sanno Torii',
      'descJP':
          '''神社に入る際、拝観者は手水舎で手と口を清める儀式を行います。柄杓を使って手と口を洗い、信仰に関係なく誰でも行うことが歓迎されています。''',
      'descENG':
          '''Before entering a shrine, visitors wash their hands and mouth at the water fountain. They use a ladle to do this. Anyone, regardless of their faith, is welcome to do this ritual.''',
    },

    'ChIJJ4l9AMuNGGAR9sc40w4RaMI': {
      'nameJP': '明治神宮 夫婦楠',
      'nameENG': '',
      'descJP':
          '''「夫婦楠」は、明治神宮にある2本のクスノキで、注連縄で結ばれています。神聖な繋がりを示し、悪霊を祓う役割もあります。1920年に植えられ、幸福や結婚、家族の健康の象徴とされ、恋愛運や結婚の成功を求める人々に人気です。''',
      'descENG':
          '''hese camphor trees are called Meoto Kusu, or ‘husband and wife trees.’ They are connected by a rope, called a shimenawa, which shows their special bond and keeps away bad spirits.

Planted in 1920 when Meiji Jingu was established, the trees have grown together since. They symbolize a strong and happy marriage and a healthy family. People visit them to wish for love and success in marriage.''',
    },

    'ChIJ5SZMmreMGGARcz8QSTiJyo8': {
      'nameJP': '明治神宮 本殿',
      'nameENG': '',
      'descJP':
          '''本殿は明治神宮で最も神聖な建物で、神霊が祀られています。日々の祭儀は午前8時と午後2時に行われ、ヒノキと銅で作られた流造様式の建物です。1920年に建立されましたが、戦火で焼失し、現在の建物は1958年完成です。防火のため、木の樹皮の代わりに銅が使用されています。''',
      'descENG':
          '''The main hall is the most sacred building at Meiji Jingu, where the spirits are enshrined. Daily rituals are held at 8 a.m. and 2 p.m. The building is made of cypress and copper in a special style. It was originally built in 1920 but was destroyed in a fire. The current hall was completed in 1958, using copper instead of wood bark to prevent fire.''',
    },

    'ChIJ04pwyreMGGARKvoa9AYdtp8': {
      'nameJP': '明治神宮 神楽殿（授与所）',
      'nameENG': '',
      'descJP':
          '''【おみくじ】
明治神宮のおみくじは「大御心」と呼ばれ、30首の和歌が書かれています。これらは明治天皇・皇后が詠んだ短歌で、解説文が添えられています。絵馬は木製で、片面に神社に関連する絵が描かれ、もう片面には願い事を書く空欄があります。絵馬は授与所で¥500で入手でき、皇室ゆかりの菊紋やその年の干支の絵が入っています。

【絵馬】
「絵馬」は古代の実馬奉納に由来し、現在は木片に馬の絵が描かれています。メッセージは自由で、信仰や言語を問わず誰でも書けます。書いた絵馬は楠の木の周りに掛け、毎朝の御饌祭で祈祷された後、お炊き上げされます。''',
      'descENG':
          '''## Omikuji
At Meiji Jingu, the omikuji are called ‘Omi Kokoro’ and have 30 poems by Emperor and Empress Meiji with explanations. The ema (wish plaques) are wooden, with pictures on one side and space for your wish on the other. You can buy an ema for ¥500 at the gift shop. They feature the Imperial Chrysanthemum crest or the zodiac sign of the year.

## About Ema
Emas are wooden plaques with pictures of horses. People write messages on them, and they can be in any language. The emas are hung around a camphor tree and burned after a daily ritual.''',
    },


  };

  @override
  void initState() {
    super.initState();
    _addMarkersFromPlaceIDs();

    // 再生開始時のハンドラー
    _flutterTts.setStartHandler(() {
      setState(() {
        _soundPlayingPlaceId = _currentPlaceId;
        _isSoundPlaying = true;
      });
    });

    // 再生完了時のハンドラー
    _flutterTts.setCompletionHandler(() {
      setState(() {
        _soundPlayingPlaceId = '';
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

    // _createPolylines();
  }

  // Place IDsからマーカーを追加する非同期メソッド
  Future<void> _addMarkersFromPlaceIDs() async {
    print(_markerInfos.length);

    // markerInfosに含まれる各Place IDについて処理
    _markerInfos.forEach((placeId, _) async {
      // Google Maps APIからPlace IDを使って場所の詳細情報を取得
      final placeDetails = await _googleMapsPlaces.getDetailsByPlaceId(
        placeId,
        language: 'ja', // 日本語で詳細情報を取得
      );

      // マーカーを作成し、取得した場所の緯度・経度を設定
      final marker = Marker(
        markerId: MarkerId(placeId), // Place IDをMarker IDとして設定
        position: LatLng(
          placeDetails.result.geometry!.location.lat, // 緯度を設定
          placeDetails.result.geometry!.location.lng, // 経度を設定
        ),
        infoWindow: InfoWindow(
          title: placeDetails.result.name, // マーカーのタイトルを場所の名前に設定
        ),
        // マーカーがタップされた時の処理
        onTap: () {
          setState(() {
            _currentPlaceId = placeId;
          });

          _panelController.animatePanelToPosition(1);
        },
      );

      // setStateでマーカーリストに追加し、UIを更新
      setState(() {
        _markers.add(marker); // 新しいマーカーをリストに追加
      });
    });
  }

  void _createPolylines() {
    setState(() {
      _polylines.add(
        Polyline(
          polylineId: PolylineId('route'),
          color: Colors.blue.withOpacity(0.5),
          width: 5,
          points: [
            LatLng(35.7109, 139.7674), // Tokyo Station
            LatLng(35.6895, 139.6917), // Shinjuku Station
            LatLng(35.6585, 139.7010), // Shibuya Station
          ],
        ),
      );
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    // https://chatgpt.com/share/f5a1368e-6390-47d9-b625-27e81b8067e6

    // パネルの高さを画面の高さの80%に設定
    _panelHeightOpen = MediaQuery.of(context).size.height * .80;

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
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: LatLng(35.6585, 139.7010), // Shibuya Station
          zoom: 16.0,
        ),
        markers: _markers,
        polylines: _polylines,
      ),
    );
  }

  // パネル側のWidget
  Widget _panel(ScrollController sc) {
    String txt = '';
    String caption = '';
    if (_currentPlaceId.isNotEmpty) {
      txt = _markerInfos[_currentPlaceId]![
          _currentLanguage == '日本語' ? 'descJP' : 'descENG'];
      caption = _markerInfos[_currentPlaceId]![
          _currentLanguage == '日本語' ? 'nameJP' : 'nameENG'];
    }

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start, // 子要素を一番上から開始
        children: [
          SizedBox(height: 10), // 行間を少し空ける
          Container(
            height: 5,
            width: 100,
            margin: EdgeInsets.only(top: 10),
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(5),
            ),
          ),

          Container(
            padding: EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, // 左寄せ
              children: [
                SizedBox(height: 20), // 行間を少し空ける
                // ボタンエリア
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        _handleLanguageChange('日本語');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _currentLanguage == '日本語'
                            ? Colors.blue // 選択されたボタンの色
                            : Colors.grey, // 非選択状態の色
                      ),
                      child: Text(
                        '日本語',
                        style: TextStyle(
                          color: _currentLanguage == '日本語'
                              ? Colors.white // 選択されたボタンの文字色
                              : Colors.black, // 非選択状態の文字色
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        _handleLanguageChange('English');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _currentLanguage == 'English'
                            ? Colors.blue // 選択されたボタンの色
                            : Colors.grey, // 非選択状態の色
                      ),
                      child: Text(
                        'English',
                        style: TextStyle(
                          color: _currentLanguage == 'English'
                              ? Colors.white // 選択されたボタンの文字色
                              : Colors.black, // 非選択状態の文字色
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        _isSoundPlaying ? _stopSpeak() : _startSpeak(txt);
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue // 選択されたボタンの色
                          ),
                      child: Text(
                        _isSoundPlaying ? 'Stop' : 'Speak',
                        style: TextStyle(color: Colors.white // 選択されたボタンの文字色
                            ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10), // 行間を少し空ける
                Center(
                  // 1行目をセンタリング
                  child: Text(
                    caption,
                    style: TextStyle(
                      fontSize: 24, // 大きめの文字
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 10), // 行間を少し空ける
                Text(
                  txt,
                  style: TextStyle(
                    fontSize: 18, // 少し小さめの文字
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future _startSpeak(String value) async {
    if (_isSoundPlaying) {
      await _stopSpeak();
    }

    await _flutterTts.setLanguage('en-US'); // 英語の設定
    await _flutterTts.setSpeechRate(0.5); // 速度調整
    await _flutterTts.setPitch(1.0); // 音程
    await _flutterTts.speak(value); // 読み上げるテキスト
  }

  Future _stopSpeak() async {
    await _flutterTts.stop(); // 再生を中止
    setState(() {
      _soundPlayingPlaceId = '';
      _isSoundPlaying = false; // 中止した場合も再生状態を false に更新
    });
  }

  void _handleLanguageChange(String language) {
    setState(() {
      _currentLanguage = language;
    });
    // 言語変更の処理をここに記述
    print('選択された言語: $language');
    // ここで必要な処理を追加
  }
}
