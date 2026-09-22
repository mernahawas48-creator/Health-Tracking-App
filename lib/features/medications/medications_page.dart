import 'package:meditrack/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meditrack/features/medications/medication_cubit.dart';
import 'package:meditrack/features/medications/add_medication_page.dart';
import 'package:meditrack/features/medications/models/medication.dart';
import 'package:meditrack/services/medication_adherence_service.dart';
import 'package:meditrack/themes/appcolors.dart';
import 'package:meditrack/l10n/app_strings.dart';

class MedicationsPage extends StatefulWidget {
  const MedicationsPage({super.key});

  @override
  State<MedicationsPage> createState() => _MedicationsPageState();
}

class _MedicationsPageState extends State<MedicationsPage> {
  Future<void> _addMedication() async {
    final medication = await Navigator.push<Medication>(
      context,
      MaterialPageRoute(builder: (_) => const AddMedicationPage()),
    );
    if (medication == null || !mounted) return;
    await context.read<MedicationCubit>().add(medication);
  }

  void _updateMedication(Medication medication) {
    context.read<MedicationCubit>().update(medication);
  }

  Future<void> _editMedication(Medication medication) async {
    final updated = await Navigator.push<Medication>(
      context,
      MaterialPageRoute(
        builder: (_) => AddMedicationPage(medication: medication),
      ),
    );
    if (updated != null && mounted) _updateMedication(updated);
  }

  Future<void> _deleteMedication(Medication medication) async {
    final strings = AppStrings.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(strings.text('deleteMedication')),
        content: Text(strings.text('deleteMedicationMessage')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(strings.text('cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(
              strings.text('delete'),
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await context.read<MedicationCubit>().delete(medication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    return BlocListener<MedicationCubit, MedicationState>(
      listenWhen: (previous, current) =>
          previous.error != current.error && current.error != null,
      listener: (context, state) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            strings.isArabic
                ? 'تعذر حفظ الأدوية. حاول مرة أخرى.'
                : 'Could not save medications. Try again.',
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
            strings.text('myMedications'),
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _addMedication,
          backgroundColor: Appcolors.Primary,
          foregroundColor: context.appOnPrimary,
          icon: Icon(Icons.add),
          label: Text(strings.text('addMedication')),
        ),
        body: BlocBuilder<MedicationCubit, MedicationState>(
          builder: (context, state) => state.loading
              ? const Center(child: CircularProgressIndicator())
              : state.medications.isEmpty
              ? _EmptyMedicationList(onAdd: _addMedication)
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                  children: [
                    _AdherenceCard(summary: state.todaySummary),
                    const SizedBox(height: 20),
                    Text(
                      strings.text('todaySchedule'),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ..._todayMedicationTiles(state.medications),
                    const SizedBox(height: 20),
                    Text(
                      strings.text('allMedications'),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...state.medications.map(
                      (medication) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _MedicationTile(
                          medication: medication,
                          onEdit: () => _editMedication(medication),
                          onDelete: () => _deleteMedication(medication),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  List<Widget> _todayMedicationTiles(List<Medication> items) {
    final today = DateTime.now();
    final medications =
        items.where((item) => item.isScheduledFor(today)).toList()..sort(
          (a, b) => a.time.hour == b.time.hour
              ? a.time.minute.compareTo(b.time.minute)
              : a.time.hour.compareTo(b.time.hour),
        );

    if (medications.isEmpty) {
      return const [_EmptyScheduleCard()];
    }

    return medications
        .map(
          (medication) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _TodayDoseCard(
              medication: medication,
              onChanged: _updateMedication,
            ),
          ),
        )
        .toList();
  }
}

class _AdherenceCard extends StatelessWidget {
  const _AdherenceCard({required this.summary});

  final MedicationAdherenceSummary summary;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final color = summary.isComplete
        ? Appcolors.Primary
        : Appcolors.SecondaryOrange;
    final message = summary.scheduledCount == 0
        ? strings.text('noDosesToday')
        : summary.isComplete
        ? strings.text('allDosesToday')
        : strings.medicationProgress(
            taken: summary.takenCount,
            total: summary.scheduledCount,
          );

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.appSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.appOutline),
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
                  color: color.withOpacity(.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.local_fire_department_rounded, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      strings.text('medicationAdherence'),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      strings.dayStreak(summary.streakDays),
                      style: TextStyle(color: Appcolors.SecondaryOrange),
                    ),
                  ],
                ),
              ),
              Text(
                summary.scheduledCount == 0
                    ? '—'
                    : '${(summary.completionRate * 100).round()}%',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: summary.completionRate,
              minHeight: 9,
              color: color,
              backgroundColor: context.appMutedSurface,
            ),
          ),
          const SizedBox(height: 10),
          Text(message, style: TextStyle(color: context.appSecondaryText)),
        ],
      ),
    );
  }
}

class _TodayDoseCard extends StatelessWidget {
  const _TodayDoseCard({required this.medication, required this.onChanged});

  final Medication medication;
  final ValueChanged<Medication> onChanged;

  @override
  Widget build(BuildContext context) {
    final status = medication.statusOn(DateTime.now());
    final isPending = status == DoseStatus.pending;
    final Color statusColor = status == DoseStatus.taken
        ? Appcolors.Primary
        : status == DoseStatus.skipped
        ? Appcolors.SecondaryOrange
        : context.appSecondaryText;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.appSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: statusColor.withOpacity(.35)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: context.appMutedSurface,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(medication.type.icon, color: Appcolors.Primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      medication.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${medication.dosage} • ${medication.formattedTime}',
                      style: TextStyle(color: context.appSecondaryText),
                    ),
                  ],
                ),
              ),
              Icon(status.icon, color: statusColor),
            ],
          ),
          const SizedBox(height: 14),
          if (isPending)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => onChanged(
                      medication.withStatus(DateTime.now(), DoseStatus.skipped),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Appcolors.SecondaryOrange,
                      side: BorderSide(color: Appcolors.SecondaryOrange),
                    ),
                    child: Text(AppStrings.of(context).text('skip')),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => onChanged(
                      medication.withStatus(DateTime.now(), DoseStatus.taken),
                    ),
                    icon: Icon(Icons.check_rounded),
                    label: Text(AppStrings.of(context).text('taken')),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Appcolors.Primary,
                      foregroundColor: context.appOnPrimary,
                    ),
                  ),
                ),
              ],
            )
          else
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${AppStrings.of(context).text('markedAs')} ${AppStrings.of(context).doseStatus(status.name)}',
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MedicationTile extends StatelessWidget {
  const _MedicationTile({
    required this.medication,
    required this.onEdit,
    required this.onDelete,
  });
  final Medication medication;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.appSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.appOutline),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: context.appMutedSurface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              medication.type.icon,
              color: Appcolors.Primary,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  medication.name,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  '${AppStrings.of(context).medicationType(medication.type.name)} • ${medication.dosage}',
                  style: TextStyle(color: context.appSecondaryText),
                ),
                const SizedBox(height: 4),
                Text(
                  medication.hasScheduledReminder
                      ? '${AppStrings.of(context).medicationFrequency(medication.frequency.name)} • ${medication.formattedTime}'
                      : AppStrings.of(context).text('asNeededNoReminder'),
                  style: TextStyle(
                    color: Appcolors.Primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) => value == 'edit' ? onEdit() : onDelete(),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'edit',
                child: Text(AppStrings.of(context).text('editMedication')),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Text(AppStrings.of(context).text('deleteMedication')),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyMedicationList extends StatelessWidget {
  const _EmptyMedicationList({required this.onAdd});
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.medication_outlined,
              size: 64,
              color: context.appSecondaryText,
            ),
            const SizedBox(height: 16),
            Text(
              AppStrings.of(context).text('noMedications'),
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              AppStrings.of(context).text('addMedicationDescription'),
              textAlign: TextAlign.center,
              style: TextStyle(color: context.appSecondaryText),
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: onAdd,
              icon: Icon(Icons.add),
              label: Text(AppStrings.of(context).text('addMedication')),
              style: OutlinedButton.styleFrom(
                foregroundColor: Appcolors.Primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyScheduleCard extends StatelessWidget {
  const _EmptyScheduleCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.appSurface,
        border: Border.all(color: context.appOutline),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(Icons.event_available_outlined, color: Appcolors.Primary),
          SizedBox(width: 12),
          Expanded(child: Text(AppStrings.of(context).text('noDosesToday'))),
        ],
      ),
    );
  }
}
