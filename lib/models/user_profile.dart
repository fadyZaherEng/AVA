// ignore_for_file: non_constant_identifier_names

class UserProfile {
  dynamic email, name, password, phone, image, uId, token, status, disappear;
  dynamic block, block_final, bio;
  UserProfile({
    required this.uId,
    required this.status,
    required this.token,
    required this.email,
    required this.name,
    required this.password,
    required this.image,
    required this.phone,
    required this.disappear,
    required this.bio,
    required this.block,
    required this.block_final,
  });

  UserProfile.fromJson(Map<String, dynamic>? json) {
    email = json!['email'];
    name = json['name'];
    password = json['password'];
    phone = json['phone'];
    image = json['image'];
    uId = json['uId'];
    token = json['token'];
    status = json['status'];
    disappear = json['disappear'];
    block_final = json['block_final'];
    block = json['block'];
    bio = json['bio'];
  }
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'password': password,
      'phone': phone,
      'image': image,
      'uId': uId,
      'token': token,
      'status': status,
      'disappear': disappear,
      'block_final': block_final,
      'block': block,
      'bio': bio
    };
  }
}
