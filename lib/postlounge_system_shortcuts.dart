/*
 * Labels for public system shortcut sections (Postlounge TV).
 */

const kPostloungeShortcutSectionOrder = ['input', 'picture', 'system', 'power'];

String postloungeShortcutSectionTitle(String section) {
  switch (section) {
    case 'input':
      return 'Input & source';
    case 'picture':
      return 'Projector & picture';
    case 'system':
      return 'Android system';
    case 'power':
      return 'Uitschakelen · Power';
    default:
      return section;
  }
}

bool postloungeShortcutNeedsConfirm(String id) => id.startsWith('power_');