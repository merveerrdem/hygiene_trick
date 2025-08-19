import 'package:flutter/material.dart';
import 'theme.dart';

class SystemSettingsScreen extends StatefulWidget {
  @override
  _SystemSettingsScreenState createState() => _SystemSettingsScreenState();
}

class _SystemSettingsScreenState extends State<SystemSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sistem Ayarları'),
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: AppTheme.backgroundGradient,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Genel Ayarlar',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    SizedBox(height: 16),
                    ListTile(
                      leading: Icon(Icons.notifications, color: AppTheme.primaryColor),
                      title: Text('Bildirimler'),
                      trailing: Switch(
                        value: true,
                        onChanged: (value) {
                          // Bildirim ayarları değişikliği
                        },
                        activeColor: AppTheme.primaryColor,
                      ),
                    ),
                    ListTile(
                      leading: Icon(Icons.language, color: AppTheme.primaryColor),
                      title: Text('Dil'),
                      trailing: Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        // Dil ayarları
                      },
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Uygulama Bilgileri',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    SizedBox(height: 16),
                    ListTile(
                      leading: Icon(Icons.info, color: AppTheme.primaryColor),
                      title: Text('Versiyon'),
                      subtitle: Text('1.0.0'),
                    ),
                    ListTile(
                      leading: Icon(Icons.security, color: AppTheme.primaryColor),
                      title: Text('Gizlilik Politikası'),
                      trailing: Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        // Gizlilik politikası sayfası
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.description, color: AppTheme.primaryColor),
                      title: Text('Kullanım Koşulları'),
                      trailing: Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        // Kullanım koşulları sayfası
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 