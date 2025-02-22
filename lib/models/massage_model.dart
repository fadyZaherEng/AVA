class MassageModel {

  dynamic text, dateTime, senderId, receiverId, image, createdAt;

  MassageModel(
      {required this.createdAt, required this.text, required this.dateTime, required this.receiverId, this.senderId, required this.image,});

  MassageModel.fromJson(Map<String, dynamic>?json)
  {
    senderId = json!['senderId'];
    receiverId = json['receiverId'];
    text = json['text'];
    dateTime = json['dateTime'];
    image = json['image'];
    createdAt = json['createdAt'];
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'text': text,
      'receiverId': receiverId,
      'dateTime': dateTime,
      'image': image,
      'createdAt': createdAt
    };
  }
}