import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'dart:math';
import 'personnel_login.dart';
import 'admin_login.dart';
import 'home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Giriş Uygulaması',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => LoginSelectionScreen(),
        '/personnel_login': (context) => PersonnelLoginScreen(),
        '/admin_login': (context) => AdminLoginScreen(),
        '/home': (context) => HomeScreen(),
      },
    );
  }
}

class LoginSelectionScreen extends StatefulWidget {
  @override
  State<LoginSelectionScreen> createState() => _LoginSelectionScreenState();
}

class _LoginSelectionScreenState extends State<LoginSelectionScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _bubbleController;

  final List<Bubble> bubbles = [];

  @override
  void initState() {
    super.initState();

    _fadeController =
        AnimationController(vsync: this, duration: Duration(seconds: 2));
    _fadeAnimation =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut);
    _fadeController.forward();

    _bubbleController =
        AnimationController(vsync: this, duration: Duration(seconds: 10))
          ..repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final random = Random();
      final size = MediaQuery.of(context).size;

      for (int i = 0; i < 20; i++) {
        bubbles.add(Bubble(
          random.nextDouble() * size.width,
          random.nextDouble() * size.height,
          random.nextDouble() * 15 + 5,
          random.nextDouble() * 0.5 + 0.2,
        ));
      }
      setState(() {}); // Bubbles eklendikten sonra rebuild için
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _bubbleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Arka plan gradyan + baloncuklar
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFA8E6CF), Color(0xFFDCEDC1)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          AnimatedBuilder(
            animation: _bubbleController,
            builder: (context, child) {
              return CustomPaint(
                painter: BubblePainter(_bubbleController.value, bubbles),
                child: Container(),
              );
            },
          ),
          // İçerik
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.clean_hands_rounded,
                      size: 64,
                      color: Colors.white,
                    ),
                    SizedBox(height: 20),
                    Text(
                      "Hygiene Track",
                      style: TextStyle(
                        fontSize: 38,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.white.withOpacity(0.2),
                            offset: Offset(2, 2),
                            blurRadius: 4,
                          )
                        ],
                        letterSpacing: 1.5,
                      ),
                    ),
                    SizedBox(height: 60),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF81C784),
                        foregroundColor: Colors.white,
                        minimumSize: Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 3,
                      ),
                      child:
                          Text("Personel Girişi", style: TextStyle(fontSize: 18)),
                      onPressed: () {
                        Navigator.pushNamed(context, '/personnel_login');
                      },
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF66BB6A),
                        foregroundColor: Colors.white,
                        minimumSize: Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 3,
                      ),
                      child: Text("Admin Girişi", style: TextStyle(fontSize: 18)),
                      onPressed: () {
                        Navigator.pushNamed(context, '/admin_login');
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Bubble {
  double x;
  double y;
  double radius;
  double speed;

  Bubble(this.x, this.y, this.radius, this.speed);
}

class BubblePainter extends CustomPainter {
  final double progress;
  final List<Bubble> bubbles;

  BubblePainter(this.progress, this.bubbles);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.1);

    for (var bubble in bubbles) {
      double newY = bubble.y - bubble.speed * progress * 60;
      if (newY < -bubble.radius) {
        bubble.y = size.height + bubble.radius;
      } else {
        bubble.y = newY;
      }
      canvas.drawCircle(Offset(bubble.x, bubble.y), bubble.radius, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
