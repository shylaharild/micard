import 'package:flutter/foundation.dart';

class User {
  int id;
  String name;
  String email;
  String phone;
  String about;
  String image;

  User({
    this.id,
    @required this.name,
    @required this.email,
    @required this.phone,
    @required this.image,
    this.about,
  });

  User.withId({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.image,
    this.about,
  });

  Map<String, dynamic> toMap() {
    final map = Map<String, dynamic>();
    if (id != null) {
      map['id'] = id;
    }
    map['name'] = name;
    map['email'] = email;
    map['phone'] = phone;
    map['image'] = image;
    map['about'] = about;
    return map;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'image': image,
        'about': about,
      };

  User.fromMap(dynamic obj) {
    this.id = obj['id'];
    this.name = obj['name'];
    this.email = obj['email'];
    this.phone = obj['phone'];
    this.about = obj['about'];
    this.image = obj['image'];
  }

  factory User.fromMapToJson(Map<String, dynamic> json) => new User(
        id: json['id'],
        name: json['name'],
        email: json['email'],
        phone: json['phone'],
        about: json['about'],
        image: json['image'],
      );

  // Getters
  int get userId => id;
  String get userName => name;
  String get userEmail => email;
  String get userPhone => phone;
  String get userAbout => about;
  String get userImage => image;
}
