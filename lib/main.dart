/*
 * FLauncher — Postlounge TV
 * Copyright (C) 2021  Étienne Fesser
 */

import 'package:flauncher/database.dart';
import 'package:flauncher/flauncher_channel.dart';
import 'package:flauncher/unsplash_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unsplash_client/unsplash_client.dart';

import 'flauncher_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final sharedPreferences = await SharedPreferences.getInstance();
  final imagePicker = ImagePicker();
  final fLauncherChannel = FLauncherChannel();
  final fLauncherDatabase = FLauncherDatabase.connect(connect());
  final unsplashService = UnsplashService(
    UnsplashClient(
      settings: ClientSettings(
        debug: kDebugMode,
        credentials: AppCredentials(accessKey: '', secretKey: ''),
      ),
    ),
  );

  runApp(
    FLauncherApp(
      sharedPreferences,
      imagePicker,
      fLauncherChannel,
      fLauncherDatabase,
      unsplashService,
    ),
  );
}