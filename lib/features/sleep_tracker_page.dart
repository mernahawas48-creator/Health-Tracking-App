import 'package:flutter/material.dart';
import 'package:meditrack/services/habit_streak_service.dart';
import 'package:meditrack/themes/appcolors.dart';

class SleepTrackerPage extends StatefulWidget {
  const SleepTrackerPage({
    super.key,
    required this.initialSleepMinutes,
    required this.goalMinutes,
  });

  final int initialSleepMinutes;
  final int goalMinutes;

  @override
  State<SleepTrackerPage> createState() => _SleepTrackerPageState();
}

class _SleepTrackerPageState extends State<SleepTrackerPage> {
  late TimeOfDay _bedtime;
  late TimeOfDay _wakeUpTime;
  int _streak = 0;

  @override
  void initState() {
    super.initState();
    _bedtime = const TimeOfDay(hour: 23, minute: 0);
    final initialDuration = widget.initialSleepMinutes == 0
        ? widget.goalMinutes
        : widget.initialSleepMinutes;
    _wakeUpTime = _timeAfter(_bedtime, initialDuration);
    _loadStreak();
  }

  int get _sleepMinutes {
    final bedtimeMinutes = _bedtime.hour * 60 + _bedtime.minute;
    final wakeMinutes = _wakeUpTime.hour * 60 + _wakeUpTime.minute;
    return wakeMinutes >= bedtimeMinutes
        ? wakeMinutes - bedtimeMinutes
        : (24 * 60 - bedtimeMinutes) + wakeMinutes;
  }

  Future<void> _loadStreak() async {
    final streak = await HabitStreakService.currentStreak(HabitType.sleep);
    if (mounted) setState(() => _streak = streak);
  }

  Future<void> _save() async {
    await HabitStreakService.updateToday(
      habit: HabitType.sleep,
      isCompleted: _sleepMinutes >= 7 * 60 && _sleepMinutes <= 9 * 60,
    );
    if (context.mounted) Navigator.pop(context, _sleepMinutes);
  }

  Future<void> _pickBedtime() async {
    final time = await showTimePicker(context: context, initialTime: _bedtime);
    if (time != null) setState(() => _bedtime = time);
  }

  Future<void> _pickWakeUpTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _wakeUpTime,
    );
    if (time != null) setState(() => _wakeUpTime = time);
  }

  TimeOfDay _timeAfter(TimeOfDay time, int minutes) {
    final total = (time.hour * 60 + time.minute + minutes) % (24 * 60);
    return TimeOfDay(hour: total ~/ 60, minute: total % 60);
  }

  String _formatDuration(int minutes) {
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    return remainingMinutes == 0
        ? '$hours h'
        : '$hours h $remainingMinutes min';
  }

  _SleepGuidance get _guidance {
    if (_sleepMinutes < 7 * 60) {
      return const _SleepGuidance(
        message: 'Below the recommended adult sleep range.',
        color: Appcolors.SecondaryOrange,
        icon: Icons.info_outline_rounded,
      );
    }
    if (_sleepMinutes <= 9 * 60) {
      return const _SleepGuidance(
        message: 'Great — this is the recommended 7–9 hour range.',
        color: Appcolors.Primary,
        icon: Icons.check_circle_outline_rounded,
      );
    }
    return const _SleepGuidance(
      message: 'Above the usual 7–9 hour range for adults.',
      color: Colors.indigo,
      icon: Icons.info_outline_rounded,
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_sleepMinutes / widget.goalMinutes).clamp(0.0, 1.0);
    final guidance = _guidance;

    return Scaffold(
      backgroundColor: const Color(0xffF9F7FB),
      appBar: AppBar(
        backgroundColor: Appcolors.White,
        foregroundColor: Appcolors.Black,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Sleep Schedule',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Appcolors.White,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Appcolors.Grey3),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      _TimeSection(
                        title: 'BEDTIME',
                        icon: Icons.bedtime_rounded,
                        time: _bedtime.format(context),
                        onTap: _pickBedtime,
                      ),
                      Container(width: 1, height: 72, color: Appcolors.Grey3),
                      _TimeSection(
                        title: 'WAKE UP',
                        icon: Icons.alarm_rounded,
                        time: _wakeUpTime.format(context),
                        onTap: _pickWakeUpTime,
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  Container(
                    width: 170,
                    height: 170,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xffEEEAFE),
                      border: Border.all(color: Colors.indigo, width: 5),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.nightlight_round,
                          color: Colors.indigo,
                          size: 42,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _formatDuration(_sleepMinutes),
                          style: const TextStyle(
                            fontSize: 27,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo,
                          ),
                        ),
                        const Text(
                          'scheduled sleep',
                          style: TextStyle(color: Appcolors.Grey1),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 10,
                      color: Colors.indigo,
                      backgroundColor: const Color(0xffE5E4FA),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Icon(guidance.icon, color: guidance.color),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          guidance.message,
                          style: TextStyle(
                            color: guidance.color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '🔥 $_streak day healthy-sleep streak',
                    style: const TextStyle(
                      color: Appcolors.SecondaryOrange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xffEEF8F8),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Healthy sleep guide',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '• Less than 7 hours: usually too little for most adults.',
                  ),
                  SizedBox(height: 5),
                  Text('• 7–9 hours: the recommended adult range.'),
                  SizedBox(height: 5),
                  Text(
                    '• More than 9 hours: may be more than most adults need.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Appcolors.Primary,
                  foregroundColor: Appcolors.White,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Save sleep schedule',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimeSection extends StatelessWidget {
  const _TimeSection({
    required this.title,
    required this.icon,
    required this.time,
    required this.onTap,
  });
  final String title;
  final IconData icon;
  final String time;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 17, color: Colors.indigo),
                  const SizedBox(width: 4),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Appcolors.Grey1,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 9),
              Text(
                time,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SleepGuidance {
  const _SleepGuidance({
    required this.message,
    required this.color,
    required this.icon,
  });
  final String message;
  final Color color;
  final IconData icon;
}
