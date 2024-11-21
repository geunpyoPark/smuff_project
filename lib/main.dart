import 'package:flutter/material.dart';
import 'package:smuff_project/screen/login_screen.dart';
import 'package:smuff_project/screen/signup_screen.dart';
import 'package:smuff_project/screen/home_screen.dart';
import 'package:smuff_project/screen/calendar_screen.dart';
import 'package:smuff_project/screen/camera_screen.dart';
import 'package:smuff_project/screen/gallery_screen.dart';
import 'package:smuff_project/screen/gallerydetail_screen.dart';
import 'package:smuff_project/screen/setting_screen.dart';
import 'package:firebase_core/firebase_core.dart';


void main() {
  runApp(
    MaterialApp(
      //home: home_screen(),
      //home: calendar_screen(),
      //home: login_screen(),
      //home: signup_screen(),
      //home: setting_screen(),
      //home: camera_screen(),
      home: gallery_screen(),
      //home: gallerydetail_screen()
    ),
  );
}