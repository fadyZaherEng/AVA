class ImageModelUser {
  dynamic name, link, username, date;
  ImageModelUser(
      {required this.name,
      required this.link,
      required this.username,
      required this.date});
  ImageModelUser.fromJson(Map<String, dynamic>? json) {
    name = json!['name'];
    link = json['link'];
    username = json['username'];
    date = json['date'];
  }
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'link': link,
      'username': username,
      'date': date,
    };
  }
}
