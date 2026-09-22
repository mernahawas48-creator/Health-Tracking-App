import 'package:flutter/material.dart';
import 'package:meditrack/themes/appcolors.dart';

class ProfileDateField extends StatelessWidget {
  final DateTime? selectedDate;
  final Function(DateTime) onDateSelected;

  const ProfileDateField({
    super.key, 
    this.selectedDate, 
    required this.onDateSelected
    });

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await 
    showDatePicker(
      context: context, 
      initialDate: selectedDate ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now()
      );
      if(pickedDate != null){
        onDateSelected(pickedDate);
      }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _selectDate(context),
      child: SizedBox(
        width: MediaQuery.sizeOf(context).width*0.9,
        height: MediaQuery.sizeOf(context).height*0.06,

        child: Container(
        padding:  EdgeInsets.symmetric(
          horizontal: MediaQuery.sizeOf(context).width*0.05,
          vertical: MediaQuery.sizeOf(context).height*0.01,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Appcolors.Grey1),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_month
            ),
            SizedBox(width: MediaQuery.sizeOf(context).width * 0.03,),
            Text(
              selectedDate == null ? 'Date of Birth' : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.normal,
                color: Appcolors.Black
              ),
            )
          ],
        ),
      ),
      )
      
    );
  }
}