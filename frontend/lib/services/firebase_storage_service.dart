import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

class FirebaseStorageService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Upload an inspection photo from File
  static Future<String?> uploadCropPhoto({
    required String uid,
    required File file,
  }) async {
    try {
      final fileName = 'photo_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage.ref().child('farmers').child(uid).child('photos').child(fileName);
      final uploadTask = await ref.putFile(
        file,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      debugPrint('FirebaseStorage: uploadCropPhoto error: $e');
      return null;
    }
  }

  /// Upload an inspection photo from raw Bytes
  static Future<String?> uploadCropPhotoBytes({
    required String uid,
    required Uint8List bytes,
  }) async {
    try {
      final fileName = 'photo_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage.ref().child('farmers').child(uid).child('photos').child(fileName);
      final uploadTask = await ref.putData(
        bytes,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      debugPrint('FirebaseStorage: uploadCropPhotoBytes error: $e');
      return null;
    }
  }

  /// Upload a temporal canopy video file
  static Future<String?> uploadCanopyVideo({
    required String uid,
    required File videoFile,
  }) async {
    try {
      final fileName = 'video_${DateTime.now().millisecondsSinceEpoch}.mp4';
      final ref = _storage.ref().child('farmers').child(uid).child('videos').child(fileName);
      final uploadTask = await ref.putFile(
        videoFile,
        SettableMetadata(contentType: 'video/mp4'),
      );
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      debugPrint('FirebaseStorage: uploadCanopyVideo error: $e');
      return null;
    }
  }
}
