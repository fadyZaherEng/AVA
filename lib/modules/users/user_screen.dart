import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ava/layout/cubit/cubit.dart';
import 'package:ava/layout/cubit/states.dart';
import 'package:ava/models/user_profile.dart';
import 'package:ava/modules/chat/chat_screen.dart';
import 'package:ava/shared/components/components.dart';
import 'package:ava/shared/network/local/cashe_helper.dart';

class UsersScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      return BlocConsumer<ChatHomeCubit, ChatHomeStates>(
          listener: (context, state) {},
          builder: (context, state) {
            print(ChatHomeCubit.get(context).users.length);
            print(ChatHomeCubit.get(context).usersStatus.length);
            return ConditionalBuilder(
              condition: ChatHomeCubit.get(context).users.isNotEmpty,
              builder: (context) => ListView.separated(
                  itemBuilder: (context, index) => buildItem(
                      context, ChatHomeCubit.get(context).users[index]),
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
                      'Last Seen: ${ChatHomeCubit.get(context).usersStatus[profile.uId]}',
                      style: Theme.of(context).textTheme.bodyText2,
                    )
                ],
              ),
            ],
          ),
        ),
        onTap: () {
          //print(profile.uid);
          navigateToWithReturn(context, ChatScreen(profile));
        },
      );
}
