import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:no_signal/models/chat.dart';

class Chatting {
  final Client client;
  late final Database database;
  late final Account account;
  late final Realtime realtime;

  // late final appwrite.Account _account;

  Chatting({required this.client}) {
    database = Database(client);
    account = Account(client);
    realtime = Realtime(client);
  }

  Future<void> sendMessage(Chat chat) async {
    try {
      await database.createDocument(
        collectionId: '613f6523da871',
        read: ['*'],
        write: ['*'],
        data: chat.toMap(),
      );
    } on AppwriteException catch (e) {
      print(e);
    }
  }

  Future<List<Chat>?> getOldMessages() async {
    try {
      final DocumentList temp =
          await database.listDocuments(collectionId: '613f6523da871');
      // print('${temp.data['documents']} temp.data print');
      final List<Chat> _chats = [];
      final response = temp.documents;
      // print(response);
      response.forEach((element) {
        _chats.add(Chat.fromMap(element.data));
      });
      return _chats;
    } on AppwriteException catch (e) {
      throw e;
    }
  }

  Future<RealtimeSubscription?> receiveMessage() async {
    try {
      RealtimeSubscription data =
          realtime.subscribe(['collections.613f6523da871.documents']);

      return data;
    } on AppwriteException catch (e) {
      print(e);
      throw e;
    }
  }
}