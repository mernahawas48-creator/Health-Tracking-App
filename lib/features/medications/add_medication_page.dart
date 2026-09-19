import 'package:flutter/material.dart';
import 'package:meditrack/features/medications/models/medication.dart';
import 'package:meditrack/themes/appcolors.dart';

class AddMedicationPage extends StatefulWidget {
  const AddMedicationPage({super.key});

  @override
  State<AddMedicationPage> createState() => _AddMedicationPageState();
}

class _AddMedicationPageState extends State<AddMedicationPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  DateTime _startDate = DateTime.now();
  TimeOfDay _time = TimeOfDay.now();
  MedicationFrequency _frequency = MedicationFrequency.daily;
  MedicationType _type = MedicationType.tablet;
  MealRelation _mealRelation = MealRelation.afterMeal;

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (date != null) setState(() => _startDate = date);
  }

  Future<void> _selectTime() async {
    final time = await showTimePicker(context: context, initialTime: _time);
    if (time != null) setState(() => _time = time);
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(
      context,
      Medication(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        type: _type,
        dosage: _dosageController.text.trim(),
        frequency: _frequency,
        startDate: _startDate,
        time: _time,
        mealRelation: _mealRelation,
      ),
    );
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
          'Add Medication',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Medication details',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Set one reminder now. You can add more doses later.',
                  style: TextStyle(color: Appcolors.Grey2),
                ),
                const SizedBox(height: 24),
                _TextInput(
                  label: 'Medication name',
                  hint: 'Example: Paracetamol',
                  icon: Icons.medication_outlined,
                  controller: _nameController,
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Enter the medication name'
                      : null,
                ),
                const SizedBox(height: 18),
                const Text(
                  'Medication type',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: MedicationType.values
                      .map(
                        (type) => ChoiceChip(
                          avatar: Icon(
                            type.icon,
                            size: 18,
                            color: _type == type
                                ? Appcolors.White
                                : Appcolors.Primary,
                          ),
                          label: Text(type.label),
                          selected: _type == type,
                          selectedColor: Appcolors.Primary,
                          labelStyle: TextStyle(
                            color: _type == type
                                ? Appcolors.White
                                : Appcolors.Black2,
                            fontWeight: FontWeight.w600,
                          ),
                          side: BorderSide(
                            color: _type == type
                                ? Appcolors.Primary
                                : Appcolors.Grey3,
                          ),
                          onSelected: (_) => setState(() => _type = type),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 18),
                _TextInput(
                  label: 'Dosage',
                  hint: 'Example: 500 mg or 2 tablets',
                  icon: Icons.medical_information_outlined,
                  controller: _dosageController,
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Enter the dosage'
                      : null,
                ),
                const SizedBox(height: 18),
                const Text(
                  'Frequency',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<MedicationFrequency>(
                  value: _frequency,
                  decoration: _inputDecoration(Icons.repeat_rounded),
                  items: MedicationFrequency.values
                      .map(
                        (frequency) => DropdownMenuItem(
                          value: frequency,
                          child: Text(frequency.label),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => setState(() => _frequency = value!),
                ),
                if (_frequency == MedicationFrequency.asNeeded) ...[
                  const SizedBox(height: 8),
                  const Text(
                    'As-needed medicines are saved but do not create automatic reminders.',
                    style: TextStyle(color: Appcolors.Grey2, fontSize: 12),
                  ),
                ],
                const SizedBox(height: 18),
                _SelectionTile(
                  label: 'Start date',
                  value:
                      '${_startDate.day.toString().padLeft(2, '0')}/${_startDate.month.toString().padLeft(2, '0')}/${_startDate.year}',
                  icon: Icons.calendar_today_outlined,
                  onTap: _selectDate,
                ),
                const SizedBox(height: 14),
                _SelectionTile(
                  label: 'Reminder time',
                  value: _time.format(context),
                  icon: Icons.access_time_rounded,
                  onTap: _selectTime,
                ),
                const SizedBox(height: 24),
                const Text(
                  'When do you take it?',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: MealRelation.values
                      .map(
                        (relation) => ChoiceChip(
                          label: Text(relation.label),
                          selected: _mealRelation == relation,
                          selectedColor: Appcolors.Primary,
                          labelStyle: TextStyle(
                            color: _mealRelation == relation
                                ? Appcolors.White
                                : Appcolors.Black2,
                            fontWeight: FontWeight.w600,
                          ),
                          side: BorderSide(
                            color: _mealRelation == relation
                                ? Appcolors.Primary
                                : Appcolors.Grey3,
                          ),
                          onSelected: (_) =>
                              setState(() => _mealRelation = relation),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 36),
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
                      'Save Medication',
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
    );
  }

  InputDecoration _inputDecoration(IconData icon) => InputDecoration(
    prefixIcon: Icon(icon, color: Appcolors.Primary),
    filled: true,
    fillColor: Appcolors.White,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Appcolors.Grey3),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Appcolors.Grey3),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Appcolors.Primary, width: 1.5),
    ),
  );
}

class _TextInput extends StatelessWidget {
  const _TextInput({
    required this.label,
    required this.hint,
    required this.icon,
    required this.controller,
    required this.validator,
  });
  final String label;
  final String hint;
  final IconData icon;
  final TextEditingController controller;
  final String? Function(String?) validator;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: Appcolors.Primary),
            filled: true,
            fillColor: Appcolors.White,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Appcolors.Grey3),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Appcolors.Grey3),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: Appcolors.Primary,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SelectionTile extends StatelessWidget {
  const _SelectionTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
  });
  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Appcolors.White,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Appcolors.Grey3),
        ),
        child: Row(
          children: [
            Icon(icon, color: Appcolors.Primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            Text(value, style: const TextStyle(color: Appcolors.Grey1)),
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right_rounded, color: Appcolors.Grey2),
          ],
        ),
      ),
    );
  }
}
