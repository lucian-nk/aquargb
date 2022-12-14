import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../AppTheme.dart';
import '../Store/AppStore.dart';
import '../app_localizations.dart';
import '../screen/DataScreen.dart';
import '../utils/common.dart';
import '../utils/constant.dart';
import 'package:nb_utils/nb_utils.dart';
import 'component/NoInternetConnection.dart';

AppStore appStore = AppStore();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await FlutterDownloader.initialize(debug: true);
  HttpOverrides.global = HttpOverridesSkipCertificate();
  await initialize();
  appStore.setDarkMode(aIsDarkMode: getBoolAsync(isDarkModeOnPref));
  appStore.setLanguage(getStringAsync(APP_LANGUAGE, defaultValue: 'en'));

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  MyApp();

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    setStatusBarColor(appStore.primaryColors, statusBarBrightness: Brightness.light);
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((e) async {
      appStore.setConnectionState(e);
      if (e == ConnectivityResult.none) {
        log('not connected');
        push(NoInternetConnection());
      } else {
        pop();
        log('connected');
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _connectivitySubscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (context) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: appStore.isNetworkAvailable ? DataScreen() : NoInternetConnection(),
        navigatorKey: navigatorKey,
        localizationsDelegates: [AppLocalizations.delegate, GlobalMaterialLocalizations.delegate, GlobalWidgetsLocalizations.delegate],
        localeResolutionCallback: (locale, supportedLocales) => locale,
        locale: Locale(getStringAsync(APP_LANGUAGE, defaultValue: 'en')),
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: appStore.isDarkModeOn! ? ThemeMode.dark : ThemeMode.light,
        scrollBehavior: SBehavior(),
      );
    });
  }
}
