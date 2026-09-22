import 'package:meditrack/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:meditrack/features/medications/models/medication.dart';
import 'package:meditrack/themes/appcolors.dart';
import 'package:meditrack/l10n/app_strings.dart';

class AddMedicationPage extends StatefulWidget {
  const AddMedicationPage({super.key, this.medication});
  final Medication? medication;

  @override
  State<AddMedicationPage> createState() => _AddMedicationPageState();
}

class _AddMedicationPageState extends State<AddMedicationPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _dosageController;
  DateTime _startDate = DateTime.now();
  TimeOfDay _time = TimeOfDay.now();
  MedicationFrequency _frequency = MedicationFrequency.daily;
  MedicationType _type = MedicationType.tablet;
  MealRelation _mealRelation = MealRelation.afterMeal;

  @override
  void initState() {
    super.initState();
    final medication = widget.medication;
    _nameController = TextEditingController(text: medication?.name ?? '');
    _dosageController = TextEditingController(text: medication?.dosage ?? '');
    if (medication != null) {
      _startDate = medication.startDate;
      _time = medication.time;
      _frequency = medication.frequency;
      _type = medication.type;
      _mealRelation = medication.mealRelation;
    }
  }

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
        id:
            widget.medication?.id ??
            DateTime.now().microsecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        type: _type,
        dosage: _dosageController.text.trim(),
        frequency: _frequency,
        startDate: _startDate,
        time: _time,
        mealRelation: _mealRelation,
        doseStatuses: widget.medication?.doseStatuses ?? const {},
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    return Scaffold(
      backgroundColor: context.appCanvas,
      appBar: AppBar(
        backgroundColor: context.appSurface,
        foregroundColor: context.appText,
        elevation: 0,
        centerTitle: true,
        title: Text(
          widget.medication == null
              ? strings.text('addMedicationTitle')
              : strings.text('editMedication'),
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
                Text(
                  strings.text('medicationDetails'),
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  strings.text('addMedicationDescription'),
                  style: TextStyle(color: context.appSecondaryText),
                ),
                const SizedBox(height: 24),
                _TextInput(
                  label: strings.text('medicationName'),
                  hint: strings.text('exampleParacetamol'),
                  icon: Icons.medication_outlined,
                  controller: _nameController,
                  validator: (value) => value == null || value.trim().isEmpty
                      ? strings.text('enterMedicationName')
                      : null,
                ),
                const SizedBox(height: 18),
                Text(
                  strings.text('medicationType'),
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
                                ? context.appOnPrimary
                                : Appcolors.Primary,
                          ),
                          label: Text(strings.medicationType(type.name)),
                          selected: _type == type,
                          selectedColor: Appcolors.Primary,
                          labelStyle: TextStyle(
                            color: _type == type
                                ? context.appOnPrimary
                                : context.appText,
                            fontWeight: FontWeight.w600,
                          ),
                          side: BorderSide(
                            color: _type == type
                                ? Appcolors.Primary
                                : context.appOutline,
                          ),
                          onSelected: (_) => setState(() => _type = type),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 18),
                _TextInput(
                  label: strings.text('dosage'),
                  hint: strings.text('exampleDosage'),
                  icon: Icons.medical_information_outlined,
                  controller: _dosageController,
                  validator: (value) => value == null || value.trim().isEmpty
                      ? strings.text('enterDosage')
                      : null,
                ),
                const SizedBox(height: 18),
                Text(
                  strings.text('frequency'),
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
                          child: Text(
                            strings.medicationFrequency(frequency.name),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => setState(() => _frequency = value!),
                ),
                if (_frequency == MedicationFrequency.asNeeded) ...[
                  const SizedBox(height: 8),
                  Text(
                    strings.text('asNeededDescription'),
                    style: TextStyle(
                      color: context.appSecondaryText,
                      fontSize: 12,
                    ),
                  ),
                ],
                const SizedBox(height: 18),
                _SelectionTile(
                  label: strings.text('startDate'),
                  value:
                      '${_startDate.day.toString().padLeft(2, '0')}/${_startDate.month.toString().padLeft(2, '0')}/${_startDate.year}',
                  icon: Icons.calendar_today_outlined,
                  onTap: _selectDate,
                ),
                const SizedBox(height: 14),
                _SelectionTile(
                  label: strings.text('reminderTime'),
                  value: _time.format(context),
                  icon: Icons.access_time_rounded,
                  onTap: _selectTime,
                ),
                const SizedBox(height: 24),
                Text(
                  strings.text('takeMedication'),
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: MealRelation.values
                      .map(
                        (relation) => ChoiceChip(
                          label: Text(strings.mealRelation(relation.name)),
                          selected: _mealRelation == relation,
                          selectedColor: Appcolors.Primary,
                          labelStyle: TextStyle(
                            color: _mealRelation == relation
                                ? context.appOnPrimary
                                : context.appText,
                            fontWeight: FontWeight.w600,
                          ),
                          side: BorderSide(
                            color: _mealRelation == relation
                                ? Appcolors.Primary
                                : context.appOutline,
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
                      foregroundColor: context.appOnPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      strings.text('saveMedication'),
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
    fillColor: context.appSurface,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: context.appOutline),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: context.appOutline),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: Appcolors.Primary, width: 1.5),
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
        Text(label, style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: Appcolors.Primary),
            filled: true,
            fillColor: context.appSurface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: context.appOutline),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: context.appOutline),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Appcolors.Primary, width: 1.5),
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
          color: context.appSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: context.appOutline),
        ),
        child: Row(
          children: [
            Icon(icon, color: Appcolors.Primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label, style: TextStyle(fontWeight: FontWeight.w600)),
            ),
            Text(value, style: TextStyle(color: context.appSecondaryText)),
            const SizedBox(width: 6),
            Icon(Icons.chevron_right_rounded, color: context.appSecondaryText),
          ],
        ),
      ),
    );
  }
}
