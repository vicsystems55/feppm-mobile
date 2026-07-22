import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key, this.userName, this.userEmail, this.onLogout});

  final String? userName;
  final String? userEmail;
  final Future<void> Function()? onLogout;

  @override
  Widget build(BuildContext context) {
    final name = userName?.trim().isNotEmpty == true
        ? userName!
        : 'Facility Manager';
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 110),
        children: [
          Text(
            'Profile',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF075BB5), Color(0xFF1264D8)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 31,
                  backgroundColor: Colors.white,
                  child: Text(
                    _initials(name),
                    style: const TextStyle(
                      color: Color(0xFF1264D8),
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        userEmail ?? '',
                        style: const TextStyle(
                          color: Color(0xFFDCEBFF),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Facility Manager',
                        style: TextStyle(
                          color: Color(0xFFB9D8FF),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const _SettingsGroup(
            title: 'Work settings',
            children: [
              _SettingsTile(
                icon: Icons.business_outlined,
                title: 'Assigned facility',
                subtitle: 'Managed by your FEPPM administrator',
              ),
              _SettingsTile(
                icon: Icons.notifications_none_rounded,
                title: 'Notifications',
                subtitle: 'Task reminders and overdue alerts',
              ),
            ],
          ),
          const SizedBox(height: 17),
          const _SettingsGroup(
            title: 'Application',
            children: [
              _SettingsTile(
                icon: Icons.cloud_done_outlined,
                title: 'Synchronization',
                subtitle: 'Connected to the FEPPM live service',
                status: 'Online',
              ),
              _SettingsTile(
                icon: Icons.language_rounded,
                title: 'Language',
                subtitle: 'English',
              ),
              _SettingsTile(
                icon: Icons.info_outline_rounded,
                title: 'About Mazilu Fe-PPM',
                subtitle: 'Version 1.0.0',
              ),
            ],
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () => _confirmLogout(context),
            icon: const Icon(Icons.logout_rounded, color: Color(0xFFD92D20)),
            label: const Text(
              'Sign out',
              style: TextStyle(color: Color(0xFFD92D20)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text(
          'You will need to sign in again to access your maintenance tasks.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
    if (confirmed == true) await onLogout?.call();
  }
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
      ),
      const SizedBox(height: 9),
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE4E7EC)),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(children: children),
      ),
    ],
  );
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.status,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final String? status;

  @override
  Widget build(BuildContext context) => ListTile(
    leading: Container(
      width: 39,
      height: 39,
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: const Color(0xFF1264D8), size: 21),
    ),
    title: Text(
      title,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
    ),
    subtitle: Text(
      subtitle,
      style: const TextStyle(color: Color(0xFF667085), fontSize: 11),
    ),
    trailing: status == null
        ? const Icon(Icons.chevron_right_rounded, size: 20)
        : Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFECFDF3),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Text(
              status!,
              style: const TextStyle(
                color: Color(0xFF079455),
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
  );
}

String _initials(String name) {
  final parts = name.trim().split(RegExp(r'\s+'));
  return parts.take(2).map((part) => part[0].toUpperCase()).join();
}
