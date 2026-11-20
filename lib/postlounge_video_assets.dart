/*
 * Bundled Postlounge video assets.
 */

import 'package:shared_preferences/shared_preferences.dart';

const kPostloungeBrandBgVideo = 'assets/videos/brand_bg.mp4';
const kPostloungeStartupVideo = 'assets/videos/startup_sequence.mp4';

/// Bumped when intro playback was fixed (avoid second player during intro).
const _postloungeStartupIntroPlayedKey = 'postlounge_startup_intro_played_v3';

bool postloungeShouldPlayStartupIntro(SharedPreferences prefs) =>
    !(prefs.getBool(_postloungeStartupIntroPlayedKey) ?? false);

Future<void> postloungeMarkStartupIntroPlayed(SharedPreferences prefs) async {
  await prefs.setBool(_postloungeStartupIntroPlayedKey, true);
}