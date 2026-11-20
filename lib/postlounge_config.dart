/*
 * Postlounge TV launcher branding constants.
 */

/// Settings panel PIN (kiosk skeleton — full kiosk mode is a later pass).
const kPostloungeSettingsPin = '8494';

/// Package names to hide on first-run catalog setup (refine on L20 hardware).
const kPostloungeHiddenPackages = <String>{
  'nl.postlounge.launcher',
  'com.android.tv.feedback',
  'com.google.android.tv.axel',
  'com.google.android.tvlauncher',
};

/// Hide apps whose package name starts with any of these prefixes (OEM / vendor clutter).
const kPostloungeHiddenPackagePrefixes = <String>[
  'com.softwinner.',
  'com.cvte.',
  'com.hisilicon.',
  'com.droidlogic.tvinput',
  'com.realtek.',
  'com.acer.',
];

bool postloungeShouldHidePackage(String packageName) {
  if (kPostloungeHiddenPackages.contains(packageName)) {
    return true;
  }
  for (final prefix in kPostloungeHiddenPackagePrefixes) {
    if (packageName.startsWith(prefix)) {
      return true;
    }
  }
  return false;
}