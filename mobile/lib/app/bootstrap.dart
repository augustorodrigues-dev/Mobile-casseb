import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

import '../repositories/estandes_repository.dart';
import '../services/analytics_service.dart';
import '../services/checkin_service.dart';
import '../services/remote_config_service.dart';
import 'discovery_controller.dart';

const useEmulators = bool.fromEnvironment('USE_FIREBASE_EMULATORS');
const _localAppName = 'circuito-local';
bool _emulatorsConnected = false;
Future<DiscoveryController> bootstrap() async {
  final FirebaseApp app;
  if (useEmulators) {
    // App secundário evita conflito com um google-services.json real já presente.
    app = Firebase.apps.any((item) => item.name == _localAppName)
        ? Firebase.app(_localAppName)
        : await Firebase.initializeApp(
            name: _localAppName,
            options: const FirebaseOptions(
              apiKey: 'demo-key',
              appId: '1:123456789:android:1234567890abcdef',
              messagingSenderId: '123456789',
              projectId: 'demo-circuito',
            ),
          );
    if (Firebase.apps.any((item) => item.name == '[DEFAULT]')) {
      await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(false);
    }
  } else {
    // Configuração nativa gerada a partir do google-services.json real.
    app = Firebase.apps.any((item) => item.name == '[DEFAULT]')
        ? Firebase.app()
        : await Firebase.initializeApp();
  }
  final auth = FirebaseAuth.instanceFor(app: app);
  final db = FirebaseFirestore.instanceFor(app: app);
  if (useEmulators && !_emulatorsConnected) {
    const host = String.fromEnvironment(
      'FIREBASE_EMULATOR_HOST',
      defaultValue: '10.0.2.2',
    );
    await auth.useAuthEmulator(host, 9099);
    db.useFirestoreEmulator(host, 8080);
    _emulatorsConnected = true;
  }
  final firebaseAnalytics = useEmulators ? null : FirebaseAnalytics.instance;
  await firebaseAnalytics?.setAnalyticsCollectionEnabled(true);
  final user = auth.currentUser ?? (await auth.signInAnonymously()).user;
  if (user == null) {
    throw StateError('Não foi possível identificar o visitante.');
  }
  final events = AnalyticsService(firebaseAnalytics);
  final repository = EstandesRepository(db);
  final controller = DiscoveryController(
    uid: user.uid,
    repository: repository,
    checkins: CheckinService(repository, events),
    analytics: events,
    remote: RemoteConfigService(
      useEmulators ? null : FirebaseRemoteConfig.instance,
    ),
  );
  controller.start();
  return controller;
}
