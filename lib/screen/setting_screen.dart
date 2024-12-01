import 'package:flutter/material.dart';
import 'package:smuff_project/screen/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:smuff_project/model/user_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:smuff_project/screen/login_screen.dart';
import 'package:flutter/services.dart';

class Settings_Screen extends StatefulWidget {
  @override
  State<Settings_Screen> createState() => _Settings_ScreenState();
}

class _Settings_ScreenState extends State<Settings_Screen> {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  DateTime firstday = DateTime.now();
  late Future<UserModel?> _userDataFuture;
  final TextEditingController _otherUidController = TextEditingController();
  String _myUid = FirebaseAuth.instance.currentUser?.uid ?? '';
  String _partnerStatus = ''; // 연결 상태 메시지

  @override
  void initState() {
    super.initState();
    _userDataFuture = fetchUserData();
  }

  Future<UserModel?> fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    if (doc.exists) {
      return UserModel.fromFirestore(doc);
    } else {
      print('Firestore에 사용자 데이터가 없습니다.');
      return null;
    }
  }

  Future<void> signOut() async {
    await googleSignIn.signOut();
    await FirebaseAuth.instance.signOut();
  }

  void _selectDate() {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        DateTime selectedDate = firstday;
        return Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            color: Colors.white,
            height: 300,
            child: Column(
              children: [
                Expanded(
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.date,
                    initialDateTime: selectedDate,
                    onDateTimeChanged: (DateTime date) {
                      setState(() {
                        selectedDate = date;
                      });
                    },
                  ),
                ),
                CupertinoButton(
                  child: Text("확인"),
                  onPressed: () {
                    int dday =
                        DateTime.now().difference(selectedDate).inDays + 1;
                    setState(() {
                      firstday = selectedDate;
                    });

                    saveDateToFirestore(selectedDate, dday);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
      barrierDismissible: true,
    );
  }
  void saveDateToFirestore(DateTime selectedDate, int dday) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      final docRef =
          FirebaseFirestore.instance.collection('users').doc(user.uid);
      await docRef.update({
        'firstday': Timestamp.fromDate(selectedDate.toUtc()),
        'dday': dday,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('날짜가 저장되었습니다.')),
      );
    } catch (e) {
      print('오류 발생: $e');
    }
  }
  //파이어베이스에서 이미지 선택하기
  void _pickImage() async {
    final currentUser = FirebaseAuth.instance.currentUser; // Rename variable
    if (currentUser == null) return;

    final storageRef = FirebaseStorage.instance.ref().child('${currentUser.uid}/');
    final ListResult result = await storageRef.listAll();

    if (result.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('이미지가 없습니다.')),
      );
      return;
    }
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ListView.builder(
          itemCount: result.items.length,
          itemBuilder: (context, index) {
            final imageRef = result.items[index];
            return ListTile(
              leading: FutureBuilder(
                future: imageRef.getDownloadURL(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done &&
                      snapshot.hasData) {
                    return Image.network(snapshot.data!,
                        width: 50, height: 50, fit: BoxFit.cover);
                  }
                  return CircularProgressIndicator();
                },
              ),
              title: Text('이미지 ${index + 1}'),
              onTap: () async {
                final imageUrl = await imageRef.getDownloadURL();
                await saveimgurlToFirestore(imageUrl);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Home_Screen(),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
//이미지url을 파이어베이스에 저장하기
  Future<void> saveimgurlToFirestore(String imageUrl) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final docRef =
          FirebaseFirestore.instance.collection('users').doc(user.uid);
      await docRef.update({'mainimg': imageUrl});
    } catch (e) {
      print('오류 발생: $e');
    }
  }
  Future<void> requestConnection(String myUid, String otherUid) async {
    try {
      // 상대방의 데이터 가져오기
      final otherUserDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(otherUid)
          .get();

      if (otherUserDoc.exists) {
        final otherUserName = otherUserDoc.data()?['mname'] ?? 'Unknown'; // 'name'을 'mname'으로 수정

        // 내 데이터베이스에 연결 정보 저장
        await FirebaseFirestore.instance.collection('users').doc(myUid).update({
          'connections': FieldValue.arrayUnion([
            {'uid': otherUid, 'name': otherUserName}
          ]),
          'yid': otherUid, // 상대방 UID 저장
          'yname': otherUserName // 상대방 이름 저장
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('연결 요청 성공: $otherUserName님과 연결되었습니다.')),
        );

        setState(() {
          _partnerStatus = '연결 완료: $otherUserName님과 연결되었습니다.';
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('존재하지 않는 사용자 UID입니다.')),
        );

        setState(() {
          _partnerStatus = '연결 실패: 존재하지 않는 사용자 UID입니다.';
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('연결 요청 중 오류 발생: $e')),
      );

      setState(() {
        _partnerStatus = '연결 실패: 오류가 발생했습니다.';
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              height: 720,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 20),
                    SizedBox(
                      height: 30  ,
                      child: Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.home, color: Colors.black),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Home_Screen()),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start, // 왼쪽 정렬
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 16.0, bottom: 8.0), // 왼쪽 여백 16px, 아래 여백 8px
                          child: Text(
                            '앱 설정',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                                color: Color.fromRGBO(236, 95, 95, 1.0) , // 완전 불투명한 빨간색

                            ),
                          ),
                        ),
                        Divider(
                          color: Color.fromRGBO(236, 95, 95, 1.0),
                        ), // 구분선
                      ],
                    ),
                    SizedBox(height: 20),

                    // 배경 사진 선택 버튼
                    SizedBox(
                      width: 300,
                      height: 50,
                      child: OutlinedButton(
                        onPressed: _pickImage,
                        child: Text('홈 화면 사진 선택',
                          style: TextStyle(color: Colors.black, fontFamily: 'poppins',fontWeight: FontWeight.bold)),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20,),
                    // 날짜 설정 버튼
                    SizedBox(
                      width: 300,
                      height: 50,
                      child: OutlinedButton(
                        onPressed: _selectDate,
                        child: Text('디데이 날짜 설정',
                          style: TextStyle(color: Colors.black , fontFamily: 'poppins', fontWeight: FontWeight.bold)),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 40),
                    // 계정 설정 제목과 구분선
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start, // 왼쪽 정렬
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 16.0, bottom: 8.0), // 왼쪽 여백 16px, 아래 여백 8px
                          child: Text(
                            '계정 설정  ',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color.fromRGBO(236, 95, 95, 1.0) , // 완전 불투명한 빨간색

                            ),
                          ),
                        ),
                        Divider(
                          color: Color.fromRGBO(236, 95, 95, 1.0),
                        ), // 구분선
                      ],
                    ),
                    SizedBox(height: 20),
                    // UID 복사 버튼
                    SizedBox(
                      width: 300,
                      height: 50,
                      child: OutlinedButton(
                        onPressed: () {
                          // UID 복사
                          Clipboard.setData(ClipboardData(text: _myUid));
                          // SnackBar 표시
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('UID가 복사되었습니다.')),
                          );
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,  // Row 내부의 자식 요소들이 최소 크기만 차지하도록 설정
                          children: [
                            Text(
                              '$_myUid',
                              style: TextStyle(fontSize: 16,
                                color: Colors.black),
                            ),
                          ],
                        ),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20,),
                    // 상대방 UID 입력
                    SizedBox(
                      width: 300,
                      height: 50,
                      child: OutlinedButton(
                        onPressed: () {
                          // 상대방 UID 입력 창 띄우기
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text('상대방 UID 입력',
                                  style: TextStyle(color: Colors.black),),
                                content: TextField(
                                  controller: _otherUidController,
                                  decoration: InputDecoration(
                                    border: UnderlineInputBorder(), // 밑줄만 표시되는 디자인
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      String yid = _otherUidController.text;
                                      if (yid.isNotEmpty) {
                                        // 연결 요청 (데이터베이스에 저장)
                                        // 여기에 직접 _myUid를 사용하여 requestConnection 호출
                                        requestConnection(_myUid, yid);  // myUid는 현재 사용자의 UID
                                        Navigator.pop(context);  // 다이얼로그 닫기
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('UID를 입력해주세요.')),
                                        );
                                      }
                                    },
                                    child: Text('확인'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);  // 취소 버튼 클릭 시 다이얼로그 닫기
                                    },
                                    child: Text('취소'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: Text('상대방 uid 입력'),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 20),
                    // 연결 상태 메시지
                    if (_partnerStatus.isNotEmpty)
                      Text(
                        _partnerStatus,
                        style: TextStyle(
                          fontSize: 14,
                          color: _partnerStatus.startsWith("연결 완료") ||
                              _partnerStatus.startsWith("이미 연결되었습니다.")
                              ? Colors.green
                              : Colors.red,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    SizedBox(height: 20),

                    // 로그아웃 버튼
                    SizedBox(
                      width: 300,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () async {
                          await signOut();
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (_) => Login_Screen()),
                          );
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.logout,
                              size: 30.0,
                              color: Colors.white,
                            ),
                            SizedBox(width: 10),
                            Text(
                              '로그아웃',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
