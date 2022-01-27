import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ava/modules/login/cubit/cubit.dart';
import 'package:ava/modules/login/cubit/states.dart';
import 'package:ava/shared/components/components.dart';
import 'package:ava/shared/network/local/cashe_helper.dart';

class LogInScreen extends StatelessWidget {
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  var nameController = TextEditingController();
  var phoneController = TextEditingController();
  var loginKey = GlobalKey<FormState>();
  var scafoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChatLoginCubit(),
      child: BlocConsumer<ChatLoginCubit, ChatLogInStates>(
        listener: (context, state) {
        },
        builder: (context, state) {
          return Scaffold(
            key: scafoldKey,
            body: Center(
              child: Card(
                margin: const EdgeInsetsDirectional.all(15),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Form(
                    key: loginKey,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (ChatLoginCubit.get(context).logInMaterialButton !=
                              'Login')
                            InkWell(
                              child: CircleAvatar(
                                radius: 80,
                                backgroundColor: Colors.pink,
                                child: ChatLoginCubit.get(context)
                                            .profileImageUrl ==
                                        null
                                    ? state is LoginGetImageLoadingStates
                                        ? const Center(
                                            child: CircularProgressIndicator(
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    Colors.white),
                                          ))
                                        : const Center(
                                            child: Text(
                                              'Select Image',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.normal,
                                                  fontSize: 16,
                                                  color: Colors.white),
                                            ),
                                          )
                                    : CircleAvatar(
                                        radius: 80,
                                        backgroundColor: Colors.white,
                                        backgroundImage: NetworkImage(
                                            ChatLoginCubit.get(context)
                                                .profileImageUrl!),
                                      ),
                              ),
                              onTap: () {
                                ChatLoginCubit.get(context).getProfileImage();
                              },
                            ),
                          if (ChatLoginCubit.get(context).logInMaterialButton !=
                              'Login')
                            const SizedBox(
                              height: 30,
                            ),
                          defaultTextForm(
                              key: 'email',
                              context: context,
                              type: TextInputType.emailAddress,
                              Controller: emailController,
                              prefixIcon: const Icon(
                                Icons.email,
                                color: Colors.pink,
                              ),
                              text: 'Email',
                              validate: (val) {
                                if (val.toString().isEmpty) {
                                  return 'Please Enter Your Email Address';
                                }
                              },
                              onSubmitted: () {}),
                          const SizedBox(
                            height: 10,
                          ),
                          if (ChatLoginCubit.get(context).logInMaterialButton !=
                              'Login')
                            defaultTextForm(
                                key: 'phone',
                                context: context,
                                type: TextInputType.phone,
                                Controller: phoneController,
                                prefixIcon: const Icon(
                                  Icons.phone,
                                  color: Colors.pink,
                                ),

                                text: 'Phone',
                                validate: (val) {
                                  if (val.toString().isEmpty) {
                                    return 'Please Enter Your Phone';
                                  }
                                },
                                onSubmitted: () {}),
                          if (ChatLoginCubit.get(context).logInMaterialButton !=
                              'Login')
                            const SizedBox(
                              height: 10,
                            ),
                          if (ChatLoginCubit.get(context).logInMaterialButton !=
                              'Login')
                            defaultTextForm(
                                key: 'name',
                                context: context,
                                type: TextInputType.text,
                                Controller: nameController,
                                prefixIcon: const Icon(
                                  Icons.person,
                                  color: Colors.pink,
                                ),

                                text: 'Username',
                                validate: (val) {
                                  if (val.toString().isEmpty) {
                                    return 'Please Enter Your Name';
                                  }
                                },
                                onSubmitted: () {}),
                          if (ChatLoginCubit.get(context).logInMaterialButton !=
                              'Login')
                            const SizedBox(
                              height: 10,
                            ),
                          defaultTextForm(
                            key: 'password',
                            context: context,
                            type: TextInputType.visiblePassword,
                            Controller: passwordController,
                            prefixIcon: const Icon(
                              Icons.lock,
                              color: Colors.pink,
                            ),
                            suffixIcon: IconButton(
                                onPressed: () {
                                  ChatLoginCubit.get(context)
                                      .changeVisibilityOfEye();
                                },
                                icon: ChatLoginCubit.get(context).suffixIcon),
                            text: 'Password',
                            validate: (val) {
                              if (val.toString().isEmpty) {
                                return 'Password is Very Short';
                              }
                            },
                            obscure: ChatLoginCubit.get(context).obscure,
                            onSubmitted: () {},
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          Center(
                            child: state is LoginGetImageLoadingStates
                                ? const Text(
                                    'Waiting...',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.pink),
                                  )
                                : Container(
                                    width: 100,
                                    decoration: BoxDecoration(
                                        color: Colors.pink,
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    child: state is LoginLoadingStates
                                        ? const CircularProgressIndicator(
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    Colors.white),
                                          )
                                        : MaterialButton(
                                            onPressed: () {
                                              FocusScope.of(context).unfocus();
                                              if (loginKey.currentState!.validate() && ChatLoginCubit.get(context).logInMaterialButton == 'Login') {
                                                ChatLoginCubit.get(context)
                                                    .LogIn(
                                                        email: emailController
                                                            .text
                                                            .trim(),
                                                        password:
                                                            passwordController
                                                                .text
                                                                .trim(),
                                                        context: context);
                                              } else {
                                                if (loginKey.currentState!.validate() && ChatLoginCubit.get(context).profileImageUrl != null) {
                                                  ChatLoginCubit.get(
                                                          context)
                                                      .signUp(
                                                          email:
                                                              emailController.text
                                                                  .trim(),
                                                          password:
                                                              passwordController
                                                                  .text
                                                                  .trim(),
                                                          name:
                                                              nameController.text
                                                                  .trim(),
                                                          phone:
                                                              phoneController
                                                                  .text
                                                                  .trim(),
                                                          image: ChatLoginCubit
                                                                  .get(context)
                                                              .profileImageUrl!,
                                                          context: context);
                                                } else {
                                                  showToast(message: 'Please Select Your Profile Image', state: ToastState.WARNING);
                                                }
                                              }
                                              SharedHelper.save(value: true, key: 'signIn');
                                            },
                                            child: Text(
                                              ChatLoginCubit.get(context)
                                                  .logInMaterialButton,
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                  ),
                          ),
                          TextButton(
                            onPressed: () {
                              ChatLoginCubit.get(context).logInToggle();
                            },
                            child: Text(
                              ChatLoginCubit.get(context).logInTextButton,
                              style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.normal),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
