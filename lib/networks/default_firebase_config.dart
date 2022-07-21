import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class DefaultFirebaseConfig {
  static FirebaseOptions get platformOptions {
    if (kIsWeb) {
      // Web
      return const FirebaseOptions(
        appId: '',
        apiKey: '',
        projectId: '',
        messagingSenderId: '',
      );
    } else if (Platform.isIOS || Platform.isMacOS) {
      // iOS and MacOS
      return const FirebaseOptions(
        appId: '',
        apiKey: '',
        projectId: '',
        messagingSenderId: '',
        iosBundleId: '',
      );
    } else {
      // Android
      return const FirebaseOptions(
        appId: '1:438524885554:android:4fcb3890f4ff19244f9a2b',
        apiKey: 'AIzaSyDrdD0fJnvDQjp02Ong4C2LxFlZV8mrCU4',
        projectId: 'bookingsystem-3be5c',
        messagingSenderId: '438524885554',
      );
    }
  }
}
