// ignore_for_file: avoid_print

import 'dart:async';

import 'package:ava_bishoy/shared/components/components.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import 'package:ava_bishoy/layout/cubit/cubit.dart';
import 'package:ava_bishoy/layout/cubit/states.dart';
import 'package:ava_bishoy/modules/splash/splash_screen.dart';
import 'package:ava_bishoy/shared/network/local/cashe_helper.dart';
import 'package:ava_bishoy/shared/network/remote/dio_helper.dart';
import 'package:ava_bishoy/shared/styles/themes.dart';
import 'bloc_observer/observer.dart';
import 'layout/cubit/cubit.dart';

Future<void> firebaseMassageBackground(RemoteMessage message) async {
  print(message.data.toString());
  showToast(
      message: 'onMassageFirebaseMassageBackground', state: ToastState.SUCCESS);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  Bloc.observer = SimpleBlocObserver();
  await SharedHelper.init();
  DioHelper.Init();
  if (SharedHelper.get(key: 'theme') == null) {
    SharedHelper.save(value: 'Light Theme', key: 'theme');
  }
  // var token =await FirebaseMessaging.instance.getToken();
  // print(token);
  // FirebaseMessaging.onMessage.listen((event) {
  //   print(event.data.toString());
  //   showToast(message: 'onMassage', state: ToastState.SUCCESS);
  // });
  // FirebaseMessaging.onMessageOpenedApp.listen((event) {
  //   print(event.data.toString());
  //   showToast(message: 'onMessageOpenedApp', state: ToastState.SUCCESS);
  // });
  // FirebaseMessaging.onBackgroundMessage(firebaseMassageBackground);

  runApp( MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isOffline=true;
@override
  void initState() {
    super.initState();
   Connectivity().onConnectivityChanged.listen((event) {
      if(event==ConnectivityResult.none){
        setState(() {
          isOffline=true;
        });
      }
      if(event==ConnectivityResult.mobile){
        setState(() {
          isOffline=false;
        });
      }
      if(event==ConnectivityResult.wifi){
        setState(() {
          isOffline=false;
        });
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChatHomeCubit(),
      child: BlocConsumer<ChatHomeCubit, ChatHomeStates>(
        listener: (context, state) {},
        builder: (context, state) {
          return Sizer(
            builder: (a, b, c) => MaterialApp(
              debugShowCheckedModeBanner: false,
              darkTheme: darkTheme(),
              theme: lightTheme(),
              themeMode: SharedHelper.get(key: 'theme') == 'Light Theme'
                  ? ThemeMode.light : ThemeMode.dark,
              home: Directionality(
                textDirection: TextDirection.ltr,
                child:!isOffline?startScreen(): Scaffold(
              backgroundColor:
              SharedHelper.get(key: 'theme') == 'Light Theme'
                  ? Colors.white
                  : Theme.of(context).scaffoldBackgroundColor,
              appBar: AppBar(
                title: const Text('No Internet'),
              ),
              body: const Center(
                child: CircularProgressIndicator(
                  valueColor:
                  AlwaysStoppedAnimation<Color>(Colors.pink),
                ),
              ),
            ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget startScreen() {
    bool? signIn = SharedHelper.get(key: 'signIn');
    if (signIn == true) {
      return SplashScreen('home');
    }
    return SplashScreen('logIn');
  }
}
