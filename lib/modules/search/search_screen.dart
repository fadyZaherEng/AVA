import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ava/layout/cubit/cubit.dart';
import 'package:ava/layout/cubit/states.dart';
import 'package:ava/models/file_model.dart';
import 'package:ava/modules/view_lectures/view_lectures.dart';
import 'package:ava/shared/components/components.dart';
import 'package:ava/shared/network/local/cashe_helper.dart';
import 'package:ava/shared/styles/Icon_broken.dart';

class SearchLectureScreen extends StatelessWidget {

  var scaffoldKey=GlobalKey<ScaffoldState>();

  var fileNameController=TextEditingController();

  var searchController=TextEditingController();
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChatHomeCubit,ChatHomeStates>(
      listener: (context,state){

      },
      builder: (context,state){
        return Scaffold(
          backgroundColor: SharedHelper.get(key: "theme")=='Light Theme'?
          Colors.white:Theme.of(context).scaffoldBackgroundColor,
          body: SafeArea(
            child: Column(
              children:
              [
                defaultTextForm(
                    key: 'search',
                    context: context,
                    type: TextInputType.text,
                    Controller: searchController,
                    prefixIcon: const Icon(
                      IconBroken.Search,
                      color: Colors.pink,
                    ),
                    text: 'Search',
                    validate: (val) {
                      if (val.toString().isEmpty) {
                        return 'Please Enter Lecture Name';
                      }
                    },
                    onSubmitted: () {},
                    onChanged: (val){
                      ChatHomeCubit.get(context).searchLectures(val!);
                    }
                ),
                const SizedBox(height: 20,),
                ConditionalBuilder(
                  condition: ChatHomeCubit.get(context).searchLecture.isNotEmpty,
                  builder:(context)=> Expanded(
                    child: ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        itemBuilder:(context,index)=>buildItem(context,ChatHomeCubit.get(context).searchLecture[index]),
                        separatorBuilder:(context,index)=>const SizedBox(height: 15,),
                        itemCount:ChatHomeCubit.get(context).searchLecture.length),
                  ),
                  fallback:(context)=> Center(child: Text('No Lectures',style: Theme.of(context).textTheme.bodyText1,),),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  Widget buildItem(context,FileModel model)=> InkWell(
    child: Container(
      width:double.infinity,
      height:130,
      margin:const EdgeInsetsDirectional.only(start: 5,end:5,top: 5),
      child:Stack(
        children:
        [
          Image(
            alignment: AlignmentDirectional.topCenter,
            image:SharedHelper.get(key: 'theme')=='Light Theme'? const AssetImage('assets/images/b.PNG'):const AssetImage('assets/images/a.PNG'),
            height: 130,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          Align(
            alignment: AlignmentDirectional.center,
            child: SizedBox(
              child: Card(
                elevation: 10,
                margin:const EdgeInsetsDirectional.only(start: 25,end:25,top: 25,bottom: 25),
                color:  SharedHelper.get(key: "theme")=='Light Theme'?
                Colors.white:Theme.of(context).scaffoldBackgroundColor,
                child: Center(
                  child: Text(model.name,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 3,
                    style:SharedHelper.get(key: "theme")=='Light Theme'? Theme.of(context).textTheme.bodyText1:const TextStyle(fontSize: 18,fontWeight: FontWeight.bold,color: Colors.white),),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
    onTap: ()async{
      Navigator.push(context, MaterialPageRoute(builder: (context)=>LectureViewer(model)));
    },
  );
}
