// Generated from android/app/google-services.json (Firebase project: individual-assignment-2-cbcb6).
// For iOS/Web, run: dart run flutterfire configure (requires Firebase CLI installed).

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for this platform. '
          'Run "dart run flutterfire configure" to add your Firebase project.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBKrj7oOlKxAYAeW1HHhudKMpHdEaSBiZ0',
    appId: '1:605958938109:android:a9793480e37cac273d0d94',
    messagingSenderId: '605958938109',
    projectId: 'individual-assignment-2-cbcb6',
    storageBucket: 'individual-assignment-2-cbcb6.firebasestorage.app',
  );
}
