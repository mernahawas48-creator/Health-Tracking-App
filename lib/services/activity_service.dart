/// Device-independent activity contract.
/// Replace [LocalActivityService] with a Health Connect/pedometer adapter later.
class ActivitySummary {
  const ActivitySummary({
    required this.steps,
    required this.distanceKm,
    required this.activeCalories,
  });
  final int steps;
  final double distanceKm;
  final int activeCalories;
}

abstract class ActivityService {
  Future<ActivitySummary> loadToday();
}

class LocalActivityService implements ActivityService {
  const LocalActivityService();

  @override
  Future<ActivitySummary> loadToday() async =>
      const ActivitySummary(steps: 0, distanceKm: 0, activeCalories: 0);
}
