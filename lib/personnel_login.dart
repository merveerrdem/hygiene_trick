import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'theme.dart'; // Temanı buradan import et

class PersonnelLoginScreen extends StatefulWidget {
  @override
  _PersonnelLoginScreenState createState() => _PersonnelLoginScreenState();
}

class _PersonnelLoginScreenState extends State<PersonnelLoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;

  Future<void> signIn() async {
    setState(() => isLoading = true);

    final String inputEmail = emailController.text.trim();
    final String inputPassword = passwordController.text.trim();

    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: inputEmail,
        password: inputPassword,
      );

      final email = userCredential.user?.email;
      if (email == null) throw Exception('Kullanıcı email bulunamadı.');

      final querySnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final userDoc = querySnapshot.docs.first;
        final role = userDoc.get('role');

        if (role == 'user' || role == 'admin') {
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          await FirebaseAuth.instance.signOut();
          _showMessage('Bu kullanıcı yetkili değil.');
        }
      } else {
        await FirebaseAuth.instance.signOut();
        _showMessage('Bu hesap personel olarak kayıtlı değil.');
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        try {
          final userQuery = await FirebaseFirestore.instance
              .collection('Users')
              .where('email', isEqualTo: inputEmail)
              .limit(1)
              .get();

          if (userQuery.docs.isNotEmpty) {
            final data = userQuery.docs.first.data();
            final String? storedPassword = data['password'] as String?;
            final String? role = data['role'] as String?;

            if (storedPassword == inputPassword && (role == 'user' || role == 'admin')) {
              await FirebaseAuth.instance.createUserWithEmailAndPassword(
                email: inputEmail,
                password: inputPassword,
              );
              Navigator.pushReplacementNamed(context, '/home');
              return;
            }
          }
          _showMessage('Giriş başarısız: Bu email için kullanıcı kaydı bulunamadı veya şifre eşleşmiyor.');
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
      body: BubbleBackground(
        child: Stack(
          children: [
            // Üstte şeffaf geri butonu (Admin ekranıyla birebir)
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
                          Icons.clean_hands_rounded,
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
                          "Personel Girişi",
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
                        TextField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: _inputDecoration("E-posta"),
                          style: const TextStyle(fontSize: 18, color: Colors.white),
                          cursorColor: Colors.white,
                        ),
                        const SizedBox(height: 24),
                        TextField(
                          controller: passwordController,
                          obscureText: true,
                          decoration: _inputDecoration("Şifre"),
                          style: const TextStyle(fontSize: 18, color: Colors.white),
                          cursorColor: Colors.white,
                        ),
                        const SizedBox(height: 60),
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
