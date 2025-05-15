import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAQZMpHM9PjNHHYf76CHUU6uWV2Oe-GL9o',
    appId: '1:237365843444:web:2f187071b2c38ccf4795a1',
    messagingSenderId: '237365843444',
    projectId: 'hygiene-track',
    authDomain: 'hygiene-track.firebaseapp.com',
    databaseURL: 'https://hygiene-track-default-rtdb.firebaseio.com',
    storageBucket: 'hygiene-track.firebasestorage.app',
    measurementId: 'G-1JJXE9JS8W',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDM4bH6XIH7rRpo3np6_KgklVUvctoShQg',
    appId: '1:237365843444:android:d50da68e6059a4674795a1',
    messagingSenderId: '237365843444',
    projectId: 'hygiene-track',
    databaseURL: 'https://hygiene-track-default-rtdb.firebaseio.com',
    storageBucket: 'hygiene-track.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBFVbmrEHco68izWmGpPXQX8-22siCFpuE',
    appId: '1:237365843444:ios:3b74b1147d2a15624795a1',
    messagingSenderId: '237365843444',
    projectId: 'hygiene-track',
    databaseURL: 'https://hygiene-track-default-rtdb.firebaseio.com',
    storageBucket: 'hygiene-track.firebasestorage.app',
    iosBundleId: 'com.example.hygieneTrick',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBFVbmrEHco68izWmGpPXQX8-22siCFpuE',
    appId: '1:237365843444:ios:3b74b1147d2a15624795a1',
    messagingSenderId: '237365843444',
    projectId: 'hygiene-track',
    databaseURL: 'https://hygiene-track-default-rtdb.firebaseio.com',
    storageBucket: 'hygiene-track.firebasestorage.app',
    iosBundleId: 'com.example.hygieneTrick',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAQZMpHM9PjNHHYf76CHUU6uWV2Oe-GL9o',
    appId: '1:237365843444:web:fda99a4764dc07164795a1',
    messagingSenderId: '237365843444',
    projectId: 'hygiene-track',
    authDomain: 'hygiene-track.firebaseapp.com',
    databaseURL: 'https://hygiene-track-default-rtdb.firebaseio.com',
    storageBucket: 'hygiene-track.firebasestorage.app',
    measurementId: 'G-53PT6D5LHS',
  );

}