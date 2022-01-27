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

class PDFScreen extends StatelessWidget {
  var scaffoldKey=GlobalKey<ScaffoldState>();

  var fileNameController=TextEditingController();

  var val=GlobalKey<FormState>();

  PDFScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChatHomeCubit,ChatHomeStates>(
        listener: (context,state){},
        builder: (context,state){
          return Scaffold(
            backgroundColor:  SharedHelper.get(key: "theme")=='Light Theme'?
            Colors.white:Theme.of(context).scaffoldBackgroundColor,
            key: scaffoldKey,
            appBar: AppBar(
              leading: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(IconBroken.Arrow___Left_2)),
              title: const Text('Add Lectures'),
            ),
            body:ConditionalBuilder(
              condition: ChatHomeCubit.get(context).lectures.isNotEmpty,
              builder:(context)=> ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  itemBuilder:(context,index)=>buildItem(context,ChatHomeCubit.get(context).lectures[index]),
                  separatorBuilder:(context,index)=>const SizedBox(height: 15,),
                  itemCount:ChatHomeCubit.get(context).lectures.length),
              fallback:(context)=> Center(child: Text('No Lectures',style: Theme.of(context).textTheme.bodyText1,),),
            ),
            floatingActionButton:state is GetFileLoadingStates?
            const LinearProgressIndicator(valueColor:AlwaysStoppedAnimation<Color>(Colors.pink),)
            :FloatingActionButton(
              onPressed: (){
                scaffoldKey.currentState!.showBottomSheet((context) =>buildBottomSheet(context,state) );
              },
              backgroundColor: SharedHelper.get(key: 'theme')=='Light Theme'?Colors.pink:Colors.white,
              child: const Icon(Icons.add),
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
             height: 130,
             child: Card(
               elevation: 10,
               margin:const EdgeInsetsDirectional.only(start: 25,end:25,top: 25,bottom: 25),
               color:  SharedHelper.get(key: "theme")=='Light Theme'?
               Colors.white:Theme.of(context).scaffoldBackgroundColor,
               child: Center(
                 child: Text(model.name,
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
 Widget buildBottomSheet(context,state) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Form(
        key: val,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children:
          [
            defaultTextForm(
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
            const SizedBox(
              height: 10,
            ),
            OutlinedButton(onPressed: (){
             if(val.currentState!.validate())
               {
                 ChatHomeCubit.get(context).getPDF(
                     name: fileNameController.text,
                   context: context
                 );
                 Navigator.pop(context);
               }

            }, child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children:
                [
                  const Icon(
                    Icons.picture_as_pdf_sharp,
                    color: Colors.pink,
                  ),
                  const SizedBox(width: 7,),
                  Text('Click To Upload PDF',
                    style: Theme.of(context).textTheme.bodyText1,)
                ],
              ),
            )),
          ],
        ),
      ),
    );
 }
}
