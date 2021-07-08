import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:green_taxi/ui/pages/add_credit_card_page.dart';
import 'package:green_taxi/ui/pages/book_taxi_page.dart';
import 'package:green_taxi/ui/pages/credit_card_page.dart';
import 'package:green_taxi/ui/pages/login.dart';
import 'package:green_taxi/ui/pages/qr_scanner_page.dart';

import 'package:green_taxi/ui/pages/rate_driver_page.dart';
import 'package:green_taxi/ui/pages/ride_details_page.dart';
import 'package:green_taxi/ui/pages/ride_history_page.dart';
import 'package:green_taxi/ui/pages/signup.dart';
import 'package:green_taxi/ui/pages/taxi_movement_page.dart';
import 'package:green_taxi/ui/pages/settings_page.dart';
import 'package:green_taxi/ui/pages/support_page.dart';
import 'package:green_taxi/ui/pages/promo_code_page.dart';

import 'package:green_taxi/ui/pages/otp_page.dart';
import 'package:green_taxi/ui/pages/phone_reg_page.dart';
import 'package:green_taxi/utils/custom_route.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final FirebaseApp app = await Firebase.initializeApp(
    name: 'db2',
    options: Platform.isIOS || Platform.isMacOS
        ? const FirebaseOptions(
      appId: '1:297855924061:ios:c6de2b69b03a5be8',
      apiKey: '',
      projectId: 'flutter-firebase-plugins',
      messagingSenderId: '297855924061',
      databaseURL: 'https://flutterfire-cd2f7.firebaseio.com',
    )
        : const FirebaseOptions(
      appId: '1:91329367115:android:5dcbb224aec4ca634811ce',
      apiKey: 'AIzaSyDZq4vFavEDszbscJhIF3h-LodKgvu1nW4',
      messagingSenderId: '91329367115',
      projectId: 'bikeservice-fa915',
      databaseURL: 'https://bikeservice-fa915-default-rtdb.firebaseio.com',
    ),
  );
  runApp(MyApp());

}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Electric Bike',
      theme: ThemeData(
          // is not restarted.
          primarySwatch: Colors.green,
          pageTransitionsTheme: PageTransitionsTheme(builders: {
            TargetPlatform.iOS: CustomPageTransitionBuilder(),
            TargetPlatform.android: CustomPageTransitionBuilder(),
          })),
      home: Login(),
      routes: {
        PhoneRegPage.routeName: (context) => PhoneRegPage(),
        OtpPage.routeName: (context) => OtpPage(),
        BookTaxiPage.routeName: (context) => BookTaxiPage(),
        TaxiMovementPage.routeName: (context) => TaxiMovementPage(),
        RideHistoryPage.routeName: (context) => RideHistoryPage(),
        SettingsPage.routeName: (context) => SettingsPage(),
        SupportPage.routeName: (context) => SupportPage(),
        PromoCodePage.routeName: (context) => PromoCodePage(),
        CreditCardPage.routeName: (context) => CreditCardPage(),
        AddCreditCardPage.routeName: (context) => AddCreditCardPage(),
        RateDriverPage.routeName: (context) => RateDriverPage(),
        RideDetailsPage.routeName: (context) => RideDetailsPage(),
        QRViewExample.routeName:(context)=>QRViewExample(),
        Signup.routeName:(context)=>Signup(),
        Login.routeName:(context)=>Login(),

      },
    );
  }
}
