import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'controllers/movie_controller.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/favourites_provider.dart';
import 'providers/movie_details_provider.dart';
import 'providers/movie_provider.dart';
import 'services/tmdb_api_service.dart';
import 'utils/app_theme.dart';
import 'views/auth_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MovieVerseApp());
}



class MovieVerseApp extends StatelessWidget {
  const MovieVerseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        
        ChangeNotifierProvider(
          create: (_) => MovieProvider(MovieController(TmdbApiService())),
        ),
        
        ChangeNotifierProvider(
          create: (_) =>
              MovieDetailsProvider(MovieController(TmdbApiService())),
        ),
        
        ChangeNotifierProvider(create: (_) => FavouritesProvider()),
      ],
      child: MaterialApp(
        title: 'MovieVerse',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        
        home: const AuthGate(),
      ),
    );
  }
}
