class FileModel
{
  dynamic name,link;
  FileModel({required this.name,required this.link});
  FileModel.fromJson(Map<String,dynamic>?json)
  {
    name=json!['name'];
    link=json['link'];
  }
  Map<String,dynamic>toMap()
  {
    return{
      'name':name,
      'link':link
    };
  }
}