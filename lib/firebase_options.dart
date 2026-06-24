// Generated from android/app/google-services.json for project local-transport-482015.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not configured for this platform.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAogYxUvVE2X07N44fPXnvVCiN8zLxTpEE',
    appId: '1:451122835320:android:ebbb15573a453adc2ba28d',
    messagingSenderId: '451122835320',
    projectId: 'local-transport-482015',
    databaseURL:
        'https://local-transport-482015-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'local-transport-482015.firebasestorage.app',
  );
}
