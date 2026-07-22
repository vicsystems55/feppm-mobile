import 'package:flutter/material.dart';

import '../../data/facility_dashboard_service.dart';
import '../../data/facility_models.dart';
import '../widgets/dashboard_widgets.dart';

enum _TaskFilter { all, completed, inProgress, overdue }

class TasksPage extends StatefulWidget {
  const TasksPage({
    super.key,
    required this.service,
    required this.onTaskSelected,
  });
  final FacilityDashboardService service;
  final ValueChanged<FacilityTask> onTaskSelected;

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  TaskFrequency _frequency = TaskFrequency.daily;
  _TaskFilter _filter = _TaskFilter.all;
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
      final tasks = await widget.service.fetchTasks(_frequency);
      if (!mounted) return;
      setState(() {
        _tasks = tasks;
        _error = null;
      });
    } on DashboardApiException catch (error) {
      if (!mounted) return;
      setState(() => _error = error.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<FacilityTask> get _filteredTasks => _tasks.where((task) {
    return switch (_filter) {
      _TaskFilter.all => true,
      _TaskFilter.completed => task.status == FacilityTaskStatus.completed,
      _TaskFilter.inProgress => task.status == FacilityTaskStatus.inProgress,
      _TaskFilter.overdue =>
        task.status == FacilityTaskStatus.overdue ||
            task.status == FacilityTaskStatus.missed,
    };
  }).toList();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      'Maintenance Tasks',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      tooltip: 'Refresh tasks',
                      onPressed: _load,
                      icon: const Icon(Icons.sync_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 17),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAECF0),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Row(
                    children: TaskFrequency.values.map((frequency) {
                      final selected = frequency == _frequency;
                      return Expanded(
                        child: InkWell(
                          onTap: () {
                            if (selected) return;
                            setState(() {
                              _frequency = frequency;
                              _filter = _TaskFilter.all;
                            });
                            _load();
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: selected
                                  ? Colors.white
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: selected
                                  ? const [
                                      BoxShadow(
                                        color: Color(0x14000000),
                                        blurRadius: 5,
                                        offset: Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Text(
                              frequency.label,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: selected
                                    ? const Color(0xFF1264D8)
                                    : const Color(0xFF667085),
                                fontSize: 13,
                                fontWeight: selected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 17),
                _WeekStrip(selected: DateTime.now()),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _FilterChip(
                        label: 'All',
                        count: _tasks.length,
                        selected: _filter == _TaskFilter.all,
                        onTap: () => setState(() => _filter = _TaskFilter.all),
                      ),
                      _FilterChip(
                        label: 'Completed',
                        count: _count(FacilityTaskStatus.completed),
                        selected: _filter == _TaskFilter.completed,
                        onTap: () =>
                            setState(() => _filter = _TaskFilter.completed),
                      ),
                      _FilterChip(
                        label: 'In progress',
                        count: _count(FacilityTaskStatus.inProgress),
                        selected: _filter == _TaskFilter.inProgress,
                        onTap: () =>
                            setState(() => _filter = _TaskFilter.inProgress),
                      ),
                      _FilterChip(
                        label: 'Overdue',
                        count: _tasks
                            .where(
                              (task) =>
                                  task.status == FacilityTaskStatus.overdue ||
                                  task.status == FacilityTaskStatus.missed,
                            )
                            .length,
                        selected: _filter == _TaskFilter.overdue,
                        onTap: () =>
                            setState(() => _filter = _TaskFilter.overdue),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 13),
              ],
            ),
          ),
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return EmptyState(
        icon: Icons.cloud_off_outlined,
        title: 'Unable to load tasks',
        message: _error!,
        actionLabel: 'Try again',
        onAction: _load,
      );
    }
    if (_filteredTasks.isEmpty) {
      return EmptyState(
        icon: Icons.event_available_rounded,
        title: 'No ${_frequency.label.toLowerCase()} tasks',
        message: _filter == _TaskFilter.all
            ? 'Tasks appear here when an active checklist is assigned to equipment at your facility.'
            : 'There are no tasks matching this status.',
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 110),
        itemCount: _filteredTasks.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final task = _filteredTasks[index];
          return TaskCard(task: task, onTap: () => widget.onTaskSelected(task));
        },
      ),
    );
  }

  int _count(FacilityTaskStatus status) =>
      _tasks.where((task) => task.status == status).length;
}

class _WeekStrip extends StatelessWidget {
  const _WeekStrip({required this.selected});
  final DateTime selected;

  @override
  Widget build(BuildContext context) {
    final start = selected.subtract(Duration(days: selected.weekday - 1));
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return Row(
      children: List.generate(7, (index) {
        final date = start.add(Duration(days: index));
        final active =
            date.year == selected.year &&
            date.month == selected.month &&
            date.day == selected.day;
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: index == 6 ? 0 : 5),
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: active ? const Color(0xFF1264D8) : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: active
                  ? null
                  : Border.all(color: const Color(0xFFEAECF0)),
            ),
            child: Column(
              children: [
                Text(
                  names[index],
                  style: TextStyle(
                    color: active ? Colors.white : const Color(0xFF667085),
                    fontSize: 9,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${date.day}',
                  style: TextStyle(
                    color: active ? Colors.white : const Color(0xFF101828),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(right: 8),
    child: ChoiceChip(
      selected: selected,
      onSelected: (_) => onTap(),
      label: Text('$label ($count)'),
      showCheckmark: false,
      labelStyle: TextStyle(
        color: selected ? const Color(0xFF1264D8) : const Color(0xFF667085),
        fontSize: 12,
        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
      ),
      selectedColor: const Color(0xFFEFF6FF),
      backgroundColor: Colors.white,
      side: BorderSide(
        color: selected ? const Color(0xFF84ADFF) : const Color(0xFFE4E7EC),
      ),
    ),
  );
}
