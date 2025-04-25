import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MedicineReminderScreen extends StatefulWidget {
  @override
  State<MedicineReminderScreen> createState() => _MedicineReminderScreenState();
}

class _MedicineReminderScreenState extends State<MedicineReminderScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();

  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  InputDecoration _inputDecoration(String hint, {IconData? icon}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.grey.shade100,
      suffixIcon: icon != null ? Icon(icon, color: const Color(0xFF0B0B45)) : null,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medicine Reminder'),
        backgroundColor: const Color(0xFF0B0B45),
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text(
                "Reminder Title",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF0B0B45)),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _titleController,
                decoration: _inputDecoration('e.g., Take Vitamin D'),
                validator: (value) => value == null || value.trim().isEmpty ? 'Please enter a title' : null,
              ),
              const SizedBox(height: 20),
              const Text(
                "Select Date",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF0B0B45)),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _dateController,
                readOnly: true,
                decoration: _inputDecoration('Choose a date', icon: Icons.calendar_today),
                onTap: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: selectedDate ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      selectedDate = pickedDate;
                      _dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
                    });
                  }
                },
                validator: (value) => value == null || value.isEmpty ? 'Please select a date' : null,
              ),
              const SizedBox(height: 20),
              const Text(
                "Select Time",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF0B0B45)),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _timeController,
                readOnly: true,
                decoration: _inputDecoration('Choose a time', icon: Icons.access_time),
                onTap: () async {
                  final pickedTime = await showTimePicker(
                    context: context,
                    initialTime: selectedTime ?? TimeOfDay.now(),
                  );
                  if (pickedTime != null) {
                    setState(() {
                      selectedTime = pickedTime;
                      _timeController.text = pickedTime.format(context);
                    });
                  }
                },
                validator: (value) => value == null || value.isEmpty ? 'Please select a time' : null,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                ),
                onPressed: () async {
                  if (_formKey.currentState?.validate() != true) return;

                  final title = _titleController.text.trim();
                  final date = _dateController.text.trim();
                  final time = _timeController.text.trim();

                  if (title.isEmpty || date.isEmpty || time.isEmpty || selectedTime == null || selectedDate == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please fill all fields')),
                    );
                    return;
                  }

                  final dtParts = date.split('-');
                  final reminderDateTime = DateTime(
                    int.parse(dtParts[0]),
                    int.parse(dtParts[1]),
                    int.parse(dtParts[2]),
                    selectedTime!.hour,
                    selectedTime!.minute,
                  );

                  try {
                    final user = FirebaseAuth.instance.currentUser;
                    if (user == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('User not logged in')),
                      );
                      return;
                    }

                    final reminderRef = FirebaseFirestore.instance
                        .collection('users')
                        .doc(user.uid)
                        .collection('MediReminders')
                        .doc();

                    // Save the reminder data to Firestore
                    await reminderRef.set({
                      'title': title,
                      'timestamp': reminderDateTime.toUtc(),
                      'notified': false,
                    });

                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Reminder "$title" set successfully')),
                      );

                      setState(() {
                        _titleController.clear();
                        _dateController.clear();
                        _timeController.clear();
                        selectedDate = null;
                        selectedTime = null;
                      });
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Failed to set reminder')),
                      );
                    }
                  }
                },
                child: const Text("Set Reminder", style: TextStyle(fontSize: 17)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
