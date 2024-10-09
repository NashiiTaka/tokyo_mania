import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';
import 'package:tokyo_mania/constants/screen_parts.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State {
  // const AuthScreen({super.key});

  @override
  void initState() {
    super.initState();
    // 初期表示時にフォーカスを外す
    Future.delayed(Duration.zero, () {
      FocusScope.of(context).unfocus();
    });
  }

  @override
  Widget build(BuildContext context) {

    const redirectTo =
        kIsWeb ? null : 'tokyomania://${const String.fromEnvironment('appId')}';
    // const redirectTo = kIsWeb ? null : 'tokyomania://authresult';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: ScreenParts.appBar('Sign In'),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          const SizedBox(height: 24.0),
          SupaSocialsAuth(
            redirectUrl: redirectTo,
            nativeGoogleAuthConfig: const NativeGoogleAuthConfig(
              iosClientId: String.fromEnvironment('iosClientId'),
              webClientId: String.fromEnvironment('webClientId'),
            ),
            socialProviders: const [
              OAuthProvider.google,
            ],
            onSuccess: (session) {

            },
            onError: (error) => SnackBar(
              content: Text(
                error.toString(),
              ),
            ),
          ),
          // ScreenParts.spacer,
          // const Divider(),
          // ScreenParts.optionText,
          // ScreenParts.spacer,
          // SupaEmailAuth(
          //   redirectTo: redirectTo,
          //   onSignInComplete: (res) => Navigator.pushNamed(context, '/'),
          //   onSignUpComplete: (res) => Navigator.pushNamed(context, '/'),
          //   onError: (error) => SnackBar(content: Text(error.toString())),
          //   localization: const SupaEmailAuthLocalization(
          //     backToSignIn: 'ログインに戻る',
          //     enterEmail: 'メールアドレスを入力',
          //     forgotPassword: 'パスワード再発行',
          //     dontHaveAccount: '新規登録',
          //     enterPassword: 'パスワード',
          //     haveAccount: 'ログインに戻る',
          //     passwordLengthError: 'パスワードは6文字以上で入力してください',
          //     passwordResetSent: 'パスワード再発行メールを送信しました',
          //     sendPasswordReset: 'パスワード再発行',
          //     validEmailError: '有効なメールアドレスを入力してください',
          //     unexpectedError: '予期せぬエラーが発生しました',
          //     signIn: 'ログイン',
          //     signUp: '登録',
          //   ),
          // ),
        ],
      ),
    );
  }
}
