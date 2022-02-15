// ignore_for_file: must_be_immutable, use_key_in_widget_constructors, sized_box_for_whitespace, avoid_unnecessary_containers
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:ava_bishoy/layout/cubit/cubit.dart';
import 'package:ava_bishoy/layout/cubit/states.dart';
import 'package:ava_bishoy/shared/components/components.dart';
import 'package:ava_bishoy/shared/network/local/cashe_helper.dart';
import 'package:ava_bishoy/shared/styles/Icon_broken.dart';
import 'package:liquid_progress_indicator/liquid_progress_indicator.dart';

class UploadVideos extends StatelessWidget {
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
                title: const Text('Upload Video Waiting')),
            body: Container(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (state is GetVedioLoadingStates)
                      Container(
                        height: 200.0,
                        width: 200.0,
                        child: LiquidCircularProgressIndicator(
                          value: ChatHomeCubit.get(context).progress / 100,
                          valueColor:
                              const AlwaysStoppedAnimation(Colors.pinkAccent),
                          backgroundColor: Colors.white,
                          direction: Axis.vertical,
                          center: Text(
                            "${ChatHomeCubit.get(context).progress}%",
                            style: GoogleFonts.poppins(
                                color: Colors.black87, fontSize: 25.0),
                          ),
                        ),
                      )
                  ],
                ),
              ),
            ),
            floatingActionButton: state is GetVedioLoadingStates
                ? const LinearProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>((Colors.pink)),
                  )
                : FloatingActionButton(
                    onPressed: () {
                      scaffoldKey.currentState!.showBottomSheet(
                          (context) => buildBottomSheet(context, state));
                    },
                    backgroundColor:
                        SharedHelper.get(key: 'theme') == 'Light Theme'
                            ? Colors.pink
                            : Colors.white,
                    child: const Icon(Icons.add),
                  ));
      },
    );
  }

  Widget buildBottomSheet(context, state) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Form(
            key: vv,
            child: defaultTextForm(
                key: 'video',
                context: context,
                type: TextInputType.text,
                Controller: fileNameController,
                prefixIcon: const Icon(
                  Icons.picture_as_pdf_sharp,
                  color: Colors.pink,
                ),
                text: 'Video Name',
                validate: (val) {
                  if (val.toString().isEmpty) {
                    return 'Please Enter Video Name';
                  }
                },
                onSubmitted: () {}),
          ),
          const SizedBox(
            height: 10,
          ),
          OutlinedButton(
              onPressed: () {
                if (vv.currentState!.validate()) {
                  if (SharedHelper.get(key: 'isAdmin')) {
                    ChatHomeCubit.get(context).getVideo(
                      context: context,
                      name: fileNameController.text,
                    );
                  } else {
                    ChatHomeCubit.get(context).getVideoUsingUser(
                      context: context,
                      name: fileNameController.text,
                      date: DateTime.now().toString(),
                      username: ChatHomeCubit.get(context).userProfile!.name,
                    );
                  }
                  Navigator.pop(context);
                }
              },
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.picture_as_pdf_sharp,
                      color: Colors.pink,
                    ),
                    const SizedBox(
                      width: 7,
                    ),
                    Text(
                      'Click To Upload Video',
                      style: Theme.of(context).textTheme.bodyText1,
                    )
                  ],
                ),
              )),
        ],
      ),
    );
  }

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
