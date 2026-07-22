import 'package:feppm_mobile/features/dashboard/data/facility_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('maps facility manager dashboard summary', () {
    final summary = DashboardSummary.fromJson({
      'scope': {'name': 'Gombe PHC'},
      'generatedAt': '2026-07-22T10:00:00.000Z',
      'summary': {
        'tasksToday': 8,
        'completedToday': 5,
        'inProgressToday': 2,
        'overdueTasks': 1,
        'compliance': 63,
        'equipment': 10,
        'operationalEquipment': 9,
      },
      'myTasks': <dynamic>[],
    });

    expect(summary.scopeName, 'Gombe PHC');
    expect(summary.tasksToday, 8);
    expect(summary.completedToday, 5);
    expect(summary.compliance, 63);
  });

  test('maps checklist task and typed questions', () {
    final task = FacilityTask.fromChecklistJson({
      'id': 'task-1',
      'status': 'DUE',
      'dueAt': '2026-07-22T17:00:00.000Z',
      'equipment': {
        'assetCode': 'CCE-001',
        'equipmentType': {'name': 'Solar Refrigerator'},
      },
      'maintenanceSchedule': {
        'checklistTemplate': {
          'name': 'Daily cold-chain inspection',
          'estimatedDurationMinutes': 12,
          'items': [
            {
              'id': 'q1',
              'title': 'What is the current temperature?',
              'inputType': 'TEMPERATURE',
              'isRequired': true,
              'evidenceRequirement': 'NONE',
            },
            {
              'id': 'q2',
              'title': 'Photograph the equipment',
              'inputType': 'PHOTO',
              'isRequired': true,
              'evidenceRequirement': 'REQUIRED',
            },
          ],
        },
      },
    }, TaskFrequency.daily);

    expect(task.assetCode, 'CCE-001');
    expect(task.status, FacilityTaskStatus.due);
    expect(task.items, hasLength(2));
    expect(task.items.first.isNumeric, isTrue);
    expect(task.items.last.isPhoto, isTrue);
    expect(task.items.last.photoRequired, isTrue);
  });
}
