// import 'package:auth_ui_example/auth_screen.dart';
// import 'package:auth_ui_example/home_screen.dart';
import 'package:flutter/material.dart';


// final activeSession = Supabase.instance.client.auth.currentSession;

// class SplashScreen extends StatelessWidget {
//   const SplashScreen({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // body: Center(child: activeSession == null ? AuthScreen() : HomeScreen()),
//     );
//   }
// }

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);

    _controller.forward();

    // アニメーション終了後、メイン画面に遷移
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Navigator.of(context).pushReplacementNamed('/map_first', arguments: null);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: FadeTransition(
          opacity: _animation,
          child: Image.asset(
            'assets/images/logo.png',
            width: 200,
            // height: 200,
          ),
        ),
      ),
    );
  }
}

