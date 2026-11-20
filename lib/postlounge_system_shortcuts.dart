/*
 * Labels and display order for public system shortcuts (Postlounge TV).
 */

import 'package:flauncher/flauncher_channel.dart';

const kPostloungeShortcutSectionOrder = ['system', 'power', 'picture', 'input'];

/// Order within the device settings list (sections top→bottom, items top→bottom).
const kPostloungeShortcutIdOrder = [
  'settings_wifi',
  'settings_bluetooth',
  'settings_sound',
  'settings_display',
  'settings_android_tv',
  'settings_android',
  'power_standby',
  'power_shutdown',
  'power_reboot',
  'oem_focus_manual',
  'oem_focus_auto',
  'oem_keystone',
  'zeasn_picture',
  'tv_display',
  'zeasn_sources',
  'tv_input_picker',
];

String postloungeShortcutSectionTitle(String section) {
  switch (section) {
    case 'system':
      return 'Wi‑Fi, Bluetooth & systeem';
    case 'power':
      return 'Uitschakelen · Power';
    case 'picture':
      return 'Focus, beeld & projector';
    case 'input':
      return 'Bronnen · Input';
    default:
      return section;
  }
}

bool postloungeShortcutNeedsConfirm(String id) => id.startsWith('power_');

int postloungeShortcutSortKey(String id, String section) {
  final index = kPostloungeShortcutIdOrder.indexOf(id);
  if (index >= 0) return index;
  final sectionIndex = kPostloungeShortcutSectionOrder.indexOf(section);
  return 1000 + (sectionIndex < 0 ? 99 : sectionIndex) * 50;
}

List<PostloungeSystemShortcut> postloungeSortShortcuts(List<PostloungeSystemShortcut> shortcuts) {
  final copy = List<PostloungeSystemShortcut>.from(shortcuts);
  copy.sort((a, b) {
    final cmp = postloungeShortcutSortKey(a.id, a.section).compareTo(postloungeShortcutSortKey(b.id, b.section));
    if (cmp != 0) return cmp;
    return a.title.compareTo(b.title);
  });
  return copy;
}