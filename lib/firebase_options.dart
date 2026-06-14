import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
    apiKey: 'AIzaSyBk_8Fjys4818cUjzlpGAYuixojJelbiLY',
    appId: '1:109288526882:web:e79659f81095f5634b267b',
    messagingSenderId: '109288526882',
    projectId: 'g8-eccomerce-app',
    authDomain: 'g8-eccomerce-app.firebaseapp.com',
    storageBucket: 'g8-eccomerce-app.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCtqh5H6wWwraOubEGqthKQEKM6AJP1GSs',
    appId: '1:109288526882:android:5b2ce237d7fc219c4b267b',
    messagingSenderId: '109288526882',
    projectId: 'g8-eccomerce-app',
    storageBucket: 'g8-eccomerce-app.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCNEWRCsPYD81a4NuTLUUTmhd9vYcj5v80',
    appId: '1:109288526882:ios:028d2f838fc3563f4b267b',
    messagingSenderId: '109288526882',
    projectId: 'g8-eccomerce-app',
    storageBucket: 'g8-eccomerce-app.firebasestorage.app',
    iosBundleId: 'com.example.smartStudentAttendanceSystem',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCNEWRCsPYD81a4NuTLUUTmhd9vYcj5v80',
    appId: '1:109288526882:ios:028d2f838fc3563f4b267b',
    messagingSenderId: '109288526882',
    projectId: 'g8-eccomerce-app',
    storageBucket: 'g8-eccomerce-app.firebasestorage.app',
    iosBundleId: 'com.example.smartStudentAttendanceSystem',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBk_8Fjys4818cUjzlpGAYuixojJelbiLY',
    appId: '1:109288526882:web:b27c6f1da4a3d7554b267b',
    messagingSenderId: '109288526882',
    projectId: 'g8-eccomerce-app',
    authDomain: 'g8-eccomerce-app.firebaseapp.com',
    storageBucket: 'g8-eccomerce-app.firebasestorage.app',
  );
}