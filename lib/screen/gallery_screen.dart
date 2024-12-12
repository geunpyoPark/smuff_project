import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'gallerydetail_screen.dart';

class GalleryScreen extends StatefulWidget {
  @override
  _GalleryScreenState createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  List<String> imageUrls = []; // Firebase Storage에서 가져온 이미지 URL 리스트
  bool isLoading = true; // 로딩 상태 표시

  @override
  void initState() {
    super.initState();
    fetchImagesFromStorage(); // Firebase Storage에서 이미지 가져오기
  }

  Future<void> fetchImagesFromStorage() async {
    final user = FirebaseAuth.instance.currentUser; // 현재 로그인된 사용자 정보 가져오기
    if (user == null) return;

    try {
      final userFolder = '${user.uid}/'; // 사용자 UID 기반 폴더 경로
      final ListResult result =
      await FirebaseStorage.instance.ref(userFolder).listAll();

      // Firebase Storage에서 다운로드 URL 가져오기
      final urls = await Future.wait(result.items
          .map((item) async {
        try {
          return await item.getDownloadURL();
        } catch (e) {
          print('Error fetching URL: $e');
          return null;
        }
      })
          .where((url) => url != null)
          .toList());

      setState(() {
        imageUrls = urls.cast<String>(); // 가져온 URL 리스트를 저장
        isLoading = false; // 로딩 상태 종료
      });
    } catch (e) {
      print('Error fetching images: $e');
      setState(() {
        isLoading = false;
      });
    }
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
          'Gallery',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // 로딩 중
          : imageUrls.isEmpty
          ? Center(child: Text('No images found')) // 이미지가 없을 경우 메시지 표시
          : Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          itemCount: imageUrls.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, // 한 행에 3개의 이미지
            mainAxisSpacing: 8, // 세로 간격
            crossAxisSpacing: 8, // 가로 간격
          ),
          itemBuilder: (context, index) {
            final imageUrl = imageUrls[index];
            return GestureDetector(
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GalleryDetailScreen(
                      imageUrls: imageUrls,
                      initialIndex: index,
                    ),
                  ),
                );

                // 삭제된 이미지 URL 반영
                if (result != null && result is String) {
                  setState(() {
                    imageUrls.remove(result);
                  });
                }
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      Center(
                          child:
                          Icon(Icons.error, color: Colors.red)),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
