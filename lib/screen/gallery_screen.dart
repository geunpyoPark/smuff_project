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
      final ListResult result = await FirebaseStorage.instance.ref(userFolder).listAll();

      // Firebase Storage에서 다운로드 URL 가져오기
      final urls = await Future.wait(result.items.map((item) async {
        try {
          return await item.getDownloadURL();
        } catch (e) {
          print('Error fetching URL: $e');
          return null;
        }
      }).where((url) => url != null).toList());

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
        title: Text('Gallery'),
        backgroundColor: Colors.white,
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
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FullScreenSlider(
                      imageUrls: imageUrls,
                      initialIndex: index,
                    ),
                  ),
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      Center(child: Icon(Icons.error, color: Colors.red)),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class FullScreenSlider extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;

  const FullScreenSlider({
    Key? key,
    required this.imageUrls,
    required this.initialIndex,
  }) : super(key: key);

  @override
  _FullScreenSliderState createState() => _FullScreenSliderState();
}

class _FullScreenSliderState extends State<FullScreenSlider> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); // 뒤로 가기 버튼을 눌렀을 때 이전 화면으로 돌아감
          },
        ),
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.imageUrls.length,
        itemBuilder: (context, index) {
          return Center(
            child: Image.network(
              widget.imageUrls[index],
              fit: BoxFit.contain,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) {
                  return child;
                } else {
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                          (loadingProgress.expectedTotalBytes ?? 1)
                          : null,
                    ),
                  );
                }
              },
              errorBuilder: (context, error, stackTrace) =>
                  Center(child: Icon(Icons.error, color: Colors.red)),
            ),
          );
        },
      ),
    );
  }
}
