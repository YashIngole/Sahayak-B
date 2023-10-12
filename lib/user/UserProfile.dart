import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sahayak/Themeconst.dart';
import 'package:sahayak/auth%20svc/authentication.dart';
import 'package:sahayak/auth%20svc/databaseService.dart';
import 'package:sahayak/auth%20svc/helper.dart';

//import 'package:image_picker/image_picker.dart';
class userprofile extends StatefulWidget {
  const userprofile({super.key});

  @override
  State<userprofile> createState() => _HomeState();
}

User? currentUser = FirebaseAuth.instance.currentUser;
String userId = currentUser!.uid;
String issue = "";
String ImageUrl = "";

class _HomeState extends State<userprofile> {
  String userName = "";
  String email = "";

  Future<void> getUserData() async {
    email = await helperFunctions.getUserEmailFromSF() ?? '';
    userName = await helperFunctions.getUserNameFromSF() ?? '';
    final imageUrl = await getImageUrl(userId);
    setState(() {
      ImageUrl = imageUrl ?? "";
    });
  }

  AuthService authService = AuthService();
  final databaseService _databaseservice = databaseService();
  final FirebaseAuth auth = FirebaseAuth.instance;
  @override
  void initState() {
    getUserData();
    getImageUrl(userId);
  }

  @override
  Widget build(BuildContext context) {
    final FirebaseAuth auth = FirebaseAuth.instance;
    User? user = authService.firebaseAuth.currentUser;

    return SafeArea(
      child: Scaffold(
        backgroundColor: kbackgroundcolor,
        body: Column(children: [
          const Spacer(),
          const Text(
            "User Card",
            style: TextStyle(fontSize: 28, color: Colors.white),
          ),
          const SizedBox(
            height: 40,
          ),
          ImageUrl.isEmpty
              ? Container(
                  height: Get.height * 0.3,
                  width: Get.width * 0.6,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.grey[800]),
                  child: IconButton(
                      onPressed: () async {
                        ImagePicker imagePicker = ImagePicker();
                        XFile? file = await imagePicker.pickImage(
                          source: ImageSource.gallery,
                        );
                        if (file == null) {
                          return;
                        }
                        //convert file to data
                        final Uint8List fileBytes = await file.readAsBytes();

                        // Reference to storage root of Firebase Storage
                        Reference referenceRoot =
                            FirebaseStorage.instance.ref();
                        Reference referenceDirImages =
                            referenceRoot.child('images');

                        // Reference for the image to be stored
                        String uniqueFileName =
                            '${DateTime.now().millisecondsSinceEpoch}.jpg';
                        Reference referenceImageToUpload =
                            referenceDirImages.child(uniqueFileName);
                        try {
                          // Store the file
                          await referenceImageToUpload.putData(fileBytes,
                              SettableMetadata(contentType: 'image/jpeg'));
                          ImageUrl =
                              await referenceImageToUpload.getDownloadURL();
                          print(ImageUrl);
                          setState(
                            () {
                              ImageUrl;
                            },
                          );
                        } catch (e) {
                          print('Error uploading image: $e');
                        }

                        AddImageUrl();
                      },
                      icon: Icon(
                        Icons.add_a_photo,
                        color: Colors.white,
                        size: Get.height * 0.12,
                      )),
                )
              : CachedNetworkImage(
                  height: Get.height * 0.3,
                  width: Get.width * 0.6,
                  imageUrl: ImageUrl,
                  imageBuilder: (context, imageProvider) => Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            image: DecorationImage(
                              image: imageProvider,
                              fit: BoxFit.fill,
                            ),
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      Positioned(
                          right: 0,
                          bottom: 0,
                          child: ElevatedButton.icon(
                              onPressed: () async {
                                ImagePicker imagePicker = ImagePicker();
                                XFile? file = await imagePicker.pickImage(
                                  source: ImageSource.gallery,
                                );
                                if (file == null) {
                                  return;
                                }
                                //convert file to data
                                final Uint8List fileBytes =
                                    await file.readAsBytes();

                                // Reference to storage root of Firebase Storage
                                Reference referenceRoot =
                                    FirebaseStorage.instance.ref();
                                Reference referenceDirImages =
                                    referenceRoot.child('images');

                                // Reference for the image to be stored
                                String uniqueFileName =
                                    '${DateTime.now().millisecondsSinceEpoch}.jpg';
                                Reference referenceImageToUpload =
                                    referenceDirImages.child(uniqueFileName);
                                try {
                                  // Store the file
                                  await referenceImageToUpload.putData(
                                      fileBytes,
                                      SettableMetadata(
                                          contentType: 'image/jpeg'));
                                  ImageUrl = await referenceImageToUpload
                                      .getDownloadURL();
                                  print(ImageUrl);
                                  setState(
                                    () {
                                      ImageUrl;
                                    },
                                  );
                                } catch (e) {
                                  print('Error uploading image: $e');
                                }

                                AddImageUrl();
                              },
                              icon: Icon(Icons.edit),
                              label: Text("edit")))
                    ],
                  ),
                  placeholder: (context, url) =>
                      const CircularProgressIndicator(),
                  errorWidget: (context, url, error) => Container(
                    height: Get.height * 0.3,
                    width: Get.width * 0.6,
                    decoration: BoxDecoration(
                        color: ktilecolor,
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
          Spacer(),
          Column(
            children: [
              Center(
                child: Container(
                  padding: EdgeInsets.all(20),
                  color: ktilecolor,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Name : $userName",
                        style:
                            GoogleFonts.acme(color: Colors.white, fontSize: 20),
                      ),
                      Text("Email : $email",
                          style: GoogleFonts.acme(
                              color: Colors.white, fontSize: 20)),
                      Row(
                        children: [
                          Text(
                            "Phone : ${user!.displayName}",
                            style: GoogleFonts.acme(
                                color: Colors.white, fontSize: 20),
                          ),
                          IconButton(onPressed: () {}, icon: Icon(Icons.edit))
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // SizedBox(
              //   height: 10,
              // ),
            ],
          ),
          const Spacer()
        ]),
      ),
    );
  }

  Future<String?> getImageUrl(String userId) async {
    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users') // Replace with your collection name
          .where('uid', isEqualTo: userId)
          .limit(1) // Limit to one document (in case multiple matches)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final imageUrl = snapshot.docs.first['ImageUrl'];
        return imageUrl;
      } else {
        // No document matching the condition was found.
        return null;
      }
    } catch (e) {
      print('Error fetching image URL: $e');
      return null;
    }
  }

  void AddImageUrl() async {
    var collection = FirebaseFirestore.instance.collection('users');

    var querySnapshot = await collection.where('uid', isEqualTo: userId).get();
    if (querySnapshot.docs.isNotEmpty) {
      var documentSnapshot = querySnapshot.docs.first;
      collection
          .doc(documentSnapshot.id)
          .update({'ImageUrl': ImageUrl})
          .then((_) => print('Success'))
          .catchError((error) => print('Failed: $error'));
    }
  }
}
