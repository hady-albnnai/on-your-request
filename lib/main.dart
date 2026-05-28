import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/posts/providers/posts_provider.dart';
import 'features/add_post/providers/add_post_provider.dart';
import 'features/my_account/providers/my_account_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // قفل الاتجاه: عمودي فقط
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // تهيئة Firebase
  await Firebase.initializeApp();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => PostsProvider()),
        ChangeNotifierProvider(create: (_) => AddPostProvider()),
        ChangeNotifierProvider(create: (_) => MyAccountProvider()),
      ],
      child: const BkhedmtakApp(),
    ),
  );
}
