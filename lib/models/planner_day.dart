class PlannerDay {
  const PlannerDay({
    required this.label,
    required this.date,
    this.isActive = false,
  });

  final String label;
  final String date;
  final bool isActive;
}
