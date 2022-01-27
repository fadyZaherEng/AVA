import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:ava/layout/cubit/cubit.dart';
import 'package:ava/layout/cubit/states.dart';
import 'package:ava/models/massage_model.dart';
import 'package:ava/models/user_profile.dart';
import 'package:ava/shared/network/local/cashe_helper.dart';
import 'package:ava/shared/network/remote/dio_helper.dart';
import 'package:ava/shared/styles/Icon_broken.dart';

class ChatScreen extends StatelessWidget {
  UserProfile? receiverProfile;

  var textController = TextEditingController();
  var scrollController = ScrollController();

  ChatScreen(this.receiverProfile);

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      //equal on start android
      ChatHomeCubit.get(context).getMassage(receiverId: receiverProfile!.uId);
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
                  title: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 25,
                          backgroundColor:
                              Theme.of(context).scaffoldBackgroundColor,
                          backgroundImage: NetworkImage(receiverProfile!.image),
                        ),
                        const SizedBox(
                          width: 11,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              receiverProfile!.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.white),
                            ),
                            const SizedBox(
                              height: 7,
                            ),
                            Text(
                              ChatHomeCubit.get(context)
                                          .usersStatus[receiverProfile!.uId] ==
                                      'Online'
                                  ? 'Online'
                                  : 'Offline',
                              style: const TextStyle(
                                  fontWeight: FontWeight.normal,
                                  fontSize: 15,
                                  color: Colors.white),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                body: Padding(
                  padding: const EdgeInsetsDirectional.only(
                      top: 20, start: 10, end: 10, bottom: 8),
                  child: Column(
                    children: [
                      if (ChatHomeCubit.get(context).massages.isNotEmpty)
                        ConditionalBuilder(
                            condition:
                                ChatHomeCubit.get(context).massages.isNotEmpty,
                            builder: (context) => Expanded(
                                  child: ListView.separated(
                                      physics: const BouncingScrollPhysics(),
                                      reverse: true,
                                      //  controller: scrollController,
                                      itemBuilder: (context, index) {
                                        var massage = ChatHomeCubit.get(context)
                                            .massages[index];
                                        if (massage.text != '') {
                                          if (ChatHomeCubit.get(context)
                                                  .userProfile!
                                                  .uId ==
                                              massage.senderId) {
                                            return buildSenderMassage(
                                                massage, context, index);
                                          } else {
                                            // if(ChatHomeCubit.get(context).usersStatus[receiverProfile!.uId]!='Online')
                                            //   {
                                            //     // DioHelper.postData(token: receiverProfile!.token.token,
                                            //     //     massage:"you have massage from${ChatHomeCubit.get(context).userProfile!.name}")
                                            //     // .then((value) {})
                                            //     // .catchError((onError){});
                                            //   }
                                            return buildReceiverMassage(
                                                massage, context, index);
                                          }
                                        } else {
                                          if (ChatHomeCubit.get(context)
                                                  .userProfile!
                                                  .uId ==
                                              massage.senderId) {
                                            return buildSenderImageMassage(
                                                massage, context, index);
                                          } else {
                                            // if(ChatHomeCubit.get(context).usersStatus[receiverProfile!.uId]!='Online')
                                            // {
                                            //   DioHelper.postData(token: receiverProfile!.token.token,
                                            //       massage:"you have massage from${ChatHomeCubit.get(context).userProfile!.name}")
                                            //       .then((value) {})
                                            //       .catchError((onError){});
                                            // }
                                            return buildReceiverImageMassage(
                                                massage, context, index);
                                          }
                                        }
                                      },
                                      separatorBuilder: (context, index) =>
                                          const SizedBox(
                                            height: 15,
                                          ),
                                      itemCount: ChatHomeCubit.get(context)
                                          .massages
                                          .length),
                                ),
                            fallback: (context) => Expanded(
                                    child: Center(
                                        child: Text(
                                  'No Massages',
                                  style: Theme.of(context).textTheme.bodyText2,
                                )))),
                      if (ChatHomeCubit.get(context).massages.isEmpty)
                        const Spacer(),
                      buildBottom(context, state),
                    ],
                  ),
                ));
          });
    });
  }

  Widget buildSenderImageMassage(MassageModel massageModel, context, index) =>
      InkWell(
        child: Align(
          alignment: AlignmentDirectional.centerEnd,
          child: Image(
            image: NetworkImage(massageModel.image),
            width: 150,
            height: 150,
            fit: BoxFit.cover,
          ),
        ),
        onTap: () {
          showDialog(
            barrierDismissible: false, //prevent close
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              title: Text(
                'Delete Massage',
                style: Theme.of(context).textTheme.bodyText1,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor:
                                Theme.of(context).scaffoldBackgroundColor,
                            title: Text(
                              'Delete Massage',
                              style: Theme.of(context).textTheme.bodyText1,
                            ),
                            content: Text(
                              'Are You Sure ?',
                              style: Theme.of(context).textTheme.bodyText2,
                            ),
                            actions: [
                              Row(
                                children: [
                                  Expanded(
                                    child: TextButton(
                                      onPressed: () {
                                        ChatHomeCubit.get(context)
                                            .deleteMassageFromMe(
                                                receiverId:
                                                    receiverProfile!.uId,
                                                massageId:
                                                    ChatHomeCubit.get(context)
                                                        .massagesId[index]);
                                        Navigator.pop(context);
                                        Navigator.pop(context);
                                      },
                                      child: Text(
                                        'Confirm',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText1,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        Navigator.pop(context);
                                      },
                                      child: Text(
                                        'Cancel',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText1,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                      child: Text(
                        'Delete Massage From Me',
                        style: Theme.of(context).textTheme.bodyText2,
                      )),
                  const SizedBox(
                    height: 6,
                  ),
                  TextButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor:
                                Theme.of(context).scaffoldBackgroundColor,
                            title: Text(
                              'Delete Massage',
                              style: Theme.of(context).textTheme.bodyText1,
                            ),
                            content: Text(
                              'Are You Sure ?',
                              style: Theme.of(context).textTheme.bodyText2,
                            ),
                            actions: [
                              Row(
                                children: [
                                  Expanded(
                                    child: TextButton(
                                      onPressed: () {
                                        ChatHomeCubit.get(context)
                                            .deleteMassageFromAll(
                                                receiverId:
                                                    receiverProfile!.uId,
                                                massageId:
                                                    ChatHomeCubit.get(context)
                                                        .massagesId[index]);
                                        Navigator.pop(context);
                                        Navigator.pop(context);
                                      },
                                      child: Text(
                                        'Confirm',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText1,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        Navigator.pop(context);
                                      },
                                      child: Text(
                                        'Cancel',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText1,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                      child: Text(
                        'Delete Massage From All',
                        style: Theme.of(context).textTheme.bodyText2,
                      )),
                ],
              ),
            ),
          );
        },
      );

  Widget buildReceiverImageMassage(MassageModel massageModel, context, index) =>
      InkWell(
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          child: Image(
            image: NetworkImage(massageModel.image),
            width: 150,
            height: 150,
            fit: BoxFit.cover,
          ),
        ),
        onTap: () {
          showDialog(
            barrierDismissible: false, //prevent close
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              title: Text(
                'Delete Massage',
                style: Theme.of(context).textTheme.bodyText1,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor:
                                Theme.of(context).scaffoldBackgroundColor,
                            title: Text(
                              'Delete Massage',
                              style: Theme.of(context).textTheme.bodyText1,
                            ),
                            content: Text(
                              'Are You Sure ?',
                              style: Theme.of(context).textTheme.bodyText2,
                            ),
                            actions: [
                              Row(
                                children: [
                                  Expanded(
                                    child: TextButton(
                                      onPressed: () {
                                        ChatHomeCubit.get(context)
                                            .deleteMassageFromMe(
                                                receiverId:
                                                    receiverProfile!.uId,
                                                massageId:
                                                    ChatHomeCubit.get(context)
                                                        .massagesId[index]);
                                        Navigator.pop(context);
                                        Navigator.pop(context);
                                      },
                                      child: Text(
                                        'Confirm',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText1,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        Navigator.pop(context);
                                      },
                                      child: Text(
                                        'Cancel',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText1,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                      child: Text(
                        'Delete Massage From Me',
                        style: Theme.of(context).textTheme.bodyText2,
                      )),
                  const SizedBox(
                    height: 6,
                  ),
                  TextButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor:
                                Theme.of(context).scaffoldBackgroundColor,
                            title: Text(
                              'Delete Massage',
                              style: Theme.of(context).textTheme.bodyText1,
                            ),
                            content: Text(
                              'Are You Sure ?',
                              style: Theme.of(context).textTheme.bodyText2,
                            ),
                            actions: [
                              Row(
                                children: [
                                  Expanded(
                                    child: TextButton(
                                      onPressed: () {
                                        ChatHomeCubit.get(context)
                                            .deleteMassageFromAll(
                                                receiverId:
                                                    receiverProfile!.uId,
                                                massageId:
                                                    ChatHomeCubit.get(context)
                                                        .massagesId[index]);
                                        Navigator.pop(context);
                                        Navigator.pop(context);
                                      },
                                      child: Text(
                                        'Confirm',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText1,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        Navigator.pop(context);
                                      },
                                      child: Text(
                                        'Cancel',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText1,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                      child: Text(
                        'Delete Massage From All',
                        style: Theme.of(context).textTheme.bodyText2,
                      )),
                ],
              ),
            ),
          );
        },
      );

  Widget buildSenderMassage(MassageModel massageModel, context, index) =>
      InkWell(
        child: Align(
          alignment: AlignmentDirectional.centerEnd,
          child: Row(
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
                    getTime(massageModel.dateTime),
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
                    massageModel.text,
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
                backgroundColor: SharedHelper.get(key: 'theme') == 'Light Theme'
                    ? Colors.white
                    : Theme.of(context).scaffoldBackgroundColor,
                backgroundImage:
                    NetworkImage(ChatHomeCubit.get(context).userProfile!.image),
              ),
            ],
          ),
        ),
        onTap: () {
          showDialog(
            barrierDismissible: false, //prevent close
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              title: Text(
                'Delete Massage',
                style: Theme.of(context).textTheme.bodyText1,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor:
                                SharedHelper.get(key: 'theme') == 'Light Theme'
                                    ? Colors.white
                                    : Theme.of(context).scaffoldBackgroundColor,
                            title: Text(
                              'Delete Massage',
                              style: Theme.of(context).textTheme.bodyText1,
                            ),
                            content: Text(
                              'Are You Sure ?',
                              style: Theme.of(context).textTheme.bodyText2,
                            ),
                            actions: [
                              Row(
                                children: [
                                  Expanded(
                                    child: TextButton(
                                      onPressed: () {
                                        ChatHomeCubit.get(context)
                                            .deleteMassageFromMe(
                                                receiverId:
                                                    receiverProfile!.uId,
                                                massageId:
                                                    ChatHomeCubit.get(context)
                                                        .massagesId[index]);
                                        Navigator.pop(context);
                                        Navigator.pop(context);
                                      },
                                      child: Text(
                                        'Confirm',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText1,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        Navigator.pop(context);
                                      },
                                      child: Text(
                                        'Cancel',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText1,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                      child: Text(
                        'Delete Massage From Me',
                        style: Theme.of(context).textTheme.bodyText2,
                      )),
                  const SizedBox(
                    height: 6,
                  ),
                  TextButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor:
                                SharedHelper.get(key: 'theme') == 'Light Theme'
                                    ? Colors.white
                                    : Theme.of(context).scaffoldBackgroundColor,
                            title: Text(
                              'Delete Massage',
                              style: Theme.of(context).textTheme.bodyText1,
                            ),
                            content: Text(
                              'Are You Sure ?',
                              style: Theme.of(context).textTheme.bodyText2,
                            ),
                            actions: [
                              Row(
                                children: [
                                  Expanded(
                                    child: TextButton(
                                      onPressed: () {
                                        ChatHomeCubit.get(context)
                                            .deleteMassageFromAll(
                                                receiverId:
                                                    receiverProfile!.uId,
                                                massageId:
                                                    ChatHomeCubit.get(context)
                                                        .massagesId[index]);
                                        Navigator.pop(context);
                                        Navigator.pop(context);
                                      },
                                      child: Text(
                                        'Confirm',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText1,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        Navigator.pop(context);
                                      },
                                      child: Text(
                                        'Cancel',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText1,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                      child: Text(
                        'Delete Massage From All',
                        style: Theme.of(context).textTheme.bodyText2,
                      )),
                ],
              ),
            ),
          );
        },
      );

  Widget buildReceiverMassage(MassageModel massageModel, context, index) =>
      InkWell(
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                backgroundImage: NetworkImage(receiverProfile!.image),
              ),
              const SizedBox(
                width: 4,
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
                    massageModel.text,
                    style: Theme.of(context).textTheme.bodyText2,
                    maxLines: 1000,
                    softWrap: true,
                  ),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Align(
                alignment: AlignmentDirectional.bottomEnd,
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(
                    start: 5,
                    end: 5,
                  ),
                  child: Text(
                    getTime(massageModel.dateTime),
                    style: Theme.of(context).textTheme.bodyText2,
                  ),
                ),
              ),
            ],
          ),
        ),
        onTap: () {
          showDialog(
            barrierDismissible: false, //prevent close
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              title: Text(
                'Delete Massage',
                style: Theme.of(context).textTheme.bodyText1,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor:
                                Theme.of(context).scaffoldBackgroundColor,
                            title: Text(
                              'Delete Massage',
                              style: Theme.of(context).textTheme.bodyText1,
                            ),
                            content: Text(
                              'Are You Sure ?',
                              style: Theme.of(context).textTheme.bodyText2,
                            ),
                            actions: [
                              Row(
                                children: [
                                  Expanded(
                                    child: TextButton(
                                      onPressed: () {
                                        ChatHomeCubit.get(context)
                                            .deleteMassageFromMe(
                                                receiverId:
                                                    receiverProfile!.uId,
                                                massageId:
                                                    ChatHomeCubit.get(context)
                                                        .massagesId[index]);
                                        Navigator.pop(context);
                                        Navigator.pop(context);
                                      },
                                      child: Text(
                                        'Confirm',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText1,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        Navigator.pop(context);
                                      },
                                      child: Text(
                                        'Cancel',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText1,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                      child: Text(
                        'Delete Massage From Me',
                        style: Theme.of(context).textTheme.bodyText2,
                      )),
                  const SizedBox(
                    height: 6,
                  ),
                  TextButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor:
                                Theme.of(context).scaffoldBackgroundColor,
                            title: Text(
                              'Delete Massage',
                              style: Theme.of(context).textTheme.bodyText1,
                            ),
                            content: Text(
                              'Are You Sure ?',
                              style: Theme.of(context).textTheme.bodyText2,
                            ),
                            actions: [
                              Row(
                                children: [
                                  Expanded(
                                    child: TextButton(
                                      onPressed: () {
                                        ChatHomeCubit.get(context)
                                            .deleteMassageFromAll(
                                                receiverId:
                                                    receiverProfile!.uId,
                                                massageId:
                                                    ChatHomeCubit.get(context)
                                                        .massagesId[index]);
                                        Navigator.pop(context);
                                        Navigator.pop(context);
                                      },
                                      child: Text(
                                        'Confirm',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText1,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        Navigator.pop(context);
                                      },
                                      child: Text(
                                        'Cancel',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText1,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                      child: Text(
                        'Delete Massage From All',
                        style: Theme.of(context).textTheme.bodyText2,
                      )),
                ],
              ),
            ),
          );
        },
      );

  buildBottom(context, state) => Container(
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
                      ChatHomeCubit.get(context).getChatImage(
                        createdAt: Timestamp.now().toString(),
                        receiverId: receiverProfile!.uId,
                        dateTime: DateTime.now().toString(),
                        text: textController.text,
                      );
                      //  scrollController.jumpTo(scrollController.position.maxScrollExtent);
                      if (receiverProfile!.token != '' ||
                          receiverProfile!.token != null) {
                        DioHelper.postData(
                                token: receiverProfile!.token.token,
                                massage:
                                    "you have massage from${ChatHomeCubit.get(context).userProfile!.name}")
                            .then((value) {})
                            .catchError((onError) {});
                      }
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
                      ChatHomeCubit.get(context).addMassage(
                          createdAt: Timestamp.now().toString(),
                          receiverId: receiverProfile!.uId,
                          text: textController.text,
                          dateTime: DateTime.now().toString());
                      textController.text = '';
                      if (receiverProfile!.token != '' ||
                          receiverProfile!.token != null) {
                        DioHelper.postData(
                                token: receiverProfile!.token.token,
                                massage:
                                    "you have massage from${ChatHomeCubit.get(context).userProfile!.name}")
                            .then((value) {})
                            .catchError((onError) {});
                      }
                      //  scrollController.jumpTo(scrollController.position.maxScrollExtent);
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
      return DateFormat('dd,MM yyyy hh:mm a').format(DateTime.parse(dateTime));
    } else if (differenceDays > 30 && differenceDays <= 365) {
      return DateFormat('dd,MM yyyy hh:mm a')
          .format(DateTime.parse(dateTime)); //'${differenceDays / 30} month';
    } else {
      return DateFormat('dd,MM yyyy hh:mm a')
          .format(DateTime.parse(dateTime)); // '${differenceDays / 365} year';
    }
  }
}
