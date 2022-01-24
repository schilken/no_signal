import 'dart:developer';
import 'dart:typed_data';

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:no_signal/models/user.dart';

class UserData {
  final Client client;
  late Database database;
  late Storage storage;
  late Account account;
  UserData(this.client) {
    account = Account(client);
    storage = Storage(client);
    database = Database(client);
  }

  Future<String?> addProfilePicture(String filePath, String imgName) async {
    try {
      User res = await account.get();
      File? result = await storage.createFile(
        file: await MultipartFile.fromPath('file', filePath, filename: imgName),
        fileId: 'unique()',
        read: ['role:all', 'user:${res.$id}'],
      );
      return result.$id;
    } catch (e) {
      log('$e');
      rethrow;
    }
  }

  Future<void> addUser(String name, String bio, String url) async {
    User res = await account.get();

    try {
      await account.updateName(name: name);
      await database
          .createDocument(collectionId: 'users', documentId: 'unique()', data: {
        'name': name,
        'bio': bio,
        'url': url,
        'email': res.email,
        'id': res.$id,
      }, read: [
        'role:all',
        'user:${res.$id}'
      ]);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<UserPerson>?> getUsersList() async {
    try {
      final response = await database.listDocuments(collectionId: 'users');
      final List<UserDetails> users = [];
      final temp = response.documents;
      final List<UserPerson> _users = [];

      for (var element in temp) {
        users.add(UserDetails.fromMap(element.data));
      }
      for (var element in users) {
        final imgurl = await getProfilePicture(element.url as String);
        _users.add(UserPerson(
            name: element.name,
            bio: element.bio,
            id: element.id,
            email: element.email,
            image: imgurl));
      }
      return _users;
    } on AppwriteException {
      rethrow;
    }
  }

  Future<Uint8List> getProfilePicture(String fileId) async {
    try {
      final data = await storage.getFilePreview(fileId: fileId);
      return data;
    } on AppwriteException {
      rethrow;
    }
  }

  Future<Uint8List> getProfilePicturebyuserId(String id) async {
    try {
      final DocumentList response =
          await database.listDocuments(collectionId: 'users');
      String? pictureId;
      final temp = response.documents;
      for (var element in temp) {
        if (element.data['id'] == id) {
          pictureId = element.data['url'];
        }
      }
      final data = await storage.getFilePreview(fileId: pictureId as String);
      return data;
    } on AppwriteException {
      rethrow;
    }
  }
}
