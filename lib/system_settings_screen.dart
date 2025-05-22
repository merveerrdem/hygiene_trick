import 'package:flutter/material.dart';
import 'dart:ui';
import 'theme.dart';

class SystemSettingsScreen extends StatefulWidget {
  @override
  _SystemSettingsScreenState createState() => _SystemSettingsScreenState();
}

class _SystemSettingsScreenState extends State<SystemSettingsScreen> {
  bool _notificationsEnabled = true;
  bool _autoReset = false;
  String _selectedLanguage = 'Türkçe';
  double _criticalTemp = 30.0;
  double _criticalHumidity = 70.0;
  double _criticalGas = 500.0;
  double _criticalAmmonia = 25.0;

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
            'Sistem Ayarları',
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
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Bildirimler ve Uyarılar'),
              _buildSettingsCard([
                SwitchListTile(
                  title: const Text('Bildirimler'),
                  subtitle: const Text('Sistem bildirimleri ve uyarıları'),
                  value: _notificationsEnabled,
                  onChanged: (value) => setState(() => _notificationsEnabled = value),
                ),
                SwitchListTile(
                  title: const Text('Otomatik Sıfırlama'),
                  subtitle: const Text('Günlük kullanım sayacını otomatik sıfırla'),
                  value: _autoReset,
                  onChanged: (value) => setState(() => _autoReset = value),
                ),
              ]),
              
              const SizedBox(height: 24),
              _buildSectionTitle('Kritik Değer Ayarları'),
              _buildSettingsCard([
                _buildSliderTile(
                  title: 'Kritik Sıcaklık',
                  subtitle: 'Sıcaklık uyarı eşiği (°C)',
                  value: _criticalTemp,
                  min: 20,
                  max: 40,
                  onChanged: (value) => setState(() => _criticalTemp = value),
                ),
                const Divider(),
                _buildSliderTile(
                  title: 'Kritik Nem',
                  subtitle: 'Nem uyarı eşiği (%)',
                  value: _criticalHumidity,
                  min: 50,
                  max: 90,
                  onChanged: (value) => setState(() => _criticalHumidity = value),
                ),
                const Divider(),
                _buildSliderTile(
                  title: 'Kritik Gaz Seviyesi',
                  subtitle: 'Gaz uyarı eşiği (ppm)',
                  value: _criticalGas,
                  min: 200,
                  max: 1000,
                  onChanged: (value) => setState(() => _criticalGas = value),
                ),
                const Divider(),
                _buildSliderTile(
                  title: 'Kritik Amonyak Seviyesi',
                  subtitle: 'Amonyak uyarı eşiği (ppm)',
                  value: _criticalAmmonia,
                  min: 10,
                  max: 50,
                  onChanged: (value) => setState(() => _criticalAmmonia = value),
                ),
              ]),

              const SizedBox(height: 24),
              _buildSectionTitle('Sistem'),
              _buildSettingsCard([
                ListTile(
                  title: const Text('Dil'),
                  subtitle: Text(_selectedLanguage),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // Dil seçim dialogu
                  },
                ),
                const Divider(),
                ListTile(
                  title: const Text('Veri Yedekleme'),
                  subtitle: const Text('Son yedekleme: Bugün 15:30'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // Yedekleme sayfası
                  },
                ),
                const Divider(),
                ListTile(
                  title: const Text('Sistem Bilgisi'),
                  subtitle: const Text('Versiyon 1.0.0'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // Sistem bilgi sayfası
                  },
                ),
              ]),
              
              const SizedBox(height: 24),
              _buildSectionTitle('Tehlike'),
              _buildSettingsCard([
                ListTile(
                  title: const Text(
                    'Sistemi Sıfırla',
                    style: TextStyle(color: Colors.red),
                  ),
                  subtitle: const Text(
                    'Tüm ayarları varsayılana döndür',
                    style: TextStyle(color: Colors.red),
                  ),
                  trailing: const Icon(Icons.warning, color: Colors.red),
                  onTap: () {
                    // Sıfırlama onay dialogu
                  },
                ),
              ]),
              
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
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
          child: Column(children: children),
        ),
      ),
    );
  }

  Widget _buildSliderTile({
    required String title,
    required String subtitle,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          Row(
            children: [
              Text(min.toStringAsFixed(1)),
              Expanded(
                child: Slider(
                  value: value,
                  min: min,
                  max: max,
                  divisions: ((max - min) * 10).toInt(),
                  label: value.toStringAsFixed(1),
                  onChanged: onChanged,
                ),
              ),
              Text(max.toStringAsFixed(1)),
            ],
          ),
        ],
      ),
    );
  }
} 