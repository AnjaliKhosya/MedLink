import 'package:flutter/material.dart';
import 'package:medlink/EmergencyAlert.dart';
import 'package:medlink/MedRecords.dart';
import 'package:medlink/MedicineReminderScreen.dart';
import 'dart:async';

// Import necessary packages for notifications
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final String userName = "Anjali";

  final List<String> bannerImages = [
    'assets/images/Banner.jpeg',
    'assets/images/bannerImage.jpeg',
  ];

  int _currentBannerIndex = 0;
  late Timer _timer;

  // Notification plugin setup
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  // Sample reminders with their dates and notification statuses
  List<Map<String, dynamic>> reminders = [
    {
      'title': 'Medication Reminder',
      'date': DateTime.now().add(Duration(days: 1)), // Example: Tomorrow
      'notified': false,
    },
    {
      'title': 'Doctor Appointment',
      'date': DateTime.now().add(Duration(days: 2)), // Example: In 2 days
      'notified': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _startBannerTimer();

    // Initialize notification plugin
    _initializeNotifications();

    // Check for reminders to send
    _checkReminders();
  }

  void _startBannerTimer() {
    _timer = Timer.periodic(Duration(seconds: 2), (Timer timer) {
      setState(() {
        _currentBannerIndex = (_currentBannerIndex + 1) % bannerImages.length;
      });
    });
  }

  // Initialize the notifications
  void _initializeNotifications() async {
    var androidInitialize = AndroidInitializationSettings('app_icon');
    var initializationSettings =
    InitializationSettings(android: androidInitialize);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // Show notification function
  void _showNotification(String title, String body) async {
    var androidDetails = AndroidNotificationDetails(
        'channel_id', 'Local Notifications', channelDescription: 'Test Channel');
    var notificationDetails = NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      notificationDetails,
    );
  }

  // Check for reminders and send notifications if due
  void _checkReminders() {
    for (var reminder in reminders) {
      if (!reminder['notified'] && _isReminderToday(reminder['date'])) {
        _showNotification(reminder['title'], 'This is your reminder for ${reminder['title']}');
        setState(() {
          reminder['notified'] = true; // Mark as notified
        });
      }
    }
  }

  // Check if the reminder date is today
  bool _isReminderToday(DateTime reminderDate) {
    DateTime now = DateTime.now();
    return reminderDate.year == now.year &&
        reminderDate.month == now.month &&
        reminderDate.day == now.day;
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add map related logic if needed
          _showNotification('Map Feature', 'You pressed the map button!');
        },
        child: Icon(Icons.map),
        backgroundColor: Colors.teal,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Med Link',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: Icon(Icons.notifications_none),
                      onPressed: () {
                        // Notification button logic
                        _showNotification('Notification', 'You pressed the notification button!');
                      },
                    ),
                  ],
                ),

                SizedBox(height: 10),

                // Greeting
                Text(
                  'Hi, $userName',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                ),

                SizedBox(height: 20),

                // Community Section
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: Text(
                      'Community Section',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),

                SizedBox(height: 20),

                // Animated Banner
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: AnimatedSwitcher(
                    duration: Duration(seconds: 1),
                    child: Image.asset(
                      bannerImages[_currentBannerIndex],
                      key: ValueKey<int>(_currentBannerIndex),
                      height: 160,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                SizedBox(height: 20),

                // Vertical Feature Boxes
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      featureBox(
                        context,
                        title: 'MedHub',
                        onTap: () {
                          // Navigate to MedHub Page
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => MedRecord()),
                          );
                        },
                      ),
                      featureBox(
                        context,
                        title: 'MediReminder',
                        onTap: () {
                          // Navigate to MediReminder Page
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => MedicineReminderScreen()),
                          );
                        },
                      ),
                      featureBox(
                        context,
                        title: 'Emergency Alert',
                        onTap: () {
                          // Navigate to EmergencyAlert Page
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => EmergencyAlert()),
                          );
                        },
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget featureBox(BuildContext context, {required String title, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: Container(
          margin: EdgeInsets.only(bottom: 16,left: 2,right: 2),
          height: 300,
          width: 130,
          decoration: BoxDecoration(
            color: Colors.teal.shade100,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(2, 2)),
            ],
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.only(left: 5.0,right: 5),
              child: Text(
                title,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
