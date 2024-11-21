import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:smuff_project/screen/gallerydetail_screen.dart';
import 'package:smuff_project/screen/home_screen.dart';

class gallery_screen extends StatelessWidget {
  final List<String> imagePaths = [];

  Future<void> loadImageUrls() async {
    //firebase에서 이미지 가져옴
    var querySnapshot =
        await FirebaseFirestore.instance.collection('camera_images/').get();
    for (var doc in querySnapshot.docs) {
      // 각 문서에서 이미지 경로를 추출하여 imagePaths에 추가
      var imagePath = doc['imagePath']; // Firestore 문서에 이미지 경로가 있는지 확인
      imagePaths.add(imagePath);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<void>(
        future: loadImageUrls(), // 이미지 URL을 Firestore에서 불러오기
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (imagePaths.isEmpty) {
            return Center(child: Text('No images available'));
          }

          return Center(
            child: SizedBox(
              width: 411,
              height: 707,
              child: Column(
                children: [
                  SizedBox(height: 20),

                  // 상단 사이즈박스
                  SizedBox(
                    height: 50,
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.home, color: Colors.black),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => home_screen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),

                  // 갤러리 그리드
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GridView.builder(
                        itemCount: imagePaths.length, // 충분한 아이템 개수로 설정
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
                        ),
                        itemBuilder: (context, index) {
                          // Firebase Storage에서 이미지 로드
                          return FutureBuilder<String>(
                            future: FirebaseStorage.instance
                                .ref()
                                .child(imagePaths[index]) // 이미지 경로
                                .getDownloadURL(), // 다운로드 URL 가져오기
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Center(
                                    child: CircularProgressIndicator());
                              }

                              if (snapshot.hasError) {
                                return Center(
                                    child: Text('Error: ${snapshot.error}'));
                              }

                              if (!snapshot.hasData) {
                                return Center(
                                    child: Text('No image available'));
                              }

                              String imageUrl = snapshot.data!;

                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          gallerydetail_screen(
                                              imagePath: imageUrl),
                                    ),
                                  );
                                },
                                child: SizedBox(
                                  width: 100,
                                  height: 100,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      imageUrl,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
