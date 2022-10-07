import 'dart:io';
import 'package:add_to_gallery/add_to_gallery.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:imagegallery/database/dbmodel.dart';
import 'package:imagegallery/screen/displayscrren.dart';

final flutter = 'flutter';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  XFile? imageFile;

  takeImage(ImageSource img) async {
    final pickedFile = await ImagePicker().pickImage(source: img);
    XFile imageFile = XFile(pickedFile!.path);

    File file = File(pickedFile.path);
    await AddToGallery.addToGallery(
      deleteOriginalFile: false,
      originalFile: file,
      albumName: flutter,
    );

    setState(
      () {
        imageFile = pickedFile;
        Hive.box<Gallery>('gallery').add(
          Gallery(imagePath: pickedFile.path),
        );
      },
    );
    File(imageFile.path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Sanush's Camera"),
        centerTitle: true,
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<Gallery>('gallery').listenable(),
        builder: (context, Box<Gallery> box, widget) {
          List keys = box.keys.toList();
          if (keys.isEmpty) {
            return const Center(
              child: Text(
                'Capture the Photo',
                style: TextStyle(color: Colors.white),
              ),
            );
          } else {
            return GridView.builder(
              padding: const EdgeInsets.all(10),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 160,
                  childAspectRatio: 1,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10),
              itemBuilder: ((context, index) {
                List<Gallery> data = box.values.toList();
                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => DisplayImage(
                          image: data[index].imagePath,
                          index: index,
                        ),
                      ),
                    );
                  },
                  onLongPress: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        content: const Text('Do you want to delete the image?'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('CANCEL'),
                          ),
                          TextButton(
                            onPressed: () {
                              data[index].delete();
                              Navigator.pop(context);
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: Colors.white,
                          width: 0.5,
                          style: BorderStyle.solid),
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: FileImage(
                          File(
                            data[index].imagePath!,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
              itemCount: keys.length,
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          takeImage(ImageSource.camera);
        },
        child: const Icon(
          Icons.camera_alt_sharp,
          size: 40,
        ),
      ),
    );
  }
}
