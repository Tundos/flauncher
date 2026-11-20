/*
 * Postlounge TV — OEM / settings discovery (PIN-protected).
 */

import 'package:flauncher/flauncher_channel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DiagnosticPanelPage extends StatefulWidget {
  static const String routeName = 'diagnostic_panel';

  const DiagnosticPanelPage({super.key});

  @override
  State<DiagnosticPanelPage> createState() => _DiagnosticPanelPageState();
}

class _DiagnosticPanelPageState extends State<DiagnosticPanelPage> {
  final _channel = FLauncherChannel();
  late Future<List<PostloungeDiagnosticActivity>> _scanFuture;

  @override
  void initState() {
    super.initState();
    _scanFuture = _channel.scanSettingsDiagnostic();
  }

  Future<void> _rescan() async {
    setState(() {
      _scanFuture = _channel.scanSettingsDiagnostic();
    });
    await _scanFuture;
  }

  void _copyLine(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied — use when hardcoding OEM shortcuts')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('OEM discovery', style: theme.textTheme.titleLarge),
        Text(
          'Packages and activities matching settings, picture, TV, input, Acer…',
          style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
        ),
        const Divider(),
        Expanded(
          child: FutureBuilder<List<PostloungeDiagnosticActivity>>(
            future: _scanFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              final rows = snapshot.data ?? [];
              if (rows.isEmpty) {
                return const Center(child: Text('No matching components found.'));
              }
              return ListView.builder(
                itemCount: rows.length,
                itemBuilder: (context, index) {
                  final row = rows[index];
                  final copyText = '${row.packageName}/${row.activityName}';
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Material(
                      color: Colors.white.withOpacity(0.04),
                      child: InkWell(
                        onTap: () => _copyLine(copyText),
                        onLongPress: () => _copyLine(copyText),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (row.label.isNotEmpty)
                                Text(row.label, style: theme.textTheme.bodyLarge),
                              Text(
                                row.packageName,
                                style: theme.textTheme.bodySmall?.copyWith(fontFamily: 'monospace'),
                              ),
                              Text(
                                row.activityName,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontFamily: 'monospace',
                                  color: const Color(0xFF007DFA),
                                ),
                              ),
                              Text(
                                'OK / long-press to copy package/activity',
                                style: theme.textTheme.labelSmall?.copyWith(color: Colors.white54),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        OutlinedButton.icon(
          onPressed: _rescan,
          icon: const Icon(Icons.refresh),
          label: const Text('Scan again'),
        ),
      ],
    );
  }
}