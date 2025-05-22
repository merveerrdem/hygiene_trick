import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:ui';
import 'theme.dart';

class PersonnelScheduleView extends StatelessWidget {
  final DatabaseReference _database = FirebaseDatabase.instance.ref().child('work_schedule/personel1');

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
            'Çalışma Saatleri',
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
        body: StreamBuilder(
          stream: _database.onValue,
          builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Hata: ${snapshot.error}',
                  style: const TextStyle(color: Colors.white),
                ),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              );
            }

            if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
              return const Center(
                child: Text(
                  'Çalışma saati bilgisi bulunamadı',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              );
            }

            Map<dynamic, dynamic> schedule = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
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
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Column(
                          children: [
                            _buildDaySchedule('Pazartesi', schedule['monday'] ?? {}),
                            const Divider(),
                            _buildDaySchedule('Salı', schedule['tuesday'] ?? {}),
                            const Divider(),
                            _buildDaySchedule('Çarşamba', schedule['wednesday'] ?? {}),
                            const Divider(),
                            _buildDaySchedule('Perşembe', schedule['thursday'] ?? {}),
                            const Divider(),
                            _buildDaySchedule('Cuma', schedule['friday'] ?? {}),
                            const Divider(),
                            _buildDaySchedule('Cumartesi', schedule['saturday'] ?? {}),
                            const Divider(),
                            _buildDaySchedule('Pazar', schedule['sunday'] ?? {}),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDaySchedule(String day, Map<dynamic, dynamic> daySchedule) {
    String startTime = daySchedule['start_time']?.toString() ?? '-';
    String endTime = daySchedule['end_time']?.toString() ?? '-';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              day,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$startTime - $endTime',
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 