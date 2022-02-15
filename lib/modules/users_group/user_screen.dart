// ignore_for_file: must_be_immutable, use_key_in_widget_constructors, avoid_print
import 'package:ava_bishoy/modules/show_user_info/setting_screen.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ava_bishoy/layout/cubit/cubit.dart';
import 'package:ava_bishoy/layout/cubit/states.dart';
import 'package:ava_bishoy/models/user_profile.dart';
import 'package:ava_bishoy/shared/components/components.dart';
import 'package:ava_bishoy/shared/network/local/cashe_helper.dart';

class UsersGroupScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      return BlocConsumer<ChatHomeCubit, ChatHomeStates>(
          listener: (context, state) {
          },
          builder: (context, state) {
            print(ChatHomeCubit.get(context).users.length);
            print(ChatHomeCubit.get(context).usersStatus.length);
            return Scaffold(
              backgroundColor: SharedHelper.get(key: "theme") == 'Light Theme'
                  ? Colors.white
                  : Theme.of(context).scaffoldBackgroundColor,
              body: SafeArea(
                child: ConditionalBuilder(
                  condition: ChatHomeCubit.get(context).users.isNotEmpty,
                  builder: (context) => ListView.separated(
                      itemBuilder: (context, index) => buildItem(
                          context, ChatHomeCubit.get(context).users.elementAt(index)),
                      separatorBuilder: (context, index) => Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Container(
                              height: 1,
                              width: double.infinity,
                              color: Colors.grey[300],
                            ),
                          ),
                      itemCount: ChatHomeCubit.get(context).users.length),
                  fallback: (context) =>
                      const Center(child: CircularProgressIndicator()),
                ),
              ),
            );
          });
    });
  }

  Widget buildItem(context, UserProfile profile) => InkWell(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Stack(
                alignment: AlignmentDirectional.bottomEnd,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor:
                        SharedHelper.get(key: 'theme') == 'Light Theme'
                            ? Colors.white
                            : Theme.of(context).scaffoldBackgroundColor,
                    backgroundImage: NetworkImage(profile.image),
                  ),
                  if (ChatHomeCubit.get(context).usersStatus[profile.uId] ==
                          'Online' &&
                      ChatHomeCubit.get(context).usersStatus[profile.uId] !=
                          null)
                    const CircleAvatar(
                      radius: 6,
                      backgroundColor: Colors.green,
                    ),
                ],
              ),
              if (profile.block) const Icon(Icons.block,color: Colors.red,),
              const SizedBox(
                width: 20,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile.name,
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                  const SizedBox(
                    height: 7,
                  ),
                  if (ChatHomeCubit.get(context).usersStatus[profile.uId] !=
                          'Online' &&
                      ChatHomeCubit.get(context).usersStatus[profile.uId] !=
                          null)
                    Text(
                      'Last Seen: ${ChatHomeCubit.get(context).usersStatus[profile.uId]!.split(' ')[0]} ${ChatHomeCubit.get(context).usersStatus[profile.uId]!.split(' ')[1]}',
                      style: Theme.of(context).textTheme.bodyText2,
                    )
                ],
              ),
            ],
          ),
        ),
        onTap: () {
          //show user info in new screen
          navigateToWithReturn(context, ShowUserInfo(profile: profile));
        },
        onLongPress: () {
          if (SharedHelper.get(key: 'isAdmin')) {
            showDialog(
              barrierDismissible: false, //prevent close
              context: context,
              builder: (context) => AlertDialog(
                backgroundColor: SharedHelper.get(key: "theme") == 'Light Theme'
                    ? Colors.white
                    : Theme.of(context).scaffoldBackgroundColor,
                title: Text(
                  'Change User Status',
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
                              backgroundColor: SharedHelper.get(key: "theme") ==
                                      'Light Theme'
                                  ? Colors.white
                                  : Theme.of(context).scaffoldBackgroundColor,
                              title: Text(
                                'Block',
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
                                              .blockUserFromChat(
                                                  profile: profile);
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
                          'Block From Chat',
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
                              backgroundColor: SharedHelper.get(key: "theme") ==
                                      'Light Theme'
                                  ? Colors.white
                                  : Theme.of(context).scaffoldBackgroundColor,
                              title: Text(
                                'Block',
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
                                              .blockUserFromApp(
                                                  profile: profile);
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
                          'Bloc From App',
                          style: Theme.of(context).textTheme.bodyText2,
                        )),
                  ],
                ),
              ),
            );
          }
        },
      );
  String getTime(dateTime) {
    print(dateTime);
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
