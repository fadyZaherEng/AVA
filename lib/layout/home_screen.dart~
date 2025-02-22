import 'package:ava_bishoy/modules/group/ava.dart';
import 'package:ava_bishoy/modules/upload_image/test.dart';
import 'package:ava_bishoy/modules/upload_temporal_images/images.dart';
import 'package:ava_bishoy/modules/upload_temporal_lectures/lectures.dart';
import 'package:ava_bishoy/modules/upload_temporal_videos/videos.dart';
import 'package:ava_bishoy/modules/upload_video/test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:intl/intl.dart';
import 'package:ava_bishoy/layout/cubit/cubit.dart';
import 'package:ava_bishoy/layout/cubit/states.dart';
import 'package:ava_bishoy/modules/login/login_screen.dart';
import 'package:ava_bishoy/modules/pdf/add_pdf_screen.dart';
import 'package:ava_bishoy/modules/search/search_screen.dart';
import 'package:ava_bishoy/modules/users_waiting/users_waiting.dart';
import 'package:ava_bishoy/shared/components/components.dart';
import 'package:ava_bishoy/shared/network/local/cashe_helper.dart';
import 'package:ava_bishoy/shared/styles/Icon_broken.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  //set online w offline
  /////////////////////////////////////////////////////////////////////////

  @override
  void initState() {
    super.initState();

    ChatHomeCubit.get(context).getUserProfile();
    ChatHomeCubit.get(context).getAllUsers();
    ChatHomeCubit.get(context).getUserStatus();
    ChatHomeCubit.get(context).getUserWaiting();
    ChatHomeCubit.get(context).getLectures();
    ChatHomeCubit.get(context).getVideos();
    ChatHomeCubit.get(context).getImages();
    ChatHomeCubit.get(context).getBlockStatus();
    ChatHomeCubit.get(context).getLecturesUsingUser();
    ChatHomeCubit.get(context).getVideosUsingUser();
    ChatHomeCubit.get(context).getImagesUsingUser();
    ChatHomeCubit.get(context).getMassageGroup();
    WidgetsBinding.instance!.addObserver(this);
    setUserStatus('Online');
  }

  void setUserStatus(String status) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(SharedHelper.get(key: 'uid'))
        .collection('userStatus')
        .doc('status')
        .set({'userStatus': status});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      setUserStatus('Online');
      //showToast(message: 'Online', state: ToastState.SUCCESS);
    } else {
      setUserStatus(DateFormat('dd,MM yyyy hh:mm a').format(DateTime.now()));
      //showToast(message: 'Offline', state: ToastState.SUCCESS);
    }
  }

  ////////////////////////////////////////////////////////////////////////////////////
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChatHomeCubit, ChatHomeStates>(
      listener: (context, state) {},
      builder: (context, state) {
        return ConditionalBuilder(
          condition: ChatHomeCubit.get(context).userProfile != null,
          builder: (context) => Scaffold(
            backgroundColor: SharedHelper.get(key: "theme") == 'Light Theme'
                ? Colors.white
                : Theme.of(context).scaffoldBackgroundColor,
            appBar: AppBar(
              title: const Text(
                'Ava Bishoy Scout Group',
              ),
              actions: [
                if (ChatHomeCubit.get(context).currentIndex == 1)
                  IconButton(
                      onPressed: () {
                        navigateToWithReturn(context, SearchLectureScreen());
                      },
                      icon: const Icon(IconBroken.Search)),
                if (ChatHomeCubit.get(context).currentIndex == 2)
                  state is! ChatUpdateProfileDataWaitingImageToFinishUploadStates
                      ? IconButton(
                          onPressed: () {
                            ChatHomeCubit.get(context).editProfile(
                                context: context,
                                name: ChatHomeCubit.get(context)
                                    .nameController
                                    .text
                                    .trim(),
                                phone: ChatHomeCubit.get(context)
                                    .phoneController
                                    .text
                                    .trim(),
                                bio: ChatHomeCubit.get(context)
                                    .bioController
                                    .text
                                    .trim(),
                                disAppear:
                                    ChatHomeCubit.get(context).disAppear ??
                                        ChatHomeCubit.get(context)
                                            .userProfile!
                                            .disappear);
                          },
                          icon: const Icon(IconBroken.Edit))
                      : Container(
                          color: SharedHelper.get(key: 'theme') == 'Light Theme'
                              ? Colors.white
                              : Theme.of(context).scaffoldBackgroundColor,
                          height: 15,
                          width: 15,
                          child: const LinearProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.pink),
                          ),
                        ),
                if (SharedHelper.get(key: 'isAdmin') != null &&
                    SharedHelper.get(key: 'isAdmin'))
                  Stack(
                    alignment: AlignmentDirectional.bottomEnd,
                    children: [
                      IconButton(
                          onPressed: () {
                            showDialog(
                                context: context,
                                barrierDismissible: true,
                                builder: (context) => AlertDialog(
                                      backgroundColor: SharedHelper.get(key: 'theme')=='Light Theme'?
                                      Colors.white:Theme.of(context).scaffoldBackgroundColor,
                                      title: Text(
                                        'What do you want?',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText1,
                                      ),
                                      content: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          TextButton(
                                            onPressed: () {
                                              navigateToWithReturn(context,
                                                  UploadImagesUsingUser());
                                            },
                                            child: Row(
                                              children: [
                                                Text(
                                                  ChatHomeCubit.get(context)
                                                      .ImagesUsingUser
                                                      .length
                                                      .toString(),
                                                  style: const TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.pink),
                                                ),
                                                const SizedBox(
                                                  width: 5,
                                                ),
                                                Text(
                                                  'Show Images Request',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyText2,
                                                ),
                                              ],
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              navigateToWithReturn(context,
                                                  UploadPDFUsingUser());
                                            },
                                            child: Row(
                                              children: [
                                                Text(
                                                  ChatHomeCubit.get(context)
                                                      .lecturesUsingUser
                                                      .length
                                                      .toString(),
                                                  style: const TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.pink),
                                                ),
                                                const SizedBox(
                                                  width: 5,
                                                ),
                                                Text(
                                                  'Show Lectures Request',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyText2,
                                                ),
                                              ],
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              navigateToWithReturn(context,
                                                  UploadVideosUsingUser());
                                            },
                                            child: Row(
                                              children: [
                                                Text(
                                                  ChatHomeCubit.get(context)
                                                      .VideosUsingUser
                                                      .length
                                                      .toString(),
                                                  style: const TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.pink),
                                                ),
                                                const SizedBox(
                                                  width: 5,
                                                ),
                                                Text(
                                                  'Show Videos Request',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyText2,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ));
                          },
                          icon: const Icon(IconBroken.Notification)),
                      if (ChatHomeCubit.get(context)
                              .lecturesUsingUser
                              .isNotEmpty ||
                          ChatHomeCubit.get(context)
                              .ImagesUsingUser
                              .isNotEmpty ||
                          ChatHomeCubit.get(context).VideosUsingUser.isNotEmpty)
                        Text(
                          (ChatHomeCubit.get(context).lecturesUsingUser.length +
                                  ChatHomeCubit.get(context)
                                      .ImagesUsingUser
                                      .length +
                                  ChatHomeCubit.get(context)
                                      .VideosUsingUser
                                      .length)
                              .toString(),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.white),
                        )
                    ],
                  ),
                if (ChatHomeCubit.get(context).currentIndex == 1)
                  IconButton(
                      onPressed: () {
                        showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => AlertDialog(
                                  backgroundColor:  SharedHelper.get(key: 'theme')=='Light Theme'?
                                  Colors.white:Theme.of(context).scaffoldBackgroundColor,
                                  title: Text(
                                    'What do you want?',
                                    style: Theme.of(context).textTheme.bodyText1,
                                  ),
                                  content: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      TextButton(
                                        onPressed: () {
                                          setState(() {
                                            ChatHomeCubit.get(context)
                                                    .listBody =
                                                ChatHomeCubit.get(context)
                                                    .listImagesScreen;
                                            ChatHomeCubit.get(context).listNav =
                                                ChatHomeCubit.get(context)
                                                    .bottomNavImagesList;
                                          });
                                          Navigator.pop(context);
                                        },
                                        child: Text(
                                          'Show Images',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText2,
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          setState(() {
                                            ChatHomeCubit.get(context)
                                                    .listBody =
                                                ChatHomeCubit.get(context)
                                                    .listVideosScreen;
                                            ChatHomeCubit.get(context).listNav =
                                                ChatHomeCubit.get(context)
                                                    .bottomNavVideosList;
                                          });
                                          Navigator.pop(context);
                                        },
                                        child: Text(
                                          'Show Videos',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText2,
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          setState(() {
                                            ChatHomeCubit.get(context)
                                                    .listBody =
                                                ChatHomeCubit.get(context)
                                                    .listLecturesScreen;
                                            ChatHomeCubit.get(context).listNav =
                                                ChatHomeCubit.get(context)
                                                    .bottomNavLecturesList;
                                          });
                                          Navigator.pop(context);
                                        },
                                        child: Text(
                                          'Show Lectures',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ));
                      },
                      icon: const Icon(Icons.list)),
              ],
            ),
            body: ChatHomeCubit.get(context)
                .listBody[ChatHomeCubit.get(context).currentIndex],
            bottomNavigationBar: BottomNavigationBar(
              items: ChatHomeCubit.get(context).listNav,
              onTap: (index) {
                ChatHomeCubit.get(context).changeNav(index);
              },
              currentIndex: ChatHomeCubit.get(context).currentIndex,
              type: BottomNavigationBarType.fixed,
            ),
            drawer: Drawer(
              //end drawer right w drawer left
              child: Column(
                children: [
                  if (ChatHomeCubit.get(context).userProfile != null)
                    UserAccountsDrawerHeader(
                      accountName: Text(
                        ChatHomeCubit.get(context).userProfile!.name,
                        style: SharedHelper.get(key: "theme") == 'Light Theme'
                            ? const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.white)
                            : TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: HexColor('000028')),
                      ),
                      accountEmail: Text(
                        ChatHomeCubit.get(context).userProfile!.email,
                        style: SharedHelper.get(key: "theme") == 'Light Theme'
                            ? const TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: 15,
                                color: Colors.white)
                            : TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: 15,
                                color: HexColor('000028')),
                      ),
                      currentAccountPicture: Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: CircleAvatar(
                          radius: 45,
                          backgroundColor:
                              Theme.of(context).scaffoldBackgroundColor,
                          backgroundImage: NetworkImage(
                            ChatHomeCubit.get(context).userProfile!.image,
                          ),
                        ),
                      ),
                      decoration:
                          BoxDecoration(color: Theme.of(context).primaryColor),
                    ),
                  InkWell(
                    child: Padding(
                      padding: const EdgeInsetsDirectional.only(
                          start: 22, bottom: 10, top: 22),
                      child: Row(
                        children: [
                          CircleAvatar(
                              radius: 11,
                              backgroundColor: SharedHelper.get(key: 'theme') ==
                                      'Light Theme'
                                  ? Colors.pink
                                  : Colors.pink,
                              child: Icon(
                                Icons.dark_mode_outlined,
                                color: SharedHelper.get(key: 'theme') ==
                                        'Light Theme'
                                    ? Colors.white
                                    : Colors.black,
                                size: 15,
                              )),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(
                            SharedHelper.get(key: 'theme'),
                            style: Theme.of(context).textTheme.bodyText2,
                          )
                        ],
                      ),
                    ),
                    onTap: () {
                      ChatHomeCubit.get(context).modeChange();
                    },
                  ),
                  InkWell(
                    child: Padding(
                      padding: const EdgeInsetsDirectional.only(
                          start: 22, bottom: 10, top: 10),
                      child: Row(
                        children: [
                          const Icon(
                            IconBroken.Setting,
                            size: 20,
                            color: Colors.pink,
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(
                            'Settings',
                            style: Theme.of(context).textTheme.bodyText2,
                          )
                        ],
                      ),
                    ),
                    onTap: () {
                      ChatHomeCubit.get(context).changeSettings(context);
                    },
                  ),
                  InkWell(
                    child: Padding(
                      padding: const EdgeInsetsDirectional.only(
                          start: 22, bottom: 10, top: 10),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.picture_as_pdf_sharp,
                            size: 20,
                            color: Colors.pink,
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(
                            'Upload Lecture',
                            style: Theme.of(context).textTheme.bodyText2,
                          )
                        ],
                      ),
                    ),
                    onTap: () {
                      if (SharedHelper.get(key: 'isAdmin')) {
                        navigateToWithReturn(context, PDFScreen());
                      } else {
                        navigateToWithReturn(context, UploadPDFUsingUser());
                      }
                    },
                  ),
                  InkWell(
                    child: Padding(
                      padding: const EdgeInsetsDirectional.only(
                          start: 22, bottom: 10, top: 10),
                      child: Row(
                        children: [
                          const Icon(
                            IconBroken.Video,
                            size: 20,
                            color: Colors.pink,
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(
                            'Upload Video',
                            style: Theme.of(context).textTheme.bodyText2,
                          )
                        ],
                      ),
                    ),
                    onTap: () {
                      navigateToWithReturn(context, UploadVideos());
                    },
                  ),
                  InkWell(
                    child: Padding(
                      padding: const EdgeInsetsDirectional.only(
                          start: 22, bottom: 10, top: 10),
                      child: Row(
                        children: [
                          const Icon(
                            IconBroken.Image,
                            size: 20,
                            color: Colors.pink,
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(
                            'Upload Image',
                            style: Theme.of(context).textTheme.bodyText2,
                          )
                        ],
                      ),
                    ),
                    onTap: () {
                      navigateToWithReturn(context, UploadImages());
                    },
                  ),
                  if (SharedHelper.get(key: 'isAdmin') != null &&
                      SharedHelper.get(key: 'isAdmin'))
                    InkWell(
                      child: Padding(
                        padding: const EdgeInsetsDirectional.only(
                            start: 22, bottom: 10, top: 10),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.person_add,
                              size: 20,
                              color: Colors.pink,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Text(
                              ChatHomeCubit.get(context)
                                  .usersWaiting
                                  .length
                                  .toString(),
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.pink),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Text(
                              'Person Waiting',
                              style: Theme.of(context).textTheme.bodyText2,
                            )
                          ],
                        ),
                      ),
                      onTap: () {
                        navigateToWithReturn(context, UsersWaitingScreen());
                      },
                    ),
                  if (SharedHelper.get(key: 'block') != null &&
                      !SharedHelper.get(key: 'block'))
                    InkWell(
                      child: Padding(
                        padding: const EdgeInsetsDirectional.only(
                            start: 22, bottom: 10, top: 10),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.group_add,
                              size: 20,
                              color: Colors.pink,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Text(
                              ChatHomeCubit.get(context)
                                  .users
                                  .length
                                  .toString(),
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.pink),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Text(
                              'Ava Group',
                              style: Theme.of(context).textTheme.bodyText2,
                            )
                          ],
                        ),
                      ),
                      onTap: () {
                        navigateToWithReturn(context, AvaGroupScreen());
                      },
                    ),
                  InkWell(
                    child: Padding(
                      padding: const EdgeInsetsDirectional.only(
                          start: 22, bottom: 10, top: 10),
                      child: Row(
                        children: [
                          const Icon(
                            IconBroken.Logout,
                            size: 20,
                            color: Colors.pink,
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(
                            'LogOut',
                            style: Theme.of(context).textTheme.bodyText2,
                          )
                        ],
                      ),
                    ),
                    onTap: () async {
                      setUserStatus(DateFormat('dd,MM yyyy hh:mm a')
                          .format(DateTime.now()));
                      await FirebaseAuth.instance.signOut();
                      SharedHelper.remove(key: 'signIn');
                      SharedHelper.remove(key: 'isAdmin');
                      SharedHelper.remove(key: 'uid');
                      ChatHomeCubit.get(context).usersStatus.clear();
                      ChatHomeCubit.get(context).users.clear();
                      navigateToWithoutReturn(context, LogInScreen());
                    },
                  ),
                ],
              ),
            ),
          ),
          fallback: (context) => const Center(
              child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.pink),
          )),
        );
      },
    );
  }
}
