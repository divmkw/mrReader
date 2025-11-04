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
          RadioListTile(
            title: const Text('Vertical (Webtoon style)'),
            value: 'Vertical',
            groupValue: readingMode,
            onChanged: (val) => setState(() => readingMode = val!),
          ),
          RadioListTile(
            title: const Text('Horizontal (Page by page)'),
            value: 'Horizontal',
            groupValue: readingMode,
            onChanged: (val) => setState(() => readingMode = val!),
          ),
          SwitchListTile(
            title: const Text('Auto Bookmark'),
            value: autoBookmark,
            onChanged: (val) => setState(() => autoBookmark = val),
          ),
          const Divider(height: 30),
          Text('Appearance', style: Theme.of(context).textTheme.titleLarge),
          RadioListTile(
            title: const Text('Light'),
            value: 'Light',
            groupValue: theme,
            onChanged: (val) => setState(() => theme = val!),
          ),
          RadioListTile(
            title: const Text('Dark'),
            value: 'Dark',
            groupValue: theme,
            onChanged: (val) => setState(() => theme = val!),
          ),
          RadioListTile(
            title: const Text('System'),
            value: 'System',
            groupValue: theme,
            onChanged: (val) => setState(() => theme = val!),
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
