import 'package:flutter/material.dart';
import 'package:meditrack/services/habit_streak_service.dart';
import 'package:meditrack/themes/appcolors.dart';
import 'package:meditrack/l10n/app_strings.dart';

class WaterTrackerPage extends StatefulWidget {
  const WaterTrackerPage({
    super.key,
    required this.initialWaterMl,
    required this.goalMl,
  });

  final int initialWaterMl;
  final int goalMl;

  @override
  State<WaterTrackerPage> createState() => _WaterTrackerPageState();
}

class _WaterTrackerPageState extends State<WaterTrackerPage> {
  late int _waterMl;
  int _streak = 0;

  @override
  void initState() {
    super.initState();
    _waterMl = widget.initialWaterMl;
    _loadStreak();
  }

  Future<void> _loadStreak() async {
    final streak = await HabitStreakService.currentStreak(HabitType.water);
    if (mounted) setState(() => _streak = streak);
  }

  Future<void> _syncStreak() async {
    await HabitStreakService.updateToday(
      habit: HabitType.water,
      isCompleted: _waterMl >= widget.goalMl,
    );
    await _loadStreak();
  }

  void _addWater(int amount) {
    setState(() => _waterMl += amount);
    _syncStreak();
  }

  void _reset() {
    setState(() => _waterMl = 0);
    _syncStreak();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final progress = (_waterMl / widget.goalMl).clamp(0.0, 1.0);
    final remaining = (widget.goalMl - _waterMl).clamp(0, widget.goalMl);

    return Scaffold(
      backgroundColor: const Color(0xffF9F7FB),
      appBar: AppBar(
        backgroundColor: Appcolors.White,
        foregroundColor: Appcolors.Black,
        elevation: 0,
        centerTitle: true,
        title: Text(
          strings.text('waterTracking'),
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: _reset,
            child: Text(
              strings.text('reset'),
              style: TextStyle(color: Appcolors.SecondaryOrange),
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _WaterSummaryCard(
                        waterMl: _waterMl,
                        goalMl: widget.goalMl,
                        streak: _streak,
                        progress: progress,
                        remaining: remaining,
                      ),
                      const SizedBox(height: 24),
                      Text(
                strings.text('addWater'),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          _WaterAmountButton(amount: 150, onTap: _addWater),
                          const SizedBox(width: 10),
                          _WaterAmountButton(amount: 250, onTap: _addWater),
                          const SizedBox(width: 10),
                          _WaterAmountButton(amount: 500, onTap: _addWater),
                        ],
                      ),
                      const SizedBox(height: 22),
                      _HydrationPaceCard(
                        waterMl: _waterMl,
                        goalMl: widget.goalMl,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () async {
                    await _syncStreak();
                    if (context.mounted) Navigator.pop(context, _waterMl);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Appcolors.Primary,
                    foregroundColor: Appcolors.White,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                  strings.text('saveWater'),
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WaterSummaryCard extends StatelessWidget {
  const _WaterSummaryCard({
    required this.waterMl,
    required this.goalMl,
    required this.streak,
    required this.progress,
    required this.remaining,
  });

  final int waterMl;
  final int goalMl;
  final int streak;
  final double progress;
  final int remaining;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Appcolors.White,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Appcolors.Grey3),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.water_drop_rounded,
            size: 62,
            color: Appcolors.SecondaryBlue,
          ),
          const SizedBox(height: 14),
          Text(
            '$waterMl ml',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Appcolors.Black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            strings.waterStreak(streak),
            style: const TextStyle(
              color: Appcolors.SecondaryOrange,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            strings.waterGoalDescription(goalMl),
            style: const TextStyle(color: Appcolors.Grey2),
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              color: Appcolors.SecondaryBlue,
              backgroundColor: const Color(0xffDDEEFF),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            remaining == 0
                ? strings.text('waterGoalReached')
                : strings.waterRemaining(remaining),
            style: const TextStyle(
              color: Appcolors.Grey1,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _HydrationPaceCard extends StatelessWidget {
  const _HydrationPaceCard({required this.waterMl, required this.goalMl});

  final int waterMl;
  final int goalMl;

  static const _dayStartHour = 8;
  static const _dayEndHour = 22;

  int _roundUpTo50(double value) => ((value / 50).ceil() * 50).toInt();

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final now = DateTime.now();
    final currentMinutes = now.hour * 60 + now.minute;
    const startMinutes = _dayStartHour * 60;
    const endMinutes = _dayEndHour * 60;
    final elapsed = (currentMinutes - startMinutes).clamp(
      0,
      endMinutes - startMinutes,
    );
    final dayLength = endMinutes - startMinutes;
    final expectedByNow = ((elapsed / dayLength) * goalMl).round();
    final difference = waterMl - expectedByNow;
    final remaining = (goalMl - waterMl).clamp(0, goalMl);
    final minutesLeft = (endMinutes - currentMinutes).clamp(0, dayLength);
    final twoHourPortions = (minutesLeft / 120).ceil().clamp(1, 8);
    final nextSipMl = remaining == 0
        ? 0
        : _roundUpTo50(remaining / twoHourPortions);

    final isGoalDone = remaining == 0;
    final isOnTrack = difference >= -150;
    final Color accent = isGoalDone || isOnTrack
        ? Appcolors.Primary
        : Appcolors.SecondaryOrange;
    final IconData icon = isGoalDone
        ? Icons.celebration_rounded
        : isOnTrack
        ? Icons.schedule_rounded
        : Icons.water_drop_outlined;
    final String headline = isGoalDone
        ? strings.text('hydratedToday')
        : isOnTrack
        ? strings.text('healthyPace')
        : strings.text('catchUp');
    final String explanation = isGoalDone
        ? strings.text('waterGoalDoneMessage')
        : isOnTrack
        ? strings.text('waterOnTrackMessage')
        : strings.waterBehindPace(difference.abs());

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Appcolors.White,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accent.withOpacity(.28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: accent.withOpacity(.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: accent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      strings.text('hydrationPace'),
                      style: TextStyle(
                        color: Appcolors.Grey1,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      headline,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            explanation,
            style: const TextStyle(color: Appcolors.Black2, height: 1.35),
          ),
          if (!isGoalDone) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xffF2FAFA),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.local_drink_outlined,
                    color: Appcolors.Primary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      strings.nextWaterTarget(nextSipMl),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Appcolors.Black2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          Text(
            strings.text('waterPaceDisclaimer'),
            style: TextStyle(color: Appcolors.Grey2, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _WaterAmountButton extends StatelessWidget {
  const _WaterAmountButton({required this.amount, required this.onTap});

  final int amount;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: OutlinedButton(
        onPressed: () => onTap(amount),
        style: OutlinedButton.styleFrom(
          foregroundColor: Appcolors.SecondaryBlue,
          side: const BorderSide(color: Appcolors.SecondaryBlue),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(
          '+$amount ml',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
