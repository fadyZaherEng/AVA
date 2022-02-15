abstract class ChatHomeStates {}

class ChatHomeInitialStates extends ChatHomeStates {}

class ChatHomeChangeBottomNavStates extends ChatHomeStates {}

class ChatHomeGetUserProfileLoadingStates extends ChatHomeStates {}

class ChatHomeGetUserProfileSuccessStates extends ChatHomeStates {}

class ChatHomeGetUserProfileErrorStates extends ChatHomeStates {}

class ChatUpdateProfileDataWaitingImageToFinishUploadStates
    extends ChatHomeStates {}

class ChatUpdateProfileDataWaitingImageToFinishUploadErrorStates
    extends ChatHomeStates {}

class ChatUpdateProfileDataWaitingImageToFinishSuccessStates
    extends ChatHomeStates {}

class ChatUpdateProfileDataWaitingImageToFinishErrorStates
    extends ChatHomeStates {}

class ChatGetAllUsersLoadingStates extends ChatHomeStates {}

class ChatGetAllUsersSuccessStates extends ChatHomeStates {}

class ChatGetAllUsersErrorStates extends ChatHomeStates {}

class SocialGetUserStatusSuccessStates extends ChatHomeStates {}

class SocialGetUserStatusErrorStates extends ChatHomeStates {}

class ChatEditProfileErrorStates extends ChatHomeStates {}

class ChatEditProfileSuccessStates extends ChatHomeStates {}

//add massages
class SocialAddMassageLoadingStates extends ChatHomeStates {}

class SocialAddMassageSuccessStates extends ChatHomeStates {}

class SocialAddMassageErrorStates extends ChatHomeStates {}

class SocialDeleteMassageSuccessStates extends ChatHomeStates {}

class SocialDeleteMassageErrorStates extends ChatHomeStates {}

class ChatGetMassageErrorStates extends ChatHomeStates {}

class ChatGetMassageSuccessStates extends ChatHomeStates {}

//image massage
class ChatUploadImageLoadingSuccessStates extends ChatHomeStates {}

class ChatUploadImageLoadingErrorStates extends ChatHomeStates {}

class SocialSChangeModeStates extends ChatHomeStates {}

//files
class GetFileLoadingStates extends ChatHomeStates {}

class GetFileSuccessStates extends ChatHomeStates {}

class GetFileErrorStates extends ChatHomeStates {}

class ViewFileLoadingStates extends ChatHomeStates {}

class ViewFileSuccessStates extends ChatHomeStates {}

class ViewFileErrorStates extends ChatHomeStates {}

//files user reject
class RejectFileLoadingStates extends ChatHomeStates {}

class RejectFileSuccessStates extends ChatHomeStates {}

class RejectFileErrorStates extends ChatHomeStates {}

//files user accept
class AcceptFileLoadingStates extends ChatHomeStates {}

class AcceptFileSuccessStates extends ChatHomeStates {}

class AcceptFileErrorStates extends ChatHomeStates {}

//get user waiting
class GetUserWaitingLoadingStates extends ChatHomeStates {}

class GetUserWaitingSuccessStates extends ChatHomeStates {}

class GetUserWaitingErrorStates extends ChatHomeStates {}

//get user accept account waiting
class GetUserAcceptWaitingLoadingStates extends ChatHomeStates {}

class GetUserAcceptWaitingSuccessStates extends ChatHomeStates {}

class GetUserAcceptWaitingErrorStates extends ChatHomeStates {}

//get user reject account waiting
class GetUserRejectWaitingLoadingStates extends ChatHomeStates {}

class GetUserRejectWaitingSuccessStates extends ChatHomeStates {}

class GetUserRejectWaitingErrorStates extends ChatHomeStates {}

class PhoneState extends ChatHomeStates {}

class GetVedioLoadingStates extends ChatHomeStates {}

class GetVedioSuccessStates extends ChatHomeStates {}

class GetVedioErrorStates extends ChatHomeStates {}

class GetImageLoadingStates extends ChatHomeStates {}

class GetImageSuccessStates extends ChatHomeStates {}

class GetImageErrorStates extends ChatHomeStates {}

class ViewVedioLoadingStates extends ChatHomeStates {}

class ViewVedioSuccessStates extends ChatHomeStates {}

class ViewVedioErrorStates extends ChatHomeStates {}

class ViewImageLoadingStates extends ChatHomeStates {}

class ViewImageSuccessStates extends ChatHomeStates {}

class ViewImageErrorStates extends ChatHomeStates {}
