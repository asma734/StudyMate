// ══════════════════════════════════════════════════════════════
// PriorityCalculator — StudyMate AI Companion
// Utility to compute and explain task priority scores.
// ══════════════════════════════════════════════════════════════

class PriorityCalculator {
  /// Formula: Score = (C×0.35) + (U×0.35) + (D×0.20) + (E_inv×0.10)
  /// C = Coefficient importance (1-5)
  /// U = Urgency (1-5)
  /// D = Difficulty (1-5)
  /// E_inv = 6 - effortInvested (reversed so less effort = higher priority)
  static double compute({
    required int coefficientImportance,
    required int urgency,
    required int difficulty,
    required int effortInvested,
  }) {
    return (coefficientImportance * 0.35) +
        (urgency * 0.35) +
        (difficulty * 0.20) +
        ((6 - effortInvested) * 0.10);
  }

  /// Returns a 0-100 percentage for display
  static double toPercent(double score) {
    // Max possible score: 5×0.35 + 5×0.35 + 5×0.20 + 5×0.10 = 5.0
    return (score / 5.0) * 100;
  }

  /// Returns a priority label (Critique / Haute / Moyenne / Faible)
  static String label(double score) {
    if (score >= 4.0) return 'Critical 🔴';
    if (score >= 3.0) return 'High 🟠';
    if (score >= 2.0) return 'Medium 🟡';
    return 'Low 🟢';
  }

  /// Auto-computes urgency based on days until deadline
  static int urgencyFromDeadline(DateTime deadline) {
    final daysLeft = deadline.difference(DateTime.now()).inDays;
    if (daysLeft <= 1) return 5;
    if (daysLeft <= 3) return 4;
    if (daysLeft <= 7) return 3;
    if (daysLeft <= 14) return 2;
    return 1;
  }

  /// Returns days left formatted string
  static String deadlineLabel(DateTime deadline) {
    final daysLeft = deadline.difference(DateTime.now()).inDays;
    if (daysLeft < 0) return 'Overdue ⚠️';
    if (daysLeft == 0) return 'Due today!';
    if (daysLeft == 1) return 'Tomorrow';
    return 'In $daysLeft days';
  }
}
