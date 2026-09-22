import 'package:meditrack/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meditrack/features/sleep/sleep_cubit.dart';
import 'package:meditrack/themes/appcolors.dart';
import 'package:meditrack/l10n/app_strings.dart';

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

  @override
  void initState() {
    super.initState();
    final state = context.read<SleepCubit>().state;
    _bedtime =
        _timeFromMinutes(state.bedtimeMinutes) ??
        const TimeOfDay(hour: 23, minute: 0);
    final initialDuration = widget.initialSleepMinutes == 0
        ? widget.goalMinutes
        : widget.initialSleepMinutes;
    _wakeUpTime =
        _timeFromMinutes(state.wakeUpMinutes) ??
        _timeAfter(_bedtime, initialDuration);
  }

  int get _sleepMinutes {
    final bedtimeMinutes = _bedtime.hour * 60 + _bedtime.minute;
    final wakeMinutes = _wakeUpTime.hour * 60 + _wakeUpTime.minute;
    return wakeMinutes >= bedtimeMinutes
        ? wakeMinutes - bedtimeMinutes
        : (24 * 60 - bedtimeMinutes) + wakeMinutes;
  }

  Future<void> _save() async {
    final saved = await context.read<SleepCubit>().save(
      _sleepMinutes,
      bedtimeMinutes: _bedtime.hour * 60 + _bedtime.minute,
      wakeUpMinutes: _wakeUpTime.hour * 60 + _wakeUpTime.minute,
    );
    if (saved && mounted) Navigator.pop(context, _sleepMinutes);
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

  TimeOfDay? _timeFromMinutes(int? minutes) {
    if (minutes == null || minutes < 0 || minutes >= 24 * 60) return null;
    return TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60);
  }

  String _formatDuration(int minutes) {
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    return remainingMinutes == 0
        ? '$hours h'
        : '$hours h $remainingMinutes min';
  }

  _SleepGuidance _guidance(AppStrings strings) {
    if (_sleepMinutes < 7 * 60) {
      return _SleepGuidance(
        message: strings.text('sleepBelow'),
        color: Appcolors.SecondaryOrange,
        icon: Icons.info_outline_rounded,
      );
    }
    if (_sleepMinutes <= 9 * 60) {
      return _SleepGuidance(
        message: strings.text('sleepRecommended'),
        color: Appcolors.Primary,
        icon: Icons.check_circle_outline_rounded,
      );
    }
    return _SleepGuidance(
      message: strings.text('sleepAbove'),
      color: Colors.indigo,
      icon: Icons.info_outline_rounded,
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final progress = (_sleepMinutes / widget.goalMinutes).clamp(0.0, 1.0);
    final guidance = _guidance(strings);

    return BlocListener<SleepCubit, SleepState>(
      listenWhen: (previous, current) =>
          previous.error != current.error && current.error != null,
      listener: (context, state) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            strings.isArabic
                ? 'تعذر حفظ النوم. حاول مرة أخرى.'
                : 'Could not save sleep. Try again.',
          ),
        ),
      ),
      child: Scaffold(
        backgroundColor: context.appCanvas,
        appBar: AppBar(
          backgroundColor: context.appSurface,
          foregroundColor: context.appText,
          elevation: 0,
          centerTitle: true,
          title: Text(
            strings.text('sleepSchedule'),
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
                  color: context.appSurface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: context.appOutline),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        _TimeSection(
                          title: strings.text('bedtime'),
                          icon: Icons.bedtime_rounded,
                          time: _bedtime.format(context),
                          onTap: _pickBedtime,
                        ),
                        Container(
                          width: 1,
                          height: 72,
                          color: context.appOutline,
                        ),
                        _TimeSection(
                          title: strings.text('wakeUp'),
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
                        color: context.appMutedSurface,
                        border: Border.all(color: Colors.indigo, width: 5),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.nightlight_round,
                            color: Colors.indigo,
                            size: 42,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _formatDuration(_sleepMinutes),
                            style: TextStyle(
                              fontSize: 27,
                              fontWeight: FontWeight.bold,
                              color: Colors.indigo,
                            ),
                          ),
                          Text(
                            strings.text('scheduledSleep'),
                            style: TextStyle(color: context.appSecondaryText),
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
                        backgroundColor: context.appMutedSurface,
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
                    BlocBuilder<SleepCubit, SleepState>(
                      builder: (context, state) => Text(
                        strings.sleepStreak(state.streak),
                        style: TextStyle(
                          color: Appcolors.SecondaryOrange,
                          fontWeight: FontWeight.w600,
                        ),
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
                  color: context.appMutedSurface,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      strings.text('sleepGuide'),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(strings.text('lessThanSeven')),
                    SizedBox(height: 5),
                    Text(strings.text('sevenToNine')),
                    SizedBox(height: 5),
                    Text(strings.text('moreThanNine')),
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
                    foregroundColor: context.appOnPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    strings.text('saveSleep'),
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
                children: [
                  Icon(icon, size: 17, color: Colors.indigo),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: context.appSecondaryText,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 9),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  time,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
