// user model with name profile picture and email
// To parse this JSON data, do
//
//     final user = userFromJson(jsonString);

import 'dart:convert';

MyUser userFromJson(String str) => MyUser.fromJson(json.decode(str));

String userToJson(MyUser data) => json.encode(data.toJson());

class MyUser {
  final String? id;
  final String? image;
  final String? about;
  final String? name;
  final String? email;
  final String? dob;
  final String? mobile;

  MyUser({
    this.id,
    this.image,
    this.about,
    this.name,
    this.email,
    this.dob,
    this.mobile,
  });

  factory MyUser.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return MyUser();
    }
    return MyUser(
      id: json.containsKey("id") ? json["id"] : '',
      image: json["image"],
      about: json["about"],
      name: json["name"],
      email: json["email"],
      dob: json["dob"],
      mobile: json["mobile"],
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "image": image,
        "about": about,
        "name": name,
        "email": email,
        "dob": dob,
        "mobile": mobile,
      };
}
