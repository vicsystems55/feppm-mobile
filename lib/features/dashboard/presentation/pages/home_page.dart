import 'package:flutter/material.dart';

import '../../data/facility_dashboard_service.dart';
import '../../data/facility_models.dart';
import '../widgets/dashboard_widgets.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.service,
    required this.onViewTasks,
    required this.onTaskSelected,
    required this.onScan,
    this.userName,
  });

  final FacilityDashboardService service;
  final String? userName;
  final VoidCallback onViewTasks;
  final ValueChanged<FacilityTask> onTaskSelected;
  final VoidCallback onScan;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DashboardSummary? _summary;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (mounted) setState(() => _loading = true);
    try {
      final summary = await widget.service.fetchSummary();
      if (!mounted) return;
      setState(() {
        _summary = summary;
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
    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 110),
          children: [
            FeppmHeader(
              trailing: Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('You have no new alerts.')),
                    ),
                    icon: const Icon(Icons.notifications_none_rounded),
                  ),
                  if ((_summary?.overdueTasks ?? 0) > 0)
                    Positioned(
                      right: 5,
                      top: 2,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Color(0xFFF79009),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${_summary!.overdueTasks}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Text(
              '${_greeting()}, ${_firstName(widget.userName)} 👋',
              style: const TextStyle(
                color: Color(0xFF101828),
                fontSize: 21,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              _summary?.scopeName ?? "Here's your maintenance overview today.",
              style: const TextStyle(color: Color(0xFF667085), fontSize: 13),
            ),
            const SizedBox(height: 20),
            if (_loading && _summary == null)
              const _SummarySkeleton()
            else
              _SummaryCard(summary: _summary),
            if (_error != null) ...[
              const SizedBox(height: 12),
              _ConnectionBanner(message: _error!, onRetry: _load),
            ],
            const SizedBox(height: 22),
            SectionHeader(
              title: "Today's Tasks",
              actionLabel: 'View all',
              onAction: widget.onViewTasks,
            ),
            const SizedBox(height: 10),
            if (!_loading && (_summary?.myTasks.isEmpty ?? true))
              const EmptyState(
                icon: Icons.task_alt_rounded,
                title: 'No tasks due today',
                message:
                    'Assigned daily maintenance tasks will appear here when a checklist is published.',
              )
            else
              ...?_summary?.myTasks
                  .take(3)
                  .map(
                    (task) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: TaskCard(
                        task: task,
                        onTap: () => widget.onTaskSelected(task),
                      ),
                    ),
                  ),
            const SizedBox(height: 15),
            const SectionHeader(title: 'Quick Actions'),
            const SizedBox(height: 11),
            Row(
              children: [
                Expanded(
                  child: _QuickAction(
                    icon: Icons.qr_code_scanner_rounded,
                    color: const Color(0xFF1264D8),
                    label: 'Scan QR',
                    onTap: widget.onScan,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _QuickAction(
                    icon: Icons.warning_amber_rounded,
                    color: const Color(0xFFF79009),
                    label: 'Report fault',
                    onTap: () => _notReady('Fault reporting'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _QuickAction(
                    icon: Icons.sync_rounded,
                    color: const Color(0xFF079455),
                    label: 'Sync now',
                    onTap: _load,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const SectionHeader(title: 'Equipment Readiness'),
            const SizedBox(height: 11),
            _EquipmentCard(summary: _summary),
          ],
        ),
      ),
    );
  }

  void _notReady(String name) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$name is coming next.')));
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.summary});
  final DashboardSummary? summary;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 15, 14, 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF075BB5), Color(0xFF1264D8), Color(0xFF07549D)],
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(
            color: Color(0x332563EB),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Text(
                "Today's Summary",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                formatShortDate(today),
                style: const TextStyle(color: Colors.white, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 13),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Row(
              children: [
                _Metric(
                  value: summary?.tasksToday ?? 0,
                  label: 'Total tasks',
                  color: const Color(0xFF1264D8),
                ),
                _Metric(
                  value: summary?.completedToday ?? 0,
                  label: 'Completed',
                  color: const Color(0xFF079455),
                ),
                _Metric(
                  value: summary?.inProgressToday ?? 0,
                  label: 'In progress',
                  color: const Color(0xFFF79009),
                ),
                _Metric(
                  value: summary?.overdueTasks ?? 0,
                  label: 'Overdue',
                  color: const Color(0xFFD92D20),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.value,
    required this.label,
    required this.color,
  });
  final int value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Text(
              '$value',
              style: const TextStyle(
                color: Color(0xFF101828),
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 7),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Color(0xFF475467), fontSize: 10),
        ),
      ],
    ),
  );
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 94,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE4E7EC)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 21),
            ),
            const SizedBox(height: 7),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    ),
  );
}

class _EquipmentCard extends StatelessWidget {
  const _EquipmentCard({required this.summary});
  final DashboardSummary? summary;

  @override
  Widget build(BuildContext context) {
    final total = summary?.equipment ?? 0;
    final ready = summary?.operationalEquipment ?? 0;
    final ratio = total == 0 ? 0.0 : ready / total;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE4E7EC)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 62,
            height: 62,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: ratio,
                  strokeWidth: 7,
                  backgroundColor: const Color(0xFFEAECF0),
                  color: const Color(0xFF079455),
                ),
                Center(
                  child: Text(
                    '${(ratio * 100).round()}%',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Operational equipment',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                ),
                const SizedBox(height: 5),
                Text(
                  '$ready of $total registered units are functional',
                  style: const TextStyle(
                    color: Color(0xFF667085),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ConnectionBanner extends StatelessWidget {
  const _ConnectionBanner({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(12, 10, 6, 10),
    decoration: BoxDecoration(
      color: const Color(0xFFFFFAEB),
      borderRadius: BorderRadius.circular(9),
      border: Border.all(color: const Color(0xFFFEC84B)),
    ),
    child: Row(
      children: [
        const Icon(
          Icons.cloud_off_outlined,
          color: Color(0xFFB54708),
          size: 20,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            message,
            style: const TextStyle(color: Color(0xFFB54708), fontSize: 12),
          ),
        ),
        TextButton(onPressed: onRetry, child: const Text('Retry')),
      ],
    ),
  );
}

class _SummarySkeleton extends StatelessWidget {
  const _SummarySkeleton();

  @override
  Widget build(BuildContext context) => Container(
    height: 148,
    decoration: BoxDecoration(
      color: const Color(0xFFEFF6FF),
      borderRadius: BorderRadius.circular(15),
    ),
    child: const Center(child: CircularProgressIndicator()),
  );
}

String _greeting() {
  final hour = DateTime.now().hour;
  if (hour < 12) return 'Good morning';
  if (hour < 17) return 'Good afternoon';
  return 'Good evening';
}

String _firstName(String? value) {
  if (value == null || value.trim().isEmpty) return 'Manager';
  return value.trim().split(RegExp(r'\s+')).first;
}
