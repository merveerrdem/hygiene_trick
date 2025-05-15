import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final Color primaryColor = Colors.blueGrey.shade900;
  final Color secondaryColor = Colors.blueGrey.shade700;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tuvalet Kirlilik Durumu',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: primaryColor,
        primarySwatch: Colors.blueGrey,
        scaffoldBackgroundColor: Colors.grey[200],
        appBarTheme: AppBarTheme(
          backgroundColor: primaryColor,
          elevation: 4,
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(
              color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        popupMenuTheme: PopupMenuThemeData(
          color: Colors.blueGrey[50],
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          textStyle:
              TextStyle(color: primaryColor, fontWeight: FontWeight.w600),
          elevation: 6,
        ),
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final databaseRef = FirebaseDatabase.instance.ref();

  Map<String, dynamic>? allData;

  String? notificationMessage;

  @override
  void initState() {
    super.initState();

    databaseRef.child('cihazlar').onValue.listen((event) {
      final dataMap = event.snapshot.value;
      if (dataMap != null && dataMap is Map) {
        final Map<String, dynamic> combinedData = {};
        // Firebase realtime database'den gelen tüm alt verileri birleştir
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

  // Bildirim kontrolü: kilit süresi 30 sn'yi geçerse
  void _checkNotification(Map<String, dynamic>? data) {
    if (data == null) {
      notificationMessage = null;
      return;
    }

    final kilitSuresiStr = data.entries
        .firstWhere(
            (entry) =>
                entry.key.toLowerCase().contains('kilit') &&
                (entry.value is int || entry.value is double || entry.value is String),
            orElse: () => MapEntry('', null))
        .value;

    if (kilitSuresiStr != null) {
      // String ya da numara olabilir, önce numaraya çevir
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

  Widget _buildDataCard(String title, Map<String, dynamic>? data) {
    if (data == null || data.isEmpty) {
      return Card(
        margin: EdgeInsets.symmetric(vertical: 16),
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Center(
            child: Text(
              "Veri yükleniyor...",
              style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
            ),
          ),
        ),
      );
    }

    return Card(
      margin: EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey.shade900)),
            SizedBox(height: 16),
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
                  // Eğer renk verisi yoksa default sarı (amber) yapabiliriz
                  iconColor = Colors.amber;
                }
                bgColor = iconColor.withOpacity(0.15);
              }

              return Container(
                margin: EdgeInsets.symmetric(vertical: 10),
                padding: EdgeInsets.symmetric(vertical: 14, horizontal: 18),
                decoration: BoxDecoration(
                  color: bgColor ?? Colors.grey[100],
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
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
                        padding: EdgeInsets.all(12),
                        child: Icon(
                          Icons.wc,
                          color: iconColor,
                          size: 28,
                        ),
                      )
                    else
                      Icon(
                        Icons.wc,
                        color: Colors.grey[400],
                        size: 28,
                      ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            key,
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.blueGrey.shade800),
                          ),
                          SizedBox(height: 4),
                          Text(
                            value.toString(),
                            style: TextStyle(
                              fontSize: 18,
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

  @override
  Widget build(BuildContext context) {
    final mainIconColor = _getMainIconColor();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Tuvalet Kirlilik Durumu"),
      ),
      body: Column(
        children: [
          SizedBox(height: 20),
          Center(
            child: Icon(
              Icons.wc,
              size: 80,
              color: mainIconColor,
            ),
          ),
          if (notificationMessage != null)
            Container(
              width: double.infinity,
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              padding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.red.shade700,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.6),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  )
                ],
              ),
              child: Text(
                notificationMessage!,
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: _buildDataCard("Cihaz Verileri", allData),
            ),
          ),
        ],
      ),
      floatingActionButton: PopupMenuButton<String>(
        icon: Container(
          decoration: BoxDecoration(
            color: theme.primaryColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: theme.primaryColor.withOpacity(0.6),
                blurRadius: 6,
                spreadRadius: 1,
                offset: Offset(0, 3),
              ),
            ],
          ),
          padding: EdgeInsets.all(8),
          child: Icon(Icons.menu, size: 32, color: Colors.white),
        ),
        offset: Offset(-150, 0), // Menü sola açılır
        onSelected: (value) {
          if (value == 'profile') {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Profil seçildi!')),
            );
          } else if (value == 'plan') {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('İş Planı seçildi!')),
            );
          }
        },
        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
          PopupMenuItem<String>(
            value: 'profile',
            child: Row(
              children: [
                Icon(Icons.person, color: Colors.blueGrey.shade900),
                SizedBox(width: 10),
                Text('Profil', style: TextStyle(color: Colors.blueGrey.shade900)),
              ],
            ),
          ),
          PopupMenuItem<String>(
            value: 'plan',
            child: Row(
              children: [
                Icon(Icons.event_note, color: Colors.blueGrey.shade900),
                SizedBox(width: 10),
                Text('İş Planı', style: TextStyle(color: Colors.blueGrey.shade900)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
