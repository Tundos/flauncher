/*
 * FLauncher — Postlounge TV
 * Copyright (C) 2021  Étienne Fesser
 */

import 'dart:io';

import 'package:flauncher/database.dart';
import 'package:flauncher/flauncher_channel.dart';
import 'package:flauncher/gradients.dart';
import 'package:flauncher/unsplash_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unsplash_client/unsplash_client.dart';

import 'flauncher_app.dart';

const _postloungeHomeBrandingKey = 'postlounge_home_branding_v1';
const _gradientUuidKey = 'gradient_uuid';

Future<void> _applyPostloungeHomeBrandingDefaults(SharedPreferences sharedPreferences) async {
  if (sharedPreferences.containsKey(_postloungeHomeBrandingKey)) {
    return;
  }
  await sharedPreferences.setString(_gradientUuidKey, FLauncherGradients.postloungeBrand.uuid);
  final directory = await getApplicationDocumentsDirectory();
  final wallpaperFile = File('${directory.path}/wallpaper');
  if (await wallpaperFile.exists()) {
    await wallpaperFile.delete();
  }
  await sharedPreferences.setBool(_postloungeHomeBrandingKey, true);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final sharedPreferences = await SharedPreferences.getInstance();
  await _applyPostloungeHomeBrandingDefaults(sharedPreferences);
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