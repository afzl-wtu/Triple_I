import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:main/bloc/news/news_bloc.dart';

import 'package:main/bloc/sectorperformance.dart';
import 'package:main/codegen_loader.g.dart';

import './bloc/home.dart';
import './bloc/profile.dart';
import './bloc/search.dart';

import './screens/mainScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  runApp(
    EasyLocalization(
      child: MyApp(),
      supportedLocales: [Locale('en'), Locale('he')],
      path: 'assets/translations',
      fallbackLocale: Locale('en'),
      assetLoader: CodegenLoader(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final time1 = DateTime.now();
    Firebase.initializeApp().then((value) {
      print('fuure solved: time1:${time1.toIso8601String()} ');
      print('Difference :${DateTime.now().difference(time1).inMilliseconds}');
    });
    // To set orientiation always portrait
    SystemChrome.setPreferredOrientations(
      [
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ],
    );

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
    );
    return MultiBlocProvider(
      providers: [
        BlocProvider<NewsBloc>(
          create: (context) => NewsBloc(),
        ),
        BlocProvider<SearchBloc>(
          create: (context) => SearchBloc(),
        ),
        BlocProvider<ProfileBloc>(
          create: (context) => ProfileBloc(),
        ),
        BlocProvider<HomeBloc>(
          create: (context) => HomeBloc(),
        ),
        BlocProvider<SectorPerformanceBloc>(
            create: (_) => SectorPerformanceBloc())
      ],
      child: MaterialApp(
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        home: MainScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
