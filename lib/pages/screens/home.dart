import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:imovies/model/firebase_model.dart';
import 'package:imovies/pages/screens/detailded_view.dart';
import 'dart:io';

import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Image Upload',
      home: MyHome(),
    );
  }
}

class MyHome extends StatefulWidget {
  const MyHome({super.key});

  @override
  State<MyHome> createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {
  XFile? selectedImage;
  String title = '';
  String description = '';
  String location = '';
  List<getImages> getimages = [];
  String searchText = '';
  List<getImages> filteredImages = [];

  void updateFilteredList() {
    setState(() {
      filteredImages = getimages.where((image) {
        return image.title.toLowerCase().contains(searchText.toLowerCase());
      }).toList();
    });
  }
  
  @override
  void initState() {
    super.initState();
    fetchImages();
  }

  Future<void> fetchImages() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('images').get();
    getimages = querySnapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return getImages(
        imageUrl: data['imageUrl'],
        title: data['title'],
        description: data['description'],
        location: data['location'] ?? 'No location provided',
      );
    }).toList();
    
    filteredImages = getimages;
    setState(() {});
  }

  void showImageDialog(BuildContext context, int index) {
  final currentContext = context;
  getLocation().then((_) {
    showDialog(
      context: currentContext,
      builder: (context) {
        return AlertDialog(
          title: Text('Enter Title and Description'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                selectedImage != null
                    ? Image.file(File(selectedImage!.path))
                    : Container(),
                TextField(
                  onChanged: (value) {
                    title = value;
                  },
                  decoration: InputDecoration(hintText: 'Title'),
                ),
                TextField(
                  onChanged: (value) {
                    description = value;
                  },
                  decoration: InputDecoration(hintText: 'Description'),
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (selectedImage != null) {
                  uploadImage(selectedImage!, title, description, location);
                }
              },
              child: Text('Upload'),
            ),
          ],
        );
      },
    );
  });
}


  Future<XFile?> _getImageFromCamera() async {
    ImagePicker imagePicker = ImagePicker();
    XFile? file = await imagePicker.pickImage(source: ImageSource.camera);
    return file;
  }

  Future<void> uploadImage(
      XFile image, String title, String description, String location) async {
    Reference referenceRoot = FirebaseStorage.instance.ref();
    String uniqueFileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference referenceDirImages = referenceRoot.child('images');
    Reference referenceImageToUpload = referenceDirImages.child(uniqueFileName);

    await referenceImageToUpload.putFile(File(image.path));
    String imageUrl = await referenceImageToUpload.getDownloadURL();

    CollectionReference images =
        FirebaseFirestore.instance.collection('images');
    images.add({
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'location': location,
    });
  }

  Future<void> getLocation() async {
  try {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    // Use geocoding to get the city name
    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    if (placemarks.isNotEmpty) {
      String city = placemarks[0].locality ?? 'Unknown City';
      setState(() {
        location = city;
      });
    } else {
      setState(() {
        location = 'Unknown City';
      });
    }
  } catch (e) {
    print("Error getting location: $e");
    setState(() {
      location = 'Unknown City';
    });
  }
}



  @override
  Widget build(BuildContext context) {
        return Scaffold(
                 appBar: AppBar(
        title: TextField(
          onChanged: (text) {
            searchText = text;
            updateFilteredList();
          },
          decoration: InputDecoration(
            hintText: 'Search...',
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              print('Searching for: $searchText');
            },
          ),
            IconButton( 
            icon: Icon(Icons.settings),
            onPressed: () {
              openAppSettings(); 
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: filteredImages.length,
        itemBuilder: (context, index) {
          final getimage = filteredImages[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailedView(
                    image: getimage.imageUrl,
                    title: getimage.title,
                    description: getimage.description,
                    location: getimage.location,
                  ),
                ),
              );
            },
            child: Card(
              elevation: 5,
              margin: EdgeInsets.all(10),
              child: Row(
                children: [
                  Container(
                    width: 125,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(5),
                        bottomLeft: Radius.circular(5),
                      ),
                      color: Colors.red,
                    ),
                    child: Image.network(getimage.imageUrl, fit: BoxFit.cover),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          getimage.title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          getimage.description,
                          style: TextStyle(fontSize: 14),
                        ),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Category',
                              style: TextStyle(fontSize: 14),
                            ),
                            Text(
                              getimage.location,
                              style: TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final locationPermissionStatus = await Permission.location.request();
          if (locationPermissionStatus.isGranted) {
            selectedImage = await _getImageFromCamera();
            if (selectedImage != null) {
              showImageDialog(context, -1);
            }
          } else {
            print('Location permission denied.');
          }
        },
        child: Icon(Icons.camera_alt),
      ),
    );
    
  }
}


















































// return Scaffold(
     
    //         appBar: AppBar(
    //     title: TextField(
    //       onChanged: (text) {
    //         searchText = text;
    //         updateFilteredList();
    //       },
    //       decoration: InputDecoration(
    //         hintText: 'Search...',
    //       ),
    //     ),
    //     actions: [
    //       IconButton(
    //         icon: Icon(Icons.search),
    //         onPressed: () {
    //           print('Searching for: $searchText');
    //         },
    //       ),
    //         IconButton( // Add this IconButton
    //         icon: Icon(Icons.settings),
    //         onPressed: () {
    //           openAppSettings(); // Open app settings to grant location permission
    //         },
    //       ),
    //     ],
    //   ),
    //   body: ListView.builder(
    //     itemCount:filteredImages.length,
    //     // getimages.length,
    //     itemBuilder: (context, index) {
    //       final getimage = filteredImages[index];
    //       ///getimages[index];
    //       return GestureDetector(
    //             onTap: () {
    //                Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => DetailedView(
    //       image: getimage.imageUrl,
    //       title: getimage.title,
    //       description: getimage.description,
    //      // category: getimage.category,
    //       location: getimage.location,
    //     ),
    //   ),
    // );
    //             },
    //             child: Container(
    //                       width: double.infinity,
    //                       height: 100,
    //                       decoration: BoxDecoration(
    //             borderRadius: BorderRadius.circular(15),
    //             color: Color.fromARGB(255, 235, 229, 211),
    //                       ),
    //                       margin: EdgeInsets.all(10),
    //                       child: Row(
    //             children: [
    //               Container(
    //                 height: 100,
    //                 width: 125, 
    //                 decoration: BoxDecoration(
    //                   borderRadius: BorderRadius.circular(15),
    //                   color: Colors.red,
    //                 ),
    //                 child: Image.network(getimage.imageUrl, fit: BoxFit.cover),
    //               ),
    //               SizedBox(width: 8),
    //               Expanded(
    //                 child: Column(
    //                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    //                   crossAxisAlignment: CrossAxisAlignment.start,
    //                   children: [
    //                     Text(
    //                       getimage.title,
    //                       //'Title for Item $index',
    //                       style: TextStyle(fontWeight: FontWeight.bold),
    //                     ),
    //                     Text(
    //                       //'Description for Item $index'
    //                       getimage.description,
    //                     ),
    //                     Row(
    //                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //                       children: [
    //                         Text('Category $index'),
    //                         Text(getimage.location),
    //                       ],
    //                     ),
    //                   ],
    //                 ),
    //               ),
    //               SizedBox(width: 8),
    //             ],
    //                       ),
    //                     ),
    //           );
    //     },
    //   ),
    //   bottomNavigationBar: BottomAppBar(
    //     child: Container(
    //       height: 65,
    //       alignment: Alignment.center,
    //       child: IconButton(
    //         icon: Icon(
    //           Icons.add,
    //           size: 40,
    //         ),
    //         onPressed: () async {
    //          // await Permission.location.request();
    //           final locationPermissionStatus =
    //               await Permission.location.request();
    //           if (locationPermissionStatus.isGranted) {
    //             // Requested location permission successfully
    //             selectedImage = await _getImageFromCamera();
    //             if (selectedImage != null) {
    //               showImageDialog(context, -1);
    //             }
    //           } else {
    //             print('Location permission denied.');
    //           }
    //         },
    //       ),
    //     ),
    //   ),
    // );

 


