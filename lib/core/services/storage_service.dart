import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';

/// Wraps Cloud Storage for Firebase: upload a file, get back a download URL
/// (the string you then save in Firestore), and delete by URL.
class StorageService {
  StorageService({FirebaseStorage? storage})
      : _storage = storage ?? FirebaseStorage.instance;

  final FirebaseStorage _storage;

  /// Uploads [file] under [folder] and returns its public download URL.
  ///
  /// Example: `uploadFile(file: image, folder: 'products')`.
  Future<String> uploadFile({
    required File file,
    String folder = 'uploads',
    String? fileName,
  }) async {
    final name = fileName ?? DateTime.now().millisecondsSinceEpoch.toString();
    final ext = _extensionOf(file.path);
    final ref = _storage.ref().child(folder).child('$name$ext');

    final task = await ref.putFile(file);
    return task.ref.getDownloadURL();
  }

  /// Uploads raw [bytes] (handy on web, or for in-memory images) and returns
  /// the download URL.
  Future<String> uploadBytes({
    required Uint8List bytes,
    required String folder,
    required String fileName,
    String contentType = 'image/jpeg',
  }) async {
    final ref = _storage.ref().child(folder).child(fileName);
    final task = await ref.putData(
      bytes,
      SettableMetadata(contentType: contentType),
    );
    return task.ref.getDownloadURL();
  }

  /// Deletes a file given its download URL. Safe to call for already-removed
  /// objects (it just no-ops on not-found).
  Future<void> deleteByUrl(String downloadUrl) async {
    try {
      await _storage.refFromURL(downloadUrl).delete();
    } on FirebaseException catch (e) {
      if (e.code != 'object-not-found') rethrow;
    }
  }

  String _extensionOf(String path) {
    final dot = path.lastIndexOf('.');
    return dot == -1 ? '' : path.substring(dot);
  }
}
