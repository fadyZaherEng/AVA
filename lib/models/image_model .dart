// ignore_for_file: file_names

class ImageModel {
  dynamic name, link;
  ImageModel({required this.name, required this.link});
  ImageModel.fromJson(Map<String, dynamic>? json) {
    name = json!['name'];
    link = json['link'];
  }
  Map<String, dynamic> toMap() {
    return {'name': name, 'link': link};
  }
}
