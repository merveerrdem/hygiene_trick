import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'profil_sayfasi.dart'; // Profil sayfasını import ettik
import 'theme.dart'; // AppTheme sınıfını ayrı dosyada tuttuysan bunu ekle
import 'dart:ui';
import 'personnel_schedule_view.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // Tema renkleri AppTheme'den geliyor
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tuvalet Kirlilik Durumu',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppTheme.primaryColor,
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.green)
            .copyWith(
              primary: AppTheme.primaryColor,
              secondary: AppTheme.primaryDark,
            ),
        scaffoldBackgroundColor: AppTheme.backgroundGradient.last,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          titleTextStyle: const TextStyle(
              color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: AppTheme.primaryColor,
        ),
        bottomSheetTheme: BottomSheetThemeData(
          backgroundColor: Colors.white,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
        ),
      ),
      home: HomeScreen(),
    );
  }
}

// ---------------- BubbleBackground Widget ----------------

class BubbleBackground extends StatelessWidget {
  final Widget child;
  const BubbleBackground({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: AppTheme.backgroundGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -50,
            left: -50,
            child: _Bubble(80),
          ),
          Positioned(
            top: 50,
            right: -40,
            child: _Bubble(100),
          ),
          Positioned(
            bottom: -50,
            right: -50,
            child: _Bubble(80),
          ),
          Positioned(
            bottom: 100,
            left: -30,
            child: _Bubble(120),
          ),
          child,
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  final double size;
  const _Bubble(this.size);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.07),
        shape: BoxShape.circle,
      ),
    );
  }
}

// ------------------ HomeScreen ------------------

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref().child('cihazlar');
  Map<String, dynamic>? allData;
  String? notificationMessage;

  @override
  void initState() {
    super.initState();

    _database.onValue.listen((event) {
      final dataMap = event.snapshot.value;
      if (dataMap != null && dataMap is Map) {
        final Map<String, dynamic> combinedData = {};
        dataMap.forEach((key, value) {
          if (value is Map) {
            combinedData.addAll(Map<String, dynamic>.from(value));
          }
        });

        setState(() {
          allData = combinedData;
          _checkNotification(allData);
        });
      } else {
        setState(() {
          allData = null;
          notificationMessage = null;
        });
      }
    });
  }

  void _checkNotification(Map<String, dynamic>? data) {
    if (data == null) {
      notificationMessage = null;
      return;
    }

    final kilitSuresiStr = data.entries
        .firstWhere(
            (entry) =>
                entry.key.toLowerCase().contains('kilit') &&
                (entry.value is int ||
                    entry.value is double ||
                    entry.value is String),
            orElse: () => MapEntry('', null))
        .value;

    if (kilitSuresiStr != null) {
      int kilitSuresi = 0;
      if (kilitSuresiStr is String) {
        kilitSuresi = int.tryParse(kilitSuresiStr) ?? 0;
      } else if (kilitSuresiStr is int) {
        kilitSuresi = kilitSuresiStr;
      } else if (kilitSuresiStr is double) {
        kilitSuresi = kilitSuresiStr.toInt();
      }

      if (kilitSuresi > 30) {
        notificationMessage = "ACİL DURUM! Kilit süresi 30 saniyeyi geçti.";
      } else {
        notificationMessage = null;
      }
    } else {
      notificationMessage = null;
    }
  }

  Color _colorFromString(String? renk) {
    switch (renk?.toLowerCase()) {
      case 'yeşil':
        return Colors.green;
      case 'sarı':
        return Colors.amber;
      case 'kırmızı':
        return Colors.red;
      default:
        return Colors.blueGrey;
    }
  }

  Color _getMainIconColor() {
    if (allData != null && allData!.containsKey('renk')) {
      final renk = allData!['renk']?.toString();
      return _colorFromString(renk);
    }
    return Colors.blueGrey;
  }

  void _handleMenuSelection(String value, BuildContext context) {
    switch (value) {
      case 'profile':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProfilSayfasi()),
        );
        break;
      case 'schedule':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PersonnelScheduleView()),
        );
        break;
      case 'logout':
        Navigator.pushReplacementNamed(context, '/');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final mainIconColor = _getMainIconColor();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BubbleBackground(
        child: Stack(
          children: [
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 40),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Tuvalet Kirlilik Durumu",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white.withOpacity(0.95),
                            ),
                          ),
                          PopupMenuButton<String>(
                            icon: Icon(Icons.more_vert, color: Colors.white),
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
                                value: 'schedule',
                                child: ListTile(
                                  leading: Icon(Icons.schedule, color: AppTheme.primaryColor),
                                  title: const Text('İş Planı'),
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
                      const SizedBox(height: 32),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          // Koyu yeşil arka plan kaldırıldı
                        ),
                        child: Icon(
                          Icons.wc_rounded,
                          size: 160,
                          color: mainIconColor,
                        ),
                      ),
                      const SizedBox(height: 32),
                      if (notificationMessage != null)
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.redAccent.withOpacity(0.85),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            notificationMessage!,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      _buildDataCard("Tüm Cihaz Verileri", allData),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataCard(String title, Map<String, dynamic>? data) {
    if (data == null || data.isEmpty) {
      return Card(
        margin: const EdgeInsets.symmetric(vertical: 16),
        child: const Padding(
          padding: EdgeInsets.all(30.0),
          child: Center(
            child: Text(
              "Veri yükleniyor...",
              style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
            ),
          ),
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey.shade900)),
            const SizedBox(height: 12),
            ...data.entries.map((entry) {
              final key = entry.key;
              final value = entry.value;

              final isCounter = (key.toLowerCase().contains('sayaç') ||
                  key.toLowerCase().contains('kirlilik') ||
                  key.toLowerCase().contains('değer'));

              Color? iconColor;
              Color? bgColor;
              if (isCounter && value is num) {
                iconColor = _colorFromString(data['renk']?.toString());
                if (iconColor == Colors.blueGrey) {
                  iconColor = Colors.amber;
                }
                bgColor = iconColor.withOpacity(0.15);
              }

              return Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                decoration: BoxDecoration(
                  color: bgColor ?? Colors.grey[100],
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    )
                  ],
                ),
                child: Row(
                  children: [
                    if (isCounter && iconColor != null)
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: iconColor.withOpacity(0.3),
                          boxShadow: [
                            BoxShadow(
                              color: iconColor.withOpacity(0.5),
                              blurRadius: 6,
                              spreadRadius: 1,
                            )
                          ],
                        ),
                        padding: const EdgeInsets.all(10),
                        child: Icon(
                          Icons.wc,
                          color: iconColor,
                          size: 24,
                        ),
                      )
                    else
                      Icon(
                        Icons.wc,
                        color: Colors.grey[400],
                        size: 24,
                      ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            key,
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.blueGrey.shade800),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            value.toString(),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
