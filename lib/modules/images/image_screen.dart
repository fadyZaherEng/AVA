// ignore_for_file: must_be_immutable, use_key_in_widget_constructors

import 'package:ava_bishoy/models/image_model%20.dart';
import 'package:ava_bishoy/modules/show_image/image.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ava_bishoy/layout/cubit/cubit.dart';
import 'package:ava_bishoy/layout/cubit/states.dart';
import 'package:ava_bishoy/shared/network/local/cashe_helper.dart';

class ImageScreen extends StatelessWidget {
  var scaffoldKey = GlobalKey<ScaffoldState>();

  var fileNameController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChatHomeCubit, ChatHomeStates>(
      listener: (context, state) {},
      builder: (context, state) {
        return ConditionalBuilder(
          condition: ChatHomeCubit.get(context).lecturesImages.isNotEmpty,
          builder: (context) => ListView.separated(
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) => buildItem(
                  context, ChatHomeCubit.get(context).lecturesImages[index]),
              separatorBuilder: (context, index) => const SizedBox(
                    height: 15,
                  ),
              itemCount: ChatHomeCubit.get(context).lecturesImages.length),
          fallback: (context) => Center(
            child: Text(
              'No Images',
              style: Theme.of(context).textTheme.bodyText1,
            ),
          ),
        );
      },
    );
  }

  Widget buildItem(context, ImageModel model) => InkWell(
        child: Card(
          elevation: 15,
          shadowColor: Colors.pink,
          child: Container(
            width: double.infinity,
            height: 130,
            margin: const EdgeInsetsDirectional.only(start: 5, end: 5, top: 5),
            child: Stack(
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
                          overflow: TextOverflow.ellipsis,
                          maxLines: 3,
                          style: SharedHelper.get(key: "theme") == 'Light Theme'
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
          ),
        ),
        onTap: () async {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => ZoomImage(model)));
        },
      );
}
