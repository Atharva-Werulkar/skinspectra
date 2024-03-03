import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:skinspectra/auth/database_services.dart';
import 'package:skinspectra/auth/firebase_auth_helper.dart';
import 'package:skinspectra/model/model.dart';
import 'package:skinspectra/utils/constants.dart';
import 'package:skinspectra/screens/image_processing.dart';
import 'package:skinspectra/widgets/messagecard.dart';
import 'package:skinspectra/widgets/show_dialog.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final GenerativeModel _model;
  late final ChatSession _chat;

  bool _loading = false;
  late String username = '';
  late String profile = '';
  final List<MessageWidget> _messages = [];

  @override
  void initState() {
    super.initState();

    _model = GenerativeModel(
      model: 'gemini-pro',
      apiKey: api_key,
    );
    _chat = _model.startChat();

    print(_model);
  }

  @override
  Widget build(BuildContext context) {
    //get current user

    return Scaffold(
      backgroundColor: const Color(0xFFE3E3E3),
      appBar: AppBar(
        backgroundColor: const Color(0xFF328B8C),
        title: const Text('SkinSpectra',
            style: TextStyle(
              color: Colors.white,
            )),
        centerTitle: true,
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Iconsax.menu, size: 30, color: Colors.white),
              onPressed: () {
                // Open the drawer
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
      ),
      drawer: StreamBuilder<MyUser>(
        stream: DatabaseServices.getCurrentUser(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return const Center(child: CircularProgressIndicator());
            case ConnectionState.active:
            case ConnectionState.done:
              return Drawer(
                backgroundColor: const Color(0xFFE3E3E3),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(0),
                    bottomRight: Radius.circular(0),
                  ),
                ),
                child: ListView(
                  children: <Widget>[
                    //close button for drawer at top right
                    Container(
                      padding: const EdgeInsets.only(right: 30, top: 10),
                      alignment: Alignment.topRight,
                      child: IconButton(
                        icon: const Icon(
                          Iconsax.close_square,
                          size: 30,
                        ),
                        onPressed: () {
                          // Open the drawer
                          Navigator.pop(context);
                        },
                      ),
                    ),

                    const SizedBox(
                      height: 20,
                    ),

                    //profile
                    DrawerHeader(
                      child: Center(
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            CircleAvatar(
                              radius: 70,
                              backgroundImage:
                                  NetworkImage(snapshot.data!.image ?? ''),
                            ),
                            Container(
                              decoration: const BoxDecoration(
                                  shape: BoxShape.circle, color: Colors.white),
                              child: IconButton(
                                onPressed: () async {
                                  //pick image from gallery
                                  await pickImage(
                                      FirebaseAuth.instance.currentUser!.uid,
                                      context);
                                },
                                icon: const Icon(
                                  Icons.add,
                                  size: 20,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    //show the user name
                    ListTile(
                      title: Text(snapshot.data!.name ?? ''),
                      leading: const Icon(Icons.person),
                    ),
                    //show the user email
                    ListTile(
                      title: Text(snapshot.data!.email ?? ''),
                      leading: const Icon(Icons.email),
                    ),
                    //show the user mobile number
                    ListTile(
                      title: Text(snapshot.data!.mobile ?? ''),
                      leading: const Icon(Icons.phone),
                    ),
                    //show the user date of birth
                    ListTile(
                      title: Text(snapshot.data!.dob ?? ''),
                      leading: const Icon(Icons.date_range),
                    ),
                    //show the user about
                    ListTile(
                      title: Text(snapshot.data!.about ?? ''),
                      leading: const Icon(Icons.info),
                    ),

                    SizedBox(
                      height: MediaQuery.of(context).size.height * .1,
                    ),

                    //logout button
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Container(
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            bottomLeft: Radius.circular(20),
                            bottomRight: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                        ),
                        alignment: Alignment.bottomCenter,
                        child: ListTile(
                          title: const Text('Logout'),
                          onTap: () async {
                            //sign out the user
                            await FirebaseAuthHelper.signOut();
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              );
          }
        },
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
              return Padding(
                padding: const EdgeInsets.all(0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    //show the hello message and option to select image from gallery and one option to give recommendation for skin care

                    const SizedBox(
                      height: 20,
                    ),
                    Expanded(
                      child: ListView(
                        physics: const BouncingScrollPhysics(),
                        //controller: _scrollController,
                        children: [
                          //message which say's hello with user name

                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20.0, vertical: 10),
                            child: Container(
                              alignment: Alignment.topLeft,
                              child: Text(
                                'Hello, ${snapshot.data!.name}',
                                style: const TextStyle(
                                  fontSize: 30,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),

                          //message which say's scan and upload image

                          GestureDetector(
                            onTap: () async {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (_) {
                                return const ImageChat();
                              }));
                            },
                            child: const MessageWidget(
                                userIcon: IconData(0xf60b,
                                    fontFamily: 'MaterialIcons'),
                                iconColor: Colors.blueGrey,
                                text: 'scan and upload image',
                                isFromUser: true),
                          ),

                          GestureDetector(
                            onTap: () async {
                              //use gemini to give tips
                              await _sendChatMessage(
                                  'Give me Some Healthy Skin Tips');
                              //show the loading animation
                            },
                            child: const MessageWidget(
                                userIcon: IconData(0xe37c,
                                    fontFamily: 'MaterialIcons'),
                                iconColor: Colors.amberAccent,
                                text: 'Healthy Skin Tips',
                                isFromUser: true),
                          ),

                          //show the loading animation
                          if (_loading)
                            const Center(
                                child: SpinKitThreeBounce(
                              color: Color(0xFF328B8C),
                              size: 40,
                            )),

                          //remove the loading animation
                          if (!_loading)
                            const SizedBox(
                              height: 0,
                            ),

                          //show the elements of the list
                          ..._messages,
                        ],
                      ),
                    ),
                  ],
                ),
              );
          }
        },
      ),
    );
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Something went wrong',
            style: TextStyle(
              color: Color(0xFFD7D1F1),
            ),
          ),
          content: SingleChildScrollView(
            child: SelectableText(
              message,
              style: const TextStyle(
                color: Color(0xFFD7D1F1),
              ),
            ),
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'OK',
                style: TextStyle(
                  color: Color(0xFFD7D1F1),
                ),
              ),
            )
          ],
        );
      },
    );
  }

  String getChatHistory() {
    return _chat.history.map((content) {
      return content.parts
          .whereType<TextPart>()
          .map<String>((e) => e.text)
          .join('');
    }).join('\n');
  }

  Future<void> _sendChatMessage(String message) async {
    setState(() {
      _loading = true;
    });

    try {
      var response = await _chat.sendMessage(
        Content.text(message),
      );

      print(response.text.toString());

      var text = response.text;

      if (text == null) {
        _showError('No response from API.');
        return;
      } else {
        setState(() {
          _loading = false;
          // Add a new MessageWidget with the response text
          _messages.add(MessageWidget(
            text: text,
            isFromUser: false,
          ));
        });
      }
    } catch (e) {
      _showError(e.toString());
      setState(() {
        _loading = false;
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> predictionimage() async {
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

                        //for hiding bottom sheet
                        Navigator.pop(context);

                        //Show AlertDialog after successful update
                        CustomDialog.showAlertDialog(context, 'Picture Updated',
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
      },
    );
  }

  Future<void> pickImage(String? userId, BuildContext context) async {
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
      },
    );
  }
}
