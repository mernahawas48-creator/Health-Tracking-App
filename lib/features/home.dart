import 'package:flutter/material.dart';
import 'package:meditrack/themes/appcolors.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  height: 203,
                  color: Appcolors.Primary,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 30,
                          child: Icon(Icons.person),
                        ),

                        const SizedBox(width: 15),

                        const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome 👋',
                              style: TextStyle(
                                color: Appcolors.White,
                                fontFamily: 'Inter',
                                fontSize: 17,
                                fontWeight: FontWeight.w400,
                              ),
                            ),

                            SizedBox(height: 4),

                            Text(
                              'User Name',
                              style: TextStyle(
                                color: Appcolors.White,
                                fontFamily: 'Inter',
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                        const Spacer(),

                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            onPressed: () {
                              // Notifications page later
                            },
                            icon: const Icon(
                              Icons.notifications_none,
                              color: Appcolors.White,
                              size: 27,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Transform.translate(
                  offset: const Offset(0, -50),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Appcolors.White,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Appcolors.Grey3),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.medication_outlined,
                                    color: Appcolors.SecondaryOrange,
                                  ),

                                  const SizedBox(width: 8),

                                  const Text(
                                    'Upcoming Medication',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 20),

                              const Icon(
                                Icons.notifications_none,
                                size: 35,
                                color: Appcolors.Grey2,
                              ),

                              const SizedBox(height: 8),

                              const Text(
                                'No reminders yet',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),

                              const SizedBox(height: 5),

                              const Text(
                                'Add your first medication',
                                style: TextStyle(color: Appcolors.Grey2),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Appcolors.White,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Appcolors.Grey3),
                          ),
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.directions_walk,
                                    color: Appcolors.Primary,
                                  ),

                                  SizedBox(width: 8),

                                  Text(
                                    'Activity',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: 20),

                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Burned Calories',
                                    style: TextStyle(fontSize: 15),
                                  ),

                                  Text(
                                    '0 / 300 kcal',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: 10),

                              LinearProgressIndicator(value: 0, minHeight: 7),

                              SizedBox(height: 25),

                              Row(
                                children: [
                                  // STEPS
                                  Expanded(
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.directions_walk,
                                          color: Appcolors.Primary,
                                        ),

                                        SizedBox(height: 5),

                                        Text(
                                          '0',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),

                                        Text(
                                          'Steps',
                                          style: TextStyle(
                                            color: Appcolors.Grey2,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // DISTANCE
                                  Expanded(
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.route_outlined,
                                          color: Appcolors.Primary,
                                        ),

                                        SizedBox(height: 5),

                                        Text(
                                          '0.0 km',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),

                                        Text(
                                          'Distance',
                                          style: TextStyle(
                                            color: Appcolors.Grey2,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        Row(
                          children: [
                            // WATER
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Appcolors.White,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Appcolors.Grey3),
                                ),
                                child: const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.water_drop_outlined,
                                      color: Colors.blue,
                                    ),

                                    SizedBox(height: 12),

                                    Text(
                                      'Water',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),

                                    SizedBox(height: 5),

                                    Text(
                                      '0 / 2000 ml',
                                      style: TextStyle(color: Appcolors.Grey2),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(width: 12),

                            // SLEEP
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Appcolors.White,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Appcolors.Grey3),
                                ),
                                child: const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.bedtime_outlined,
                                      color: Colors.indigo,
                                    ),

                                    SizedBox(height: 12),

                                    Text(
                                      'Sleep',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),

                                    SizedBox(height: 5),

                                    Text(
                                      'No sleep logged',
                                      style: TextStyle(color: Appcolors.Grey2),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Appcolors.White,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Appcolors.Grey3),
                          ),
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Today's Medications",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              SizedBox(height: 20),

                              Center(
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.medication_outlined,
                                      size: 38,
                                      color: Appcolors.Grey2,
                                    ),

                                    SizedBox(height: 8),

                                    Text(
                                      'No medications scheduled for today',
                                      style: TextStyle(color: Appcolors.Grey2),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            right: 20,
            bottom: 20,
            child: FloatingActionButton(
              heroTag: 'aiAssistant',
              backgroundColor: Appcolors.White,
              shape: const CircleBorder(),
              onPressed: () {
                // AI Assistant page later
              },
              child: const Text('🤖', style: TextStyle(fontSize: 27)),
            ),
          ),
        ],
      ),

      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Appcolors.White, width: 4),
            ),
            child: FloatingActionButton(
              heroTag: 'addAlert',
              backgroundColor: Appcolors.Primary,
              elevation: 0,
              shape: const CircleBorder(),
              onPressed: () {
                // Add Alert page later
              },
              child: const Icon(Icons.add, color: Appcolors.White, size: 40),
            ),
          ),

          const SizedBox(height: 3),

          const Text(
            'Add Alert',
            style: TextStyle(
              color: Appcolors.Grey2,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: BottomAppBar(
        height: 80,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(index: 0, icon: Icons.home_outlined, title: 'Home'),

            _navItem(
              index: 1,
              icon: Icons.local_pharmacy_outlined,
              title: 'Meds',
            ),

            // Space for Add Alert button
            const SizedBox(width: 70),

            _navItem(index: 2, icon: Icons.eco_outlined, title: 'Nutrition'),

            _navItem(index: 3, icon: Icons.person_2_outlined, title: 'Profile'),
          ],
        ),
      ),
    );
  }

  Widget _navItem({
    required int index,
    required IconData icon,
    required String title,
  }) {
    return IconButton(
      padding: EdgeInsets.zero,
      onPressed: () {
        setState(() {
          selectedIndex = index;
        });
      },
      icon: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: selectedIndex == index ? Appcolors.Primary : Appcolors.Grey2,
          ),

          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: selectedIndex == index
                  ? Appcolors.Primary
                  : Appcolors.Grey2,
            ),
          ),
        ],
      ),
    );
  }
}
