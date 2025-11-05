import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool autoBookmark = false;
  bool enableNotifications = false;
  String readingMode = 'Vertical';
  String theme = 'System';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Reading', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 10),
          SegmentedButton<String>(
            segments: const <ButtonSegment<String>>[
              ButtonSegment<String>(value: 'Vertical', label: Text('Vertical')),
              ButtonSegment<String>(value: 'Horizontal', label: Text('Horizontal')),
            ],
            selected: {readingMode},
            onSelectionChanged: (selection) => setState(() => readingMode = selection.first),
          ),
          SwitchListTile(
            title: const Text('Auto Bookmark'),
            value: autoBookmark,
            onChanged: (val) => setState(() => autoBookmark = val),
          ),
          const Divider(height: 30),
          Text('Appearance', style: Theme.of(context).textTheme.titleLarge),
          SegmentedButton<String>(
            segments: const <ButtonSegment<String>>[
              ButtonSegment<String>(value: 'Light', label: Text('Light')),
              ButtonSegment<String>(value: 'Dark', label: Text('Dark')),
              ButtonSegment<String>(value: 'System', label: Text('System')),
            ],
            selected: {theme},
            onSelectionChanged: (selection) => setState(() => theme = selection.first),
          ),
          const Divider(height: 30),
          Text('Notifications', style: Theme.of(context).textTheme.titleLarge),
          SwitchListTile(
            title: const Text('Enable Notifications'),
            value: enableNotifications,
            onChanged: (val) => setState(() => enableNotifications = val),
          ),
        ],
      ),
    );
  }
}
