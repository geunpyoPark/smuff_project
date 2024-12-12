import 'package:flutter/material.dart';
import 'package:smuff_project/screen/setting_screen.dart';
import 'package:smuff_project/screen/calendar_screen.dart';
import 'package:smuff_project/screen/camera_screen.dart';
import 'package:smuff_project/screen/gallery_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:smuff_project/model/user_model.dart';

class Home_Screen extends StatefulWidget {
  final File? image;
  Home_Screen({this.image});

  @override
  State<Home_Screen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<Home_Screen> {
  late Future<UserModel?> _userDataFuture;

  void refreshUserData() {
    setState(() {
      _userDataFuture = fetchUserData(); // Future를 새로 호출하여 데이터를 다시 가져옴
    });
  }

  @override
  void initState() {
    super.initState();
    _userDataFuture = fetchUserData();
  }

  Future<UserModel?> fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    if (doc.exists) {
      return UserModel.fromFirestore(doc);
    } else {
      print('Firestore에 사용자 데이터가 없습니다.');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(236, 95, 95, 1.0),
        elevation: 0,
        leading: SizedBox(),
      ),
      backgroundColor: Colors.white,
      body: FutureBuilder<UserModel?>(

        future: _userDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('오류 발생: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text('데이터 없음'));
          }

          final userData = snapshot.data!;

          return Center(
            child: SizedBox(
              width: 411,
              height: 707,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 80),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16), // 좌우 패딩 20
                    child: Divider(
                      color: Color.fromRGBO(236, 95, 95, 1.0),
                    ), // 구분선
                  ),
                  SizedBox(height: 10,),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${userData.mname} ❤️ ${userData.yname}',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'poppins'),
                          textAlign: TextAlign.left,
                        ),
                        SizedBox(height: 4),
                        Text(
                          '${userData.firstday.toString().substring(0, 10)} ~ ${userData.dday}일 째',
                          style: TextStyle(fontSize: 24, color: Colors.black, fontFamily: 'poppins'),
                          textAlign: TextAlign.left,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16), // 좌우 패딩 20
                    child: Divider(
                      color: Color.fromRGBO(236, 95, 95, 1.0),
                    ), // 구분선
                  ),
                  SizedBox(height: 10,),
                  // 이미지
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SizedBox(
                      width: 400,
                      height: 300,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: userData.mainimg != null && userData.mainimg!.isNotEmpty
                            ? Image.network(
                          userData.mainimg!, // Firestore에서 가져온 이미지 URL 사용
                          fit: BoxFit.cover,
                        )
                            : Center(child: Text('설정에서 이미지를 선택해주세요.')),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Spacer(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16), // 좌우 패딩 20
                    child: Divider(
                      color: Color.fromRGBO(236, 95, 95, 1.0),
                    ), // 구분선
                  ),
                  // 하단 아이콘 버튼들
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => Calendar_Screen(partnerUid: userData.yid)),
                          );
                        },
                        child: Column(
                          children: [
                            Image.asset(
                              'assets/img/calendar_month.png',
                              width: 24,
                              height: 24,
                            ),
                            SizedBox(height: 4),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => Camera_Screen()),
                          );
                        },
                        child: Column(
                          children: [
                            Image.asset(
                              'assets/img/photo_camera.png',
                              width: 24,
                              height: 24,
                            ),
                            SizedBox(height: 4),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => GalleryScreen()),
                          );
                        },
                        child: Column(
                          children: [
                            Image.asset(
                              'assets/img/broken_image.png',
                              width: 24,
                              height: 24,
                            ),
                            SizedBox(height: 4),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => Settings_Screen()),
                          ).then((result) {
                            if (result == true) {
                              refreshUserData(); // Settings_Screen에서 변경 후 돌아오면 데이터 새로고침
                            }
                          });
                        },
                        child: Column(
                          children: [
                            Image.asset(
                              'assets/img/settings.png',
                              width: 24,
                              height: 24,
                            ),
                            SizedBox(height: 4),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
