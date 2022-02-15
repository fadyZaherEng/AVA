// ignore_for_file: must_be_immutable, use_key_in_widget_constructors
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:ava_bishoy/layout/cubit/cubit.dart';
import 'package:ava_bishoy/layout/cubit/states.dart';
import 'package:ava_bishoy/models/file_model.dart';
import 'package:ava_bishoy/models/file_model_user.dart';
import 'package:ava_bishoy/modules/view_lectures/view_lectures.dart';
import 'package:ava_bishoy/shared/components/components.dart';
import 'package:ava_bishoy/shared/network/local/cashe_helper.dart';
import 'package:ava_bishoy/shared/styles/Icon_broken.dart';

class UploadPDFUsingUser extends StatelessWidget {
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
            title: SharedHelper.get(key: 'isAdmin') == false
                ? Text(ChatHomeCubit.get(context).lecturesUsingUser.isNotEmpty
                    ? 'Upload PDF'
                    : 'Waiting To Accept Form Admin')
                : const Text('User Requests'),
          ),
          body: SharedHelper.get(key: 'isAdmin')
              ? ConditionalBuilder(
                  condition:
                      ChatHomeCubit.get(context).lecturesUsingUser.isNotEmpty,
                  builder: (context) => ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, index) => buildItem(
                          context,
                          ChatHomeCubit.get(context).lecturesUsingUser[index],
                          index),
                      separatorBuilder: (context, index) => const SizedBox(
                            height: 15,
                          ),
                      itemCount:
                          ChatHomeCubit.get(context).lecturesUsingUser.length),
                  fallback: (context) => Center(
                    child: Text(
                      'No PDF',
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                  ),
                )
              : null,
          floatingActionButton: SharedHelper.get(key: 'isAdmin') == false
              ? state is GetFileLoadingStates
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
                    )
              : null,
        );
      },
    );
  }

  Widget buildItem(context, FileModelUser model, index) => Padding(
        padding: const EdgeInsets.all(1.0),
        child: InkWell(
          child: Container(
            color: Colors.black,
            width: double.infinity,
            height: SharedHelper.get(key: 'isAdmin') ? 225 : 130,
            margin: const EdgeInsetsDirectional.only(start: 5, end: 5, top: 5),
            child: Column(
              children: [
                if (SharedHelper.get(key: 'isAdmin'))
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
                if (SharedHelper.get(key: 'isAdmin'))
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
                if (SharedHelper.get(key: 'isAdmin'))
                  const SizedBox(
                    height: 10,
                  ),
                if (SharedHelper.get(key: 'isAdmin'))
                  Padding(
                    padding: const EdgeInsets.all(1.0),
                    child: Row(
                      children: [
                        MaterialButton(
                          color: Colors.green,
                          onPressed: () {
                            ChatHomeCubit.get(context).accept(
                                pdfId: ChatHomeCubit.get(context)
                                    .lecturesUsingUserId[index]);
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
                            ChatHomeCubit.get(context).reject(
                                pdfId: ChatHomeCubit.get(context)
                                    .lecturesUsingUserId[index]);
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
                    builder: (context) => LectureViewer(
                        FileModel(name: model.name, link: model.link))));
          },
        ),
      );

  Widget buildBottomSheet(context, state) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Form(
            key: vv,
            child: defaultTextForm(
                key: 'lecture',
                context: context,
                type: TextInputType.text,
                Controller: fileNameController,
                prefixIcon: const Icon(
                  Icons.picture_as_pdf_sharp,
                  color: Colors.pink,
                ),
                text: 'Lecture Name',
                validate: (val) {
                  if (val.toString().isEmpty) {
                    return 'Please Enter Lecture Name';
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
                  ChatHomeCubit.get(context).getPDFUsingUser(
                    context: context,
                    name: fileNameController.text,
                    date: DateTime.now().toString(),
                    username: ChatHomeCubit.get(context).userProfile!.name,
                  );
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
                      'Click To Upload PDF',
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
