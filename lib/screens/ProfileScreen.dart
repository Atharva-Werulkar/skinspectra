import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:skinspectra/auth/database_services.dart';
import 'package:skinspectra/auth/firebase_auth_helper.dart';
import 'package:skinspectra/auth/validator.dart';
import 'package:skinspectra/model/model.dart';
import 'package:skinspectra/screens/homePage.dart';
import 'package:skinspectra/widgets/show_dialog.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _aboutController;
  late TextEditingController _emailController;
  late TextEditingController _dobController;
  late TextEditingController _mobileController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _aboutController = TextEditingController();
    _emailController = TextEditingController();
    _dobController = TextEditingController();
    _mobileController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _aboutController.dispose();
    _emailController.dispose();
    _dobController.dispose();
    _mobileController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Profile screen with profile avatar text field to update the user's name and change the profile picture and a logout button
    return Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.exit_to_app),
              onPressed: () async {
                // Implement logout logic
                await FirebaseAuthHelper.signOut();
                //     .then(
                //   (value) => Navigator.of(context).pushReplacement(
                //     MaterialPageRoute(
                //       builder: (context) => const LandingPage(),
                //     ),
                //   ),
                // );
              },
            ),
          ],
        ),
        body: StreamBuilder<MyUser>(
            stream: DatabaseServices.getCurrentUser(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                case ConnectionState.waiting:
                  return const Center(child: CircularProgressIndicator());
                case ConnectionState.active:
                case ConnectionState.done:
                  _nameController.text = snapshot.data!.name ?? '';
                  _aboutController.text = snapshot.data!.about ?? '';
                  _emailController.text = snapshot.data!.email ?? '';
                  _dobController.text = snapshot.data!.dob ?? '';
                  _mobileController.text = snapshot.data!.mobile ?? '';

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          //profile picture
                          Stack(
                            children: [
                              SizedBox(
                                height: 150,
                                width: 150,
                                child: CircleAvatar(
                                  radius: 50,
                                  backgroundImage:
                                      NetworkImage(snapshot.data!.image ?? ''),
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
                                    _pickImage(snapshot.data!.id, context);
                                  },
                                  shape: const CircleBorder(),
                                  color: Colors.white,
                                  child: const Icon(Icons.edit),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 16),

                          //name text field
                          TextFormField(
                            controller: _nameController,
                            //initialValue: snapshot.data!.name,
                            decoration: const InputDecoration(
                              labelText: 'Name',
                              border: OutlineInputBorder(),
                            ),
                          ),

                          const SizedBox(height: 16),

                          //about text field
                          TextFormField(
                            controller: _aboutController,
                            // initialValue: snapshot.data!.about,
                            decoration: const InputDecoration(
                              labelText: 'About',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 16),
                          //email text field
                          TextFormField(
                            readOnly: true,
                            controller: _emailController,
                            //initialValue: snapshot.data!.email,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Date of Birth text field
                          TextFormField(
                            controller: _dobController,
                            readOnly: true,
                            decoration: const InputDecoration(
                              labelText: 'Date of Birth',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Mobile Number text field
                          TextFormField(
                            validator: (value) => Validator.validateMobile(
                              mobile: value,
                            ),
                            keyboardType: TextInputType.number,
                            controller: _mobileController,
                            decoration: const InputDecoration(
                              labelText: 'Mobile Number',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 16),

                          //update profile button
                          ElevatedButton(
                            onPressed: () async {
                              //update the profile only if the changes are made
                              if (_nameController.text == snapshot.data!.name &&
                                  _aboutController.text ==
                                      snapshot.data!.about &&
                                  _emailController.text ==
                                      snapshot.data!.email &&
                                  _dobController.text == snapshot.data!.dob &&
                                  _mobileController.text ==
                                      snapshot.data!.mobile) {
                                return;
                              }

                              //show the dialog when the profile is updated
                              try {
                                await DatabaseServices.updateProfile(
                                  userId: snapshot.data!.id,
                                  name: _nameController.text,
                                  about: _aboutController.text,
                                  mobile: _mobileController.text,
                                );
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Profile Updated'),
                                    content: const Text(
                                        'Your profile has been updated'),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text('OK'),
                                      ),
                                    ],
                                  ),
                                );
                              } catch (e) {
                                //show snakbar
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Failed to update profile'),
                                  ),
                                );
                              }
                            },
                            child: const Text('Update Profile'),
                          ),
                          //redirect to home page
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => HomePage(),
                                ),
                              );
                            },
                            child: const Text('Home'),
                          ),
                        ],
                      ),
                    ),
                  );
              }
            }));
  }
}

//pick image from gallery or camera
Future<void> _pickImage(String? userId, BuildContext context) async {
  print(userId);
  final ImagePicker picker = ImagePicker();
  final ImageCropper cropper = ImageCropper();
  String? photo;

  //show bottom sheet
  showBottomSheet(
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
                            photo = crop.path;

                            //update the profile picture
                            await DatabaseServices.updateProfilePicture(
                                File(photo!), userId);

                            //for hiding bottom sheet
                            Navigator.pop(context);

                            //Show AlertDialog after successful update

                            CustomDialog.showAlertDialog(
                                context,
                                'Profile Picture Updated',
                                'Your profile picture has been updated');
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
                        photo = crop.path;

                        //update the profile picture
                        DatabaseServices.updateProfilePicture(
                            File(photo!), userId);

                        //for hiding bottom sheet
                        Navigator.pop(context);

                        //Show AlertDialog after successful update
                        CustomDialog.showAlertDialog(
                            context,
                            'Profile Picture Updated',
                            'Your profile picture has been updated');
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
      });
}
