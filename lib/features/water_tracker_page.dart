import 'package:meditrack/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meditrack/features/water/water_cubit.dart';
import 'package:meditrack/themes/appcolors.dart';
import 'package:meditrack/l10n/app_strings.dart';

class WaterTrackerPage extends StatefulWidget {
  const WaterTrackerPage({super.key, required this.goalMl});

  final int goalMl;

  @override
  State<WaterTrackerPage> createState() => _WaterTrackerPageState();
}

class _WaterTrackerPageState extends State<WaterTrackerPage> {
  late final WaterCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = context.read<WaterCubit>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _cubit.beginEdit();
    });
  }

  @override
  void dispose() {
    _cubit.discard();
    super.dispose();
  }

  void _addWater(int amount) => _cubit.add(amount);
  void _reset() => _cubit.reset();

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);

    return BlocListener<WaterCubit, WaterState>(
      listenWhen: (previous, current) =>
          previous.error != current.error && current.error != null,
      listener: (context, state) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            strings.isArabic
                ? 'تعذر حفظ الماء. حاول مرة أخرى.'
                : 'Could not save water. Try again.',
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
        body: BlocBuilder<WaterCubit, WaterState>(
          builder: (context, state) => state.loading
              ? const Center(child: CircularProgressIndicator())
              : SafeArea(
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
                                  waterMl: state.displayedMl,
                                  goalMl: widget.goalMl,
                                  streak: state.streak,
                                  progress: state.progress(widget.goalMl),
                                  remaining: state.remaining(widget.goalMl),
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
                                    _WaterAmountButton(
                                      amount: 150,
                                      onTap: _addWater,
                                    ),
                                    const SizedBox(width: 10),
                                    _WaterAmountButton(
                                      amount: 250,
                                      onTap: _addWater,
                                    ),
                                    const SizedBox(width: 10),
                                    _WaterAmountButton(
                                      amount: 500,
                                      onTap: _addWater,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 22),
                                _HydrationPaceCard(
                                  waterMl: state.displayedMl,
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
                              final saved = await _cubit.save(widget.goalMl);
                              if (context.mounted && saved) {
                                Navigator.pop(context, _cubit.state.intakeMl);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Appcolors.Primary,
                              foregroundColor: context.appOnPrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: Text(
                              strings.text('saveWater'),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
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
        color: context.appSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: context.appOutline),
      ),
      child: Column(
        children: [
          Icon(
            Icons.water_drop_rounded,
            size: 62,
            color: Appcolors.SecondaryBlue,
          ),
          const SizedBox(height: 14),
          Text(
            '$waterMl ml',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: context.appText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            strings.waterStreak(streak),
            style: TextStyle(
              color: Appcolors.SecondaryOrange,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            strings.waterGoalDescription(goalMl),
            style: TextStyle(color: context.appSecondaryText),
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              color: Appcolors.SecondaryBlue,
              backgroundColor: context.appMutedSurface,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            remaining == 0
                ? strings.text('waterGoalReached')
                : strings.waterRemaining(remaining),
            style: TextStyle(
              color: context.appSecondaryText,
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
        color: context.appSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accent.withOpacity(.28)),
        boxShadow: [
          BoxShadow(
            color: context.appText.withOpacity(.03),
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
                        color: context.appSecondaryText,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      headline,
                      style: TextStyle(
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
            style: TextStyle(color: context.appText, height: 1.35),
          ),
          if (!isGoalDone) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: context.appSoftSurface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.local_drink_outlined, color: Appcolors.Primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      strings.nextWaterTarget(nextSipMl),
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: context.appText,
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
            style: TextStyle(color: context.appSecondaryText, fontSize: 11),
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
          side: BorderSide(color: Appcolors.SecondaryBlue),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(
          '+$amount ml',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
