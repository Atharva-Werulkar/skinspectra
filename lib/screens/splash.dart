// import 'package:flutter/material.dart';
//
// class SplashScreen extends StatefulWidget {
//   @override
//   _SplashScreenState createState() => _SplashScreenState();
// }
//
// class _SplashScreenState extends State<SplashScreen> {
//   @override
//   void initState() {
//     super.initState();
//     _navigateToHome();
//   }
//
//   _navigateToHome() async {
//     await Future.delayed(Duration(seconds: 3), () {});
//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(builder: (context) => MyApp()),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Image.asset('assets/images/logo.png'),
//             const SizedBox(height: 20),
//             const CircularProgressIndicator(),
//           ],
//         ),
//       ),
//     );
//   }
// }
