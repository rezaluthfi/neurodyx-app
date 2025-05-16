import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:neurodyx/features/progress/domain/entities/progress_entity.dart';
import 'package:provider/provider.dart';
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';
import '../../../../core/constants/app_colors.dart';
import '../providers/progress_provider.dart';

class ProgressPage extends StatefulWidget {
  const ProgressPage({super.key});

  @override
  _ProgressPageState createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  DateTime selectedMonth = DateTime.now(); // Dynamic default to current month
  bool showCalendar = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProgressProvider>(context, listen: false).fetchProgress();
    });
  }

  void changeMonth(int direction) {
    setState(() {
      selectedMonth =
          DateTime(selectedMonth.year, selectedMonth.month + direction);
    });
    Provider.of<ProgressProvider>(context, listen: false).fetchProgress();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final bottomPadding = mediaQuery.padding.bottom;
    final topPadding = mediaQuery.padding.top;
    final availableHeight = mediaQuery.size.height - topPadding - bottomPadding;

    return Consumer<ProgressProvider>(
      builder: (context, provider, child) {
        // Process the data to ensure streaks are correctly identified
        final processedWeeklyProgress =
            _processWeeklyProgress(provider.weeklyProgress);
        final processedMonthlyProgress = _processMonthlyProgress(
            provider.monthlyProgress, processedWeeklyProgress);

        return Scaffold(
          backgroundColor: AppColors.offWhite,
          body: SafeArea(
            bottom:
                false, // We'll handle bottom padding manually for the sticky button
            child: Stack(
              children: [
                Column(
                  children: [
                    // App Bar
                    _buildAppBar(),

                    // Main Content Area
                    Expanded(
                      child: provider.isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : provider.errorMessage != null
                              ? Center(child: Text(provider.errorMessage!))
                              : Padding(
                                  padding: const EdgeInsets.only(
                                      bottom:
                                          80), // Space for the bottom button
                                  child: SingleChildScrollView(
                                    physics:
                                        const AlwaysScrollableScrollPhysics(),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (showCalendar) ...[
                                          _buildMonthSelector(),
                                          const SizedBox(height: 16),
                                          _buildCalendarView(
                                              processedMonthlyProgress),
                                        ] else ...[
                                          _buildWeeklyOverview(
                                              processedWeeklyProgress),
                                          const SizedBox(height: 24),
                                          _buildWeeklyProgressChart(
                                              processedWeeklyProgress),
                                          const SizedBox(height: 24),
                                          _buildMotivationCard(),
                                          // Add extra padding at the bottom for content scrolling
                                          const SizedBox(height: 16),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                    ),
                  ],
                ),

                // Sticky Bottom Button
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.offWhite,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          offset: const Offset(0, -2),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    padding:
                        EdgeInsets.fromLTRB(16, 12, 16, 12 + bottomPadding),
                    child: _buildToggleButton(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppBar() {
    return Container(
      height: kToolbarHeight,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      color: AppColors.offWhite,
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              showCalendar ? Icons.close : Icons.arrow_back,
              color: AppColors.textPrimary,
            ),
            onPressed: () {
              if (showCalendar) {
                setState(() {
                  showCalendar = false;
                });
              } else {
                Navigator.pop(context);
              }
            },
          ),
          const Expanded(
            child: Center(
              child: Text(
                'Your Progress',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                ),
              ),
            ),
          ),
          // Add a transparent placeholder to balance the appbar
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildToggleButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        color: AppColors.primary,
        boxShadow: [
          BoxShadow(
            offset: const Offset(-2, -4),
            blurRadius: 4,
            color: AppColors.grey.withOpacity(0.7),
            inset: true,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(50),
          onTap: () {
            setState(() {
              showCalendar = !showCalendar;
            });
          },
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  showCalendar ? 'Weekly View' : 'Monthly View',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.arrow_forward_rounded,
                  size: 20,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Process weekly progress to dynamically update streak status based on therapy count
  List<WeeklyProgressEntity> _processWeeklyProgress(
      List<WeeklyProgressEntity> progress) {
    return progress.map((entity) {
      // If therapy count >= 5, mark as streak achieved regardless of API's streakAchieved value
      if (entity.therapyCount >= 5) {
        return WeeklyProgressEntity(
          userID: entity.userID,
          date: entity.date,
          therapyCount: entity.therapyCount,
          streakAchieved: true,
        );
      }
      return entity;
    }).toList();
  }

  // Process monthly progress to align with weekly progress for consistent streak display
  List<MonthlyProgressEntity> _processMonthlyProgress(
      List<MonthlyProgressEntity> monthlyProgress,
      List<WeeklyProgressEntity> weeklyProgress) {
    return monthlyProgress.map((entity) {
      // Format the date to match the format used in weekly data
      final dateString = entity.date.toIso8601String().split('T')[0];

      // Find matching weekly progress entry
      final matchingWeeklyEntry = weeklyProgress.firstWhere(
        (weekly) => weekly.date.toIso8601String().startsWith(dateString),
        orElse: () => WeeklyProgressEntity(
          userID: '',
          date: entity.date,
          therapyCount: 0,
          streakAchieved: false,
        ),
      );

      // If we found a weekly entry with streak achieved, update the monthly status
      if (matchingWeeklyEntry.streakAchieved) {
        return MonthlyProgressEntity(
          date: entity.date,
          status: 'streak',
        );
      } else if (matchingWeeklyEntry.therapyCount > 0) {
        // If therapy count > 0 but streak not achieved, mark as active
        return MonthlyProgressEntity(
          date: entity.date,
          status: 'active',
        );
      }

      // Otherwise return the original entity
      return entity;
    }).toList();
  }

  Widget _buildMonthSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, color: AppColors.textPrimary),
            onPressed: () => changeMonth(-1),
            constraints: const BoxConstraints(), // Remove default padding
            padding: EdgeInsets.zero,
            iconSize: 24,
          ),
          Text(
            DateFormat('MMMM yyyy').format(selectedMonth),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, color: AppColors.textPrimary),
            onPressed: () => changeMonth(1),
            constraints: const BoxConstraints(), // Remove default padding
            padding: EdgeInsets.zero,
            iconSize: 24,
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarView(List<MonthlyProgressEntity> monthlyProgress) {
    final deviceWidth = MediaQuery.of(context).size.width;
    final cellSize = (deviceWidth - 32 - 24) /
        7; // Adjusting cell size based on device width

    final daysInMonth =
        DateTime(selectedMonth.year, selectedMonth.month + 1, 0).day;
    final firstDayOfMonth =
        DateTime(selectedMonth.year, selectedMonth.month, 1);
    final startingWeekday = firstDayOfMonth.weekday % 7; // Sunday start (0-6)

    List<TableRow> dayWidgets = [];
    const daysOfWeek = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

    // Weekday headers
    dayWidgets.add(
      TableRow(
        children: daysOfWeek
            .map(
              (day) => Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    day,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );

    // Calendar days
    List<Widget> currentRow = List.filled(7, const SizedBox());
    int currentPosition = 0;

    // Add empty placeholders before the 1st
    for (int i = 0; i < startingWeekday; i++) {
      currentRow[i] = const SizedBox();
      currentPosition++;
    }

    // Add days
    for (int day = 1; day <= daysInMonth; day++) {
      final currentDate =
          DateTime(selectedMonth.year, selectedMonth.month, day);
      final dateString = currentDate.toIso8601String().split('T')[0];
      final status = monthlyProgress
          .firstWhere(
            (data) => data.date.toIso8601String().startsWith(dateString),
            orElse: () =>
                MonthlyProgressEntity(date: currentDate, status: 'inactive'),
          )
          .status;

      // Calculate the size based on available width
      final dayCellSize = min(cellSize - 8, 36.0); // Limit maximum size

      currentRow[currentPosition] = Center(
        child: Container(
          width: dayCellSize,
          height: dayCellSize,
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: status == 'streak'
                ? AppColors.yellow200
                : status == 'active'
                    ? AppColors.yellow200
                    : Colors.transparent,
            border: Border.all(
              color: status == 'streak'
                  ? AppColors.yellow200
                  : status == 'active'
                      ? AppColors.yellow200
                      : AppColors.grey,
            ),
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$day',
                  style: TextStyle(
                    fontSize: dayCellSize > 30
                        ? 14
                        : 12, // Adjust text size based on cell size
                    color: status == 'inactive'
                        ? AppColors.grey
                        : AppColors.textPrimary,
                    fontWeight: status != 'inactive'
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
                if (status == 'streak')
                  Padding(
                    padding: const EdgeInsets.only(left: 2),
                    child: Icon(
                      Icons.local_fire_department,
                      size: dayCellSize > 30 ? 14 : 12, // Adjust icon size
                      color: Colors.orange,
                    ),
                  ),
              ],
            ),
          ),
        ),
      );

      currentPosition++;
      if (currentPosition == 7 || day == daysInMonth) {
        dayWidgets.add(TableRow(children: List.from(currentRow)));
        currentRow = List.filled(7, const SizedBox());
        currentPosition = 0;
      }
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Table(
        children: dayWidgets,
      ),
    );
  }

  Widget _buildWeeklyOverview(List<WeeklyProgressEntity> weeklyProgress) {
    final streakCount =
        weeklyProgress.where((data) => data.streakAchieved).length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Weekly Progress',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Complete at least 5 workouts per day to maintain your streak.',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.local_fire_department,
                color: Colors.orange,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                "Current Streak: $streakCount day${streakCount == 1 ? '' : 's'}",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyProgressChart(List<WeeklyProgressEntity> weeklyProgress) {
    // Use the current date to determine the week to display
    final referenceDate = DateTime.now();
    final weekStart =
        referenceDate.subtract(Duration(days: referenceDate.weekday % 7));
    final weekDates = List.generate(7, (i) => weekStart.add(Duration(days: i)));

    // Calculate maxY dynamically based on the highest therapyCount
    final maxTherapyCount = weeklyProgress.isNotEmpty
        ? weeklyProgress
            .map((e) => e.therapyCount)
            .reduce((a, b) => a > b ? a : b)
        : 15;
    final maxY = (maxTherapyCount + 5).toDouble(); // Add buffer for visibility

    List<BarChartGroupData> barGroups = [];
    for (int i = 0; i < 7; i++) {
      final date = weekDates[i];
      final dateString =
          DateFormat('yyyy-MM-dd').format(date); // Consistent date format
      final dayData = weeklyProgress.firstWhere(
        (data) => DateFormat('yyyy-MM-dd').format(data.date) == dateString,
        orElse: () => WeeklyProgressEntity(
          userID: '',
          date: date,
          therapyCount: 0,
          streakAchieved: false,
        ),
      );

      // Determine bar color: green for therapyCount >= 5, red for therapyCount < 5
      Color barColor = dayData.therapyCount >= 5 ? Colors.green : Colors.red;

      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: dayData.therapyCount.toDouble(),
              color: barColor,
              width: 12,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      );
    }

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxY, // Dynamic maxY to accommodate high therapy counts
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              tooltipBgColor: AppColors.textPrimary.withOpacity(0.8),
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final date = weekDates[group.x.toInt()];
                final dateFormatted = DateFormat('MMM d').format(date);
                return BarTooltipItem(
                  '$dateFormatted\n${rod.toY.toInt()} sessions',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  const days = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
                  return Text(
                    days[value.toInt()],
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 12,
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: maxY / 3, // Adjust interval based on maxY
                reservedSize: 28,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 12,
                    ),
                  );
                },
              ),
            ),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(
            show: true,
            drawHorizontalLine: true,
            horizontalInterval: maxY / 3, // Adjust grid based on maxY
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: AppColors.grey.withOpacity(0.3),
                strokeWidth: 1,
              );
            },
            drawVerticalLine: false,
          ),
          borderData: FlBorderData(show: false),
          barGroups: barGroups,
        ),
      ),
    );
  }

  Widget _buildMotivationCard() {
    return Card(
      elevation: 0,
      color: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.rocket_launch,
                  color: AppColors.primary,
                  size: 20,
                ),
                SizedBox(width: 8),
                Text(
                  "Motivation",
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              "Keep pushing your limits! Every session counts towards your progress.",
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Helper function to find the minimum of two doubles
double min(double a, double b) {
  return a < b ? a : b;
}
