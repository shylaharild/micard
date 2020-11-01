import 'dart:io';

import 'package:flutter/material.dart';
import 'package:micard/edit_profile.dart';
import 'package:micard/helper/databaseHelper.dart';
import 'package:micard/model/user_model.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  DatabaseHelper helper = DatabaseHelper.instance;

  Future<User> _userProfile;

  File _storedImage;
  User user;

  String _fullName = "", _email = "", _phone = "", _about = "";

  @override
  void initState() {
    _updateProfile();
    super.initState();
  }

  void _updateProfile() {
    setState(() {
      _userProfile = helper.getUserWithId(1);
    });
  }

  void _getUserData(User user) {
    user = user;
    _fullName = user.name;
    _email = user.email;
    _phone = user.phone;
    _about = user.about;
    if (user.image != null && user.image.isNotEmpty) {
      _storedImage = File(user.image);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FutureBuilder(
        future: _userProfile,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            _getUserData(snapshot.data);
          }
          return Scaffold(
            backgroundColor: Colors.teal,
            floatingActionButton: FloatingActionButton(
              backgroundColor: Colors.white,
              child: Icon(
                Icons.edit,
                color: Colors.teal,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditProfile(
                      user: snapshot.data,
                      updateProfile: _updateProfile,
                    ),
                  ),
                );
              },
            ),
            body: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  CircleAvatar(
                    radius: 50.0,
                    backgroundImage: _storedImage != null
                        ? FileImage(_storedImage)
                        : AssetImage('images/angela.jpg'),
                  ),
                  Text(
                    _fullName.isEmpty ? 'Angela Yu' : _fullName,
                    style: TextStyle(
                      fontFamily: 'Pacifico',
                      fontSize: 40.0,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _about.isEmpty ? 'FLUTTER DEVELOPER' : _about,
                    style: TextStyle(
                      fontFamily: 'Source Sans Pro',
                      color: Colors.teal.shade100,
                      fontSize: 20.0,
                      letterSpacing: 2.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    height: 20.0,
                    width: 150.0,
                    child: Divider(
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ),
                  Card(
                      margin: EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 25.0),
                      child: ListTile(
                        leading: Icon(
                          Icons.phone,
                          color: Colors.teal,
                        ),
                        title: Text(
                          _phone.isEmpty ? '+44 123 456 789' : _phone,
                          style: TextStyle(
                            color: Colors.teal.shade900,
                            fontFamily: 'Source Sans Pro',
                            fontSize: 20.0,
                          ),
                        ),
                      )),
                  Card(
                    margin:
                        EdgeInsets.symmetric(vertical: 10.0, horizontal: 25.0),
                    child: ListTile(
                      leading: Icon(
                        Icons.email,
                        color: Colors.teal,
                      ),
                      title: Text(
                        _email.isEmpty ? 'angela@email.com' : _email,
                        style: TextStyle(
                            fontSize: 20.0,
                            color: Colors.teal.shade900,
                            fontFamily: 'Source Sans Pro'),
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
