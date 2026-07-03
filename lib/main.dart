import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'features/auth/presentation/providers/profile_provider.dart';
import 'features/residents/presentation/providers/family_member_provider.dart';
import 'features/residents/presentation/providers/resident_provider.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'features/auth/presentation/providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);

  runApp(const SmartApartApp());
}

@pragma('vm:entry-point')
Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

class SmartApartApp extends StatelessWidget {
  const SmartApartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      // MultiProvider just lets us register several providers at once —
      // right now it's only AuthProvider, but ResidentProvider,
      // VisitorProvider etc. will be added here in later phases.
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => ResidentProvider()),
        ChangeNotifierProvider(create: (_) => FamilyMemberProvider()),
      ],
      child: MaterialApp.router(
        title: 'SmartApart',
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.system,
        routerConfig: appRouter,
      ),
    );
  }
}