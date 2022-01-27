class UserProfile
{
  dynamic email,name,password,phone,image,uId,token,status;

  UserProfile({required this.uId,required this.status,required this.token,required this.email,required this.name,required this.password,required this.image,required this.phone});

  UserProfile.fromJson(Map<String,dynamic>?json)
  {
    email=json!['email'];
    name=json['name'];
    password=json['password'];
    phone=json['phone'];
    image=json['image'];
    uId=json['uId'];
    token=json['token'];
    status=json['status'];
  }
  Map<String,dynamic> toMap()
  {
    return {
      'email':email,
      'name':name,
      'password':password,
      'phone':phone,
      'image':image,
      'uId':uId,
      'token':token,
      'status':status,
    };
  }
}