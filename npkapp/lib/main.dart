import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:npkapp/screens/home_screen.dart';
import 'package:npkapp/state/npk_state.dart';
import 'package:npkapp/utils/colors.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return 
       MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => NPKState()),
        ],
        child: MaterialApp(
          title: 'NPK Sensor Dashboard',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primaryColor: AppColors.primary,
            scaffoldBackgroundColor: AppColors.background,
            fontFamily: GoogleFonts.poppins().fontFamily,
            colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
            useMaterial3: true,
          ),
          home: const HomeScreen(),
        ),
      
    );
  }
}
