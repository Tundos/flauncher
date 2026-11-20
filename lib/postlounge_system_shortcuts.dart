/*
 * Labels for public system shortcut sections (Postlounge TV).
 */

const kPostloungeShortcutSectionOrder = ['input', 'picture', 'system'];

String postloungeShortcutSectionTitle(String section) {
  switch (section) {
    case 'input':
      return 'Input & source';
    case 'picture':
      return 'Projector & picture';
    case 'system':
      return 'Android system';
    default:
      return section;
  }
}