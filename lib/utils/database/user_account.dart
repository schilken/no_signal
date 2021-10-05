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
      File? result = await storage.createFile(
          file: await MultipartFile.fromPath('file', filePath,
              filename: imgName));
      return result.$id;
    } catch (e) {
      print(e);
    }
  }

  Future<void> addUser(String name, String bio, String url) async {
    User res = await account.get();

    try {
      await database.createDocument(collectionId: '613c3298e2a69', data: {
        'name': name,
        'bio': bio,
        'url': url,
        'email': res.email,
        'id': res.$id,
      });
    } catch (e) {
      print(e);
    }
  }

  Future<List<UserPerson>?> getUsersList() async {
    try {
      final response =
          await database.listDocuments(collectionId: '613c3298e2a69');
      final List<UserDetails> users = [];
      final temp = response.documents;
      final List<UserPerson> _users = [];

      temp.forEach((element) {
        users.add(UserDetails.fromMap(element.data));
      });
      users.forEach((element) async {
        final imgurl = await getProfilePicture(element.url as String);
        _users.add(UserPerson(
            name: element.name,
            bio: element.bio,
            id: element.id,
            email: element.email,
            image: imgurl));
      });
      return _users;
    } on AppwriteException catch (e) {
      throw e;
    }
  }

  Future<Uint8List> getProfilePicture(String fileId) async {
    try {
      final data = await storage.getFilePreview(fileId: fileId);
      return data;
    } on AppwriteException catch (e) {
      throw e;
    }
  }

  Future<Uint8List> getProfilePicturebyuserId(String id) async {
    try {
      final DocumentList response =
          await database.listDocuments(collectionId: '613c3298e2a69');
      String? pictureId;
      final temp = response.documents;
      temp.forEach((element) {
        if (element.data['id'] == id) {
          pictureId = element.data['url'];
        }
      });
      final data = await storage.getFilePreview(fileId: pictureId as String);
      return data;
    } on AppwriteException catch (e) {
      throw e;
    }
  }
}