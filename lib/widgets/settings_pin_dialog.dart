/*
 * Postlounge TV — PIN gate for launcher admin settings.
 */

import 'package:flauncher/postlounge_config.dart';
import 'package:flauncher/widgets/settings/public_settings_panel.dart';
import 'package:flauncher/widgets/settings/settings_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<void> showPostloungePublicSettings(BuildContext context) async {
  await showDialog<void>(
    context: context,
    builder: (_) => const PublicSettingsPanel(),
  );
}

Future<void> showPostloungeAdminSettings(BuildContext context) async {
  final pin = await showDialog<String>(
    context: context,
    builder: (context) => const SettingsPinDialog(),
  );
  if (pin == kPostloungeSettingsPin) {
    if (!context.mounted) return;
    await showDialog<void>(
      context: context,
      builder: (_) => const SettingsPanel(),
    );
  } else if (pin != null && pin.isNotEmpty) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Incorrect PIN')),
    );
  }
}

@Deprecated('Use showPostloungePublicSettings from the home gear icon')
Future<void> showPostloungeSettings(BuildContext context) => showPostloungePublicSettings(context);

class SettingsPinDialog extends StatefulWidget {
  const SettingsPinDialog({Key? key}) : super(key: key);

  @override
  State<SettingsPinDialog> createState() => _SettingsPinDialogState();
}

class _SettingsPinDialogState extends State<SettingsPinDialog> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Launcher admin PIN'),
      content: TextField(
        controller: _controller,
        focusNode: _focusNode,
        autofocus: true,
        keyboardType: TextInputType.number,
        obscureText: true,
        maxLength: 8,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: const InputDecoration(
          counterText: '',
          hintText: 'PIN',
        ),
        onSubmitted: (value) => Navigator.of(context).pop(value),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(_controller.text),
          child: const Text('OK'),
        ),
      ],
    );
  }
}