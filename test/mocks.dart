/*
 * FLauncher
 * Copyright (C) 2021  Étienne Fesser
 */

import 'dart:math';

import 'package:flauncher/database.dart';
import 'package:flauncher/flauncher_channel.dart';
import 'package:flauncher/providers/apps_service.dart';
import 'package:flauncher/providers/settings_service.dart';
import 'package:flauncher/providers/wallpaper_service.dart';
import 'package:flauncher/unsplash_service.dart';
import 'package:mockito/annotations.dart';
import 'package:moor/moor.dart';

@GenerateMocks([
  FLauncherChannel,
  FLauncherDatabase,
  WallpaperService,
  AppsService,
  SettingsService,
  UnsplashService,
])
void main() {}

App fakeApp({
  String packageName = "me.efesser.flauncher",
  String name = "FLauncher",
  String version = "1.0.0",
  Uint8List? banner,
  Uint8List? icon,
  bool hidden = false,
  bool sideloaded = false,
}) =>
    App(
      packageName: packageName,
      name: name,
      version: version,
      banner: banner,
      icon: icon,
      hidden: hidden,
      sideloaded: sideloaded,
    );

Category fakeCategory({
  String name = "Favorites",
  int order = 0,
  CategorySort sort = CategorySort.manual,
  CategoryType type = CategoryType.grid,
  int rowHeight = 110,
  int columnsCount = 6,
}) =>
    Category(
      id: Random().nextInt(1 << 32),
      name: name,
      sort: sort,
      type: type,
      rowHeight: rowHeight,
      columnsCount: columnsCount,
      order: order,
    );