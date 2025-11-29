import '../../models/enums.dart';

/// Strategy Pattern for priority calculation
/// Open/Closed Principle: Open for extension, closed for modification
abstract class PriorityStrategy {
  /// Calculate priority based on deadline and remaining work
  Priority calculate(DateTime taskDeadline, int remainingStepsAfter, int currentStepDuration);
}

/// Default priority strategy according to requirements
/// - Immediate (sofort): ≤ 8 hours until deadline
/// - Medium (mittelfristig): > 8 and ≤ 32 hours
/// - LongTerm (langfristig): > 32 hours
class DefaultPriorityStrategy implements PriorityStrategy {
  @override
  Priority calculate(DateTime taskDeadline, int remainingStepsAfter, int currentStepDuration) {
    final now = DateTime.now();
    final hoursUntilDeadline = taskDeadline.difference(now).inHours;

    if (hoursUntilDeadline <= 8) {
      return Priority.immediate; // Sofort: ≤ 8 Stunden
    } else if (hoursUntilDeadline <= 32) {
      return Priority.medium; // Mittelfristig: > 8 und ≤ 32 Stunden
    } else {
      return Priority.longTerm; // Langfristig: > 32 Stunden
    }
  }
}

/// Context class for priority calculation
/// Uses Strategy Pattern to allow different priority calculation algorithms
class PriorityCalculator {
  final PriorityStrategy _strategy;

  PriorityCalculator({PriorityStrategy? strategy})
      : _strategy = strategy ?? DefaultPriorityStrategy();

  /// Calculate priority for a work step
  Priority calculatePriority(
    DateTime taskDeadline,
    int remainingStepsAfter,
    int currentStepDuration,
  ) {
    return _strategy.calculate(taskDeadline, remainingStepsAfter, currentStepDuration);
  }
}

