import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myenvato/screens/settings/about_screen.dart';
import 'package:myenvato/screens/settings/accounts_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const String _prefsTimezoneKey = 'app_timezone';
  static const String _systemTimezoneValue = 'system';
  static const List<String> _timezones = [
    _systemTimezoneValue,
    'UTC',
    'Australia/Melbourne',
    'Asia/Dhaka',
    'Europe/London',
    'America/New_York',
    'America/Los_Angeles',
  ];

  String _selectedTimezone = _systemTimezoneValue;

  @override
  void initState() {
    super.initState();
    _loadTimezone();
  }

  Future<void> _loadTimezone() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_prefsTimezoneKey);
    if (saved != null && saved.isNotEmpty) {
      setState(() => _selectedTimezone = saved);
    }
  }

  String _formatOffset(Duration offset) {
    final sign = offset.isNegative ? '-' : '+';
    final totalMinutes = offset.inMinutes.abs();
    final hours = (totalMinutes ~/ 60).toString().padLeft(2, '0');
    final minutes = (totalMinutes % 60).toString().padLeft(2, '0');
    return 'UTC$sign$hours:$minutes';
  }

  String get _timezoneDisplay {
    if (_selectedTimezone == _systemTimezoneValue) {
      final now = DateTime.now();
      return 'System ${_formatOffset(now.timeZoneOffset)}';
    }
    return _selectedTimezone;
  }

  Future<void> _selectTimezone(String timezone) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsTimezoneKey, timezone);
    if (!mounted) {
      return;
    }
    setState(() => _selectedTimezone = timezone);
  }

  void _showTimezonePicker(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: _timezones.length,
            separatorBuilder: (_, __) => Divider(
              height: 1,
              color: colorScheme.onSurface.withOpacity(0.12),
            ),
            itemBuilder: (context, index) {
              final timezone = _timezones[index];
              final isSelected = timezone == _selectedTimezone;
              final label = timezone == _systemTimezoneValue
                  ? 'System (device)'
                  : timezone;
              return ListTile(
                title: Text(label),
                trailing: isSelected
                    ? Icon(Icons.check_circle, color: colorScheme.primary)
                    : null,
                onTap: () {
                  Navigator.pop(context);
                  _selectTimezone(timezone);
                },
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        children: [
          Text(
            'General',
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          _buildSectionSurface(
            context,
            children: [
              _buildListTile(
                context,
                icon: Icons.schedule,
                title: 'Timezone',
                subtitle: _timezoneDisplay,
                onTap: () => _showTimezonePicker(context),
              ),
              _buildDivider(context),
              _buildListTile(
                context,
                icon: Icons.account_circle,
                title: 'Accounts',
                onTap: () => Get.to(() => const AccountsScreen()),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Text(
            'More',
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          _buildSectionSurface(
            context,
            children: [
              _buildListTile(
                context,
                icon: Icons.info,
                title: 'About',
                onTap: () => Get.to(() => const AboutScreen()),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionSurface(BuildContext context, {required List<Widget> children}) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(16.0),
      clipBehavior: Clip.hardEdge,
      child: Column(children: children),
    );
  }

  // Helper method to create a ListTile
  ListTile _buildListTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    String? trailingText,
    VoidCallback? onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return ListTile(
      leading: _buildIconContainer(context, icon),
      title: Text(title),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
            )
          : null,
      trailing: trailingText != null
          ? ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 180),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      trailingText,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.chevron_right, color: colorScheme.onSurface),
                ],
              ),
            )
          : Icon(Icons.chevron_right, color: colorScheme.onSurface),
      onTap: onTap,
    );
  }

  // Helper method to create a divider
  Divider _buildDivider(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Divider(
      height: 1,
      thickness: 1,
      color: colorScheme.onSurface.withOpacity(0.08),
    );
  }

  // Helper method to create a square icon container
  Widget _buildIconContainer(BuildContext context, IconData icon) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: colorScheme.primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Icon(icon, color: colorScheme.primary, size: 18),
    );
  }
}
