import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:tokyo_mania/sample/idochu.dart';
import 'package:tokyo_mania/screen/auth_screen.dart';
import 'package:tokyo_mania/screen/lib/attraction.dart';
import 'package:tokyo_mania/screen/lib/auth_required.dart';
import 'package:tokyo_mania/screen/map_screen.dart';
import 'package:tokyo_mania/screen/provider/detail_info_model.dart';
import 'package:tokyo_mania/screen/provider/map_view_mode_model.dart';
import 'package:tokyo_mania/screen/provider/panel_content_model.dart';
import 'package:tokyo_mania/screen/provider/search_model.dart';
import 'package:tokyo_mania/screen/provider/search_view_model.dart';
import 'package:tokyo_mania/screen/provider/selected_attraction_model.dart';
import 'package:tokyo_mania/screen/splash_screen.dart';
import 'package:tokyo_mania/screen/wigdet/search_area.dart';
// import 'package:cached_network_image/cached_network_image.dart';
import 'package:tokyo_mania/util/supabase_util.dart';
// import 'package:flutter_markdown/flutter_markdown.dart';

// void main(){
//   runApp(
//     MyApp()
//   );
// }
// class MyApp extends StatelessWidget{
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context){
//     return MaterialApp(
//       home: MovingModeMap(),
//     );
//   }
// }

Future<Position?>? futureInitilizePosition;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _getCurrentLocationPermition();
  futureInitilizePosition = Geolocator.getLastKnownPosition();

  SupabaseUtil.initialize();
  // WidgetsFlutterBinding.ensureInitialized();
  // SystemChrome.setSystemUIOverlayStyle(
  //   const SystemUiOverlayStyle(
  //     statusBarColor: Colors.blueAccent,
  //   ),
  // );
  // runApp(const YoutubePlayerDemoApp());

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => SearchModel()),
        ChangeNotifierProvider(create: (context) => DetailInfoModel()),
        ChangeNotifierProvider(create: (context) => PanelContentModel()),
        ChangeNotifierProvider(create: (context) => SelectedAttractionModel()),
        ChangeNotifierProvider(create: (context) => MapViewModeModel()),
        ChangeNotifierProxyProvider3<SearchModel, DetailInfoModel,
            PanelContentModel, SearchViewModel>(
          create: (_) => SearchViewModel(
            Provider.of<SearchModel>(_, listen: false),
            Provider.of<DetailInfoModel>(_, listen: false),
            Provider.of<PanelContentModel>(_, listen: false),
          ),
          update: (context, searchModel, infoModel, panelControllerModel,
                  searchViewModel) =>
              SearchViewModel(searchModel, infoModel, panelControllerModel),
        ),
      ],
      child: const MyApp(),
    ),
    // const MyApp()
    // MyAppRestaurantListPage()
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // home: MapScreen(),
      // home: MarkdownLinkExample(),
      // home: GetMarkerImage()
      // home: SlidingUpPanelExample(),
      // home: MarkdownExample(),
      // home: SlidingMarkdownPanel()
      // home: RouteMapScreen(),
      // home: MapScreenGPT(),
      // home: AuthSample(),
      // home: MovingModeMap(),
      // home: Scaffold(
      //   body: Stack(
      //     children: [
      //       // Your Google Map widget here
      //       Positioned(
      //         top: 200,
      //         left: 0,
      //         right: 0,
      //         child: CategorySearchBar(),
      //       ),
      //     ],
      //   ),
      // ),
      // home: Scaffold(
      //   body: Stack(
      //     children: [
      //       // Your Google Map widget here
      //       SafeArea(
      //         child: SearchArea()
      //         // Positioned(
      //         //   // top: 100,
      //         //   left: 0,
      //         //   right: 0,
      //         //   child: SearchArea(),
      //         // ),
      //       ),
      //     ],
      //   ),
      // ),
      // home: MapScreenSampleCurrentPosition(),

      theme: ThemeData(
        scaffoldBackgroundColor: Colors.black, // ここで背景色を設定
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        '/auth': (context) => AuthScreen(),
        '/map': (context) => AuthRequired(childBuilder: () => MapScreen()),
        // '/map_first': (context) => MapScreen(),
        // '/home': (context) => HomeScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/map_first') {
          return PageRouteBuilder(
            settings: settings,
            pageBuilder: (context, animation, secondaryAnimation) =>
                AuthRequired(childBuilder: () => Material(child: MapScreen())),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            transitionDuration: Duration(milliseconds: 1500),
          );
        }
        // 他のルートに対するカスタムトランジションもここで設定できます
        return null;
      },
    );
  }
}

  void _getCurrentLocationPermition() async {
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
  }