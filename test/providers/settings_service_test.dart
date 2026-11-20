/*
 * FLauncher
 * Copyright (C) 2021  Étienne Fesser
 */

import 'package:flauncher/providers/settings_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';

void main() {
  setUp(() {
    SharedPreferencesStorePlatform.instance = InMemorySharedPreferencesStore.empty();
  });

  test("setUse24HourTimeFormat", () async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final settingsService = SettingsService(sharedPreferences);

    await settingsService.setUse24HourTimeFormat(true);

    expect(sharedPreferences.getBool("use_24_hour_time_format"), isTrue);
  });

  test("setGradientUuid", () async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final settingsService = SettingsService(sharedPreferences);

    await settingsService.setGradientUuid("4730aa2d-1a90-49a6-9942-ffe82f470e26");

    expect(sharedPreferences.getString("gradient_uuid"), "4730aa2d-1a90-49a6-9942-ffe82f470e26");
  });

  group("setUnsplashAuthor", () {
    test("with value saves author info", () async {
      final sharedPreferences = await SharedPreferences.getInstance();
      final settingsService = SettingsService(sharedPreferences);

      await settingsService.setUnsplashAuthor("unsplash author");

      expect(sharedPreferences.getString("unsplash_author"), "unsplash author");
    });

    test("without value erases author info", () async {
      final sharedPreferences = await SharedPreferences.getInstance();
      await sharedPreferences.setString("unsplash_author", "unsplash author");
      final settingsService = SettingsService(sharedPreferences);

      await settingsService.setUnsplashAuthor(null);

      expect(sharedPreferences.getString("unsplash_author"), isNull);
    });
  });

  test("unsplashEnabled is disabled without Firebase", () async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final settingsService = SettingsService(sharedPreferences);

    expect(settingsService.unsplashEnabled, isFalse);
  });

  test("unsplashAuthor", () async {
    final sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setString("unsplash_author", "unsplash author");
    final settingsService = SettingsService(sharedPreferences);

    expect(settingsService.unsplashAuthor, "unsplash author");
  });

  group("getGradientUuid", () {
    test("without uuid from shared preferences", () async {
      final sharedPreferences = await SharedPreferences.getInstance();
      await sharedPreferences.clear();
      final settingsService = SettingsService(sharedPreferences);

      expect(settingsService.gradientUuid, null);
    });

    test("with uuid from shared preferences", () async {
      final sharedPreferences = await SharedPreferences.getInstance();
      await sharedPreferences.clear();
      sharedPreferences.setString("gradient_uuid", "4730aa2d-1a90-49a6-9942-ffe82f470e26");
      final settingsService = SettingsService(sharedPreferences);

      expect(settingsService.gradientUuid, "4730aa2d-1a90-49a6-9942-ffe82f470e26");
    });
  });

  group("getUse24HourTimeFormat", () {
    test("without value from shared preferences", () async {
      final sharedPreferences = await SharedPreferences.getInstance();
      await sharedPreferences.clear();
      final settingsService = SettingsService(sharedPreferences);

      expect(settingsService.use24HourTimeFormat, isTrue);
    });

    test("with value from shared preferences", () async {
      final sharedPreferences = await SharedPreferences.getInstance();
      await sharedPreferences.clear();
      sharedPreferences.setBool("use_24_hour_time_format", false);
      final settingsService = SettingsService(sharedPreferences);

      expect(settingsService.use24HourTimeFormat, isFalse);
    });
  });
}