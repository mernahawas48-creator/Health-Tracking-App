import 'package:flutter/material.dart';
import 'package:meditrack/themes/appcolors.dart';

class GenderSelector extends StatelessWidget {
  final String? selectedGender;
  final Function(String) onGenderSelected;

  const GenderSelector({
    super.key,
    required this.selectedGender,
    required this.onGenderSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _genderCard(
            icon: Icons.male,
            title: 'Male',
          ),
        ),

        const SizedBox(width: 16),

        Expanded(
          child: _genderCard(
            icon: Icons.female,
            title: 'Female',
          ),
        ),
      ],
    );
  }


Widget _genderCard({
  required IconData icon,
  required String title,
}) {
  final bool isSelected = selectedGender == title;

  return GestureDetector(
    onTap: () {
      onGenderSelected(title);
    },
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: isSelected
            ? Appcolors.Primary
            : Colors.grey.shade50,
        border: Border.all(
          color: isSelected
              ? Appcolors.Primary
              : Colors.grey.shade200,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: isSelected
                ? Appcolors.White
                : Appcolors.Primary,
            size: 28,
          ),

          const SizedBox(height: 8),

          Text(
            title,
            style: TextStyle(
              color: isSelected
                  ? Appcolors.White
                  : Appcolors.Black,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ),
  );
}
}