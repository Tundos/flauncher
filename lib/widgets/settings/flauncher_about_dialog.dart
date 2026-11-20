/*
 * FLauncher
 * Copyright (C) 2021  Étienne Fesser
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class FLauncherAboutDialog extends StatelessWidget {
  final PackageInfo packageInfo;

  FLauncherAboutDialog({
    Key? key,
    required this.packageInfo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodyMedium!;
    final underlined = textStyle.copyWith(decoration: TextDecoration.underline);
    return AboutDialog(
      applicationName: packageInfo.appName,
      applicationVersion: "${packageInfo.version} (${packageInfo.buildNumber})",
      applicationIcon: Image.asset("assets/logo.png", height: 72),
      applicationLegalese: "© Postlounge",
      children: [
        SizedBox(height: 24),
        RichText(
          text: TextSpan(
            style: textStyle,
            children: [
              TextSpan(
                text: "Postlounge TV is a white-label Android TV launcher for Acer Aopen L20, "
                    "based on open-source FLauncher.\n",
              ),
              TextSpan(text: "Upstream: ", style: textStyle),
              TextSpan(text: "https://gitlab.com/flauncher/flauncher", style: underlined),
              TextSpan(text: "."),
            ],
          ),
        )
      ],
    );
  }
}
