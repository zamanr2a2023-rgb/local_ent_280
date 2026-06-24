/// Detailed Reports demo data — `roles/details.md`.
abstract final class AdminReportsData {
  static const chartImage =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuCq4PqypmAlrt1YBF8Za0sW0OsxPFAKIS_RavqmXpFiv1oWYj4SdyFi_xGtHXfyV9tOzCF-bd0v-ErF3CCV8G7dTrNYvZDAlxY5E68k7_ax4gGjyOgfYcWy0xmMTp9Hs6XbQwxRsvTZFZnetHi1YmMX5jkVDzQJlUtIuoSdUrIuwr9sU4MqO7WOHwrKzC7ze66SFTllprJtS5AKQudGtB-TNYiNeFymzQBxzMr-L4rNJcGFYstmOlN6k0imS5C4qr2PHe1ga4G7zJc';

  static const dateRangeValue = '01 Jan 2024 - 31 Jan 2024';

  static const totalTrips = '1,284';
  static const tripsTrend = '+12%';
  static const totalDistance = '14.2k';
  static const timeOnRoute = '842';
  static const totalCost = '42.1k';
  static const pendingDebt = '1.4k';

  static const fleetEfficiencyPercent = 85;

  static const activities = <AdminReportActivity>[];
}

class AdminReportActivity {
  const AdminReportActivity({
    required this.title,
    required this.reference,
    required this.time,
    required this.amount,
    required this.iconName,
  });

  final String title;
  final String reference;
  final String time;
  final String amount;
  final String iconName;
}
