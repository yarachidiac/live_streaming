import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:project_live_streaming/providers/user_provider.dart';
import 'package:project_live_streaming/resources/auth_methods.dart';
import 'package:project_live_streaming/screens/home_screen.dart';
import 'package:project_live_streaming/screens/login_screen.dart';
import 'package:project_live_streaming/screens/onboarding_screen.dart';
import 'package:project_live_streaming/screens/signup_screen.dart';
import 'package:project_live_streaming/utils/colors.dart';
import 'package:project_live_streaming/widgets/loading_indicator.dart';
import 'package:provider/provider.dart';
import 'package:project_live_streaming/models/user.dart' as model;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (_)=> UserProvider(),
    ),
  ], child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData.light().copyWith(
        scaffoldBackgroundColor: backgroundColor,
        appBarTheme: AppBarTheme.of(context).copyWith(
            backgroundColor: backgroundColor,
            elevation: 0,
            titleTextStyle: const TextStyle(
              color: primaryColor,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ) ,
            iconTheme: const IconThemeData(
              color: primaryColor,
            )
        ),
      ),
      routes: {
        OnboardingScreen.routeName: (context) => const OnboardingScreen(),
        LoginScreen.routeName: (context) => const LoginScreen(),
        SignupScreen.routeName: (context) => const SignupScreen(),
        HomeScreen.routeName: (context) => const HomeScreen(),
      },
      home: FutureBuilder(
          future: AuthMethods().getCurrentUser(FirebaseAuth.instance.currentUser != null ? FirebaseAuth.instance.currentUser!.uid : null).then((value) {
            if(value != null){
              Provider.of<UserProvider>(context, listen: false).setUser(
                  model.User.fromMap(value)
              );
            }
            return value;
          }),
          
          builder: (context, snapshot){
            if(snapshot.connectionState == ConnectionState.waiting){
              return const LoadingIndicator();
            }
            if(snapshot.hasData){
              return const HomeScreen();
            }
            return const OnboardingScreen();
          }
      ),
    );
  }
}



