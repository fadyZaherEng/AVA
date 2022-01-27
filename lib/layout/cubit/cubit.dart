import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ava/layout/cubit/states.dart';
import 'package:ava/models/file_model.dart';
import 'package:ava/models/file_model_user.dart';
import 'package:ava/models/massage_model.dart';
import 'package:ava/models/user_profile.dart';
import 'package:ava/modules/lecture/lecture_screen.dart';
import 'package:ava/modules/setting/setting_screen.dart';
import 'package:ava/modules/users/user_screen.dart';
import 'package:ava/shared/components/components.dart';
import 'package:ava/shared/network/local/cashe_helper.dart';
import 'package:ava/shared/network/remote/dio_helper.dart';
import 'package:ava/shared/styles/Icon_broken.dart';
import 'package:intl/intl.dart';

// ignore_for_file: avoid_print
class ChatHomeCubit extends Cubit<ChatHomeStates> {
  ChatHomeCubit() : super(ChatHomeInitialStates());

  static ChatHomeCubit get(context) => BlocProvider.of(context);
  var nameController = TextEditingController();
  var phoneController = TextEditingController();

  int currentIndex = 0;
  List<Widget> listScreen = [
    UsersScreen(),
    LectureScreen(),
    SettingsScreen(),
  ];
  List<String> listTitles = [
    'Users',
    'Lectures',
    'Settings',
  ];
  List<BottomNavigationBarItem> bottomNavList = const [
    BottomNavigationBarItem(icon: Icon(IconBroken.User), label: 'Users'),
    BottomNavigationBarItem(
        icon: Icon(Icons.set_meal_rounded), label: 'Lectures'),
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
  List<UserProfile> users = [];
  Map<String, String> usersStatus = {};

  void getAllUsers() async {
    emit(ChatGetAllUsersLoadingStates());
    FirebaseFirestore.instance
        .collection('users')
        .orderBy('name')
        .snapshots()
        .listen((event) async {
      users = [];
      usersStatus.clear();
      for (var element in event.docs) {
        if (element.data()['uId'] != SharedHelper.get(key: 'uid') &&
            element.data()['status']) {
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
      print('eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee${handleError.toString()}');
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
              element.data()['status']) {
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
        token: token);
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

  // ///////////////////lectures using user
  // void getPDFUsingUser({
  //   required String name,
  //   required String username,
  //   required String date,
  //   required  context,
  // }) async{
  //   emit(GetFileLoadingStates());
  //   FilePickerResult? result=await FilePicker.platform.pickFiles();
  //   File pick=File(result!.files.single.path.toString());
  //   var file=pick.readAsBytesSync();
  //   if(result!=null) {
  //     FirebaseStorage.instance
  //         .ref()
  //         .child(
  //         'lectures/${DateTime.now().millisecondsSinceEpoch}').child('/.pdf')
  //         .putData(file)
  //         .then((val) {
  //       val.ref.getDownloadURL().then((value) {
  //         storeInFirestoreUsingUser(link:value.toString(),pdfName: name,username: username,date: date,context: context);
  //       }).catchError((onError) {
  //         showToast(message:onError.toString(), state: ToastState.WARNING);
  //         emit(GetFileErrorStates());
  //       });
  //     }).catchError((onError) {
  //       showToast(message:onError.toString(), state: ToastState.WARNING);
  //       emit(GetFileErrorStates());
  //     });
  //
  //   }
  //   else{
  //     showToast(message: 'No File Selected', state: ToastState.WARNING);
  //     emit(GetFileSuccessStates());
  //   }
  // }
  // void storeInFirestoreUsingUser({
  //   required String pdfName,
  //   required String link,
  //   required String username,
  //   required String date,
  //   required context,
  // }) {
  //   FileModelUser model=FileModelUser(name: pdfName, link: link,date: date,username: username);
  //   FirebaseFirestore.instance
  //       .collection('lecturesUsingUser')
  //       .add(model.toMap())
  //       .then((value) {
  //         Navigator.pop(context);
  //     showToast(message: 'File Uploaded Successfully', state: ToastState.SUCCESS);
  //     emit(GetFileSuccessStates());
  //   })
  //       .catchError((onError){
  //     showToast(message:onError.toString(), state: ToastState.WARNING);
  //     emit(GetFileErrorStates());
  //   });
  // }
  //
  // List<FileModelUser>lecturesUsingUser=[];
  // List<String>lecturesUsingUserId=[];
  // void getLecturesUsingUser()
  // {
  //   emit(ViewFileLoadingStates());
  //   FirebaseFirestore.instance
  //       .collection('lecturesUsingUser')
  //       .snapshots()
  //       .listen((event) {
  //     lecturesUsingUser=[];
  //     lecturesUsingUserId=[];
  //     event.docs.forEach((element) {
  //       lecturesUsingUser.add(FileModelUser.fromJson(element.data()));
  //       lecturesUsingUserId.add(element.id);
  //     });
  //     emit(ViewFileSuccessStates());
  //   }).onError((handleError){
  //     emit(ViewFileErrorStates());
  //   });
  // }
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
        phone: profile.phone);
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
                              DioHelper.postData(
                                      token: profile.token,
                                      massage:
                                          "عذرا لقد تم رفض حسابك تستطيع ان تجعل حساب اخر ")
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
}
