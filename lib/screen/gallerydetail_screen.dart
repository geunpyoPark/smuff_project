import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';

class GalleryDetailScreen extends StatefulWidget {
  final List<String> imageUrls; // Firebase Storage에서 가져온 이미지 URL 리스트
  final int initialIndex; // 초기 이미지 인덱스

  const GalleryDetailScreen({
    Key? key,
    required this.imageUrls,
    required this.initialIndex,
  }) : super(key: key);

  @override
  _GalleryDetailScreenState createState() => _GalleryDetailScreenState();
}

class _GalleryDetailScreenState extends State<GalleryDetailScreen> {
  late PageController _pageController; // PageView에서 페이지를 제어할 컨트롤러

  @override
  void initState() {
    super.initState();
    _pageController =
        PageController(initialPage: widget.initialIndex); // 초기 페이지 인덱스로 설정
  }

  @override
  void dispose() {
    _pageController.dispose(); // 페이지 컨트롤러 해제
    super.dispose();
  }

  // Firebase Storage에서 이미지를 삭제하는 함수
  Future<void> deleteImage(String imageUrl) async {
    try {
      // 이미지 URL을 Firebase Storage의 참조로 변환
      final ref = FirebaseStorage.instance.refFromURL(imageUrl);

      // Firebase Storage에서 해당 이미지 삭제
      await ref.delete();

      // 이미지 삭제 후 화면 갱신
      setState(() {
        widget.imageUrls.remove(imageUrl); // 삭제한 이미지를 리스트에서 제거
      });

      // 삭제 성공 메시지 표시
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('이미지가 삭제되었습니다.')),
      );
    } catch (e) {
      // 삭제 실패 시 오류 메시지 표시
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('이미지 삭제에 실패했습니다.')),
      );
      print('Error deleting image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // 배경색을 검정색으로 설정
      appBar: AppBar(
        backgroundColor: Colors.transparent, // AppBar 배경을 투명하게 설정
        elevation: 0, // 그림자 제거
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white), // 뒤로 가기 버튼
          onPressed: () {
            Navigator.pop(context); // 단순히 뒤로가기
          },
        ),
        actions: [
          // 삭제 버튼 클릭 시 삭제된 URL 반환
          IconButton(
            icon: Icon(Icons.delete, color: Colors.white),
            onPressed: () async {
              final currentImageUrl =
              widget.imageUrls[_pageController.page!.toInt()];
              await deleteImage(currentImageUrl);
              Navigator.pop(context, currentImageUrl); // 삭제된 URL 반환
            },
          ),
        ],
      ),
      body: PageView.builder(
        controller: _pageController, // PageView의 페이지 컨트롤러 설정
        itemCount: widget.imageUrls.length, // 이미지 개수만큼 페이지 표시
        itemBuilder: (context, index) {
          return Center(
            child: Image.network(
              widget.imageUrls[index], // 이미지 URL로 이미지를 로딩
              fit: BoxFit.contain, // 이미지 비율을 유지하면서 최대한 크기를 맞추기
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null)
                  return child; // 로딩이 끝났으면 이미지를 바로 표시
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                        (loadingProgress.expectedTotalBytes ?? 1)
                        : null, // 로딩 진행 상태 표시
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Center(
                  child: Text(
                    '이미지를 불러오는 데 실패했습니다.',
                    style: TextStyle(color: Colors.red), // 이미지 로딩 실패시 오류 메시지 표시
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
