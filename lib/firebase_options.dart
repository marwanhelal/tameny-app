

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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDrhljjzcNEpvCRse2_T4inpVvG4wRZ0TQ',
    appId: '1:887788328036:android:2bb96df55ff48a1e70fb71',
    messagingSenderId: '887788328036',
    projectId: 'tameny-f78c5',
    storageBucket: 'tameny-f78c5.firebasestorage.app',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAWleETBreJJ8MT1e32xl-F5Y-q6zcY5IY',
    appId: '1:887788328036:web:35a178a39771a6ea70fb71',
    messagingSenderId: '887788328036',
    projectId: 'tameny-f78c5',
    authDomain: 'tameny-f78c5.firebaseapp.com',
    storageBucket: 'tameny-f78c5.firebasestorage.app',
    measurementId: 'G-5M8FN6DEBQ',
  );

}

