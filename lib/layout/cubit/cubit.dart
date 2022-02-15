// ignore_for_file: avoid_function_literals_in_foreach_calls, non_constant_identifier_names

import 'dart:io';
import 'package:ava_bishoy/models/image_model%20.dart';
import 'package:ava_bishoy/models/image_model_user.dart';
import 'package:ava_bishoy/models/video_model%20.dart';
import 'package:ava_bishoy/models/video_model_user.dart';
import 'package:ava_bishoy/modules/images/image_screen.dart';
import 'package:ava_bishoy/modules/videos/video_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ava_bishoy/layout/cubit/states.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:ava_bishoy/models/file_model.dart';
import 'package:ava_bishoy/models/model_group_massage.dart';
import 'package:ava_bishoy/models/file_model_user.dart';
import 'package:ava_bishoy/models/massage_model.dart';
import 'package:ava_bishoy/models/user_profile.dart';
import 'package:ava_bishoy/modules/lecture/lecture_screen.dart';
import 'package:ava_bishoy/modules/setting/setting_screen.dart';
import 'package:ava_bishoy/modules/users/user_screen.dart';
import 'package:ava_bishoy/shared/components/components.dart';
import 'package:ava_bishoy/shared/network/local/cashe_helper.dart';
import 'package:ava_bishoy/shared/network/remote/dio_helper.dart';
import 'package:ava_bishoy/shared/styles/Icon_broken.dart';
import 'package:intl/intl.dart';

// ignore_for_file: avoid_print
class ChatHomeCubit extends Cubit<ChatHomeStates> {
  ChatHomeCubit() : super(ChatHomeInitialStates());

  static ChatHomeCubit get(context) => BlocProvider.of(context);
  var nameController = TextEditingController();
  var phoneController = TextEditingController();
  var bioController = TextEditingController();
  bool? disAppear;
  void disAppearPhnone(bool val) {
    disAppear = val;
    emit(PhoneState());
  }

  int currentIndex = 0;

  List<Widget> listLecturesScreen = [
    UsersScreen(),
    LectureScreen(),
    SettingsScreen(),
  ];

  List<BottomNavigationBarItem> bottomNavLecturesList = const [
    BottomNavigationBarItem(icon: Icon(IconBroken.User), label: 'Users'),
    BottomNavigationBarItem(
        icon: Icon(Icons.set_meal_rounded), label: 'Lectures'),
    BottomNavigationBarItem(icon: Icon(IconBroken.Setting), label: 'Settings'),
  ];
  dynamic listBody = [
    UsersScreen(),
    LectureScreen(),
    SettingsScreen(),
  ];
  dynamic listNav = const [
    BottomNavigationBarItem(icon: Icon(IconBroken.User), label: 'Users'),
    BottomNavigationBarItem(
        icon: Icon(Icons.set_meal_rounded), label: 'Lectures'),
    BottomNavigationBarItem(icon: Icon(IconBroken.Setting), label: 'Settings'),
  ];

  List<Widget> listImagesScreen = [
    UsersScreen(),
    ImageScreen(),
    SettingsScreen(),
  ];

  List<BottomNavigationBarItem> bottomNavImagesList = const [
    BottomNavigationBarItem(icon: Icon(IconBroken.User), label: 'Users'),
    BottomNavigationBarItem(icon: Icon(IconBroken.Image), label: 'Images'),
    BottomNavigationBarItem(icon: Icon(IconBroken.Setting), label: 'Settings'),
  ];
  List<Widget> listVideosScreen = [
    UsersScreen(),
    VideosScreen(),
    SettingsScreen(),
  ];

  List<BottomNavigationBarItem> bottomNavVideosList = const [
    BottomNavigationBarItem(icon: Icon(IconBroken.User), label: 'Users'),
    BottomNavigationBarItem(icon: Icon(IconBroken.Video), label: 'Videos'),
    BottomNavigationBarItem(icon: Icon(IconBroken.Setting), label: 'Settings'),
  ];

  void changeNav(idx) {
    currentIndex = idx;
    emit(ChatHomeChangeBottomNavStates());
  }

  UserProfile? userProfile;

  void getUserProfile() {
    emit(ChatHomeGetUserProfileLoadingStates());
    FirebaseFirestore.instance
        .collection('users')
        .doc(SharedHelper.get(key: 'uid'))
        .snapshots()
        .listen((event) {
      userProfile = UserProfile.fromJson(event.data());
      emit(ChatHomeGetUserProfileSuccessStates());
    }).onError((handleError) {
      emit(ChatHomeGetUserProfileErrorStates());
    });
  }

  File? profileImage;

  void getProfileImage() async {
    emit(ChatUpdateProfileDataWaitingImageToFinishUploadStates());
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      profileImage = File(pickedFile.path);
      uploadProfileImage();
      //   emit(SocialGetProfileImageSuccessStates());
    } else {
      showToast(message: 'No Image Selected', state: ToastState.WARNING);
      print('eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee$onError');
      emit(ChatUpdateProfileDataWaitingImageToFinishUploadErrorStates());
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
        emit(ChatUpdateProfileDataWaitingImageToFinishSuccessStates());
      }).catchError((onError) {
        print('eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee$onError');
        emit(ChatUpdateProfileDataWaitingImageToFinishErrorStates());
      });
    }).catchError((onError) {
      print('eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee$onError');
      emit(ChatUpdateProfileDataWaitingImageToFinishErrorStates());
    });
  }

  //get online w offline
  ///////////////////////////////////////////////////
  //get all users
  Set<UserProfile> users = {};
  Map<String, String> usersStatus = {};

  void getAllUsers() async {
    emit(ChatGetAllUsersLoadingStates());
    FirebaseFirestore.instance
        .collection('users')
        .orderBy('name')
        .snapshots()
        .listen((event) async {
      users.clear();
      usersStatus.clear();
      for (var element in event.docs) {
        if (element.data()['uId'] != SharedHelper.get(key: 'uid') &&
            element.data()['status'] &&
            !element.data()['block_final']) {
          DocumentSnapshot<Map<String, dynamic>> Status =
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(element.data()['uId'])
                  .collection('userStatus')
                  .doc('status')
                  .get();
            users.add(UserProfile.fromJson(element.data()));
            usersStatus[element.data()['uId']] = Status['userStatus'];
        }
      }
      emit(ChatGetAllUsersSuccessStates());
    }).onError((handleError) {
      emit(ChatGetAllUsersErrorStates());
    }); //uid
  }

  //get user status
  void getUserStatus() async {
    await FirebaseFirestore.instance
        .collection('users')
        .orderBy('name')
        .get()
        .then((event) {
      usersStatus.clear();
      event.docs.forEach((element) async {
        FirebaseFirestore.instance
            .collection('users')
            .doc(element.id)
            .collection('userStatus')
            .doc('status')
            .snapshots()
            .listen((event) {
          if (element.data()['uId'] != SharedHelper.get(key: 'uid') &&
              element.data()['status'] &&
              !element.data()['block_final']) {
            usersStatus[element.data()['uId']] = event['userStatus'];
            emit(SocialGetUserStatusSuccessStates());
          }
        });
      });
      emit(SocialGetUserStatusSuccessStates());
    }).catchError((onError) {
      emit(SocialGetUserStatusErrorStates());
    });
  }

  ///////////////////////////////////////////////////
  void editProfile({
    required String name,
    required String phone,
    required String bio,
    required bool disAppear,
    required context,
  }) async {
    var token = await FirebaseMessaging.instance.getToken();
    UserProfile profile = UserProfile(
        email: userProfile!.email,
        name: name,
        password: userProfile!.password,
        image: profileImageUrl ?? userProfile!.image,
        phone: phone,
        uId: SharedHelper.get(key: 'uid'),
        status: true,
        token: token,
        bio: bio,
        block: userProfile!.block,
        block_final: userProfile!.block_final,
        disappear: disAppear);
    FirebaseFirestore.instance
        .collection('users')
        .doc(SharedHelper.get(key: 'uid'))
        .set(profile.toMap())
        .then((value) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          'Edited Successfully...',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.green),
        ),
        backgroundColor: Colors.pink,
      ));
      print(profile.uId);
      emit(ChatEditProfileSuccessStates());
    }).catchError((onError) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          onError.toString(),
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.red),
        ),
        backgroundColor: Colors.pink,
      ));
      emit(ChatEditProfileErrorStates());
    });
  }

  //add massages
  void addMassage(
      {required String receiverId,
      required String? text,
      required String dateTime,
      required String createdAt,
      String? chatImage}) {
    MassageModel model = MassageModel(
        senderId: userProfile!.uId,
        receiverId: receiverId,
        text: text,
        dateTime: dateTime,
        createdAt: createdAt,
        image: chatImage);
    FirebaseFirestore.instance
        .collection('users')
        .doc(userProfile!.uId)
        .collection('chats')
        .doc(receiverId)
        .collection('massages')
        .add(model.toMap())
        .then((value) {
      emit(SocialAddMassageSuccessStates());
    }).catchError((onError) {
      emit(SocialAddMassageErrorStates());
    });
    FirebaseFirestore.instance
        .collection('users')
        .doc(receiverId)
        .collection('chats')
        .doc(userProfile!.uId)
        .collection('massages')
        .add(model.toMap())
        .then((value) {
      emit(SocialAddMassageSuccessStates());
    }).catchError((onError) {
      emit(SocialAddMassageErrorStates());
    });
  }

  List<MassageModel> massages = [];
  List<String> massagesId = [];

  //get massages
  void getMassage({
    required String receiverId,
  }) {
    FirebaseFirestore.instance
        .collection('users')
        .doc(userProfile!.uId)
        .collection('chats')
        .doc(receiverId)
        .collection('massages')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((event) {
      massages = [];
      massagesId = [];
      event.docs.forEach((element) {
        massages.add(MassageModel.fromJson(element.data()));
        massagesId.add(element.id);
      });
      emit(ChatGetMassageSuccessStates());
    }).onError((error) {
      emit(ChatGetMassageErrorStates());
    });
  }

  void getChatImage({
    required String receiverId,
    required String? text,
    required String dateTime,
    required String createdAt,
  }) async {
    emit(ChatUploadImageLoadingSuccessStates());
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      uploadChatImage(
        chatImage: File(pickedFile.path),
        text: text,
        dateTime: dateTime,
        createdAt: createdAt,
        receiverId: receiverId,
      );
    } else {
      showToast(message: 'No Chat Image Selected', state: ToastState.WARNING);
      emit(ChatUploadImageLoadingErrorStates());
    }
  }

  void uploadChatImage({
    required File chatImage,
    required String receiverId,
    required String? text,
    required String dateTime,
    required String createdAt,
  }) {
    FirebaseStorage.instance
        .ref()
        .child(
            'chats/${Uri.file(chatImage.path).pathSegments.length / DateTime.now().millisecondsSinceEpoch}')
        .putFile(chatImage)
        .then((val) {
      val.ref.getDownloadURL().then((value) {
        addMassage(
            receiverId: receiverId,
            text: text,
            dateTime: dateTime,
            createdAt: createdAt,
            chatImage: value.toString());
      }).catchError((onError) {
        emit(ChatUploadImageLoadingErrorStates());
      });
    }).catchError((onError) {
      emit(ChatUploadImageLoadingErrorStates());
    });
  }

  //delete massage from me
  void deleteMassageFromMe({
    required String receiverId,
    required String massageId,
  }) {
    FirebaseFirestore.instance
        .collection('users')
        .doc(userProfile!.uId)
        .collection('chats')
        .doc(receiverId)
        .collection('massages')
        .doc(massageId)
        .delete()
        .then((value) {
      emit(SocialDeleteMassageSuccessStates());
    }).catchError((onError) {
      emit(SocialDeleteMassageErrorStates());
    });
  }

//delete massage from all
  void deleteMassageFromAll({
    required String receiverId,
    required String massageId,
  }) {
    FirebaseFirestore.instance
        .collection('users')
        .doc(userProfile!.uId)
        .collection('chats')
        .doc(receiverId)
        .collection('massages')
        .doc(massageId)
        .delete()
        .then((value) {
      emit(SocialDeleteMassageSuccessStates());
    }).catchError((onError) {
      emit(SocialDeleteMassageErrorStates());
    });
    FirebaseFirestore.instance
        .collection('users')
        .doc(receiverId)
        .collection('chats')
        .doc(userProfile!.uId)
        .collection('massages')
        .doc(massageId)
        .delete()
        .then((value) {
      emit(SocialDeleteMassageSuccessStates());
    }).catchError((onError) {
      emit(SocialDeleteMassageErrorStates());
    });
  }

  void modeChange() {
    if (SharedHelper.get(key: 'theme') == 'Light Theme') {
      SharedHelper.save(value: 'Dark Theme', key: 'theme');
    } else {
      SharedHelper.save(value: 'Light Theme', key: 'theme');
    }
    emit(SocialSChangeModeStates());
  }

  void changeSettings(context) {
    Navigator.pop(context);
    changeNav(2);
  }

  ///////////////////lectures
  void getPDF({required String name, required context}) async {
    emit(GetFileLoadingStates());
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
    if (result != null) {
      File pick = File(result.files.single.path.toString());
      var file = pick.readAsBytesSync();
      FirebaseStorage.instance
          .ref()
          .child('lectures/${DateTime.now().millisecondsSinceEpoch}')
          .child('/.pdf')
          .putData(file)
          .then((val) {
        val.ref.getDownloadURL().then((value) {
          storeInFirestore(
              link: value.toString(), pdfName: name, context: context);
        }).catchError((onError) {
          showToast(message: onError.toString(), state: ToastState.WARNING);
          emit(GetFileErrorStates());
        });
      }).catchError((onError) {
        showToast(message: onError.toString(), state: ToastState.WARNING);
        emit(GetFileErrorStates());
      });
    } else {
      showToast(message: 'No File Selected', state: ToastState.WARNING);
      emit(GetFileSuccessStates());
    }
  }

  void storeInFirestore({
    required String link,
    required String pdfName,
    required context,
  }) {
    FileModel model = FileModel(name: pdfName, link: link);
    FirebaseFirestore.instance
        .collection('lectures')
        .add(model.toMap())
        .then((value) {
      showToast(
          message: 'File Uploaded Successfully', state: ToastState.SUCCESS);
      emit(GetFileSuccessStates());
    }).catchError((onError) {
      showToast(message: onError.toString(), state: ToastState.WARNING);
      emit(GetFileErrorStates());
    });
  }

  List<FileModel> lectures = [];
  void getLectures() {
    emit(ViewFileLoadingStates());
    FirebaseFirestore.instance
        .collection('lectures')
        .snapshots()
        .listen((event) {
      lectures = [];
      event.docs.forEach((element) {
        lectures.add(FileModel.fromJson(element.data()));
      });
      emit(ViewFileSuccessStates());
    }).onError((handleError) {
      emit(ViewFileErrorStates());
    });
  }

  ///////////////////lectures using user
  void getPDFUsingUser({
    required String name,
    required String username,
    required String date,
    required context,
  }) async {
    emit(GetFileLoadingStates());
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
    if (result != null) {
      File pick = File(result.files.single.path.toString());
      var file = pick.readAsBytesSync();
      FirebaseStorage.instance
          .ref()
          .child('lectures/${DateTime.now().millisecondsSinceEpoch}')
          .child('/.pdf')
          .putData(file)
          .then((val) {
        val.ref.getDownloadURL().then((value) {
          storeInFirestoreUsingUser(
              link: value.toString(),
              pdfName: name,
              username: username,
              date: date,
              context: context);
        }).catchError((onError) {
          print('jjjjjjjjjjjjjjjjjjjjjjjjj${onError.toString()}');
          showToast(message: onError.toString(), state: ToastState.ERROR);
          emit(GetFileErrorStates());
        });
      }).catchError((onError) {
        print('xxxxxxxxxxxxxxxxxxxxxxxxxx${onError.toString()}');
        showToast(message: onError.toString(), state: ToastState.WARNING);
        emit(GetFileErrorStates());
      });
    } else {
      showToast(message: 'No File Selected', state: ToastState.WARNING);
      print('ccccccccccccccccccccccc${onError.toString()}');
      emit(GetFileErrorStates());
    }
  }

  void storeInFirestoreUsingUser({
    required String pdfName,
    required String link,
    required String username,
    required String date,
    required context,
  }) {
    FileModelUser model = FileModelUser(
        name: pdfName, link: link, date: date, username: username);
    FirebaseFirestore.instance
        .collection('lecturesUsingUser')
        .add(model.toMap())
        .then((value) {
      //  Navigator.pop(context);
      showToast(
          message: 'File Uploaded Successfully', state: ToastState.SUCCESS);
      emit(GetFileSuccessStates());
    }).catchError((onError) {
      print('pppppppppppppppppppppppp${onError.toString()}');
      showToast(message: onError.toString(), state: ToastState.WARNING);
      emit(GetFileErrorStates());
    });
  }

  List<FileModelUser> lecturesUsingUser = [];
  List<String> lecturesUsingUserId = [];
  void getLecturesUsingUser() {
    emit(ViewFileLoadingStates());
    FirebaseFirestore.instance
        .collection('lecturesUsingUser')
        .snapshots()
        .listen((event) {
      lecturesUsingUser = [];
      lecturesUsingUserId = [];
      event.docs.forEach((element) {
        lecturesUsingUser.add(FileModelUser.fromJson(element.data()));
        lecturesUsingUserId.add(element.id);
      });
      emit(ViewFileSuccessStates());
    }).onError((handleError) {
      print('xxxxxxxxxxxxxxxxxxxxrrrrrrrrrrrr${onError.toString()}');
      emit(ViewFileErrorStates());
    });
  }

  //accept lecture from admin
  void accept({required String pdfId}) {
    {
      emit(AcceptFileLoadingStates());
      FirebaseFirestore.instance
          .collection('lecturesUsingUser')
          .doc(pdfId)
          .get()
          .then((value) {
        FileModel model =
            FileModel(name: value.data()!['name'], link: value.data()!['link']);
        FirebaseFirestore.instance
            .collection('lectures')
            .add(model.toMap())
            .then((value) async {
          await FirebaseFirestore.instance
              .collection('lecturesUsingUser')
              .doc(pdfId)
              .delete();
          emit(AcceptFileSuccessStates());
        }).catchError((onError) {
          emit(AcceptFileErrorStates());
        });
      }).catchError((onError) {
        emit(AcceptFileErrorStates());
      });
    }
  }

  //reject lecture from admin
  void reject({required String pdfId}) {
    emit(RejectFileLoadingStates());
    FirebaseFirestore.instance
        .collection('lecturesUsingUser')
        .doc(pdfId)
        .delete()
        .then((value) {
      emit(RejectFileSuccessStates());
    }).catchError((onError) {
      emit(RejectFileErrorStates());
    });
  }

  List<FileModel> searchLecture = [];
  //search lecture
  void searchLectures(String name) {
    emit(ViewFileLoadingStates());
    FirebaseFirestore.instance.collection('lectures').get().then((value) {
      searchLecture = [];
      value.docs.forEach((element) {
        if (element
            .data()['name']
            .toString()
            .toUpperCase()
            .contains(name.toUpperCase())) {
          searchLecture.add(FileModel.fromJson(element.data()));
        }
      });
      emit(ViewFileSuccessStates());
    }).catchError((onError) {
      emit(ViewFileErrorStates());
    });
  }

  List<UserProfile> usersWaiting = [];
  void getUserWaiting() {
    emit(GetUserWaitingLoadingStates());
    FirebaseFirestore.instance
        .collection('users')
        .orderBy('name')
        .snapshots()
        .listen((event) {
      usersWaiting = [];
      event.docs.forEach((element) {
        if (!element.data()['status']) {
          usersWaiting.add(UserProfile.fromJson(element.data()));
        }
      });
      emit(GetUserWaitingSuccessStates());
    }).onError((handleError) {
      emit(GetUserWaitingErrorStates());
    });
  }

  void acceptAccount(UserProfile profile) async {
    emit(GetUserAcceptWaitingLoadingStates());
    await FirebaseFirestore.instance
        .collection('users')
        .doc(profile.uId)
        .collection('userStatus')
        .doc('status')
        .set({
      'userStatus': DateFormat('dd,MM yyyy hh:mm a').format(DateTime.now())
    });
    UserProfile user = UserProfile(
        uId: profile.uId,
        status: true,
        token: profile.token,
        email: profile.email,
        name: profile.name,
        password: profile.password,
        image: profile.image,
        phone: profile.phone,
        bio: profile.bio,
        block: profile.block,
        block_final: profile.block_final,
        disappear: profile.disappear);
    FirebaseFirestore.instance
        .collection('users')
        .doc(profile.uId)
        .set(user.toMap())
        .then((value) {
      DioHelper.postData(
              token: profile.token,
              massage:
                  "لقد تم انشاء حسابك بنجاح تستطيع ان تجعل تسجيل الدخول الان")
          .then((value) {
        showToast(message: 'Accepted Successfully', state: ToastState.SUCCESS);
        emit(GetUserAcceptWaitingSuccessStates());
      }).catchError((onError) {
        emit(GetUserAcceptWaitingErrorStates());
      });
    }).catchError((onError) {
      emit(GetUserAcceptWaitingErrorStates());
    });
  }

  void rejectAccount(UserProfile profile, context) {
    emit(GetUserRejectWaitingLoadingStates());
    showDialog(
        barrierDismissible: false, //prevent close
        context: context,
        builder: (context) => AlertDialog(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              title: const Text(
                'Confirm....',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Are you Sure that delete this account Finally',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.normal,
                      fontSize: 15,
                    ),
                  ),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        MaterialButton(
                          onPressed: () {
                            FirebaseFirestore.instance
                                .collection('users')
                                .doc(profile.uId)
                                .delete()
                                .then((value) {
                              usersStatus.remove(profile.uId);
                              Navigator.pop(context);
                              DioHelper.postData(token: profile.token,
                                      massage: "عذرا لقد تم رفض حسابك تستطيع ان تجعل حساب اخر ")
                                  .then((value) {
                                emit(GetUserRejectWaitingSuccessStates());
                              }).catchError((onError) {
                                emit(GetUserRejectWaitingErrorStates());
                              });
                            }).catchError((onError) {
                              Navigator.pop(context);
                              emit(GetUserRejectWaitingErrorStates());
                            });
                          },
                          child: const Text(
                            'Yes',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                          color: Colors.green,
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        MaterialButton(
                          onPressed: () async {
                            Navigator.pop(context);
                          },
                          child: const Text('No',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                          color: Colors.red,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ));
  }

  //add massages group
  void addMassageToGroup(
      {required String? text,
      required String dateTime,
      required String createdAt,
      String? chatImage}) {
    MassageModelGroup model = MassageModelGroup(
        senderId: userProfile!.uId,
        text: text,
        dateTime: dateTime,
        createdAt: createdAt,
        image: chatImage,
        name: userProfile!.name,
        userImage: userProfile!.image);
    FirebaseFirestore.instance
        .collection('group')
        .doc('chat')
        .collection('massages')
        .add(model.toMap())
        .then((value) {
      emit(SocialAddMassageSuccessStates());
    }).catchError((onError) {
      emit(SocialAddMassageErrorStates());
    });
  }

  List<MassageModelGroup> massagesGroup = [];
  List<String> massagesGroupId = [];

  //get massages
  void getMassageGroup() {
    FirebaseFirestore.instance
        .collection('group')
        .doc('chat')
        .collection('massages')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((event) {
      massagesGroup = [];
      massagesGroupId = [];
      event.docs.forEach((element) {
        massagesGroup.add(MassageModelGroup.fromJson(element.data()));
        massagesGroupId.add(element.id);
      });
      emit(ChatGetMassageSuccessStates());
    }).onError((error) {
      emit(ChatGetMassageErrorStates());
    });
  }

  void getGroupImage({
    required String? text,
    required String dateTime,
    required String createdAt,
  }) async {
    emit(ChatUploadImageLoadingSuccessStates());
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      uploadGroupImage(
        chatImage: File(pickedFile.path),
        text: text,
        dateTime: dateTime,
        createdAt: createdAt,
      );
    } else {
      showToast(message: 'No Chat Image Selected', state: ToastState.WARNING);
      emit(ChatUploadImageLoadingErrorStates());
    }
  }

  void uploadGroupImage({
    required File chatImage,
    required String? text,
    required String dateTime,
    required String createdAt,
  }) {
    FirebaseStorage.instance
        .ref()
        .child(
            'chats/${Uri.file(chatImage.path).pathSegments.length / DateTime.now().millisecondsSinceEpoch}')
        .putFile(chatImage)
        .then((val) {
      val.ref.getDownloadURL().then((value) {
        addMassageToGroup(
            text: text,
            dateTime: dateTime,
            createdAt: createdAt,
            chatImage: value.toString());
      }).catchError((onError) {
        emit(ChatUploadImageLoadingErrorStates());
      });
    }).catchError((onError) {
      emit(ChatUploadImageLoadingErrorStates());
    });
  }

  //block from chat
  void blockUserFromChat({
    required UserProfile profile,
  }) {
    FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid.toString())
        .get()
        .then((value) {
      SharedHelper.save(value: value.data()!['block'], key: 'block');
      emit(SocialDeleteMassageSuccessStates());
    }).catchError((onError) {
      emit(SocialDeleteMassageErrorStates());
    });
    profile.block = true;
    FirebaseFirestore.instance
        .collection('users')
        .doc(profile.uId)
        .set(profile.toMap())
        .then((value) {
      emit(SocialDeleteMassageSuccessStates());
    }).catchError((onError) {
      emit(SocialDeleteMassageErrorStates());
    });
  }

  //block from app
  void blockUserFromApp({
    required UserProfile profile,
  }) {
    FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid.toString())
        .get()
        .then((value) {
      SharedHelper.save(value: value.data()!['block'], key: 'block_final');
      emit(SocialDeleteMassageSuccessStates());
    }).catchError((onError) {
      emit(SocialDeleteMassageErrorStates());
    });
    profile.block_final = true;
    FirebaseFirestore.instance
        .collection('users')
        .doc(profile.uId)
        .set(profile.toMap())
        .then((value) {
      emit(SocialDeleteMassageSuccessStates());
    }).catchError((onError) {
      emit(SocialDeleteMassageErrorStates());
    });
  }

  //delete group massage
  void deleteGroupMassage({required int index, required String id}) {
    MassageModelGroup group = MassageModelGroup(
        name: massagesGroup[index].name,
        userImage: massagesGroup[index].userImage,
        createdAt: massagesGroup[index].createdAt,
        text: 'لقد تم مسح ارسال رسالة',
        dateTime: massagesGroup[index].dateTime,
        image: massagesGroup[index].image,
        senderId: massagesGroup[index].senderId);
    FirebaseFirestore.instance
        .collection('group')
        .doc('chat')
        .collection('massages')
        .doc(id)
        .set(group.toMap())
        .then((value) {
      emit(SocialDeleteMassageSuccessStates());
    }).catchError((onError) {
      emit(SocialDeleteMassageErrorStates());
    });
  }

  void getBlockStatus() {
    FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((value) {
      SharedHelper.save(value: value.data()!['block'], key: 'block');
      emit(ChatGetAllUsersLoadingStates());
    });
  }

//upload video using user
  void getVideoUsingUser(
      {required context,
      required String name,
      required String username,
      required String date}) async {
    emit(GetVedioLoadingStates());
    final pickedFile =
        await ImagePicker().pickVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      uploadVideoUsingUser(
        date: date,
        name: name,
        username: username,
        context: context,
        video: File(pickedFile.path),
      );
    } else {
      showToast(message: 'No Chat Image Selected', state: ToastState.WARNING);
      emit(GetVedioErrorStates());
    }
  }

  double progress = 0.0;
  void uploadVideoUsingUser(
      {required File video,
      required context,
      required String name,
      required String username,
      required String date}) {
    progress = 0.0;
    UploadTask task = FirebaseStorage.instance
        .ref()
        .child(
            'Videos/${Uri.file(video.path).pathSegments.length / DateTime.now().millisecondsSinceEpoch}')
        .putFile(
            video,
            firebase_storage.SettableMetadata(
              contentType: 'video/mp4',
            ));
    task.snapshotEvents.listen((event) {
      progress =
          ((event.bytesTransferred.toDouble() / event.totalBytes.toDouble()) *
                  100)
              .roundToDouble();
      print(progress);
      emit(GetVedioLoadingStates());
    });

    task.then((val) {
      val.ref.getDownloadURL().then((value) {
        print(value);
        storeVideoInFirestoreUsingUser(
            link: value.toString(),
            videoName: name,
            username: username,
            date: date,
            context: context);
      }).catchError((onError) {
        showToast(message: onError.toString(), state: ToastState.ERROR);
        emit(GetVedioErrorStates());
      });
    }).catchError((onError) {
      showToast(message: onError.toString(), state: ToastState.WARNING);
      emit(GetVedioErrorStates());
    });
  }

  void storeVideoInFirestoreUsingUser({
    required String videoName,
    required String link,
    required String username,
    required String date,
    required context,
  }) {
    VideoModelUser model = VideoModelUser(
        name: videoName, link: link, date: date, username: username);
    FirebaseFirestore.instance
        .collection('videosUsingUser')
        .add(model.toMap())
        .then((value) {
      showToast(
          message: 'Video Uploaded Successfully', state: ToastState.SUCCESS);
      emit(GetVedioSuccessStates());
    }).catchError((onError) {
      print('pppppppppppppppppppppppp${onError.toString()}');
      showToast(message: onError.toString(), state: ToastState.WARNING);
      emit(GetVedioErrorStates());
    });
  }

  //upload video using admin
  void getVideo({
    required context,
    required String name,
  }) async {
    emit(GetVedioLoadingStates());
    final pickedFile =
        await ImagePicker().pickVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      uploadVideo(
        name: name,
        context: context,
        video: File(pickedFile.path),
      );
    } else {
      showToast(message: 'No Chat Image Selected', state: ToastState.WARNING);
      emit(GetVedioErrorStates());
    }
  }

  void uploadVideo({
    required File video,
    required context,
    required String name,
  }) {
    UploadTask task = FirebaseStorage.instance
        .ref()
        .child(
            'Videos/${Uri.file(video.path).pathSegments.length / DateTime.now().millisecondsSinceEpoch}')
        .putFile(
            video,
            firebase_storage.SettableMetadata(
              contentType: 'video/mp4',
            ));
    //calculate progress
    task.snapshotEvents.listen((event) {
      progress =
          ((event.bytesTransferred.toDouble() / event.totalBytes.toDouble()) *
                  100)
              .roundToDouble();
      print(progress);
      emit(GetVedioLoadingStates());
    });
    task.then((val) {
      val.ref.getDownloadURL().then((value) {
        print(value);
        storeVideoInFirestore(
            link: value.toString(), videoName: name, context: context);
      }).catchError((onError) {
        showToast(message: onError.toString(), state: ToastState.ERROR);
        emit(GetVedioErrorStates());
      });
    }).catchError((onError) {
      showToast(message: onError.toString(), state: ToastState.WARNING);
      emit(GetVedioErrorStates());
    });
  }

  void storeVideoInFirestore({
    required String videoName,
    required String link,
    required context,
  }) {
    VideoModel model = VideoModel(
      name: videoName,
      link: link,
    );
    FirebaseFirestore.instance
        .collection('videos')
        .add(model.toMap())
        .then((value) {
      showToast(
          message: 'Video Uploaded Successfully', state: ToastState.SUCCESS);
      emit(GetVedioSuccessStates());
    }).catchError((onError) {
      print('pppppppppppppppppppppppp${onError.toString()}');
      showToast(message: onError.toString(), state: ToastState.WARNING);
      emit(GetVedioErrorStates());
    });
  }

//upload image using user
  void getImageUsingUser(
      {required context,
      required String name,
      required String username,
      required String date}) async {
    emit(GetImageLoadingStates());
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      uploadImageUsingUser(
        date: date,
        name: name,
        username: username,
        context: context,
        Image: File(pickedFile.path),
      );
    } else {
      showToast(message: 'No Chat Image Selected', state: ToastState.WARNING);
      emit(GetImageErrorStates());
    }
  }

  void uploadImageUsingUser(
      {required File Image,
      required context,
      required String name,
      required String username,
      required String date}) {
    FirebaseStorage.instance
        .ref()
        .child(
            'Images/${Uri.file(Image.path).pathSegments.length / DateTime.now().millisecondsSinceEpoch}')
        .putFile(Image)
        .then((val) {
      val.ref.getDownloadURL().then((value) {
        print(value);
        storeImageInFirestoreUsingUser(
            link: value.toString(),
            Image: name,
            username: username,
            date: date,
            context: context);
      }).catchError((onError) {
        showToast(message: onError.toString(), state: ToastState.ERROR);
        emit(GetImageErrorStates());
      });
    }).catchError((onError) {
      showToast(message: onError.toString(), state: ToastState.WARNING);
      emit(GetImageErrorStates());
    });
  }

  void storeImageInFirestoreUsingUser({
    required String Image,
    required String link,
    required String username,
    required String date,
    required context,
  }) {
    ImageModelUser model =
        ImageModelUser(name: Image, link: link, date: date, username: username);
    FirebaseFirestore.instance
        .collection('imagesUsingUser')
        .add(model.toMap())
        .then((value) {
      showToast(
          message: 'Image Uploaded Successfully', state: ToastState.SUCCESS);
      emit(GetImageSuccessStates());
    }).catchError((onError) {
      print('pppppppppppppppppppppppp${onError.toString()}');
      showToast(message: onError.toString(), state: ToastState.WARNING);
      emit(GetImageErrorStates());
    });
  }

  //upload image using admin
  void getImage({
    required context,
    required String name,
  }) async {
    emit(GetImageLoadingStates());
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      uploadImage(
        name: name,
        context: context,
        Image: File(pickedFile.path),
      );
    } else {
      showToast(message: 'No Chat Image Selected', state: ToastState.WARNING);
      emit(GetImageErrorStates());
    }
  }

  void uploadImage({
    required File Image,
    required context,
    required String name,
  }) {
    FirebaseStorage.instance
        .ref()
        .child(
            'Images/${Uri.file(Image.path).pathSegments.length / DateTime.now().millisecondsSinceEpoch}')
        .putFile(Image)
        .then((val) {
      val.ref.getDownloadURL().then((value) {
        print(value);
        storeImageInFirestore(
            link: value.toString(), ImageName: name, context: context);
      }).catchError((onError) {
        showToast(message: onError.toString(), state: ToastState.ERROR);
        emit(GetImageErrorStates());
      });
    }).catchError((onError) {
      showToast(message: onError.toString(), state: ToastState.WARNING);
      emit(GetImageErrorStates());
    });
  }

  void storeImageInFirestore({
    required String ImageName,
    required String link,
    required context,
  }) {
    ImageModel model = ImageModel(
      name: ImageName,
      link: link,
    );
    FirebaseFirestore.instance
        .collection('images')
        .add(model.toMap())
        .then((value) {
      showToast(
          message: 'Image Uploaded Successfully', state: ToastState.SUCCESS);
      emit(GetImageSuccessStates());
    }).catchError((onError) {
      print('pppppppppppppppppppppppp${onError.toString()}');
      showToast(message: onError.toString(), state: ToastState.WARNING);
      emit(GetImageErrorStates());
    });
  }

  //get video using admin
  List<VideoModel> lecturesVideos = [];
  void getVideos() {
    emit(ViewFileLoadingStates());
    FirebaseFirestore.instance.collection('videos').snapshots().listen((event) {
      lecturesVideos = [];
      event.docs.forEach((element) {
        lecturesVideos.add(VideoModel.fromJson(element.data()));
      });
      emit(ViewFileSuccessStates());
    }).onError((handleError) {
      emit(ViewFileErrorStates());
    });
  }

  //get images using admin
  List<ImageModel> lecturesImages = [];
  void getImages() {
    emit(ViewFileLoadingStates());
    FirebaseFirestore.instance.collection('images').snapshots().listen((event) {
      lecturesImages = [];
      event.docs.forEach((element) {
        lecturesImages.add(ImageModel.fromJson(element.data()));
      });
      emit(ViewFileSuccessStates());
    }).onError((handleError) {
      emit(ViewFileErrorStates());
    });
  }

  //get videos using user
  List<VideoModelUser> VideosUsingUser = [];
  List<String> VideosUsingUserId = [];
  void getVideosUsingUser() {
    emit(ViewVedioLoadingStates());
    FirebaseFirestore.instance
        .collection('videosUsingUser')
        .snapshots()
        .listen((event) {
      VideosUsingUser = [];
      VideosUsingUserId = [];
      event.docs.forEach((element) {
        VideosUsingUser.add(VideoModelUser.fromJson(element.data()));
        VideosUsingUserId.add(element.id);
      });
      emit(ViewVedioSuccessStates());
    }).onError((handleError) {
      print('xxxxxxxxxxxxxxxxxxxxrrrrrrrrrrrr${onError.toString()}');
      emit(ViewVedioErrorStates());
    });
  }

  //accept video from admin
  void acceptVideoUsingUser({required String videoId}) {
    {
      emit(AcceptFileLoadingStates());
      FirebaseFirestore.instance
          .collection('videosUsingUser')
          .doc(videoId)
          .get()
          .then((value) {
        VideoModel model = VideoModel(
            name: value.data()!['name'], link: value.data()!['link']);
        FirebaseFirestore.instance
            .collection('videos')
            .add(model.toMap())
            .then((value) async {
          await FirebaseFirestore.instance
              .collection('videosUsingUser')
              .doc(videoId)
              .delete();
          emit(AcceptFileSuccessStates());
        }).catchError((onError) {
          emit(AcceptFileErrorStates());
        });
      }).catchError((onError) {
        emit(AcceptFileErrorStates());
      });
    }
  }

  //reject video from admin
  void rejectVideoUsingUser({required String videoId}) {
    emit(RejectFileLoadingStates());
    FirebaseFirestore.instance
        .collection('videosUsingUser')
        .doc(videoId)
        .delete()
        .then((value) {
      emit(RejectFileSuccessStates());
    }).catchError((onError) {
      emit(RejectFileErrorStates());
    });
  }

  //get images using user
  List<ImageModelUser> ImagesUsingUser = [];
  List<String> ImagesUsingUserId = [];
  void getImagesUsingUser() {
    emit(ViewVedioLoadingStates());
    FirebaseFirestore.instance
        .collection('imagesUsingUser')
        .snapshots()
        .listen((event) {
      ImagesUsingUser = [];
      ImagesUsingUserId = [];
      event.docs.forEach((element) {
        ImagesUsingUser.add(ImageModelUser.fromJson(element.data()));
        ImagesUsingUserId.add(element.id);
      });
      emit(ViewVedioSuccessStates());
    }).onError((handleError) {
      print('xxxxxxxxxxxxxxxxxxxxrrrrrrrrrrrr${onError.toString()}');
      emit(ViewVedioErrorStates());
    });
  }

  //accept image from admin
  void acceptImageUsingUser({required String imageId}) {
    {
      emit(AcceptFileLoadingStates());
      FirebaseFirestore.instance
          .collection('imagesUsingUser')
          .doc(imageId)
          .get()
          .then((value) {
        ImageModel model = ImageModel(
            name: value.data()!['name'], link: value.data()!['link']);
        FirebaseFirestore.instance
            .collection('images')
            .add(model.toMap())
            .then((value) async {
          await FirebaseFirestore.instance
              .collection('imagesUsingUser')
              .doc(imageId)
              .delete();
          emit(AcceptFileSuccessStates());
        }).catchError((onError) {
          emit(AcceptFileErrorStates());
        });
      }).catchError((onError) {
        emit(AcceptFileErrorStates());
      });
    }
  }

  //reject image from admin
  void rejectImageUsingUser({required String imageId}) {
    emit(RejectFileLoadingStates());
    FirebaseFirestore.instance
        .collection('imagesUsingUser')
        .doc(imageId)
        .delete()
        .then((value) {
      emit(RejectFileSuccessStates());
    }).catchError((onError) {
      emit(RejectFileErrorStates());
    });
  }
  Set usersTemporal={};
}
