enum TaskFrequency {
  daily('DAILY', 'Daily'),
  weekly('WEEKLY', 'Weekly'),
  monthly('MONTHLY', 'Monthly');

  const TaskFrequency(this.apiValue, this.label);
  final String apiValue;
  final String label;
}

enum FacilityTaskStatus {
  upcoming,
  due,
  inProgress,
  completed,
  overdue,
  missed,
  other;

  factory FacilityTaskStatus.fromApi(String? value) {
    return switch (value) {
      'UPCOMING' => upcoming,
      'DUE' => due,
      'IN_PROGRESS' => inProgress,
      'SUBMITTED' || 'COMPLETED_ON_TIME' || 'COMPLETED_LATE' => completed,
      'OVERDUE' => overdue,
      'MISSED' => missed,
      _ => other,
    };
  }

  String get label => switch (this) {
    upcoming => 'Scheduled',
    due => 'Due today',
    inProgress => 'In progress',
    completed => 'Completed',
    overdue => 'Overdue',
    missed => 'Missed',
    other => 'Pending',
  };
}

class DashboardSummary {
  const DashboardSummary({
    required this.scopeName,
    required this.tasksToday,
    required this.completedToday,
    required this.inProgressToday,
    required this.overdueTasks,
    required this.compliance,
    required this.equipment,
    required this.operationalEquipment,
    required this.myTasks,
    required this.generatedAt,
  });

  final String scopeName;
  final int tasksToday;
  final int completedToday;
  final int inProgressToday;
  final int overdueTasks;
  final int compliance;
  final int equipment;
  final int operationalEquipment;
  final List<FacilityTask> myTasks;
  final DateTime? generatedAt;

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    final summary = _map(json['summary']);
    final scope = _map(json['scope']);
    return DashboardSummary(
      scopeName: scope['name']?.toString() ?? 'My facility',
      tasksToday: _integer(summary['tasksToday']),
      completedToday: _integer(summary['completedToday']),
      inProgressToday: _integer(summary['inProgressToday']),
      overdueTasks: _integer(summary['overdueTasks']),
      compliance: _integer(summary['compliance']),
      equipment: _integer(summary['equipment']),
      operationalEquipment: _integer(summary['operationalEquipment']),
      myTasks: _list(
        json['myTasks'],
      ).map((item) => FacilityTask.fromDashboardJson(_map(item))).toList(),
      generatedAt: DateTime.tryParse(json['generatedAt']?.toString() ?? ''),
    );
  }
}

class FacilityTask {
  const FacilityTask({
    required this.id,
    required this.title,
    required this.assetCode,
    required this.facilityName,
    required this.status,
    required this.dueAt,
    required this.frequency,
    this.templateName,
    this.estimatedMinutes,
    this.items = const [],
  });

  final String id;
  final String title;
  final String assetCode;
  final String facilityName;
  final FacilityTaskStatus status;
  final DateTime? dueAt;
  final TaskFrequency frequency;
  final String? templateName;
  final int? estimatedMinutes;
  final List<ChecklistQuestion> items;

  factory FacilityTask.fromDashboardJson(Map<String, dynamic> json) {
    final equipment = _map(json['equipment']);
    final type = _map(equipment['equipmentType']);
    final facility = _map(json['facility']);
    return FacilityTask(
      id: json['id']?.toString() ?? '',
      title: type['name']?.toString() ?? 'Equipment inspection',
      assetCode: equipment['assetCode']?.toString() ?? 'Equipment',
      facilityName: facility['name']?.toString() ?? 'My facility',
      status: FacilityTaskStatus.fromApi(json['status']?.toString()),
      dueAt: DateTime.tryParse(json['dueAt']?.toString() ?? ''),
      frequency: TaskFrequency.daily,
    );
  }

  factory FacilityTask.fromChecklistJson(
    Map<String, dynamic> json,
    TaskFrequency frequency,
  ) {
    final equipment = _map(json['equipment']);
    final type = _map(equipment['equipmentType']);
    final schedule = _map(json['maintenanceSchedule']);
    final template = _map(schedule['checklistTemplate']);
    return FacilityTask(
      id: json['id']?.toString() ?? '',
      title: type['name']?.toString() ?? 'Equipment inspection',
      assetCode: equipment['assetCode']?.toString() ?? 'Equipment',
      facilityName: 'Assigned facility',
      status: FacilityTaskStatus.fromApi(json['status']?.toString()),
      dueAt: DateTime.tryParse(json['dueAt']?.toString() ?? ''),
      frequency: frequency,
      templateName: template['name']?.toString(),
      estimatedMinutes: _nullableInteger(template['estimatedDurationMinutes']),
      items: _list(
        template['items'],
      ).map((item) => ChecklistQuestion.fromJson(_map(item))).toList(),
    );
  }
}

class ChecklistQuestion {
  const ChecklistQuestion({
    required this.id,
    required this.title,
    required this.inputType,
    required this.required,
    required this.photoRequired,
    this.instruction,
  });

  final String id;
  final String title;
  final String? instruction;
  final String inputType;
  final bool required;
  final bool photoRequired;

  bool get isPhoto => inputType == 'PHOTO' || inputType == 'MULTIPLE_PHOTOS';
  bool get isBoolean =>
      inputType == 'CHECKBOX' ||
      inputType == 'YES_NO' ||
      inputType == 'PASS_FAIL';
  bool get isNumeric =>
      inputType == 'NUMBER' ||
      inputType == 'TEMPERATURE' ||
      inputType == 'HUMIDITY';

  factory ChecklistQuestion.fromJson(Map<String, dynamic> json) {
    return ChecklistQuestion(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Checklist item',
      instruction: json['instruction']?.toString(),
      inputType: json['inputType']?.toString() ?? 'CHECKBOX',
      required: json['isRequired'] != false,
      photoRequired: json['evidenceRequirement'] == 'REQUIRED',
    );
  }
}

Map<String, dynamic> _map(dynamic value) =>
    value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{};

List<dynamic> _list(dynamic value) => value is List ? value : const [];

int _integer(dynamic value) => _nullableInteger(value) ?? 0;

int? _nullableInteger(dynamic value) {
  if (value is num) return value.round();
  return int.tryParse(value?.toString() ?? '');
}
