import 'dart:io';

import 'package:flutter/material.dart';
import 'package:meditrack/themes/appcolors.dart';
import 'package:meditrack/features/create_profile/widgets/gender_selector.dart';
import 'package:meditrack/features/create_profile/widgets/profile_date_field.dart';
import 'package:meditrack/features/create_profile/widgets/profile_image_picker.dart';

class CreateProfilePage extends StatefulWidget {
  const CreateProfilePage({super.key});

  @override
  State<CreateProfilePage> createState() => _CreateProfilePageState();
}

class _CreateProfilePageState extends State<CreateProfilePage> {
  // ----------------------------------------------------------
  // CONTROLLERS
  // ----------------------------------------------------------

  final PageController _pageController = PageController();

  final TextEditingController heightController = TextEditingController();
  final TextEditingController weightController = TextEditingController();

  // ----------------------------------------------------------
  // PROFILE DATA
  // ----------------------------------------------------------

  DateTime? dateOfBirth;
  String? gender;
  File? profileImage;

  double? height;
  double? weight;

  List<String> goals = [];

  int currentPage = 0;

  // ----------------------------------------------------------
  // DISPOSE
  // ----------------------------------------------------------

  @override
  void dispose() {
    _pageController.dispose();
    heightController.dispose();
    weightController.dispose();

    super.dispose();
  }

  // ----------------------------------------------------------
  // PAGE NAVIGATION
  // ----------------------------------------------------------

  void nextPage() {
    if (currentPage < 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      finishProfile();
    }
  }

  void previousPage() {
    if (currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  // ----------------------------------------------------------
  // FINISH PROFILE
  // ----------------------------------------------------------

  void finishProfile() {
    height = double.tryParse(heightController.text);
    weight = double.tryParse(weightController.text);

    debugPrint('Profile completed');
    debugPrint('Date of Birth: $dateOfBirth');
    debugPrint('Gender: $gender');
    debugPrint('Height: $height cm');
    debugPrint('Weight: $weight kg');
    debugPrint('Goals: $goals');

    // TODO:
    // Save profile data to Firebase / local storage
    // Then navigate to Home Page
  }

  // ----------------------------------------------------------
  // BUILD
  // ----------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: Appcolors.White,

      body: Column(
        children: [
          _buildHeader(size),

          Expanded(
            child: PageView(
              controller: _pageController,

              // Prevent swiping between pages
              physics: const NeverScrollableScrollPhysics(),

              onPageChanged: (index) {
                setState(() {
                  currentPage = index;
                });
              },

              children: [
                _buildFirstPage(size),
                _buildSecondPage(size),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // HEADER
  // ==========================================================

  Widget _buildHeader(Size size) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: MediaQuery.sizeOf(context).height * 0.02,
        horizontal: 24,
      ),

      decoration: BoxDecoration(
        color: Appcolors.Primary,

        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(15),
          bottomRight: Radius.circular(15),
        ),
      ),

      child: Column(
        children: [
          SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.025,
          ),

          Row(
            children: [
              // Back Button
              GestureDetector(
                onTap: () {
                  if (currentPage > 0) {
                    previousPage();
                  } else {
                    Navigator.pop(context);
                  }
                },

                child: Container(
                  width: 42,
                  height: 42,

                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                  ),

                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Appcolors.White,
                    size: 18,
                  ),
                ),
              ),

              const SizedBox(width: 14),

              // Title
              const Expanded(
                child: Text(
                  'Create Your Profile',

                  style: TextStyle(
                    color: Appcolors.White,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              // Page Number
              Text(
                '${currentPage + 1}/2',

                style: TextStyle(
                  color: Appcolors.White.withValues(alpha: 0.85),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(20),

            child: LinearProgressIndicator(
              value: (currentPage + 1) / 2,

              minHeight: 6,

              backgroundColor:
                  Colors.white.withValues(alpha: 0.25),

              valueColor:
                  const AlwaysStoppedAnimation<Color>(
                Appcolors.White,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // FIRST PAGE
  // ==========================================================

  Widget _buildFirstPage(Size size) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        24,
        28,
        24,
        24,
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          // Title
          const Text(
            'Tell us about yourself',

            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w700,
              color: Appcolors.Black,
            ),
          ),

          const SizedBox(height: 8),

          // Description
          Text(
            'Add some basic information to personalize your '
            'MediTrack experience.',

            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Colors.grey.shade600,
            ),
          ),

          SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.03,
          ),

          // --------------------------------------------------
          // PROFILE PICTURE
          // --------------------------------------------------

          Center(
            child: Column(
              children: [
                Text(
                  'Profile Picture',

                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),

                const SizedBox(height: 14),

                ProfileImagePicker(
                  image: profileImage,

                  onImageSelected: (image) {
                    setState(() {
                      profileImage = image;
                    });
                  },
                ),

                const SizedBox(height: 8),

                Text(
                  'Add a photo so we can recognize you',

                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.04,
          ),

          // --------------------------------------------------
          // DATE OF BIRTH
          // --------------------------------------------------

          _buildSectionTitle(
            icon: Icons.cake_outlined,
            title: 'Date of Birth',
          ),

          const SizedBox(height: 10),

          ProfileDateField(
            selectedDate: dateOfBirth,

            onDateSelected: (date) {
              setState(() {
                dateOfBirth = date;
              });
            },
          ),

          SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.05,
          ),

          // --------------------------------------------------
          // GENDER
          // --------------------------------------------------

          _buildSectionTitle(
            icon: Icons.person_outline_rounded,
            title: 'Gender',
          ),

          const SizedBox(height: 10),

          GenderSelector(
            selectedGender: gender,

            onGenderSelected: (value) {
              setState(() {
                gender = value;
              });
            },
          ),

          SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.07,
          ),

          // Continue Button
          _buildNextButton(),
        ],
      ),
    );
  }

  // ==========================================================
  // SECOND PAGE
  // ==========================================================

  Widget _buildSecondPage(Size size) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        24,
        28,
        24,
        24,
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          // Title
          const Text(
            'Your health details',

            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w700,
              color: Appcolors.Black,
            ),
          ),

          const SizedBox(height: 8),

          // Description
          Text(
            'These details will help us personalize your '
            'health tracking.',

            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Colors.grey.shade600,
            ),
          ),

          SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.04,
          ),

          // --------------------------------------------------
          // HEIGHT
          // --------------------------------------------------

          _buildSectionTitle(
            icon: Icons.height_rounded,
            title: 'Height',
          ),

          const SizedBox(height: 10),

          _buildInputField(
            hint: 'Enter your height',
            suffix: 'cm',
            icon: Icons.height_rounded,
            controller: heightController,
          ),

          SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.04,
          ),

          // --------------------------------------------------
          // WEIGHT
          // --------------------------------------------------

          _buildSectionTitle(
            icon: Icons.monitor_weight_outlined,
            title: 'Weight',
          ),

          const SizedBox(height: 10),

          _buildInputField(
            hint: 'Enter your weight',
            suffix: 'kg',
            icon: Icons.monitor_weight_outlined,
            controller: weightController,
          ),

          SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.05,
          ),

          // --------------------------------------------------
          // HEALTH GOAL
          // --------------------------------------------------

          _buildSectionTitle(
            icon: Icons.flag_outlined,
            title: 'Health Goal',
          ),

          const SizedBox(height: 10),

          _buildGoalSelector(),

          SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.15,
          ),

          // --------------------------------------------------
          // BUTTONS
          // --------------------------------------------------

          Row(
            children: [
              Expanded(
                child: _buildBackButton(),
              ),

              const SizedBox(width: 12),

              Expanded(
                flex: 2,
                child: _buildFinishButton(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // SECTION TITLE
  // ==========================================================

  Widget _buildSectionTitle({
    required IconData icon,
    required String title,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Appcolors.Primary,
        ),

        const SizedBox(width: 8),

        Text(
          title,

          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: Appcolors.Black,
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // INPUT FIELD
  // ==========================================================

  Widget _buildInputField({
    required String hint,
    required String suffix,
    required IconData icon,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.number,
  }) {
    return TextFormField(
      controller: controller,

      keyboardType: keyboardType,

      style: const TextStyle(
        fontSize: 14,
        color: Appcolors.Black,
        fontWeight: FontWeight.w500,
      ),

      decoration: InputDecoration(
        hintText: hint,

        hintStyle: TextStyle(
          color: Colors.grey.shade400,
          fontSize: 14,
        ),

        prefixIcon: Icon(
          icon,
          color: Colors.grey.shade500,
          size: 21,
        ),

        suffixText: suffix,

        suffixStyle: const TextStyle(
          color: Appcolors.Primary,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),

        filled: true,

        fillColor: Colors.grey.shade50,

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),

          borderSide: BorderSide(
            color: Colors.grey.shade200,
          ),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),

          borderSide: BorderSide(
            color: Colors.grey.shade200,
          ),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),

          borderSide: const BorderSide(
            color: Appcolors.Primary,
            width: 1.5,
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // GOAL SELECTOR
  // ==========================================================

  Widget _buildGoalSelector() {
    final goalOptions = [
      'Stay Healthy',
      'Lose Weight',
      'Gain Weight',
      'Build Muscle',
    ];

    return Wrap(
      spacing: 10,
      runSpacing: 10,

      children: goalOptions.map((item) {
        final bool isSelected = goals.contains(item);

        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                goals.remove(item);
              } else {
                goals.add(item);
              }
            });
          },

          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),

            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),

            decoration: BoxDecoration(
              color: isSelected
                  ? Appcolors.Primary
                  : Colors.grey.shade50,

              borderRadius: BorderRadius.circular(14),

              border: Border.all(
                color: isSelected
                    ? Appcolors.Primary
                    : Colors.grey.shade200,
              ),
            ),

            child: Row(
              mainAxisSize: MainAxisSize.min,

              children: [
                Text(
                  item,

                  style: TextStyle(
                    color: isSelected
                        ? Appcolors.White
                        : Colors.grey.shade700,

                    fontSize: 13,

                    fontWeight: FontWeight.w500,
                  ),
                ),

                if (isSelected) ...[
                  const SizedBox(width: 6),

                  const Icon(
                    Icons.check_rounded,
                    color: Appcolors.White,
                    size: 16,
                  ),
                ],
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ==========================================================
  // NEXT BUTTON
  // ==========================================================

  Widget _buildNextButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,

      child: ElevatedButton(
        onPressed: nextPage,

        style: ElevatedButton.styleFrom(
          backgroundColor: Appcolors.Primary,
          foregroundColor: Appcolors.White,
          elevation: 0,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),

        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Text(
              'Continue',

              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),

            SizedBox(width: 8),

            Icon(
              Icons.arrow_forward_rounded,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // BACK BUTTON
  // ==========================================================

  Widget _buildBackButton() {
    return SizedBox(
      height: 54,

      child: OutlinedButton(
        onPressed: previousPage,

        style: OutlinedButton.styleFrom(
          foregroundColor: Appcolors.Primary,

          side: BorderSide(
            color: Appcolors.Primary.withValues(alpha: 0.5),
          ),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),

        child: const Text(
          'Back',

          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // FINISH BUTTON
  // ==========================================================

  Widget _buildFinishButton() {
    return SizedBox(
      height: 54,

      child: ElevatedButton(
        onPressed: finishProfile,

        style: ElevatedButton.styleFrom(
          backgroundColor: Appcolors.Primary,
          foregroundColor: Appcolors.White,
          elevation: 0,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),

        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Text(
              'Finish',

              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),

            SizedBox(width: 8),

            Icon(
              Icons.check_rounded,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}