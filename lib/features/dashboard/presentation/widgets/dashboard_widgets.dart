import 'package:flutter/material.dart';

import '../../data/facility_models.dart';

class FeppmHeader extends StatelessWidget {
  const FeppmHeader({super.key, this.trailing});
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        width: 43,
        height: 43,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: const Color(0xFFE4E7EC)),
        ),
        child: Image.asset('assets/images/icon.png'),
      ),
      const SizedBox(width: 9),
      const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(
              style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800),
              children: [
                TextSpan(
                  text: 'FE',
                  style: TextStyle(color: Color(0xFF1264D8)),
                ),
                TextSpan(
                  text: 'PPM',
                  style: TextStyle(color: Color(0xFF12A05C)),
                ),
              ],
            ),
          ),
          Text(
            'Planned Preventive Maintenance',
            style: TextStyle(color: Color(0xFF667085), fontSize: 8.5),
          ),
        ],
      ),
      const Spacer(),
      ?trailing,
    ],
  );
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(
          title,
          style: const TextStyle(
            color: Color(0xFF101828),
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      if (actionLabel != null)
        TextButton(onPressed: onAction, child: Text(actionLabel!)),
    ],
  );
}

class TaskCard extends StatelessWidget {
  const TaskCard({super.key, required this.task, this.onTap});
  final FacilityTask task;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final appearance = statusAppearance(task.status);
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE4E7EC)),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 47,
                height: 47,
                decoration: BoxDecoration(
                  color: appearance.color,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.ac_unit_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            task.assetCode,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF101828),
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        StatusPill(status: task.status),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      task.templateName ?? task.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF344054),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 15,
                          color: Color(0xFF667085),
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            task.facilityName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF667085),
                              fontSize: 12,
                            ),
                          ),
                        ),
                        Text(
                          formatTaskTime(task.dueAt),
                          style: const TextStyle(
                            color: Color(0xFF667085),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (onTap != null) ...[
                const SizedBox(width: 3),
                const Padding(
                  padding: EdgeInsets.only(top: 15),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    color: Color(0xFF667085),
                    size: 20,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class StatusPill extends StatelessWidget {
  const StatusPill({super.key, required this.status});
  final FacilityTaskStatus status;

  @override
  Widget build(BuildContext context) {
    final appearance = statusAppearance(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: appearance.background,
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: appearance.color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 66,
            height: 66,
            decoration: const BoxDecoration(
              color: Color(0xFFEFF6FF),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF1264D8), size: 30),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF667085), height: 1.45),
          ),
          if (actionLabel != null) ...[
            const SizedBox(height: 15),
            TextButton(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ],
      ),
    ),
  );
}

({Color color, Color background}) statusAppearance(FacilityTaskStatus status) =>
    switch (status) {
      FacilityTaskStatus.completed => (
        color: const Color(0xFF079455),
        background: const Color(0xFFECFDF3),
      ),
      FacilityTaskStatus.inProgress => (
        color: const Color(0xFFF79009),
        background: const Color(0xFFFFFAEB),
      ),
      FacilityTaskStatus.overdue || FacilityTaskStatus.missed => (
        color: const Color(0xFFD92D20),
        background: const Color(0xFFFEF3F2),
      ),
      FacilityTaskStatus.upcoming => (
        color: const Color(0xFF1264D8),
        background: const Color(0xFFEFF6FF),
      ),
      _ => (
        color: const Color(0xFF079455),
        background: const Color(0xFFECFDF3),
      ),
    };

String formatTaskTime(DateTime? value) {
  if (value == null) return '';
  final local = value.toLocal();
  final hour = local.hour == 0
      ? 12
      : local.hour > 12
      ? local.hour - 12
      : local.hour;
  return '$hour:${local.minute.toString().padLeft(2, '0')} ${local.hour >= 12 ? 'PM' : 'AM'}';
}

String formatShortDate(DateTime value) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${value.day} ${months[value.month - 1]} ${value.year}';
}
