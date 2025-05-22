import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:ui';
import 'theme.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminHomeScreen extends StatefulWidget {
  @override
  _AdminHomeScreenState createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref().child('cihazlar');
  final user = FirebaseAuth.instance.currentUser;

  String formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return 'Bilgi yok';
    return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
  }

  Color getColorFromStatus(String renk) {
    switch (renk.toLowerCase()) {
      case 'kırmızı':
        return Colors.red;
      case 'sarı':
        return Colors.orange;
      case 'yeşil':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData getIconFromStatus(String renk) {
    switch (renk.toLowerCase()) {
      case 'kırmızı':
        return Icons.warning_rounded;
      case 'sarı':
        return Icons.warning_amber_rounded;
      case 'yeşil':
        return Icons.check_circle;
      default:
        return Icons.help_outline;
    }
  }

  String getStatusText(String renk) {
    switch (renk.toLowerCase()) {
      case 'kırmızı':
        return 'Kritik';
      case 'sarı':
        return 'Uyarı';
      case 'yeşil':
        return 'Normal';
      default:
        return 'Bilinmiyor';
    }
  }

  String getKabinName(String deviceKey) {
    return deviceKey.replaceAll('ESP32_', 'Kabin ');
  }

  void _handleMenuSelection(String value, BuildContext context) {
    switch (value) {
      case 'profile':
        Navigator.pushNamed(context, '/admin_profile');
        break;
      case 'settings':
        Navigator.pushNamed(context, '/system_settings');
        break;
      case 'schedule':
        Navigator.pushNamed(context, '/work_schedule');
        break;
      case 'logout':
        Navigator.pushReplacementNamed(context, '/');
        break;
    }
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
            'Kabin Kontrol Paneli',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              itemBuilder: (BuildContext context) => [
                PopupMenuItem<String>(
                  value: 'profile',
                  child: ListTile(
                    leading: Icon(Icons.person, color: AppTheme.primaryColor),
                    title: const Text('Profil'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'settings',
                  child: ListTile(
                    leading: Icon(Icons.settings, color: AppTheme.primaryColor),
                    title: const Text('Ayarlar'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'schedule',
                  child: ListTile(
                    leading: Icon(Icons.schedule, color: AppTheme.primaryColor),
                    title: const Text('Çalışma Saatleri'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuDivider(),
                PopupMenuItem<String>(
                  value: 'logout',
                  child: ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text('Çıkış Yap', 
                      style: TextStyle(color: Colors.red),
                    ),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
              onSelected: (value) => _handleMenuSelection(value, context),
            ),
          ],
        ),
        body: Stack(
          children: [
            StreamBuilder(
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
                      'Cihaz verisi bulunamadı',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  );
                }

                Map<dynamic, dynamic> devices = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: devices.length,
                  itemBuilder: (context, index) {
                    String deviceKey = devices.keys.elementAt(index);
                    Map<dynamic, dynamic> device = devices[deviceKey] as Map<dynamic, dynamic>;
                    
                    String renk = device['renk']?.toString() ?? 'yeşil';
                    int sayac = device['sayac'] ?? 0;
                    bool sifirla = device['sifirla'] ?? false;
                    int sicaklik = device['sicaklik'] ?? 0;
                    int nem = device['nem'] ?? 0;
                    int gazDegeri = device['gaz_degeri'] ?? 0;
                    int amonyakDegeri = device['amonyak_degeri'] ?? 0;

                    Color statusColor = getColorFromStatus(renk);
                    IconData statusIcon = getIconFromStatus(renk);
                    String statusText = getStatusText(renk);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withOpacity(0.9),
                            Colors.white.withOpacity(0.8),
                          ],
                        ),
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
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      getKabinName(deviceKey),
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF2C3E50),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: statusColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: statusColor.withOpacity(0.5),
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            statusIcon,
                                            color: statusColor,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            statusText,
                                            style: TextStyle(
                                              color: statusColor,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    _buildInfoCard(
                                      icon: Icons.thermostat,
                                      title: 'Sıcaklık',
                                      value: '$sicaklik°C',
                                      color: Colors.orange,
                                    ),
                                    _buildInfoCard(
                                      icon: Icons.water_drop,
                                      title: 'Nem',
                                      value: '%$nem',
                                      color: Colors.blue,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    _buildInfoCard(
                                      icon: Icons.cloud,
                                      title: 'Gaz',
                                      value: gazDegeri.toString(),
                                      color: Colors.purple,
                                    ),
                                    _buildInfoCard(
                                      icon: Icons.science,
                                      title: 'Amonyak',
                                      value: amonyakDegeri.toString(),
                                      color: Colors.green,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2C3E50).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Kullanım Sayacı: $sayac',
                                        style: const TextStyle(
                                          color: Color(0xFF2C3E50),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        'Sıfırlama: ${sifirla ? "Aktif" : "Pasif"}',
                                        style: TextStyle(
                                          color: sifirla ? Colors.green : Colors.red,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
