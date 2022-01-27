abstract class ChatLogInStates{}

class LoginInitialStates  extends ChatLogInStates {}

class LoginChangEyeStates extends ChatLogInStates {}

class LoginToggleStates   extends ChatLogInStates {}

class LoginLoadingStates  extends ChatLogInStates {}
class LoginSuccessStates  extends ChatLogInStates {
  String id;

  LoginSuccessStates(this.id);

}
class LoginErrorStates    extends ChatLogInStates {
  String error;

  LoginErrorStates(this.error);

}

class LoginGetImageLoadingStates  extends ChatLogInStates {}
class LoginGetImageErrorStates  extends ChatLogInStates {}
class LoginGetImageSuccessStates  extends ChatLogInStates {}
