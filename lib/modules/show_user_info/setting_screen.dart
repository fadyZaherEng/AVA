// ignore_for_file: must_be_immutable, use_key_in_widget_constructors

import 'package:ava_bishoy/models/user_profile.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ava_bishoy/layout/cubit/cubit.dart';
import 'package:ava_bishoy/layout/cubit/states.dart';
import 'package:ava_bishoy/shared/network/local/cashe_helper.dart';
import 'package:ava_bishoy/shared/styles/Icon_broken.dart';

class ShowUserInfo extends StatelessWidget {
  var formKey = GlobalKey<FormState>();
  UserProfile? profile;
  ShowUserInfo({required this.profile});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChatHomeCubit, ChatHomeStates>(
      listener: (context, state) {},
      builder: (context, state) {
        return Scaffold(
          backgroundColor: SharedHelper.get(key: "theme") == 'Light Theme'
              ? Colors.white
              : Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            title: const Text(
              'Ava Bishoy Scout Group',
            ),
            leading: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(IconBroken.Arrow___Left_2)),
          ),
          body: ConditionalBuilder(
            condition: profile != null,
            builder: (context) => SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(
                        height: 40,
                      ),
                      CircleAvatar(
                        radius: 45,
                        backgroundColor:
                            SharedHelper.get(key: 'theme') == 'Light Theme'
                                ? Colors.white
                                : Theme.of(context).scaffoldBackgroundColor,
                        backgroundImage: NetworkImage(profile!.image),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        profile!.bio,
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                      const SizedBox(
                        height: 60,
                      ),
                      Text(
                        profile!.name,
                        style: Theme.of(context).textTheme.bodyText2,
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Text(
                        profile!.email,
                        style: Theme.of(context).textTheme.bodyText2,
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      if (profile!.disappear)
                        Text(
                          profile!.phone,
                          style: Theme.of(context).textTheme.bodyText2,
                        ),
                    ],
                  ),
                ),
              ),
            ),
            fallback: (context) => const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.pink),
            ),
          ),
        );
      },
    );
  }
}
