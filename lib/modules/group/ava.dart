// ignore_for_file: must_be_immutable, use_key_in_widget_constructors, avoid_print

import 'package:ava_bishoy/models/model_group_massage.dart';
import 'package:ava_bishoy/modules/users_group/user_screen.dart';
import 'package:ava_bishoy/shared/components/components.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ava_bishoy/layout/cubit/cubit.dart';
import 'package:ava_bishoy/layout/cubit/states.dart';
import 'package:ava_bishoy/shared/network/local/cashe_helper.dart';
import 'package:ava_bishoy/shared/styles/Icon_broken.dart';

class AvaGroupScreen extends StatelessWidget {
  var textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      //equal on start android

      return BlocConsumer<ChatHomeCubit, ChatHomeStates>(
          listener: (context, state) {},
          builder: (context, state) {
            return Scaffold(
                backgroundColor: SharedHelper.get(key: 'theme') == 'Light Theme'
                    ? Colors.white
                    : Theme.of(context).scaffoldBackgroundColor,
                appBar: AppBar(
                  leading: IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(IconBroken.Arrow___Left_2)),
                  titleSpacing: 0,
                  title: InkWell(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor:
                            Theme.of(context).scaffoldBackgroundColor,
                            backgroundImage:
                            const AssetImage('assets/images/logo.jpg'),
                          ),
                          const SizedBox(
                            width: 11,
                          ),
                          const Text(
                            'AVA Group Chats',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    onTap: () {
                      //show users
                      //edit block in firebase w shared
                      navigateToWithReturn(context, UsersGroupScreen());
                    },
                  ),
                ),
                body: Column(
                  children: [
                    ConditionalBuilder(
                        condition: ChatHomeCubit.get(context)
                            .massagesGroup
                            .isNotEmpty,
                        builder: (context) => Expanded(
                          child: Stack(
                            children: [
                              Image(
                                  fit: BoxFit.fill,
                                  width:double.infinity,
                                  height: double.infinity,
                                  image: SharedHelper.get(key: 'theme') == 'Light Theme'
                                      ? const AssetImage('assets/images/cccc.jpg')
                                      : const AssetImage('assets/images/cc.jpg')),
                              Padding(
                                padding:const EdgeInsetsDirectional.only(
                                    top: 20, start: 10, end: 10, bottom: 8),
                                child: ListView.separated(
                                    physics:
                                    const BouncingScrollPhysics(),
                                    reverse: true,
                                    itemBuilder: (context, index) {
                                      var massage = ChatHomeCubit.get(context).massagesGroup[index];
                                      if (massage.text != '') {
                                        bool flag=false;
                                        if (FirebaseAuth.instance.currentUser!.uid == massage.senderId) {
                                           if(index>0) {
                                               var nextMassage = ChatHomeCubit.get(context).massagesGroup[index-1];
                                               if (FirebaseAuth.instance.currentUser!.uid != nextMassage.senderId){
                                                 flag=true;
                                               }
                                             }
                                           if(index==0) {
                                             flag=true;
                                           }
                                            return buildSenderMassage(
                                              massage, context, index,flag);
                                        }
                                        else {
                                          if(index>0)
                                          {
                                            var nextMassage = ChatHomeCubit.get(context).massagesGroup[index-1];
                                            if (massage.senderId!= nextMassage.senderId){
                                              flag=true;
                                            }
                                          }
                                          if(index==0) {
                                            flag=true;
                                          }
                                          return buildReceiverMassage(
                                              massage, context, index,flag);
                                        }
                                      } else {
                                        if (ChatHomeCubit.get(context)
                                            .userProfile!
                                            .uId ==
                                            massage.senderId) {
                                          return buildSenderImageMassage(
                                              massage, context, index);
                                        } else {
                                          return buildReceiverImageMassage(
                                              massage, context, index);
                                        }
                                      }
                                    },
                                    separatorBuilder:
                                        (context, index) {
                                          var massage = ChatHomeCubit.get(context).massagesGroup[index];
                                          if(index>0) {
                                            var nextMassage = ChatHomeCubit.get(context).massagesGroup[index-1];
                                            if (FirebaseAuth.instance.currentUser!.uid == massage.senderId) {
                                              if (FirebaseAuth.instance.currentUser!.uid != nextMassage.senderId) {
                                                return const SizedBox(
                                                  height: 10,
                                                );
                                              }
                                            }
                                            else {
                                              if (massage.senderId != nextMassage.senderId) {
                                                return const SizedBox(height: 10,);
                                              }
                                            }
                                          }
                                          if(index==0) {
                                            return const SizedBox(
                                              height: 10,
                                            );
                                          }
                                          return const SizedBox(
                                            height: 0.5,
                                          );
                                 },
                                    itemCount:
                                    ChatHomeCubit.get(context)
                                        .massagesGroup
                                        .length),
                              ),
                            ],
                          ),
                        ),
                        fallback: (context) => Expanded(
                            child: Center(
                                child: Text(
                                  'No Massages',
                                  style: Theme.of(context).textTheme.bodyText2,
                                )))),
                    if (ChatHomeCubit.get(context).massagesGroup.isEmpty)
                      const Spacer(),
                    buildBottom(context, state),
                  ],
                )
            );
          }
          );
      }
    );
  }

  Widget buildSenderImageMassage(MassageModelGroup massageModelGroup, context, index)
  => Align(
        alignment: AlignmentDirectional.centerEnd,
        child: Image(
          image: NetworkImage(massageModelGroup.image),
          width: 150,
          height: 150,
          fit: BoxFit.cover,
        ),
      );
  Widget buildReceiverImageMassage(MassageModelGroup massageModelGroup, context, index)
  => Align(
        alignment: AlignmentDirectional.centerStart,
        child: Image(
          image: NetworkImage(massageModelGroup.image),
          width: 150,
          height: 150,
          fit: BoxFit.cover,
        ),
      );
  Widget buildSenderMassage(MassageModelGroup massageModelGroup, context, index,flag) {
    if (massageModelGroup.text == 'لقد تم مسح ارسال رسالة') {
      if (SharedHelper.get(key: 'theme') == 'Light Theme')
      {
          return Align(
          alignment: AlignmentDirectional.centerEnd,
          child: Column(
            children: [
              Text(
                massageModelGroup.name,
                style: Theme.of(context).textTheme.bodyText1,
              ),
              const SizedBox(
                height: 5,
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: AlignmentDirectional.bottomEnd,
                    child: Padding(
                      padding: const EdgeInsetsDirectional.only(
                        start: 5,
                        end: 5,
                      ),
                      child: Text(
                        getTime(massageModelGroup.dateTime),
                        style: Theme.of(context).textTheme.bodyText2,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadiusDirectional.only(
                          topStart: Radius.circular(10),
                          topEnd: Radius.circular(10),
                          bottomStart: Radius.circular(10),
                          bottomEnd: Radius.circular(10),
                        ),
                      ),
                      child: Text(
                        massageModelGroup.text,
                        style: Theme.of(context).textTheme.bodyText2,
                        maxLines: 1000,
                        softWrap: true,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 4,
                  ),
                  CircleAvatar(
                    radius: 20,
                    backgroundColor:
                    SharedHelper.get(key: 'theme') == 'Light Theme'
                        ? Colors.white
                        : Theme.of(context).scaffoldBackgroundColor,
                    backgroundImage: NetworkImage(massageModelGroup.userImage),
                  ),
                ],
              ),
            ],
          ),
        );
      }
      else
      {
          return Align(
          alignment: AlignmentDirectional.centerEnd,
          child: Column(
            children: [
              Text(
                massageModelGroup.name,
                style: Theme.of(context).textTheme.bodyText1,
              ),
              const SizedBox(
                height: 5,
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: AlignmentDirectional.bottomEnd,
                    child: Padding(
                      padding: const EdgeInsetsDirectional.only(
                        start: 5,
                        end: 5,
                      ),
                      child: Text(
                        getTime(massageModelGroup.dateTime),
                        style: Theme.of(context).textTheme.bodyText2,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadiusDirectional.only(
                          topStart: Radius.circular(10),
                          topEnd: Radius.circular(10),
                          bottomStart: Radius.circular(10),
                          bottomEnd: Radius.circular(10),
                        ),
                      ),
                      child: Text(
                        massageModelGroup.text,
                        style: Theme.of(context).textTheme.bodyText2,
                        maxLines: 1000,
                        softWrap: true,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 4,
                  ),
                    CircleAvatar(
                      radius: 20,
                      backgroundColor:
                      SharedHelper.get(key: 'theme') == 'Light Theme'
                          ? Colors.white
                          : Theme.of(context).scaffoldBackgroundColor,
                      backgroundImage: NetworkImage(massageModelGroup.userImage),
                    ),
                ],
              ),
            ],
          ),
        );
      }
    }
    else {
        return InkWell(
        child: Align(
          alignment: AlignmentDirectional.centerEnd,
          child: Column(
            children: [
              if(flag)
              const SizedBox(
                height: 5,
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if(flag)
                  Align(
                    alignment: AlignmentDirectional.bottomEnd,
                    child: Padding(
                      padding: const EdgeInsetsDirectional.only(
                        start: 5,
                        end: 5,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if(flag)
                          Text(
                              massageModelGroup.name,
                              style:const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white
                              ),
                            ),
                          Text(
                            getTime(massageModelGroup.dateTime),
                            style:  TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.normal,
                                color: Colors.grey[300]
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if(flag)
                  const SizedBox(
                    width: 10,
                  ),
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .scaffoldBackgroundColor
                            .withOpacity(0.6),
                        borderRadius: const BorderRadiusDirectional.only(
                          topStart: Radius.circular(10),
                          topEnd: Radius.circular(10),
                          bottomStart: Radius.circular(10),
                        ),
                      ),
                      child: Text(
                        massageModelGroup.text,
                        style: Theme.of(context).textTheme.bodyText2,
                        maxLines: 1000,
                        softWrap: true,
                      ),
                    ),
                  ),
                  if(flag)
                  const SizedBox(
                    width: 4,
                  ),
                  if(flag)
                  CircleAvatar(
                    radius: 20,
                    backgroundColor:
                    SharedHelper.get(key: 'theme') == 'Light Theme'
                        ? Colors.white
                        : Theme.of(context).scaffoldBackgroundColor,
                    backgroundImage: NetworkImage(massageModelGroup.userImage),
                  ),
                  if(!flag)
                   const SizedBox(width: 40,),
                ],
              ),
            ],
          ),
        ),
        onTap: () {
          showDialog(
              context: context,
              builder: (context) => AlertDialog(
                backgroundColor:
                SharedHelper.get(key: "theme") == 'Light Theme'
                    ? Colors.white
                    : Theme.of(context).scaffoldBackgroundColor,
                title: Text(
                  'Delete Massage',
                  style: Theme.of(context).textTheme.bodyText1,
                ),
                content: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: TextButton(
                          onPressed: () {
                            ChatHomeCubit.get(context).deleteGroupMassage(
                                id: ChatHomeCubit.get(context)
                                    .massagesGroupId[index],
                                index: index);
                            Navigator.pop(context);
                          },
                          child: Text(
                            'Yes',
                            style: Theme.of(context).textTheme.bodyText2,
                          )),
                    ),
                    Expanded(
                      child: TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            'No',
                            style: Theme.of(context).textTheme.bodyText2,
                          )),
                    )
                  ],
                ),
              ));
        },
      );
    }
  }
  Widget buildReceiverMassage(MassageModelGroup massageModelGroup, context, index,flag)
  => Align(
        alignment: AlignmentDirectional.centerStart,
        child: Column(
          children: [
            if(flag)
            const SizedBox(
              height: 5,
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if(flag)
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  backgroundImage: NetworkImage(massageModelGroup.userImage),
                ),
                if(flag)
                const SizedBox(
                  width: 4,
                ),
                if(!flag)
                const SizedBox(
                    width: 40,
                  ),
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadiusDirectional.only(
                        topStart: Radius.circular(10),
                        topEnd: Radius.circular(10),
                        bottomEnd: Radius.circular(10),
                      ),
                    ),
                    child: Text(
                      massageModelGroup.text,
                      style: Theme.of(context).textTheme.bodyText2,
                      maxLines: 1000,
                      softWrap: true,
                    ),
                  ),
                ),
                if(flag)
                const SizedBox(
                  width: 10,
                ),
                if(flag)
                Align(
                  alignment: AlignmentDirectional.bottomEnd,
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(
                      start: 5,
                      end: 5,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if(flag)
                          Text(
                            massageModelGroup.name,
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white
                            ),
                          ),
                        Text(
                          getTime(massageModelGroup.dateTime),
                          style:TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.normal,
                              color: Colors.grey[300]
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
  buildBottom(context, state)
  => Padding(
    padding: const EdgeInsetsDirectional.only(
        top: 2, start: 5, end: 5, bottom: 2),
    child: Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        color: SharedHelper.get(key: 'theme') == 'Light Theme'
            ? Colors.white
            : Theme.of(context).scaffoldBackgroundColor,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: TextFormField(
              maxLines: 1000,
              minLines: 1,
              validator: (val) {
                if (val!.isEmpty) {
                  return '';
                }
                return null;
              },
              controller: textController,
              decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'write here your massage...',
                  hintStyle: TextStyle(color: Colors.grey)),
              // style: Theme.of(context).textTheme.bodyText2,
            ),
          ),
          if (state is ChatUploadImageLoadingSuccessStates)
            const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.pink)),
          if (state is! ChatUploadImageLoadingSuccessStates)
            Padding(
              padding: const EdgeInsets.only(top: 5.0),
              child: IconButton(
                  onPressed: () {
                    ChatHomeCubit.get(context).getGroupImage(
                      createdAt: Timestamp.now().toString(),
                      dateTime: DateTime.now().toString(),
                      text: textController.text,
                    );
                  },
                  icon: const Icon(
                    IconBroken.Camera,
                    color: Colors.pink,
                  )),
            ),
          Padding(
            padding: const EdgeInsets.only(top: 5.0, bottom: 5, right: 5),
            child: MaterialButton(
                height: 50,
                color: SharedHelper.get(key: 'theme') == 'Light Theme'
                    ? Colors.white
                    : Theme.of(context).scaffoldBackgroundColor,
                onPressed: () {
                  if (textController.text != '') {
                    ChatHomeCubit.get(context).addMassageToGroup(
                        createdAt: Timestamp.now().toString(),
                        text: textController.text,
                        dateTime: DateTime.now().toString());
                    textController.text = '';
                  }
                },
                child: const Icon(
                  IconBroken.Send,
                  color: Colors.pink,
                  size: 25,
                )),
          ),
        ],
      ),
    ),
  );
  String getTime(dateTime) {
    DateTime lastTime = DateTime.parse(dateTime);
    DateTime currentTime = DateTime.now();
    int differenceMinutes = currentTime.difference(lastTime).inMinutes;
    int differenceHours = currentTime.difference(lastTime).inHours;
    int differenceDays = currentTime.difference(lastTime).inDays;
    if (differenceMinutes < 60) {
      if (differenceMinutes == 0) {
        return 'now';
      }
      return '$differenceMinutes m';
    } else if (differenceHours < 24) {
      return '$differenceHours h';
    } else if (differenceDays < 30) {
      return '$differenceDays days';
    } else if (differenceDays > 30 && differenceDays <= 365) {
      return '${differenceDays / 30} month';
    } else {
      return '${differenceDays / 365} year';
    }
  }
}
