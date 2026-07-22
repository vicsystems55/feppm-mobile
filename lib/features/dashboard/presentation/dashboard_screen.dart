import 'package:flutter/material.dart';

import '../data/facility_dashboard_service.dart';
import '../data/facility_models.dart';
import 'pages/activity_page.dart';
import 'pages/home_page.dart';
import 'pages/profile_page.dart';
import 'pages/tasks_page.dart';
import 'task_detail_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    super.key,
    required this.accessToken,
    this.userName,
    this.userEmail,
    this.onLogout,
  });

  final String accessToken;
  final String? userName;
  final String? userEmail;
  final Future<void> Function()? onLogout;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late final FacilityDashboardService _service;
  late final List<Widget?> _pages;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _service = FacilityDashboardService(accessToken: widget.accessToken);
    _pages = List<Widget?>.filled(4, null);
    _pages[0] = _createPage(0);
  }

  Future<void> _openTask(FacilityTask task) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => TaskDetailScreen(task: task, service: _service),
      ),
    );
    if (changed == true && mounted) {
      setState(() => _pages[1] = _createPage(1));
    }
  }

  void _selectPage(int index) {
    setState(() {
      _pages[index] ??= _createPage(index);
      _selectedIndex = index;
    });
  }

  Widget _createPage(int index) => switch (index) {
    0 => HomePage(
      service: _service,
      userName: widget.userName,
      onViewTasks: () => _selectPage(1),
      onTaskSelected: _openTask,
      onScan: _showScanActions,
    ),
    1 => TasksPage(service: _service, onTaskSelected: _openTask),
    2 => ActivityPage(service: _service),
    _ => ProfilePage(
      userName: widget.userName,
      userEmail: widget.userEmail,
      onLogout: widget.onLogout,
    ),
  };

  void _showScanActions() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Field actions',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              const Text(
                'Quickly identify equipment or report an issue.',
                style: TextStyle(color: Color(0xFF667085)),
              ),
              const SizedBox(height: 18),
              _ActionTile(
                icon: Icons.qr_code_scanner_rounded,
                color: const Color(0xFF1264D8),
                title: 'Scan equipment QR',
                subtitle: 'Open an equipment record and its assigned tasks',
                onTap: () => _showComingSoon('QR equipment scanning'),
              ),
              const SizedBox(height: 10),
              _ActionTile(
                icon: Icons.report_problem_outlined,
                color: const Color(0xFFF79009),
                title: 'Report a fault',
                subtitle: 'Record an equipment issue for follow-up',
                onTap: () => _showComingSoon('Fault reporting'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showComingSoon(String feature) {
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature will be connected in the next module.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages
            .map((page) => page ?? const SizedBox.shrink())
            .toList(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: _showScanActions,
        elevation: 3,
        backgroundColor: const Color(0xFF1264D8),
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        child: const Icon(Icons.qr_code_scanner_rounded, size: 28),
      ),
      bottomNavigationBar: _DashboardNavigation(
        selectedIndex: _selectedIndex,
        onSelected: _selectPage,
      ),
    );
  }
}

class _DashboardNavigation extends StatelessWidget {
  const _DashboardNavigation({
    required this.selectedIndex,
    required this.onSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      height: 74,
      padding: EdgeInsets.zero,
      color: Colors.white,
      surfaceTintColor: Colors.white,
      notchMargin: 8,
      shape: const CircularNotchedRectangle(),
      child: Row(
        children: [
          Expanded(
            child: _NavItem(
              icon: Icons.home_outlined,
              selectedIcon: Icons.home_rounded,
              label: 'Home',
              selected: selectedIndex == 0,
              onTap: () => onSelected(0),
            ),
          ),
          Expanded(
            child: _NavItem(
              icon: Icons.assignment_outlined,
              selectedIcon: Icons.assignment_rounded,
              label: 'Tasks',
              selected: selectedIndex == 1,
              onTap: () => onSelected(1),
            ),
          ),
          const SizedBox(width: 72),
          Expanded(
            child: _NavItem(
              icon: Icons.history_rounded,
              selectedIcon: Icons.manage_history_rounded,
              label: 'Activity',
              selected: selectedIndex == 2,
              onTap: () => onSelected(2),
            ),
          ),
          Expanded(
            child: _NavItem(
              icon: Icons.person_outline_rounded,
              selectedIcon: Icons.person_rounded,
              label: 'Profile',
              selected: selectedIndex == 3,
              onTap: () => onSelected(3),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? const Color(0xFF1264D8) : const Color(0xFF667085);
    return InkResponse(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(selected ? selectedIcon : icon, color: color, size: 23),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ListTile(
    onTap: onTap,
    contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
    leading: Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Icon(icon, color: color),
    ),
    title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
    subtitle: Text(subtitle),
    trailing: const Icon(Icons.chevron_right_rounded),
  );
}
