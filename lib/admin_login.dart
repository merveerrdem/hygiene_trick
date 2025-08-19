import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'theme.dart'; // Tema dosyan

class AdminLoginScreen extends StatefulWidget {
  @override
  _AdminLoginScreenState createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  Future<void> signIn() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      _showMessage('Lütfen email ve şifre alanlarını doldurun.');
      return;
    }

    setState(() => isLoading = true);
    final String inputEmail = emailController.text.trim();
    final String inputPassword = passwordController.text.trim();
    try {
      // Firebase Authentication ile giriş
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: inputEmail,
        password: inputPassword,
      );

      final email = userCredential.user?.email;
      if (email == null) throw Exception('Kullanıcı email bulunamadı.');

      // Firestore'da admin rolünü doğrula
      final querySnapshot = await FirebaseFirestore.instance
          .collection('Admin')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final Map<String, dynamic> adminData = querySnapshot.docs.first.data();
        final String? role = _getStringField(adminData, 'role');
        if (role == 'admin') {
          Navigator.pushReplacementNamed(context, '/admin_home_screen');
          return;
        } else {
          await FirebaseAuth.instance.signOut();
          _showMessage('Bu kullanıcı admin yetkisine sahip değil veya role alanı eksik.');
        }
      } else {
        await FirebaseAuth.instance.signOut();
        _showMessage('Bu hesap admin olarak kayıtlı değil. Lütfen yönetici ile iletişime geçin.');
      }
    } on FirebaseAuthException catch (e) {
      // Kullanıcı Auth'ta yoksa, Firestore'daki kayıtla otomatik oluşturmayı dene
      if (e.code == 'user-not-found') {
        try {
          final adminQuery = await FirebaseFirestore.instance
              .collection('Admin')
              .where('email', isEqualTo: inputEmail)
              .limit(1)
              .get();

          if (adminQuery.docs.isNotEmpty) {
            final data = adminQuery.docs.first.data();
            final String? storedPassword = _getStringField(data, 'password');
            final String? role = _getStringField(data, 'role');

            if (storedPassword == inputPassword && role == 'admin') {
              // Auth'ta kullanıcı oluştur ve giriş yap
              await FirebaseAuth.instance.createUserWithEmailAndPassword(
                email: inputEmail,
                password: inputPassword,
              );
              Navigator.pushReplacementNamed(context, '/admin_home_screen');
              return;
            }
          }
          _showMessage('Giriş başarısız: Bu email için admin kaydı bulunamadı veya şifre/role eşleşmiyor.');
        } catch (ie) {
          _showMessage('Hata: $ie');
        }
      } else if (e.code == 'wrong-password') {
        _showMessage('Hatalı şifre girdiniz.');
      } else if (e.code == 'invalid-email') {
        _showMessage('Geçersiz email formatı.');
      } else {
        _showMessage('Giriş başarısız: ${e.message ?? 'Bilinmeyen bir hata oluştu.'}');
      }
    } catch (e) {
      _showMessage('Hata: $e');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  // Firestore'da alan adı "role ", " Role", "ROLE" gibi hatalı/boşluklu olabilir
  String? _getStringField(Map<String, dynamic> data, String expectedKey) {
    for (final key in data.keys) {
      final String normalized = key.toString().trim().toLowerCase();
      if (normalized == expectedKey.toLowerCase()) {
        final value = data[key];
        if (value is String) return value;
        return value?.toString();
      }
    }
    return null;
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w600,
      ),
      filled: true,
      fillColor: AppTheme.primaryColor.withOpacity(0.6),
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(color: Colors.white54, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(color: Colors.white, width: 2.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppTheme.backgroundGradient.last,
      body: BubbleBackground( // Eğer bu özel bir widget'sa theme.dart içinde tanımlı olmalı
        child: Stack(
          children: [
            // Geri butonu
            Positioned(
              top: MediaQuery.of(context).padding.top,
              left: 0,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28.0),
                  child: SingleChildScrollView(
                    reverse: true,
                    padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 30),
                        Icon(
                          Icons.admin_panel_settings_rounded,
                          size: 72,
                          color: Colors.white.withOpacity(0.85),
                          shadows: const [
                            Shadow(
                              color: Colors.black45,
                              offset: Offset(2, 2),
                              blurRadius: 4,
                            )
                          ],
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "Admin Paneli",
                          style: textTheme.headlineLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.4),
                                offset: const Offset(2, 2),
                                blurRadius: 5,
                              )
                            ],
                          ),
                        ),
                        const SizedBox(height: 60),

                        // E-posta Alanı
                        TextField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: _inputDecoration("E-posta"),
                          style: const TextStyle(fontSize: 18, color: Colors.white),
                          cursorColor: Colors.white,
                        ),
                        const SizedBox(height: 24),

                        // Şifre Alanı
                        TextField(
                          controller: passwordController,
                          obscureText: true,
                          decoration: _inputDecoration("Şifre"),
                          style: const TextStyle(fontSize: 18, color: Colors.white),
                          cursorColor: Colors.white,
                        ),
                        const SizedBox(height: 60),

                        // Giriş Butonu veya Yükleniyor
                        isLoading
                            ? const CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                strokeWidth: 4,
                              )
                            : ElevatedButton(
                                onPressed: signIn,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: AppTheme.primaryColor,
                                  minimumSize: const Size(double.infinity, 56),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  elevation: 8,
                                  shadowColor: Colors.black45,
                                ),
                                child: Text(
                                  "Giriş Yap",
                                  style: textTheme.labelLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryColor,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
