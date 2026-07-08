import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'features/admin/presentation/providers/admin_dashboard_provider.dart';
import 'features/amenities/presentation/providers/amenity_provider.dart';
import 'features/announcements/presentation/providers/announcement_provider.dart';
import 'features/auth/presentation/providers/profile_provider.dart';
import 'features/complaints/presentation/providers/complaint_provider.dart';
import 'features/maintenance/presentation/providers/maintenance_provider.dart';
import 'features/residents/presentation/providers/family_member_provider.dart';
import 'features/residents/presentation/providers/resident_detail_provider.dart';
import 'features/residents/presentation/providers/resident_directory_provider.dart';
import 'features/residents/presentation/providers/resident_provider.dart';
import 'features/visitors/presentation/providers/visitor_provider.dart';
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
        ChangeNotifierProvider(create: (_) => ResidentDirectoryProvider()),
        ChangeNotifierProvider(create: (_) => ResidentDetailProvider()),
        ChangeNotifierProvider(create: (_) => VisitorProvider()),
        ChangeNotifierProvider(create: (_) => MaintenanceProvider()),
        ChangeNotifierProvider(create: (_) => ComplaintProvider()),
        ChangeNotifierProvider(create: (_) => AnnouncementProvider()),
        ChangeNotifierProvider(create: (_) => AmenityProvider()),
        ChangeNotifierProvider(create: (_) => AdminDashboardProvider()),
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