/*
 * FLauncher — Postlounge TV
 * Copyright (C) 2021  Étienne Fesser
 */

import 'package:flauncher/actions.dart';
import 'package:flauncher/providers/apps_service.dart';
import 'package:flauncher/providers/settings_service.dart';
import 'package:flauncher/providers/wallpaper_service.dart';
import 'package:flauncher/unsplash_service.dart';
import 'package:flauncher/widgets/postlounge_startup_intro.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'database.dart';
import 'flauncher.dart';
import 'flauncher_channel.dart';

class FLauncherApp extends StatelessWidget {
  final SharedPreferences _sharedPreferences;
  final ImagePicker _imagePicker;
  final FLauncherChannel _fLauncherChannel;
  final FLauncherDatabase _fLauncherDatabase;
  final UnsplashService _unsplashService;

  static const Color _accent = Color(0xFF007DFA);
  static const Color _primarySurface = Color(0xFFF7F1EB);

  static const MaterialColor _swatch = MaterialColor(0xFF007DFA, <int, Color>{
    50: Color(0xFFE8F3FF),
    100: Color(0xFFBBD9FF),
    200: Color(0xFF007DFA),
    300: Color(0xFF0062C7),
    400: Color(0xFF004A96),
    500: Color(0xFF003366),
    600: Color(0xFF002952),
    700: Color(0xFF001F3D),
    800: Color(0xFF001428),
    900: Color(0xFF000A14),
  });

  FLauncherApp(
    this._sharedPreferences,
    this._imagePicker,
    this._fLauncherChannel,
    this._fLauncherDatabase,
    this._unsplashService,
  );

  @override
  Widget build(BuildContext context) => MultiProvider(
        providers: [
          ChangeNotifierProvider(
              create: (_) => SettingsService(_sharedPreferences),
              lazy: false),
          ChangeNotifierProvider(create: (_) => AppsService(_fLauncherChannel, _fLauncherDatabase)),
          ChangeNotifierProxyProvider<SettingsService, WallpaperService>(
              create: (_) => WallpaperService(_imagePicker, _fLauncherChannel, _unsplashService),
              update: (_, settingsService, wallpaperService) => wallpaperService!..settingsService = settingsService)
        ],
        child: MaterialApp(
          shortcuts: {
            ...WidgetsApp.defaultShortcuts,
            SingleActivator(LogicalKeyboardKey.select): ActivateIntent(),
            SingleActivator(LogicalKeyboardKey.gameButtonB): PrioritizedIntents(orderedIntents: [
              DismissIntent(),
              BackIntent(),
            ]),
          },
          actions: {
            ...WidgetsApp.defaultActions,
            DirectionalFocusIntent: SoundFeedbackDirectionalFocusAction(),
          },
          title: 'Postlounge TV',
          theme: ThemeData(
            brightness: Brightness.dark,
            primarySwatch: _swatch,
            colorScheme: ColorScheme.dark(
              primary: _accent,
              surface: const Color(0xFF1E1B18),
              onPrimary: _primarySurface,
            ),
            focusColor: _accent,
            cardColor: const Color(0xFF2A2622),
            canvasColor: const Color(0xFF2A2622),
            dialogTheme: const DialogThemeData(backgroundColor: Color(0xFF1E1B18)),
            scaffoldBackgroundColor: Colors.transparent,
            textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: _primarySurface)),
            appBarTheme: const AppBarTheme(elevation: 0, backgroundColor: Colors.transparent),
            inputDecorationTheme: InputDecorationTheme(
              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: _accent)),
              labelStyle: const TextStyle(color: Colors.white70),
            ),
            textSelectionTheme: TextSelectionThemeData(
              cursorColor: _accent,
              selectionColor: _accent.withOpacity(0.35),
              selectionHandleColor: _accent,
            ),
          ),
          home: PostloungeStartupIntro(
            sharedPreferences: _sharedPreferences,
            child: Builder(
              builder: (context) => WillPopScope(
                onWillPop: () => shouldPopScope(context),
                child: Actions(actions: {BackIntent: BackAction(context, systemNavigator: true)}, child: FLauncher()),
              ),
            ),
          ),
        ),
      );
}