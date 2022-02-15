// ignore_for_file: must_be_immutable, use_key_in_widget_constructors
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ava_bishoy/layout/cubit/cubit.dart';
import 'package:ava_bishoy/layout/cubit/states.dart';
import 'package:ava_bishoy/models/user_profile.dart';
import 'package:ava_bishoy/shared/network/local/cashe_helper.dart';

class UsersWaitingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChatHomeCubit, ChatHomeStates>(
        listener: (context, state) {},
        builder: (context, state) {
          return Scaffold(
            backgroundColor: SharedHelper.get(key: 'theme') == 'Light Theme'
                ? Colors.white
                : Theme.of(context).scaffoldBackgroundColor,
            appBar: AppBar(
              title: const Text('Users Waiting'),
            ),
            body: ConditionalBuilder(
              condition: ChatHomeCubit.get(context).usersWaiting.isNotEmpty,
              builder: (context) => ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) => buildItem(
                      context, ChatHomeCubit.get(context).usersWaiting[index]),
                  separatorBuilder: (context, index) => const SizedBox(
                        height: 15,
                      ),
                  itemCount: ChatHomeCubit.get(context).usersWaiting.length),
              fallback: (context) => Center(
                  child: Text('No Requests',
                      style: Theme.of(context).textTheme.bodyText1)),
            ),
          );
        });
  }

  Widget buildItem(context, UserProfile profile) {
    return Card(
      margin: const EdgeInsetsDirectional.all(15),
      elevation: 15,
      shadowColor: Colors.pink,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 35,
                  backgroundColor:
                      SharedHelper.get(key: 'theme') == 'Light Theme'
                          ? Colors.white
                          : Theme.of(context).scaffoldBackgroundColor,
                  backgroundImage: NetworkImage(profile.image),
                ),
                const Spacer(),
                Column(
                  children: [
                    Text(
                      profile.name,
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Text(
                      profile.phone,
                      style: Theme.of(context).textTheme.bodyText2,
                    )
                  ],
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MaterialButton(
                    onPressed: () {
                      ChatHomeCubit.get(context).acceptAccount(profile);
                    },
                    child: const Text(
                      'Accept',
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
                    onPressed: () {
                      ChatHomeCubit.get(context)
                          .rejectAccount(profile, context);
                    },
                    child: const Text('Reject',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                    color: Colors.red,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
