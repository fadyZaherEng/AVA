class VideoModelUser {
  dynamic name, link, username, date;
  VideoModelUser(
      {required this.name,
      required this.link,
      required this.username,
      required this.date});
  VideoModelUser.fromJson(Map<String, dynamic>? json) {
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
