import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tokyo_mania/screen/auth_screen.dart';
import 'package:tokyo_mania/util/supabase_util.dart';

class AuthRequired extends StatefulWidget {
  final Widget Function() childBuilder;

  const AuthRequired({super.key, required this.childBuilder});

  @override
  _AuthRequiredState createState() => _AuthRequiredState();
}

class _AuthRequiredState extends State<AuthRequired> {
  late Widget _child;
  late Widget _currentWidget;

  @override
  void initState() {
    super.initState();
    _child = widget.childBuilder();
    _checkAndUpdateAuth();

    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      _checkAndUpdateAuth();
    });
  }

  void _checkAndUpdateAuth() {
    setState(() {
      _currentWidget = SupabaseUtil.isAuthenticated ? _child : const AuthScreen();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      child: _currentWidget,
    );
  }
}