import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // 날짜 포맷을 위한 패키지

class Camera_Screen extends StatefulWidget {
  const Camera_Screen({Key? key}) : super(key: key);

  @override
  State<Camera_Screen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<Camera_Screen> {
  late CameraController _cameraController;
  late Future<void> _initializeControllerFuture;
  final String _uid = FirebaseAuth.instance.currentUser?.uid ?? 'unknown_user';

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;

    _cameraController = CameraController(
      firstCamera,
      ResolutionPreset.high,
    );

    _initializeControllerFuture = _cameraController.initialize();
    setState(() {});
  }

  Future<void> _takePicture() async {
    try {
      // Ensure the camera is initialized
      await _initializeControllerFuture;

      // Format the current date and time
      final String formattedDate =
      DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());

      // Get the directory to save the image temporarily
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/$formattedDate.png';

      // Take the picture and save it to the path
      final image = await _cameraController.takePicture();

      // Save the picture to the provided path
      final savedImage = await File(image.path).copy(path);

      // Upload the image to Firebase Storage
      await _uploadToFirebase(savedImage, formattedDate);

      // Show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Picture saved to Firebase Storage!')),
      );
    } catch (e) {
      print('Error taking picture: $e');
    }
  }

  Future<void> _uploadToFirebase(File image, String fileName) async {
    try {
      // Create a reference to Firebase Storage
      final storageRef = FirebaseStorage.instance.ref();

      // Use the UID as the folder name
      final userFolderRef = storageRef.child('$_uid');
      final imageRef = userFolderRef.child('$fileName.png'); // 파일 이름 지정

      // Upload the file
      await imageRef.putFile(image);

      // Get the download URL
      final downloadUrl = await imageRef.getDownloadURL();
      print('Image uploaded successfully! Download URL: $downloadUrl');
    } catch (e) {
      print('Error uploading to Firebase Storage: $e');
    }
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Camera'),
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              children: [
                CameraPreview(_cameraController),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: FloatingActionButton(
                      onPressed: _takePicture,
                      child: const Icon(Icons.camera_alt),
                    ),
                  ),
                ),
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}