import 'package:flutter/material.dart';

import '../../data/facility_dashboard_service.dart';
import '../../data/facility_models.dart';
import '../widgets/dashboard_widgets.dart';

class ActivityPage extends StatefulWidget {
  const ActivityPage({super.key, required this.service});
  final FacilityDashboardService service;

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  List<FacilityTask> _tasks = const [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait(
        TaskFrequency.values.map(widget.service.fetchTasks),
      );
      if (!mounted) return;
      setState(() {
        _tasks = results.expand((items) => items).toList()
          ..sort((a, b) {
            final left = a.dueAt ?? DateTime.fromMillisecondsSinceEpoch(0);
            final right = b.dueAt ?? DateTime.fromMillisecondsSinceEpoch(0);
            return right.compareTo(left);
          });
        _error = null;
      });
    } on DashboardApiException catch (error) {
      if (!mounted) return;
      setState(() => _error = error.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final completed = _tasks
        .where((task) => task.status == FacilityTaskStatus.completed)
        .toList();
    final active = _tasks
        .where((task) => task.status == FacilityTaskStatus.inProgress)
        .length;

    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 110),
          children: [
            Row(
              children: [
                Text(
                  'My Activity',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const Spacer(),
                IconButton(
                  onPressed: _load,
                  icon: const Icon(Icons.sync_rounded),
                ),
              ],
            ),
            const SizedBox(height: 7),
            const Text(
              'Your daily, weekly and monthly maintenance record.',
              style: TextStyle(color: Color(0xFF667085), fontSize: 13),
            ),
            const SizedBox(height: 21),
            Row(
              children: [
                Expanded(
                  child: _ActivityMetric(
                    icon: Icons.task_alt_rounded,
                    value: completed.length,
                    label: 'Completed',
                    color: const Color(0xFF079455),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _ActivityMetric(
                    icon: Icons.pending_actions_rounded,
                    value: active,
                    label: 'In progress',
                    color: const Color(0xFFF79009),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _ActivityMetric(
                    icon: Icons.calendar_month_outlined,
                    value: _tasks.length,
                    label: 'Assigned',
                    color: const Color(0xFF1264D8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 26),
            const SectionHeader(title: 'Recent submissions'),
            const SizedBox(height: 11),
            if (_loading)
              const Padding(
                padding: EdgeInsets.all(40),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error != null)
              EmptyState(
                icon: Icons.cloud_off_outlined,
                title: 'Unable to load activity',
                message: _error!,
                actionLabel: 'Try again',
                onAction: _load,
              )
            else if (completed.isEmpty)
              const EmptyState(
                icon: Icons.history_toggle_off_rounded,
                title: 'No submissions yet',
                message:
                    'Completed inspections will appear here as your maintenance activity history.',
              )
            else
              ...completed.map(
                (task) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: TaskCard(task: task),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ActivityMetric extends StatelessWidget {
  const _ActivityMetric({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });
  final IconData icon;
  final int value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 8),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: const Color(0xFFE4E7EC)),
      borderRadius: BorderRadius.circular(13),
    ),
    child: Column(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 8),
        Text(
          '$value',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Color(0xFF667085), fontSize: 10),
        ),
      ],
    ),
  );
}
