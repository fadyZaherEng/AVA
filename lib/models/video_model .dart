// ignore_for_file: file_names

class VideoModel {
  dynamic name, link;
  VideoModel({required this.name, required this.link});
  VideoModel.fromJson(Map<String, dynamic>? json) {
    name = json!['name'];
    link = json['link'];
  }
  Map<String, dynamic> toMap() {
    return {'name': name, 'link': link};
  }
}
