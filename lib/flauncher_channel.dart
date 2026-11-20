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

import 'dart:async';

import 'package:flutter/services.dart';

class PostloungeSystemShortcut {
  final String id;
  final String title;
  final String section;
  final String resolvedLabel;

  const PostloungeSystemShortcut({
    required this.id,
    required this.title,
    required this.section,
    required this.resolvedLabel,
  });

  factory PostloungeSystemShortcut.fromMap(Map<dynamic, dynamic> map) => PostloungeSystemShortcut(
        id: map['id'] as String,
        title: map['title'] as String,
        section: map['section'] as String,
        resolvedLabel: map['resolvedLabel'] as String? ?? '',
      );
}

class PostloungeDiagnosticActivity {
  final String packageName;
  final String activityName;
  final String label;

  const PostloungeDiagnosticActivity({
    required this.packageName,
    required this.activityName,
    required this.label,
  });

  factory PostloungeDiagnosticActivity.fromMap(Map<dynamic, dynamic> map) => PostloungeDiagnosticActivity(
        packageName: map['package'] as String,
        activityName: map['activity'] as String,
        label: map['label'] as String? ?? '',
      );

  String get componentLine => '$packageName\n$activityName';
}

class FLauncherChannel {
  static const _methodChannel = MethodChannel('nl.postlounge.launcher/method');
  static const _eventChannel = EventChannel('nl.postlounge.launcher/event');

  Future<List<dynamic>> getApplications() async => (await _methodChannel.invokeListMethod('getApplications'))!;

  Future<void> launchApp(String packageName) async => await _methodChannel.invokeMethod('launchApp', packageName);

  Future<void> openSettings() async => await _methodChannel.invokeMethod('openSettings');

  Future<void> openAppInfo(String packageName) async => await _methodChannel.invokeMethod('openAppInfo', packageName);

  Future<void> uninstallApp(String packageName) async => await _methodChannel.invokeMethod('uninstallApp', packageName);

  Future<bool> isDefaultLauncher() async => await _methodChannel.invokeMethod('isDefaultLauncher');

  Future<bool> checkForGetContentAvailability() async =>
      await _methodChannel.invokeMethod("checkForGetContentAvailability");

  Future<List<PostloungeSystemShortcut>> getResolvedSystemShortcuts() async {
    final raw = await _methodChannel.invokeListMethod('getResolvedSystemShortcuts') ?? [];
    return raw
        .cast<Map<dynamic, dynamic>>()
        .map((e) => PostloungeSystemShortcut.fromMap(e))
        .toList(growable: false);
  }

  Future<bool> launchSystemShortcut(String id) async =>
      await _methodChannel.invokeMethod<bool>('launchSystemShortcut', id) ?? false;

  Future<List<PostloungeDiagnosticActivity>> scanSettingsDiagnostic() async {
    final raw = await _methodChannel.invokeListMethod('scanSettingsDiagnostic') ?? [];
    return raw
        .cast<Map<dynamic, dynamic>>()
        .map((e) => PostloungeDiagnosticActivity.fromMap(e))
        .toList(growable: false);
  }

  void addAppsChangedListener(void Function(Map<dynamic, dynamic>) listener) =>
      _eventChannel.receiveBroadcastStream().listen((event) => listener(event));
}
