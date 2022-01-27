// ignore_for_file: avoid_print

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import 'package:ava/layout/cubit/cubit.dart';
import 'package:ava/layout/cubit/states.dart';
import 'package:ava/modules/splash/splash_screen.dart';
import 'package:ava/shared/components/components.dart';
import 'package:ava/shared/network/local/cashe_helper.dart';
import 'package:ava/shared/network/remote/dio_helper.dart';
import 'package:ava/shared/styles/themes.dart';

import 'bloc_observer/observer.dart';
import 'layout/cubit/cubit.dart';
Future<void> firebaseMassageBackground(RemoteMessage message)async{
  print(message.data.toString());
  showToast(message: 'onMassageFirebaseMassageBackground', state: ToastState.SUCCESS);
}
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  Bloc.observer = SimpleBlocObserver();
  await SharedHelper.init();
  DioHelper.Init();
  if(SharedHelper.get(key: 'theme')==null){
    SharedHelper.save(value: 'Light Theme', key:'theme' );
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

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (context)=>ChatHomeCubit(),
      child: BlocConsumer<ChatHomeCubit,ChatHomeStates>(
        listener: (context,state){},
        builder: (context,state){
          return Sizer(
            builder: (a, b, c) => MaterialApp(
              debugShowCheckedModeBanner: false,
              darkTheme: darkTheme(),
              theme: lightTheme(),
              themeMode:SharedHelper.get(key: 'theme')=='Light Theme'?ThemeMode.light:ThemeMode.dark,
              home: Directionality(
                  textDirection: TextDirection.ltr,
                  child:startScreen()// startScreen(),
              ),
            ),
          );
        },
      ),
    );
  }
  Widget startScreen() {
    bool? signIn=SharedHelper.get(key: 'signIn');
    if(signIn==true)
    {
      return SplashScreen('home');
    }
    return SplashScreen('logIn');
  }
}
