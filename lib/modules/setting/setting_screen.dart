import 'dart:io';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ava/layout/cubit/cubit.dart';
import 'package:ava/layout/cubit/states.dart';
import 'package:ava/shared/components/components.dart';
import 'package:ava/shared/network/local/cashe_helper.dart';
import 'package:ava/shared/styles/Icon_broken.dart';

class SettingsScreen extends StatelessWidget {

  var formKey=GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChatHomeCubit,ChatHomeStates>(
        listener: (context,state){

        },
        builder: (context,state){
          ChatHomeCubit.get(context).nameController.text=ChatHomeCubit.get(context).userProfile!.name;
          ChatHomeCubit.get(context).phoneController.text=ChatHomeCubit.get(context).userProfile!.phone;
          return ConditionalBuilder(
            condition: ChatHomeCubit.get(context).userProfile!=null,
            builder:(context)=> SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Form(
                  key: formKey,
                  child: Column(
                    children: [
                      SizedBox(
                        height: 210,
                        child: Stack(
                        //  alignment: Alignment.bottomCenter,
                          children: [
                            Align(
                              alignment: AlignmentDirectional.topCenter,
                              child: Container(
                                color: Theme.of(context).scaffoldBackgroundColor,
                                height: 150,
                              ),
                            ),
                            Align(
                              alignment: AlignmentDirectional.bottomCenter,
                              child: InkWell(
                                child: state is! ChatUpdateProfileDataWaitingImageToFinishUploadStates?
                                Stack(
                                  alignment: Alignment.bottomRight,
                                  children: [
                                    CircleAvatar(
                                      radius: 64,
                                      backgroundColor:Colors.white,
                                      child: CircleAvatar(
                                        backgroundColor:SharedHelper.get(key: 'theme')=='Light Theme'?Colors.white:Theme.of(context).scaffoldBackgroundColor,
                                        backgroundImage: NetworkImage('${ChatHomeCubit.get(context)
                                            .userProfile!.image}'),
                                        child: ChatHomeCubit.get(context).profileImage == null
                                            ? null
                                            : Container(
                                          clipBehavior: Clip.antiAlias,
                                          decoration: const BoxDecoration(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(64)),
                                          ),
                                          child: Image.file(
                                            File(ChatHomeCubit.get(context).profileImage!.path),
                                            width: 128,
                                            height: 128,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        radius: 60,
                                      ),
                                    ),
                                     Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: CircleAvatar(
                                        backgroundColor:SharedHelper.get(key: 'theme')=='Light Theme'?Colors.pink:Theme.of(context).scaffoldBackgroundColor,
                                        radius: 15,
                                        child: const Icon(IconBroken.Camera),
                                      ),
                                    ),
                                  ],
                                ):const Center(child: LinearProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.pink),)),
                                onTap: () {
                                  ChatHomeCubit.get(context).getProfileImage();
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      defaultTextForm(
                          key: 'm',
                          context: context,
                          type: TextInputType.text,
                          Controller: ChatHomeCubit.get(context).nameController,
                          prefixIcon: const Icon(
                            IconBroken.User,
                            color: Colors.pink,
                          ),
                          text: 'Username',
                          validate: (val) {
                            if (val.toString().isEmpty) {
                              return 'Please Enter Your Username';
                            }
                          },
                          onSubmitted: () {}),
                      const SizedBox(
                        height: 20,
                      ),
                      defaultTextForm(
                        key: 'c',
                          context: context,
                          type: TextInputType.phone,
                          Controller: ChatHomeCubit.get(context).phoneController,
                          prefixIcon: const Icon(
                            IconBroken.Call,
                            color: Colors.pink,
                          ),
                          text: 'Phone',
                          validate: (val) {
                            if (val.toString().isEmpty) {
                              return 'Please Enter Your Phone';
                            }
                          },
                          onSubmitted: () {

                          }),
                    ],
                  ),
                ),
              ),
            ),
            fallback:(context)=>const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.pink),),
          );
        },
    );
  }
}
