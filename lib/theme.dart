import 'dart:math';
import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF81C784);
  static const Color primaryDark = Color(0xFF66BB6A);
  static const List<Color> backgroundGradient = [
    Color(0xFFA8E6CF),
    Color(0xFFDCEDC1),
  ];

  static ThemeData get themeData => ThemeData(
        primaryColor: primaryColor,
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: primaryColor,
          secondary: primaryDark,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
            elevation: 3,
            minimumSize: const Size(double.infinity, 50),
            textStyle:
                const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            textStyle:
                const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            fontSize: 38,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: 1.5,
          ),
          labelLarge: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      );
}

class Bubble {
  double x;
  double y;
  double radius;
  double speed;

  Bubble(this.x, this.y, this.radius, this.speed);
}

class BubbleBackground extends StatefulWidget {
  final Widget child;

  const BubbleBackground({required this.child, Key? key}) : super(key: key);

  @override
  State<BubbleBackground> createState() => _BubbleBackgroundState();
}

class _BubbleBackgroundState extends State<BubbleBackground>
    with TickerProviderStateMixin {
  late final AnimationController _bubbleController;
  final List<Bubble> bubbles = [];

  @override
  void initState() {
    super.initState();
    _bubbleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

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
      setState(() {});
    });
  }

  @override
  void dispose() {
    _bubbleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: AppTheme.backgroundGradient,
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        AnimatedBuilder(
          animation: _bubbleController,
          builder: (_, __) => CustomPaint(
            painter: BubblePainter(_bubbleController.value, bubbles),
            child: const SizedBox.expand(),
          ),
        ),
        widget.child,
      ],
    );
  }
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
  bool shouldRepaint(covariant BubblePainter oldDelegate) => true;
}
