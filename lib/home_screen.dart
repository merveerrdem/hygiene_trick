import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tuvalet Kirlilik Durumu',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        scaffoldBackgroundColor: Colors.grey[200],
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blueGrey[900],
          elevation: 4,
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
  Map<String, dynamic>? esp32_1Data;
  Map<String, dynamic>? esp32_2Data;

  @override
  void initState() {
    super.initState();

    databaseRef.child('cihazlar/ESP32_1').onValue.listen((event) {
      final dataMap = event.snapshot.value;
      if (dataMap != null && dataMap is Map) {
        final data = Map<String, dynamic>.from(dataMap);
        setState(() {
          esp32_1Data = data;
        });
      } else {
        setState(() {
          esp32_1Data = null;
        });
      }
    });

    databaseRef.child('cihazlar/ESP32_2').onValue.listen((event) {
      final dataMap = event.snapshot.value;
      if (dataMap != null && dataMap is Map) {
        final data = Map<String, dynamic>.from(dataMap);
        setState(() {
          esp32_2Data = data;
        });
      } else {
        setState(() {
          esp32_2Data = null;
        });
      }
    });
  }

  Color _getPollutionColor(num value) {
    if (value < 5) return Colors.green;
    if (value < 10) return Colors.orange;
    return Colors.red;
  }

  // En baştaki iconun rengini belirle (sayac değerine göre)
  Color _getMainIconColor() {
    // esp32_1'de sayaç, kirlilik ya da değer içeren ilk uygun numarayı alalım
    if (esp32_1Data != null) {
      for (var entry in esp32_1Data!.entries) {
        var key = entry.key.toLowerCase();
        var value = entry.value;
        if (value is num && (key.contains('sayaç') || key.contains('kirlilik') || key.contains('değer'))) {
          return _getPollutionColor(value);
        }
      }
    }
    // Eğer bulamazsa varsayılan renk
    return Colors.grey;
  }

  Widget _buildDataCard(String title, Map<String, dynamic>? data) {
    if (data == null) {
      return Card(
        margin: EdgeInsets.symmetric(vertical: 16),
        child: Padding(
          padding: const EdgeInsets.all(30.0),
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
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey[900])),
            SizedBox(height: 16),
            ...data.entries.map((entry) {
              final key = entry.key;
              final value = entry.value;

              bool isCounter = false;
              num? numericValue;
              if (value is num) {
                numericValue = value;
                if (key.toLowerCase().contains('sayaç') ||
                    key.toLowerCase().contains('kirlilik') ||
                    key.toLowerCase().contains('değer')) {
                  isCounter = true;
                }
              }

              Color? iconColor;
              Color? bgColor;
              if (isCounter && numericValue != null) {
                iconColor = _getPollutionColor(numericValue);
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
                    if (isCounter && numericValue != null)
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: iconColor!.withOpacity(0.3),
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
                          size: 32,
                        ),
                      )
                    else
                      Icon(
                        Icons.wc,
                        color: Colors.grey[400],
                        size: 32,
                      ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            key,
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.blueGrey[800]),
                          ),
                          SizedBox(height: 4),
                          Text(
                            value.toString(),
                            style: TextStyle(
                              fontSize: 16,
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
    final theme = Theme.of(context);
    final mainIconColor = _getMainIconColor();

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
              size: 90,
              color: mainIconColor,
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                children: [
                  _buildDataCard("ESP32_1 Verileri", esp32_1Data),
                  _buildDataCard("ESP32_2 Verileri", esp32_2Data),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: PopupMenuButton<String>(
        icon: Icon(Icons.menu, size: 32, color: theme.primaryColor),
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
            child: Text('Profil'),
          ),
          PopupMenuItem<String>(
            value: 'plan',
            child: Text('İş Planı'),
          ),
        ],
      ),
    );
  }
}
