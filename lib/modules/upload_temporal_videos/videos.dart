// ignore_for_file: must_be_immutable, use_key_in_widget_constructors
import 'package:ava_bishoy/models/video_model_user.dart';
import 'package:ava_bishoy/modules/show_video/video.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:ava_bishoy/layout/cubit/cubit.dart';
import 'package:ava_bishoy/layout/cubit/states.dart';
import 'package:ava_bishoy/shared/network/local/cashe_helper.dart';
import 'package:ava_bishoy/shared/styles/Icon_broken.dart';

class UploadVideosUsingUser extends StatelessWidget {
  var scaffoldKey = GlobalKey<ScaffoldState>();

  var fileNameController = TextEditingController();

  var vv = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChatHomeCubit, ChatHomeStates>(
      listener: (context, state) {},
      builder: (context, state) {
        return Scaffold(
          backgroundColor: SharedHelper.get(key: "theme") == 'Light Theme'
              ? Colors.white
              : Theme.of(context).scaffoldBackgroundColor,
          key: scaffoldKey,
          appBar: AppBar(
            leading: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(IconBroken.Arrow___Left_2)),
            title: const Text('User Requests'),
          ),
          body: ConditionalBuilder(
            condition: ChatHomeCubit.get(context).VideosUsingUser.isNotEmpty,
            builder: (context) => ListView.separated(
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) => buildItem(context,
                    ChatHomeCubit.get(context).VideosUsingUser[index], index),
                separatorBuilder: (context, index) => const SizedBox(
                      height: 15,
                    ),
                itemCount: ChatHomeCubit.get(context).VideosUsingUser.length),
            fallback: (context) => Center(
              child: Text(
                'No Video',
                style: Theme.of(context).textTheme.bodyText1,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildItem(context, VideoModelUser model, index) => Padding(
        padding: const EdgeInsets.all(1.0),
        child: InkWell(
          child: Container(
            color: Colors.black,
            width: double.infinity,
            height: 225,
            margin: const EdgeInsetsDirectional.only(start: 5, end: 5, top: 5),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(1.0),
                  child: Row(
                    children: [
                      Text(
                        model.username,
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      const Spacer(),
                      Text(
                        getTime(model.date),
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                            color: Colors.white),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Stack(
                  children: [
                    Image(
                      alignment: AlignmentDirectional.topCenter,
                      image: SharedHelper.get(key: 'theme') == 'Light Theme'
                          ? const AssetImage('assets/images/b.PNG')
                          : const AssetImage('assets/images/a.PNG'),
                      height: 130,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                    Align(
                      alignment: AlignmentDirectional.center,
                      child: SizedBox(
                        height: 130,
                        child: Card(
                          elevation: 10,
                          margin: const EdgeInsetsDirectional.only(
                              start: 25, end: 25, top: 25, bottom: 25),
                          color: SharedHelper.get(key: "theme") == 'Light Theme'
                              ? Colors.white
                              : Theme.of(context).scaffoldBackgroundColor,
                          child: Center(
                            child: Text(
                              model.name,
                              style: SharedHelper.get(key: "theme") ==
                                      'Light Theme'
                                  ? Theme.of(context).textTheme.bodyText1
                                  : const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.all(1.0),
                  child: Row(
                    children: [
                      MaterialButton(
                        color: Colors.green,
                        onPressed: () {
                          ChatHomeCubit.get(context).acceptVideoUsingUser(
                              videoId: ChatHomeCubit.get(context)
                                  .VideosUsingUserId[index]);
                        },
                        child: Text(
                          'Accept',
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                      ),
                      const Spacer(),
                      MaterialButton(
                        color: Colors.red,
                        onPressed: () {
                          ChatHomeCubit.get(context).rejectVideoUsingUser(
                              videoId: ChatHomeCubit.get(context)
                                  .VideosUsingUserId[index]);
                        },
                        child: Text(
                          'Reject',
                          style: Theme.of(context).textTheme.bodyText2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          onTap: () async {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => VideoWidget(model.link)));
          },
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
