import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:skinspectra/auth/firebase_auth_helper.dart';
import 'package:skinspectra/auth/validator.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _registerFormKey = GlobalKey<FormState>();

  final _nameTextController = TextEditingController();
  final _emailTextController = TextEditingController();
  final _passwordTextController = TextEditingController();
  final _mobileTextController = TextEditingController();
  final _dobTextController = TextEditingController();
  DateTime? _dob; // Added for date of birth

  final _focusName = FocusNode();
  final _focusEmail = FocusNode();
  final _focusPassword = FocusNode();
  final _focusMobile = FocusNode();
  final _focusDob = FocusNode();

  bool _isProcessing = false;

  String? _profilePicturePath;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _focusName.unfocus();
        _focusEmail.unfocus();
        _focusPassword.unfocus();
        _focusMobile.unfocus();
        _focusDob.unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Create Account'),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Profile picture selection
                  Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Color(0xFF328B8C),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        height: 150,
                        width: 150,
                        child: _profilePicturePath == null
                            ? const Icon(
                                Icons.person,
                                size: 100,
                                color: Colors.white,
                              )
                            : CircleAvatar(
                                radius: 50,
                                backgroundImage:
                                    FileImage(File(_profilePicturePath ?? '')),
                              ),
                      ),

                      //edit profile button
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: MaterialButton(
                          height: 50,
                          onPressed: () {
                            // Implement image update logic
                            _pickImageForRegistration();
                          },
                          shape: const CircleBorder(),
                          color: const Color(0xFFE3E3E3),
                          child: const Icon(Icons.edit),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 24.0),
                  Form(
                    key: _registerFormKey,
                    child: Column(
                      children: <Widget>[
                        // Name
                        TextFormField(
                          controller: _nameTextController,
                          focusNode: _focusName,
                          validator: (value) => Validator.validateName(
                            name: value,
                          ),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            hintText: "Name",
                            errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15.0)),
                          ),
                        ),
                        const SizedBox(height: 12.0),
                        // Email
                        TextFormField(
                          controller: _emailTextController,
                          focusNode: _focusEmail,
                          validator: (value) => Validator.validateEmail(
                            email: value,
                          ),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            hintText: "Email",
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12.0),
                        // Date of Birth Picker
                        TextFormField(
                          focusNode: _focusDob,
                          controller: _dobTextController,
                          readOnly: true,
                          onTap: () async {
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(1900),
                              lastDate: DateTime.now(),
                            );
                            if (pickedDate != null && pickedDate != _dob) {
                              setState(() {
                                _dob = pickedDate;
                                _dobTextController.text =
                                    DateFormat('dd-MM-yyyy').format(_dob!);
                              });
                            }
                          },
                          validator: (value) {
                            if (_dob == null) {
                              return 'Please pick a date of birth';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            hintText: "Date of Birth",
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            suffixIcon: Icon(Icons.calendar_today),
                          ),
                        ),
                        const SizedBox(height: 12.0),
                        // Mobile
                        TextFormField(
                          controller: _mobileTextController,
                          focusNode: _focusMobile,
                          keyboardType:
                              TextInputType.phone, // Set keyboard type to phone
                          validator: (value) => Validator.validateMobile(
                            mobile: value,
                          ),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            hintText: "Mobile Number",
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12.0),
                        // Password
                        TextFormField(
                          controller: _passwordTextController,
                          focusNode: _focusPassword,
                          obscureText: true,
                          validator: (value) => Validator.validatePassword(
                            password: value,
                          ),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            hintText: "Password",
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32.0),
                        _isProcessing
                            ? const CircularProgressIndicator()
                            : Row(
                                children: [
                                  Expanded(
                                    child: SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.8,
                                      height: 50.0,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xFF328B8C),
                                        ),
                                        onPressed: () async {
                                          setState(() {
                                            _isProcessing = true;
                                          });

                                          if (_registerFormKey.currentState!
                                              .validate()) {
                                            try {
                                              User? user =
                                                  await FirebaseAuthHelper
                                                      .registerUsingEmailPassword(
                                                dob: _dobTextController.text,
                                                mobile:
                                                    _mobileTextController.text,
                                                name: _nameTextController.text,
                                                email:
                                                    _emailTextController.text,
                                                password:
                                                    _passwordTextController
                                                        .text,
                                              );

                                              setState(() {
                                                _isProcessing = false;
                                              });

                                              if (user != null) {
                                                Navigator.pop(context);
                                              }
                                            } on FirebaseAuthException catch (e) {
                                              _showErrorDialog(e);
                                              setState(() {
                                                _isProcessing = false;
                                              });
                                              log(e.message.toString());
                                            }
                                          } else {
                                            setState(() {
                                              _isProcessing = false;
                                            });
                                          }
                                        },
                                        child: const Text(
                                          'Sign up',
                                          style: TextStyle(
                                            fontSize: 18.0,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                        //already have an account login
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Already have an account?'),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text(
                                'Login',
                                style: TextStyle(
                                  color: Color(0xFFD9D9D9),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  //pick image for registration
  Future<void> _pickImageForRegistration() async {
    final ImagePicker picker = ImagePicker();
    final ImageCropper cropper = ImageCropper();

    //show bottom sheet
    showModalBottomSheet(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      context: context,
      builder: (_) {
        return ListView(
          shrinkWrap: true,
          padding: EdgeInsets.only(
              top: MediaQuery.of(context).size.height * .02,
              bottom: MediaQuery.of(context).size.height * .05),
          children: [
            const Text(
              'Pick Profile picture',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * .02,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                //pick image from gallery
                ElevatedButton.icon(
                    style: ButtonStyle(iconSize: MaterialStateProperty.all(30)),
                    onPressed: () async {
                      final ImageCropper cropper = ImageCropper();

                      // Pick an image .
                      final XFile? image =
                          await picker.pickImage(source: ImageSource.gallery);

                      if (image != null) {
                        final CroppedFile? crop = await cropper.cropImage(
                            sourcePath: image.path,
                            aspectRatio:
                                const CropAspectRatio(ratioX: 1, ratioY: 1),
                            compressQuality: 100,
                            compressFormat: ImageCompressFormat.jpg);

                        try {
                          if (crop != null) {
                            setState(() {
                              _profilePicturePath = crop.path;
                            });
                          }
                        } catch (e) {
                          //show snakbar
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Failed to update profile picture'),
                            ),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.photo),
                    label: const Text('Gallery')),
                //pick image from camera
                ElevatedButton.icon(
                  style: ButtonStyle(iconSize: MaterialStateProperty.all(30)),
                  onPressed: () async {
                    final ImagePicker picker = ImagePicker();
                    // Pick an image .
                    final XFile? image =
                        await picker.pickImage(source: ImageSource.camera);
                    if (image != null) {
                      final CroppedFile? crop = await cropper.cropImage(
                          sourcePath: image.path,
                          aspectRatio:
                              const CropAspectRatio(ratioX: 1, ratioY: 1),
                          compressQuality: 100,
                          compressFormat: ImageCompressFormat.jpg);
                      if (crop != null) {
                        setState(() {
                          _profilePicturePath = crop.path;
                        });
                      }
                    }
                  },
                  icon: const Icon(Icons.photo_camera),
                  label: const Text('Camera'),
                )
              ],
            ),
          ],
        );
      },
    );
  }

  //show error dialog
  void _showErrorDialog(FirebaseAuthException e) {
    String errorMessage = '';
    switch (e.code) {
      case 'email-already-in-use':
        errorMessage = 'An account already exists with that email address.';
        break;
      case 'invalid-email':
        errorMessage = 'The email address is not valid.';
        break;
      case 'weak-password':
        errorMessage = 'The password is too weak.';
        break;
      // General authentication errors
      case 'user-disabled':
        errorMessage = 'The user account has been disabled.';
        break;
      case 'user-not-found':
        errorMessage = 'The user account has not been found.';
        break;
      case 'wrong-password':
        errorMessage = 'The password is invalid.';
        break;
      default:
        errorMessage = 'An undefined Error happened.';
    }
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(errorMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
