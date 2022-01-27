// ignore_for_file: avoid_print

import 'dart:io';

import 'package:ava/layout/cubit/cubit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ava/layout/home_screen.dart';
import 'package:ava/models/user_profile.dart';
import 'package:ava/modules/login/cubit/states.dart';
import 'package:ava/modules/login/login_screen.dart';
import 'package:ava/shared/components/components.dart';
import 'package:ava/shared/network/local/cashe_helper.dart';

class ChatLoginCubit extends Cubit<ChatLogInStates> {
  ChatLoginCubit() : super(LoginInitialStates());

  static ChatLoginCubit get(context) => BlocProvider.of(context);

  Icon suffixIcon = const Icon(
    Icons.visibility_outlined,
    color: Colors.pink,
  );
  bool obscure = true;

  void changeVisibilityOfEye() {
    obscure = !obscure;
    if (obscure) {
      suffixIcon = const Icon(
        Icons.remove_red_eye,
        color: Colors.pink,
      );
    } else {
      suffixIcon = const Icon(
        Icons.visibility_off_outlined,
        color: Colors.pink,
      );
    }
    emit(LoginChangEyeStates());
  }

  String logInMaterialButton = 'Login';
  String logInTextButton = 'Create New Account';

  void logInToggle() {
    if (logInMaterialButton == 'Login') {
      logInMaterialButton = 'Sign Up';
      logInTextButton = 'I Already Have An Account';
    } else {
      logInMaterialButton = 'Login';
      logInTextButton = 'Create New Account';
    }
    emit(LoginToggleStates());
  }

  void LogIn({
    required String email,
    required String password,
    required context,
  }) {
    emit(LoginLoadingStates());
    FirebaseAuth.instance
        .signInWithEmailAndPassword(
      email: email,
      password: password,
    )
        .then((value) {
      SharedHelper.save(value: value.user!.uid.toString(), key: 'uid');
      var x = value;
      searchAdmins(email: email, password: password);
      if (SharedHelper.get(key: 'isAdmin')) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
            'Logged Successfully',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.green),
          ),
          backgroundColor: Colors.white,
        ));
        navigateToWithoutReturn(context, HomeScreen());
        emit(LoginSuccessStates(value.user!.uid));
        // print(value.user!.email);
      } else {
        FirebaseFirestore.instance
            .collection('users')
            .doc(value.user!.uid.toString())
            .get()
            .then((value) {
          if (value.data()!['status']) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text(
                'Logged Successfully',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.green),
              ),
              backgroundColor: Colors.white,
            ));
            navigateToWithoutReturn(context, HomeScreen());
            emit(LoginSuccessStates(x.user!.uid));
            print(x.user!.email);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text(
                'تم ارسال طلبك الى الادمن انتظر لحين الرد عليك',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.green),
              ),
              backgroundColor: Colors.white,
            ));
            emit(LoginErrorStates(onError.toString()));
          }
        }).catchError((onError) {
          emit(LoginErrorStates(onError.toString()));
        });
      }
    }).catchError((onError) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          onError.toString(),
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.red),
        ),
        backgroundColor: Colors.white,
      ));
      emit(LoginErrorStates(onError.toString()));
    });
    ChatHomeCubit.get(context).users.clear();
    ChatHomeCubit.get(context).usersStatus.clear();
  }

  UserProfile? userProfile;

  void signUp({
    required String email,
    required String password,
    required String name,
    required String image,
    required String phone,
    required context,
  }) {
    showToast(
        message: 'Create Account Loading ....', state: ToastState.WARNING);
    emit(LoginLoadingStates());
    FirebaseAuth.instance
        .createUserWithEmailAndPassword(
      email: email,
      password: password,
    )
        .then((value) async {
//      await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
      var x = value;
      var token = await FirebaseMessaging.instance.getToken();
      print('ddddddddddddddddddddddddd$token');
      userProfile = UserProfile(
          email: email,
          name: name,
          password: password,
          image: image,
          phone: phone,
          token: token,
          status: false,
          uId: value.user!.uid.toString());
      storeDatabaseFirestore(value.user!.uid.toString()).then((value) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
            'تم ارسال طلبك الى الادمن انتظر لحين الرد عليك',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.green),
          ),
          backgroundColor: Colors.white,
        ));
        emit(LoginSuccessStates(x.user!.uid.toString()));
        navigateToWithReturn(context, LogInScreen());
      }).catchError((onError) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            onError.toString(),
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red),
          ),
          backgroundColor: Colors.white,
        ));
        emit(LoginErrorStates(onError.toString()));
      });
    }).catchError((onError) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          onError.toString(),
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.red),
        ),
        backgroundColor: Colors.white,
      ));
      emit(LoginErrorStates(onError.toString()));
    });
  }

  Future storeDatabaseFirestore(String id) async {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(id)
        .set(userProfile!.toMap());
  }

  void searchAdmins({
    required String email,
    required String password,
  }) {
    SharedHelper.save(value: false, key: 'isAdmin');
    FirebaseFirestore.instance.collection('admins').get().then((value) {
      value.docs.forEach((element) {
        if (element.data()['email'] == email &&
            element.data()['password'] == password) {
          SharedHelper.save(value: true, key: 'isAdmin');
        }
      });
    });
  }

  File? profileImage;
  void getProfileImage() async {
    emit(LoginGetImageLoadingStates());
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      profileImage = File(pickedFile.path);
      uploadProfileImage();
    } else {
      showToast(message: 'No Image Selected', state: ToastState.WARNING);
      //emit(LoginGetImageErrorStates());
    }
  }

  String? profileImageUrl;

  void uploadProfileImage() {
    FirebaseStorage.instance
        .ref()
        .child(
            'users/${Uri.file(profileImage!.path).pathSegments.length / DateTime.now().millisecond}')
        .putFile(profileImage!)
        .then((val) {
      val.ref.getDownloadURL().then((value) {
        profileImageUrl = value;
        emit(LoginGetImageSuccessStates());
      }).catchError((onError) {
        print(onError.toString());
        emit(LoginGetImageErrorStates());
      });
    }).catchError((onError) {
      print(onError.toString());
      emit(LoginGetImageErrorStates());
    });
  }
}
