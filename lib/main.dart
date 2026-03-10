import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gawein/blocs/auth/auth_bloc.dart';
import 'package:gawein/screens/splash_screen.dart'; // Kita mulai dari SplashScreen

Future<void> main() async {
  await Supabase.initialize(
    url: 'https://dvdeblchlvgvuzrhbego.supabase.co',
    anonKey: 'sb_publishable_9KJErR2X4YQVFBJkmcjuRw_EAzQsoGh',
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 2. Bungkus aplikasi dengan MultiBlocProvider agar BLoC Auth bisa dipakai di mana saja
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(supabase: Supabase.instance.client),
        ),
      ],
      child: MaterialApp(
        title: 'GaweIn',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
          scaffoldBackgroundColor: Colors.white,
        ),
        home: const SplashScreen(), // Pintu masuk pertama aplikasi
      ),
    );
  }
}