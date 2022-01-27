import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:intl/intl.dart';
import 'package:ava/layout/cubit/cubit.dart';
import 'package:ava/layout/cubit/states.dart';
import 'package:ava/modules/login/login_screen.dart';
import 'package:ava/modules/pdf/add_pdf_screen.dart';
import 'package:ava/modules/search/search_screen.dart';
import 'package:ava/modules/upload_temporal/lectures.dart';
import 'package:ava/modules/users_waiting/users_waiting.dart';
import 'package:ava/shared/components/components.dart';
import 'package:ava/shared/network/local/cashe_helper.dart';
import 'package:ava/shared/styles/Icon_broken.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);


  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  //set online w offline
  /////////////////////////////////////////////////////////////////////////
  @override
  void initState(){
    super.initState();
    ChatHomeCubit.get(context).getUserProfile();
    ChatHomeCubit.get(context).getAllUsers();
    ChatHomeCubit.get(context).getUserStatus();
    ChatHomeCubit.get(context).getUserWaiting();
    ChatHomeCubit.get(context).getLectures();
    ChatHomeCubit.get(context).getLecturesUsingUser();
    WidgetsBinding.instance!.addObserver(this);
    setUserStatus('Online');
  }
  void setUserStatus(String status)async{
    await FirebaseFirestore.instance
        .collection('users')
        .doc( SharedHelper.get(key: 'uid'))
        .collection('userStatus')
        .doc('status').set({'userStatus':status});
  }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if(state==AppLifecycleState.resumed) {
      setUserStatus('Online');
      //showToast(message: 'Online', state: ToastState.SUCCESS);
    }else{
      setUserStatus(DateFormat('dd,MM yyyy hh:mm a').format(DateTime.now()));
      //showToast(message: 'Offline', state: ToastState.SUCCESS);
    }
  }
  ////////////////////////////////////////////////////////////////////////////////////
  @override
  Widget build(BuildContext context) {
   return BlocConsumer<ChatHomeCubit,ChatHomeStates>(
     listener: (context,state) {},
     builder: (context,state) {
       return  ConditionalBuilder(
         condition:ChatHomeCubit.get(context).userProfile!=null,
         builder:(context)=> Scaffold(
           backgroundColor: SharedHelper.get(key: "theme")=='Light Theme'?
           Colors.white:Theme.of(context).scaffoldBackgroundColor,
           appBar: AppBar(
             title: const Text(
               'Ava Bishoy Scout Group',
             ),
             actions: [
               if(ChatHomeCubit.get(context).currentIndex==1)
                 IconButton(onPressed: (){
                   navigateToWithReturn(context, SearchLectureScreen());
                 }, icon: const Icon(IconBroken.Search)),
               if(ChatHomeCubit.get(context).currentIndex==2)state is! ChatUpdateProfileDataWaitingImageToFinishUploadStates?
                 IconButton(onPressed: (){
                   ChatHomeCubit.get(context).editProfile(
                       context: context,
                       name: ChatHomeCubit.get(context).nameController.text.trim(),
                       phone:ChatHomeCubit.get(context).phoneController.text.trim());
                 }, icon: const Icon(IconBroken.Edit)):Container(color:SharedHelper.get(key: 'theme')=='Light Theme'?Colors.white:Theme.of(context).scaffoldBackgroundColor,height:15,width:15,child: const LinearProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.pink),),),
               if(SharedHelper.get(key: 'isAdmin')!=null&&SharedHelper.get(key: 'isAdmin'))
               Stack(
                 alignment: AlignmentDirectional.bottomEnd,
                 children: [
                   IconButton(onPressed: (){
                    //convert to activity in list user lecture
                     navigateToWithReturn(context,UploadPDFUsingUser());
                   }, icon: const Icon(IconBroken.Notification)),
                   if(ChatHomeCubit.get(context).lecturesUsingUser.isNotEmpty)
                   Text(ChatHomeCubit.get(context).lecturesUsingUser.length.toString(),style: const TextStyle(
                     fontWeight: FontWeight.bold,
                     fontSize: 18,
                     color: Colors.white
                   ),)
                 ],
               )
             ],
           ),
           body: ChatHomeCubit.get(context).listScreen[ChatHomeCubit.get(context).currentIndex],
           bottomNavigationBar: BottomNavigationBar(
             items: ChatHomeCubit.get(context).bottomNavList,
             onTap: (index){
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
                       style:SharedHelper.get(key: "theme")=='Light Theme'?
                       const TextStyle(
                           fontWeight: FontWeight.bold,
                           fontSize: 18,
                           color: Colors.white):
                       TextStyle(
                           fontWeight: FontWeight.bold,
                           fontSize: 18,
                           color: HexColor('000028')),
                     ),
                     accountEmail: Text(
                       ChatHomeCubit.get(context).userProfile!.email,
                       style:SharedHelper.get(key: "theme")=='Light Theme'?
                       const TextStyle(
                           fontWeight: FontWeight.normal,
                           fontSize: 15,
                           color: Colors.white):
                       TextStyle(
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
                     decoration: BoxDecoration(
                         color: Theme.of(context).primaryColor),
                   ),
                 InkWell(
                   child: Padding(
                     padding: const EdgeInsetsDirectional.only(
                         start: 22, bottom: 10, top: 22),
                     child: Row(
                       children: [
                         CircleAvatar(
                             radius: 11,
                             backgroundColor:
                             SharedHelper.get(key: 'theme')=='Light Theme'?Colors.pink:Colors.pink,
                             child:  Icon(
                               Icons.dark_mode_outlined,
                               color:SharedHelper.get(key: 'theme')=='Light Theme'?Colors.white:Colors.black,
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
                     if(SharedHelper.get(key: 'isAdmin')) {
                       navigateToWithReturn(context, PDFScreen());
                     }else{
                        navigateToWithReturn(context, UploadPDFUsingUser());
                     }
                   },
                 ),
                 if(SharedHelper.get(key: 'isAdmin')!=null&&SharedHelper.get(key: 'isAdmin'))
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
                         const SizedBox(width: 10,),
                         Text(
                           ChatHomeCubit.get(context).usersWaiting.length.toString(),
                           style: const TextStyle(
                               fontWeight: FontWeight.bold,
                               fontSize: 18,
                               color: Colors.pink
                           ),
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
                   onTap: ()async {
                     setUserStatus(DateFormat('dd,MM yyyy hh:mm a').format(DateTime.now()));
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
         fallback: (context)=>const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.pink),)),
       );
     },
   );
  }
}
