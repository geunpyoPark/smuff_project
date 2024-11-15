import 'package:flutter/material.dart';
import 'package:smuff_project/screen/login_screen.dart';
import 'package:smuff_project/screen/signup_screen.dart';
import 'package:smuff_project/screen/home_screen.dart';
import 'package:smuff_project/screen/calendar_screen.dart';
import 'package:smuff_project/screen/camera_screen.dart';
import 'package:smuff_project/screen/gallery_screen.dart';
import 'package:smuff_project/screen/gallerydetail_screen.dart';
import 'package:smuff_project/screen/setting_screen.dart';
import 'package:intl/date_symbol_data_local.dart'; // 올바른 intl 패키지 임포트



void main() async{

  WidgetsFlutterBinding.ensureInitialized(); // 비동기 함수 호출 전 초기화
  await initializeDateFormatting('ko_KR', null); // 한국어 로케일 초기화

  runApp(
    MaterialApp(
      //home: home_screen(),
      home: CalendarScreen(),
      // home: login_screen(),
      //home: signup_screen(),
      //home: setting_screen(),
      //home: camera_screen(),
      //home: gallery_screen(),
      //home: gallerydetail_screen()
    ),
  );
}