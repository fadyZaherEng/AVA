class MassageModelGroup {
  dynamic text, dateTime, senderId, image, createdAt, userImage, name;
  MassageModelGroup(
      {required this.name,
      required this.userImage,
      required this.createdAt,
      required this.text,
      required this.dateTime,
      required this.senderId,
      required this.image});

  MassageModelGroup.fromJson(Map<String, dynamic>? json) {
    senderId = json!['senderId'];
    text = json['text'];
    dateTime = json['dateTime'];
    image = json['image'];
    createdAt = json['createdAt'];
    userImage = json['userImage'];
    name = json['name'];
  }
  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'text': text,
      'dateTime': dateTime,
      'image': image,
      'createdAt': createdAt,
      'userImage': userImage,
      'name': name
    };
  }
}
