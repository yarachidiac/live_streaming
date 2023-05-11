import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:project_live_streaming/providers/user_provider.dart';
import 'package:project_live_streaming/resources/storage_methods.dart';
import 'package:provider/provider.dart';

import '../models/livestream.dart';
import '../utils/utils.dart';



class FirestoreMethods{
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final StorageMehtods _storageMethods = StorageMehtods();


}