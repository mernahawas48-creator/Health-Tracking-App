import 'package:flutter/material.dart';
import 'package:meditrack/themes/appcolors.dart';
import 'package:meditrack/services/habit_streak_service.dart';

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

  @override
  Widget build(BuildContext context) {
    final progress = (_waterMl / widget.goalMl).clamp(0.0, 1.0);
    final remaining = (widget.goalMl - _waterMl).clamp(0, widget.goalMl);

    return Scaffold(
      backgroundColor: const Color(0xffF9F7FB),
      appBar: AppBar(
        backgroundColor: Appcolors.White,
        foregroundColor: Appcolors.Black,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Water Tracking',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() => _waterMl = 0);
              _syncStreak();
            },
            child: const Text(
              'Reset',
              style: TextStyle(color: Appcolors.SecondaryOrange),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
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
                    '$_waterMl ml',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Appcolors.Black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '🔥 $_streak day water streak',
                    style: const TextStyle(
                      color: Appcolors.SecondaryOrange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'of ${widget.goalMl} ml daily goal',
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
                        ? 'Great! You reached today\'s water goal.'
                        : '$remaining ml remaining today',
                    style: const TextStyle(
                      color: Appcolors.Grey1,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Add water',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
            const Spacer(),
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
                child: const Text(
                  'Save today\'s water',
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
