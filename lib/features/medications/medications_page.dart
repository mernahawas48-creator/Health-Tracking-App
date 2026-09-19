import 'package:flutter/material.dart';
import 'package:meditrack/features/medications/add_medication_page.dart';
import 'package:meditrack/features/medications/models/medication.dart';
import 'package:meditrack/themes/appcolors.dart';

class MedicationsPage extends StatefulWidget {
  const MedicationsPage({super.key, required this.medications});
  final List<Medication> medications;

  @override
  State<MedicationsPage> createState() => _MedicationsPageState();
}

class _MedicationsPageState extends State<MedicationsPage> {
  Future<void> _addMedication() async {
    final medication = await Navigator.push<Medication>(
      context,
      MaterialPageRoute(builder: (_) => const AddMedicationPage()),
    );
    if (medication == null) return;
    setState(() => widget.medications.add(medication));
  }

  @override
  Widget build(BuildContext context) {
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
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: widget.medications.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, index) =>
                  _MedicationTile(medication: widget.medications[index]),
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
              'Add a medication to see your reminders here.',
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

class _MedicationTile extends StatelessWidget {
  const _MedicationTile({required this.medication});
  final Medication medication;

  @override
  Widget build(BuildContext context) {
    final hasReminder = medication.hasScheduledReminder;
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
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: const Color(0xffE3F7F8),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              medication.type.icon,
              color: Appcolors.Primary,
              size: 29,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  medication.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${medication.type.label} • ${medication.dosage}',
                  style: const TextStyle(color: Appcolors.Grey2),
                ),
                const SizedBox(height: 4),
                Text(
                  hasReminder
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
          const Icon(Icons.chevron_right_rounded, color: Appcolors.Grey2),
        ],
      ),
    );
  }
}
