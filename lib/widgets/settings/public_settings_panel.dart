/*
 * Postlounge TV — right-hand panel for public device settings.
 */

import 'package:flauncher/widgets/right_panel_dialog.dart';
import 'package:flauncher/widgets/settings/public_settings_panel_page.dart';
import 'package:flutter/material.dart';

class PublicSettingsPanel extends StatefulWidget {
  const PublicSettingsPanel({super.key});

  @override
  State<PublicSettingsPanel> createState() => _PublicSettingsPanelState();
}

class _PublicSettingsPanelState extends State<PublicSettingsPanel> {
  @override
  Widget build(BuildContext context) => WillPopScope(
        onWillPop: () async => true,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: RightPanelDialog(
            width: 420,
            child: const PublicSettingsPanelPage(),
          ),
        ),
      );
}