import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:micard/helper/databaseHelper.dart';
import 'package:micard/model/user_model.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as syspaths;

class EditProfile extends StatefulWidget {
  final Function updateProfile;
  final User user;

  const EditProfile({this.user, this.updateProfile});
  @override
  _ProfileDialogState createState() => _ProfileDialogState();
}

class _ProfileDialogState extends State<EditProfile> {
  DatabaseHelper helper = DatabaseHelper.instance;
  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _aboutController = TextEditingController();
  File _storedImage, _pickedImage;
  final _formKey = GlobalKey<FormState>();
  bool error = false;
  String _fullName = "", _email = "", _phone = "", _about = "", image = "";

  @override
  void initState() {
    super.initState();
    if (widget.user != null) {
      print("profile initState ${widget.user.image}");
      _nameController.text = widget.user.name;
      _emailController.text = widget.user.email;
      _phoneController.text = widget.user.phone;
      _aboutController.text = widget.user.about;
      _storedImage =
          File(widget.user.image) != null ? File(widget.user.image) : "";
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _aboutController.dispose();
    super.dispose();
  }

  void _selectImage(File pickedImage, String fileString) {
    print("profile _selectImage pickedImage $pickedImage");
    print("profile _selectImage fileString $fileString");
    _pickedImage = pickedImage;
    image = fileString;
  }

  void _saveProfileData() {
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _aboutController.text.isEmpty) {
      return;
    }
    if (_storedImage == null) {
      helper.saveUser(
        User(
          name: _nameController.text,
          email: _emailController.text,
          phone: _phoneController.text,
          about: _aboutController.text,
          image: "",
        ),
      );
    } else {
      print("profile _saveProfileData _storedImage.path ${_storedImage.path}");
      helper.saveUser(
        User(
            name: _nameController.text,
            email: _emailController.text,
            phone: _phoneController.text,
            about: _aboutController.text,
            image: _storedImage.path),
      );
    }
  }

  void _submit() {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      User user;
      if (_storedImage != null) {
        setState(() {
          error = false;
        });

        user = User(
          name: _fullName.trim(),
          email: _email.trim(),
          phone: _phone.trim(),
          about: _about.trim(),
          image: _storedImage.path,
        );
        if (widget.user == null) {
          _saveProfileData();
        } else {
          user.id = 1;
          user.name = _nameController.text;
          user.email = _emailController.text;
          user.phone = _phoneController.text;
          user.about = _aboutController.text;
          user.image = _pickedImage.path;
          DatabaseHelper.instance.updateUser(user);
        }
        widget.updateProfile();
        Navigator.of(context).pop();
      } else {
        setState(() {
          error = true;
        });
      }
    }
  }

  Widget _getNotificationMessage() {
    return Card(
      color: Colors.red,
      margin: EdgeInsets.all(20),
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Row(
          children: <Widget>[
            Container(
              child: Expanded(
                child: Text(
                  "Image cannot be empty",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Source Sans Pro',
                    fontWeight: FontWeight.w600,
                    fontSize: 24,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _takePicture(ImageSource source) async {
    print("in get Camera Icon _takePicture");
    File imageFile;
    final appDir = await syspaths.getApplicationDocumentsDirectory();

    print("in get Camera Icon appDir is $appDir");

    if (source == ImageSource.camera) {
      PickedFile cameraPickedFile = await ImagePicker().getImage(
        source: source,
        maxWidth: 600,
      );
      imageFile = File(cameraPickedFile.path);
    } else if (source == ImageSource.gallery) {
      PickedFile galleryPickedFile = await ImagePicker().getImage(
        source: ImageSource.gallery,
        maxWidth: 200,
        maxHeight: 200,
      );
      imageFile = File(galleryPickedFile.path);
    }

    if (imageFile == null) {
      return;
    }

    setState(() {
      _storedImage = imageFile;
      error = false;
    });
    print("profile appDir $appDir");
    final fileName = path.basename(imageFile.path);
    print("profile fileName $fileName");

    final savedImage = await imageFile.copy('${appDir.path}/$fileName');
    print("profile savedImage $savedImage");
    final base64Encoded = base64Encode(savedImage.readAsBytesSync());
    print("profile base64Encoded $base64Encoded");
    _selectImage(savedImage, base64Encoded);
  }

  TextInputType _getKeyboardType(String from) {
    if (from == "Email Address") {
      return TextInputType.emailAddress;
    } else if (from == "Phone Number") {
      return TextInputType.phone;
    } else if (from == "About") {
      return TextInputType.multiline;
    } else {
      return TextInputType.text;
    }
  }

  Widget buildTextField(
      {String name,
      String hint,
      TextEditingController controller,
      String field}) {
    return Card(
      color: Colors.teal[400],
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 5),
              child: Text(
                name,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Source Sans Pro',
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: controller,
                keyboardType: _getKeyboardType(name),
                cursorColor: Colors.white,
                decoration: InputDecoration(
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.teal[400]),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  hintText: hint,
                  hintStyle: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Source Sans Pro',
                    fontWeight: FontWeight.normal,
                    fontSize: 22,
                  ),
                ),
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Source Sans Pro',
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
                validator: (input) =>
                    input.trim().isEmpty ? "$name cannot be empty" : null,
                onSaved: (input) => name = input,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    _getProfilePicture() {
      return Container(
        height: 100.0,
        width: 100.0,
        decoration: BoxDecoration(shape: BoxShape.circle),
        child: CircleAvatar(
          radius: 100.0,
          backgroundImage: _storedImage != null
              ? FileImage(_storedImage)
              : AssetImage('images/angela.jpg'),
        ),
      );
    }

    _getCameraIcon() {
      print("in get Camera Icon");
      return Positioned(
        bottom: 0.0,
        right: 0.0,
        child: GestureDetector(
          child: Container(
            width: 40.0,
            height: 30.0,
            decoration: BoxDecoration(
              color: Colors.teal[400],
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: Icon(
              Icons.edit,
              color: Colors.white,
              size: 20.0,
            ),
          ),
          onTap: () {
            print("tapping Camera Icon");
            _takePicture(ImageSource.gallery);
          },
        ),
      );
    }

    return Container(
      width: 110.0,
      height: 110.0,
      child: Stack(
        children: [
          _getProfilePicture(),
          _getCameraIcon(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[900],
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: Text('Edit Profile'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _submit();
        },
        backgroundColor: Colors.teal[400],
        child: Icon(
          Icons.save_alt,
          color: Colors.white,
        ),
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
            }
          },
          child: Form(
            key: _formKey,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              alignment: Alignment.topCenter,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      _buildAvatar(),
                      SizedBox(
                        height: 20.0,
                      ),
                      (error) ? _getNotificationMessage() : Container(),
                      buildTextField(
                          name: 'Name',
                          hint: 'Name Hint',
                          controller: _nameController,
                          field: _fullName),
                      buildTextField(
                          name: 'Email Address',
                          hint: 'Email Hint',
                          controller: _emailController,
                          field: _email),
                      buildTextField(
                          name: 'Phone Number',
                          hint: '0123456789',
                          controller: _phoneController,
                          field: _phone),
                      buildTextField(
                          name: 'About',
                          hint: 'About Hint',
                          controller: _aboutController,
                          field: _about),
                      SizedBox(
                        height: 50.0,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
