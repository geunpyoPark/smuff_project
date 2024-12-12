import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'gallery_screen.dart';

class Camera_Screen extends StatefulWidget {
  const Camera_Screen({Key? key}) : super(key: key);

  @override
  State<Camera_Screen> createState() => _Camera_ScreenState();
}

class _Camera_ScreenState extends State<Camera_Screen> {
  late CameraController _cameraController;
  late Future<void> _initializeControllerFuture;
  final String _uid = FirebaseAuth.instance.currentUser?.uid ?? 'unknown_user';
  bool _isFlashing = false; // 화면 반짝임 상태 변수
  String? _latestImageUrl; // 최신 이미지 URL 상태 변수

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _fetchLatestImage(); // 최신 사진 로드
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      final firstCamera = cameras.first;

      _cameraController = CameraController(
        firstCamera,
        ResolutionPreset.high,
      );

      _initializeControllerFuture = _cameraController.initialize();
      setState(() {});
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  Future<void> _fetchLatestImage() async {
    try {
      final storageRef = FirebaseStorage.instance.ref().child(_uid);
      final ListResult result = await storageRef.listAll();

      if (result.items.isNotEmpty) {
        // 최신 파일 가져오기
        final latestItem = result.items.last;
        final downloadUrl = await latestItem.getDownloadURL();

        setState(() {
          _latestImageUrl = downloadUrl;
        });
      }
    } catch (e) {
      print('Error fetching latest image: $e');
    }
  }

  Future<void> _takePicture() async {
    try {
      setState(() {
        _isFlashing = true;
      });

      await Future.delayed(const Duration(milliseconds: 100));
      setState(() {
        _isFlashing = false;
      });

      await _initializeControllerFuture;

      final directory = await getApplicationDocumentsDirectory();
      final String formattedDate = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final path = '${directory.path}/$formattedDate.jpeg';

      final image = await _cameraController.takePicture();
      final savedImage = await File(image.path).copy(path);

      await _uploadToFirebase(savedImage, formattedDate);

      await _fetchLatestImage(); // 최신 사진 로드
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Picture saved to Firebase Storage!')),
      );
    } catch (e) {
      print('Error taking picture: $e');
    }
  }

  Future<void> _uploadToFirebase(File image, String fileName) async {
    try {
      final storageRef = FirebaseStorage.instance.ref();
      final userFolderRef = storageRef.child('$_uid');
      final imageRef = userFolderRef.child('$fileName.jpeg');

      await imageRef.putFile(image);

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
        backgroundColor: const Color(0xFFEC5F5F),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Camera',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          FutureBuilder<void>(
            future: _initializeControllerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return SizedBox.expand(
                  child: CameraPreview(_cameraController),
                );
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
          // 반짝임 효과
          AnimatedOpacity(
            opacity: _isFlashing ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: Container(
              color: Colors.white,
            ),
          ),
          // 하단 버튼들
          Positioned(
            bottom: 40,
            left: 175,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: _takePicture,
                  child: SizedBox(
                    width: 70,
                    height: 70,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.black26,
                          width: 3,
                        ),
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    final latestImageUrl = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => GalleryScreen()),
                    );
                    if (latestImageUrl != null && mounted) {
                      setState(() {
                        _latestImageUrl = latestImageUrl;
                      });
                    }
                  },
                  child: SizedBox(
                    width: 50,
                    height: 50,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        image: _latestImageUrl != null
                            ? DecorationImage(
                          image: NetworkImage(_latestImageUrl!),
                          fit: BoxFit.cover,
                        )
                            : const DecorationImage(
                          image: NetworkImage(
                            'https://via.placeholder.com/50x50',
                          ),
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.black12,
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
