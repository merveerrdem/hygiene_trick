import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'theme.dart';

class WorkScheduleScreen extends StatefulWidget {
  @override
  _WorkScheduleScreenState createState() => _WorkScheduleScreenState();
}

class _WorkScheduleScreenState extends State<WorkScheduleScreen> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref().child('work_schedule');
  
  Map<String, List<bool>> workDays = {
    'Pazartesi': List.generate(24, (index) => false),
    'Salı': List.generate(24, (index) => false),
    'Çarşamba': List.generate(24, (index) => false),
    'Perşembe': List.generate(24, (index) => false),
    'Cuma': List.generate(24, (index) => false),
    'Cumartesi': List.generate(24, (index) => false),
    'Pazar': List.generate(24, (index) => false),
  };

  void saveSchedule() {
    Map<String, Map<String, bool>> schedule = {};
    workDays.forEach((day, hours) {
      schedule[day] = {};
      for (int i = 0; i < hours.length; i++) {
        if (hours[i]) {
          schedule[day]!['$i'] = true;
        }
      }
    });

    _database.child('personel1').set(schedule).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Çalışma saatleri kaydedildi')),
      );
      setState(() {
        workDays.forEach((day, hours) {
          for (int i = 0; i < hours.length; i++) {
            hours[i] = false;
          }
        });
      });
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: $error')),
      );
    });
  }

  @override
  void initState() {
    super.initState();
    // Mevcut çalışma saatlerini yükle
    _database.child('personel1').once().then((DatabaseEvent event) {
      if (event.snapshot.value != null) {
        Map<dynamic, dynamic> data = event.snapshot.value as Map<dynamic, dynamic>;
        setState(() {
          data.forEach((day, hours) {
            if (workDays.containsKey(day)) {
              Map<dynamic, dynamic> hourData = hours as Map<dynamic, dynamic>;
              hourData.forEach((hour, value) {
                int hourIndex = int.parse(hour.toString());
                if (hourIndex >= 0 && hourIndex < 24) {
                  workDays[day]![hourIndex] = value as bool;
                }
              });
            }
          });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: AppTheme.backgroundGradient,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text(
            'Haftalık Çalışma Planı',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: ListView.builder(
            itemCount: workDays.length,
            itemBuilder: (context, dayIndex) {
              String day = workDays.keys.elementAt(dayIndex);
              List<bool> hours = workDays[day]!;
              
              return Theme(
                data: Theme.of(context).copyWith(
                  dividerColor: Colors.transparent,
                ),
                child: ExpansionTile(
                  title: Text(
                    day,
                    style: const TextStyle(
                      color: Color(0xFF2C3E50),
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  children: [
                    Container(
                      height: 100,
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: 24,
                        itemBuilder: (context, hourIndex) {
                          return Container(
                            width: 70,
                            margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                            decoration: BoxDecoration(
                              color: hours[hourIndex] ? AppTheme.primaryColor.withOpacity(0.1) : Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: hours[hourIndex] ? AppTheme.primaryColor : Colors.grey[300]!,
                                width: 1,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '$hourIndex:00',
                                  style: TextStyle(
                                    color: hours[hourIndex] ? AppTheme.primaryColor : Colors.grey[600],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Transform.scale(
                                  scale: 1.2,
                                  child: Checkbox(
                                    value: hours[hourIndex],
                                    onChanged: (value) {
                                      setState(() {
                                        hours[hourIndex] = value!;
                                      });
                                    },
                                    activeColor: AppTheme.primaryColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: saveSchedule,
          backgroundColor: AppTheme.primaryColor,
          icon: const Icon(Icons.save),
          label: const Text('Kaydet'),
        ),
      ),
    );
  }
} 