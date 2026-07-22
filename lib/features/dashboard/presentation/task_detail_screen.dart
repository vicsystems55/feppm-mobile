import 'package:flutter/material.dart';

import '../data/facility_dashboard_service.dart';
import '../data/facility_models.dart';
import 'widgets/dashboard_widgets.dart';

class TaskDetailScreen extends StatefulWidget {
  const TaskDetailScreen({
    super.key,
    required this.task,
    required this.service,
  });
  final FacilityTask task;
  final FacilityDashboardService service;

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  bool _starting = false;
  bool _started = false;

  Future<void> _start() async {
    setState(() => _starting = true);
    try {
      await widget.service.startTask(widget.task.id);
      if (!mounted) return;
      setState(() => _started = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Task started. Your progress is now tracked.'),
        ),
      );
    } on DashboardApiException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } finally {
      if (mounted) setState(() => _starting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.task;
    final color = statusAppearance(task.status).color;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Task Details',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [color, color.withValues(alpha: 0.78)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 54,
                          height: 54,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(Icons.ac_unit_rounded, color: color),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                task.assetCode,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                task.templateName ?? task.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                '${task.frequency.label} routine',
                                style: const TextStyle(
                                  color: Color(0xFFE6F4FF),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _started ? 'In progress' : task.status.label,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: const Color(0xFFE4E7EC)),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      children: [
                        _DetailRow(label: 'Facility', value: task.facilityName),
                        _DetailRow(label: 'Equipment', value: task.title),
                        _DetailRow(
                          label: 'Due date',
                          value: task.dueAt == null
                              ? 'Current period'
                              : '${formatShortDate(task.dueAt!.toLocal())} · ${formatTaskTime(task.dueAt)}',
                        ),
                        _DetailRow(
                          label: 'Frequency',
                          value: task.frequency.label,
                        ),
                        _DetailRow(
                          label: 'Estimated time',
                          value: task.estimatedMinutes == null
                              ? '${task.items.length * 2} min'
                              : '${task.estimatedMinutes} min',
                          last: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  SectionHeader(title: 'Checklist (${task.items.length})'),
                  const SizedBox(height: 10),
                  if (task.items.isEmpty)
                    const EmptyState(
                      icon: Icons.playlist_add_check_rounded,
                      title: 'Checklist details unavailable',
                      message:
                          'Open this task from the Tasks tab to load its full checklist.',
                    )
                  else
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: const Color(0xFFE4E7EC)),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        children: List.generate(task.items.length, (index) {
                          final item = task.items[index];
                          return _ChecklistRow(
                            number: index + 1,
                            item: item,
                            last: index == task.items.length - 1,
                          );
                        }),
                      ),
                    ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFE4E7EC))),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton.icon(
                  onPressed: _starting || _started || task.items.isEmpty
                      ? null
                      : _start,
                  icon: _starting
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Icon(
                          _started
                              ? Icons.check_circle_outline_rounded
                              : Icons.play_arrow_rounded,
                        ),
                  label: Text(
                    _starting
                        ? 'Starting task…'
                        : _started
                        ? 'Task in progress'
                        : 'Start task',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.last = false,
  });
  final String label;
  final String value;
  final bool last;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 11),
    decoration: BoxDecoration(
      border: last
          ? null
          : const Border(bottom: BorderSide(color: Color(0xFFEAECF0))),
    ),
    child: Row(
      children: [
        SizedBox(
          width: 108,
          child: Text(
            label,
            style: const TextStyle(color: Color(0xFF667085), fontSize: 12),
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: Color(0xFF101828),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );
}

class _ChecklistRow extends StatelessWidget {
  const _ChecklistRow({
    required this.number,
    required this.item,
    required this.last,
  });
  final int number;
  final ChecklistQuestion item;
  final bool last;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(
      border: last
          ? null
          : const Border(bottom: BorderSide(color: Color(0xFFEAECF0))),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: Color(0xFFEFF6FF),
            shape: BoxShape.circle,
          ),
          child: Text(
            '$number',
            style: const TextStyle(
              color: Color(0xFF1264D8),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (item.instruction?.isNotEmpty == true) ...[
                const SizedBox(height: 4),
                Text(
                  item.instruction!,
                  style: const TextStyle(
                    color: Color(0xFF667085),
                    fontSize: 11,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (item.isPhoto || item.photoRequired)
          const Padding(
            padding: EdgeInsets.only(left: 7),
            child: Icon(
              Icons.camera_alt_outlined,
              color: Color(0xFF1264D8),
              size: 19,
            ),
          ),
      ],
    ),
  );
}
