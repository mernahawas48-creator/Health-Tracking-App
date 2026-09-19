import 'package:flutter/material.dart';
import 'package:meditrack/features/medications/add_medication_page.dart';
import 'package:meditrack/features/medications/models/medication.dart';
import 'package:meditrack/services/medication_adherence_service.dart';
import 'package:meditrack/themes/appcolors.dart';

class MedicationsPage extends StatefulWidget {
  const MedicationsPage({
    super.key,
    required this.medications,
    required this.onMedicationAdded,
    required this.onMedicationChanged,
  });

  final List<Medication> medications;
  final ValueChanged<Medication> onMedicationAdded;
  final ValueChanged<Medication> onMedicationChanged;

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
    widget.onMedicationAdded(medication);
    setState(() {});
  }

  void _updateMedication(Medication medication) {
    widget.onMedicationChanged(medication);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final summary = MedicationAdherenceService.summaryForToday(
      widget.medications,
    );

    return Scaffold(
      backgroundColor: const Color(0xffF9F7FB),
      appBar: AppBar(
        backgroundColor: Appcolors.White,
        foregroundColor: Appcolors.Black,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'My Medications',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addMedication,
        backgroundColor: Appcolors.Primary,
        foregroundColor: Appcolors.White,
        icon: const Icon(Icons.add),
        label: const Text('Add medication'),
      ),
      body: widget.medications.isEmpty
          ? _EmptyMedicationList(onAdd: _addMedication)
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              children: [
                _AdherenceCard(summary: summary),
                const SizedBox(height: 20),
                const Text(
                  'Today\'s schedule',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ..._todayMedicationTiles(),
                const SizedBox(height: 20),
                const Text(
                  'All medications',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ...widget.medications.map(
                  (medication) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _MedicationTile(medication: medication),
                  ),
                ),
              ],
            ),
    );
  }

  List<Widget> _todayMedicationTiles() {
    final today = DateTime.now();
    final medications =
        widget.medications.where((item) => item.isScheduledFor(today)).toList()
          ..sort(
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
    final color = summary.isComplete
        ? Appcolors.Primary
        : Appcolors.SecondaryOrange;
    final message = summary.scheduledCount == 0
        ? 'No doses are scheduled for today.'
        : summary.isComplete
        ? 'Every scheduled dose was completed today.'
        : '${summary.takenCount} of ${summary.scheduledCount} doses taken today.';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Appcolors.White,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Appcolors.Grey3),
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
                    const Text(
                      'Medication adherence',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '🔥 ${summary.streakDays} day streak',
                      style: const TextStyle(color: Appcolors.SecondaryOrange),
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
              backgroundColor: const Color(0xffFBE5DD),
            ),
          ),
          const SizedBox(height: 10),
          Text(message, style: const TextStyle(color: Appcolors.Grey1)),
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
        : Appcolors.Grey1;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Appcolors.White,
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
                  color: const Color(0xffE3F7F8),
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
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${medication.dosage} • ${medication.formattedTime}',
                      style: const TextStyle(color: Appcolors.Grey2),
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
                      side: const BorderSide(color: Appcolors.SecondaryOrange),
                    ),
                    child: const Text('Skip'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => onChanged(
                      medication.withStatus(DateTime.now(), DoseStatus.taken),
                    ),
                    icon: const Icon(Icons.check_rounded),
                    label: const Text('Taken'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Appcolors.Primary,
                      foregroundColor: Appcolors.White,
                    ),
                  ),
                ),
              ],
            )
          else
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Marked as ${status.label.toLowerCase()}',
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
  const _MedicationTile({required this.medication});
  final Medication medication;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Appcolors.White,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Appcolors.Grey3),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xffE3F7F8),
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
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  '${medication.type.label} • ${medication.dosage}',
                  style: const TextStyle(color: Appcolors.Grey2),
                ),
                const SizedBox(height: 4),
                Text(
                  medication.hasScheduledReminder
                      ? '${medication.frequency.label} • ${medication.formattedTime}'
                      : 'As needed — no automatic reminder',
                  style: const TextStyle(
                    color: Appcolors.Primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
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
            const Icon(
              Icons.medication_outlined,
              size: 64,
              color: Appcolors.Grey2,
            ),
            const SizedBox(height: 16),
            const Text(
              'No medications yet',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add a medication to see your reminders and daily doses here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Appcolors.Grey2),
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('Add your first medication'),
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
        color: Appcolors.White,
        border: Border.all(color: Appcolors.Grey3),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Row(
        children: [
          Icon(Icons.event_available_outlined, color: Appcolors.Primary),
          SizedBox(width: 12),
          Expanded(child: Text('No medications are scheduled for today.')),
        ],
      ),
    );
  }
}
