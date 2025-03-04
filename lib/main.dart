import 'dart:io';

import 'package:dio_log/overlay_draggable_button.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:qinglong_app/base/theme.dart';
import 'package:qinglong_app/module/login/login_page.dart';
import 'package:qinglong_app/utils/sp_utils.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'base/routes.dart';
import 'base/userinfo_viewmodel.dart';
import 'module/home/home_page.dart';

final getIt = GetIt.instance;
var navigatorState = GlobalKey<NavigatorState>();

var logger = Logger();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SpUtil.getInstance();
  getIt.registerSingleton<UserInfoViewModel>(UserInfoViewModel());

  await SystemChrome.setPreferredOrientations(
    [
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ],
  );
  runApp(
    ProviderScope(
      overrides: [
        themeProvider,
      ],
      child: const QlApp(),
    ),
  );
  if (Platform.isAndroid) {
    SystemUiOverlayStyle style =
        const SystemUiOverlayStyle(statusBarColor: Colors.transparent);
    SystemChrome.setSystemUIOverlayStyle(style);
  }
}

class QlApp extends ConsumerStatefulWidget {
  const QlApp({Key? key}) : super(key: key);

  @override
  ConsumerState<QlApp> createState() => QlAppState();
}

class QlAppState extends ConsumerState<QlApp> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: MediaQuery(
        data:
            MediaQueryData.fromWindow(WidgetsBinding.instance.window).copyWith(
          textScaleFactor: 1,
        ),
        child: MaterialApp(
          title: "青龙",
          locale: const Locale('zh', 'CN'),
          navigatorKey: navigatorState,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('zh', 'CN'),
            Locale('en', 'US'),
          ],
          theme: ref.watch<ThemeViewModel>(themeProvider).currentTheme,
          onGenerateRoute: (setting) {
            return Routes.generateRoute(setting);
          },
          home: Builder(
            builder: (context) {
              if (!kReleaseMode) {
                showDebugBtn(context);
              }
              return getIt<UserInfoViewModel>().isLogined()
                  ? const HomePage()
                  : const LoginPage();
            },
          ),
          // home: LoginPage(),
        ),
      ),
    );
  }
}
