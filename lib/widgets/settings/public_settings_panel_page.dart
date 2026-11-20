/*
 * Postlounge TV — device settings (no PIN).
 */

import 'package:flauncher/flauncher_channel.dart';
import 'package:flauncher/postlounge_system_shortcuts.dart';
import 'package:flauncher/widgets/settings_pin_dialog.dart';
import 'package:flutter/material.dart';

class PublicSettingsPanelPage extends StatefulWidget {
  static const String routeName = 'public_settings_panel';

  const PublicSettingsPanelPage({super.key});

  @override
  State<PublicSettingsPanelPage> createState() => _PublicSettingsPanelPageState();
}

class _PublicSettingsPanelPageState extends State<PublicSettingsPanelPage> {
  final _channel = FLauncherChannel();
  late Future<List<PostloungeSystemShortcut>> _shortcutsFuture;

  static const _accent = Color(0xFF007DFA);

  @override
  void initState() {
    super.initState();
    _shortcutsFuture = _channel.getResolvedSystemShortcuts();
  }

  Future<void> _reload() async {
    setState(() {
      _shortcutsFuture = _channel.getResolvedSystemShortcuts();
    });
    await _shortcutsFuture;
  }

  Future<void> _launch(String id) async {
    final ok = await _channel.launchSystemShortcut(id);
    if (!mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open this menu on this device')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Device settings', style: theme.textTheme.titleLarge),
        Text(
          'Wi‑Fi, inputs, and picture — no PIN',
          style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
        ),
        const Divider(),
        Expanded(
          child: FutureBuilder<List<PostloungeSystemShortcut>>(
            future: _shortcutsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Could not load menus\n${snapshot.error}'));
              }
              final shortcuts = snapshot.data ?? [];
              if (shortcuts.isEmpty) {
                return Center(
                  child: Text(
                    'No system menus resolved on this device.',
                    style: theme.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                );
              }
              final bySection = <String, List<PostloungeSystemShortcut>>{};
              for (final item in shortcuts) {
                bySection.putIfAbsent(item.section, () => []).add(item);
              }
              return FocusTraversalGroup(
                child: ListView(
                  children: [
                    for (final section in kPostloungeShortcutSectionOrder)
                      if (bySection[section]?.isNotEmpty == true) ...[
                        Padding(
                          padding: const EdgeInsets.only(top: 8, bottom: 4),
                          child: Text(
                            postloungeShortcutSectionTitle(section),
                            style: theme.textTheme.titleSmall?.copyWith(color: _accent),
                          ),
                        ),
                        for (final shortcut in bySection[section]!)
                          _ShortcutTile(
                            title: shortcut.title,
                            subtitle: shortcut.resolvedLabel,
                            onActivate: () => _launch(shortcut.id),
                          ),
                      ],
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: _reload,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Refresh list'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const Divider(),
        TextButton.icon(
          onPressed: () => showPostloungeAdminSettings(context),
          icon: const Icon(Icons.lock_outline),
          label: const Text('Launcher admin (PIN)'),
        ),
      ],
    );
  }
}

class _ShortcutTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onActivate;

  const _ShortcutTile({
    required this.title,
    required this.subtitle,
    required this.onActivate,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Material(
          color: Colors.white.withOpacity(0.04),
          child: InkWell(
            onTap: onActivate,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  const Icon(Icons.arrow_forward_ios, size: 14),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: Theme.of(context).textTheme.bodyLarge),
                        if (subtitle.isNotEmpty)
                          Text(
                            subtitle,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white60),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}