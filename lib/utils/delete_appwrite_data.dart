// ignore_for_file: avoid_print

import 'package:dart_appwrite/dart_appwrite.dart';

/// Function to delete all data for project 'signal2'
/// Just run this function setting your endpoint, ProjectID and APIKey
void main() async {
  Client client = Client()
      .setEndpoint('https://192.168.2.23/v1') // Replace with the endpoint
      .setProject('signal2') // Replace with your Project ID
      .setKey(
          'a5fecd32356ccf97560af133cdc396196edf3847903d82dbedd2e9f24a636a54492737bb390c594c2c7662b00367442edd5641370a433810598404a15f1df9b0ea7f1f34111fb7ca248959f7f34a003b83a7d852e0fa6a4a61df8426f8b935d9032a72df53a8cc9c15fb27cc7d2c3ae4868c7672f22fa74b7c269a8b7ca0d53d') // Replace with your API Key
      .setSelfSigned(status: true);

  const dbId = 'db';
  const bucketId = 'default';

  final db = Databases(client);
  try {
    await db.delete(databaseId: dbId);
    print("database 'db' deleted");
  } on Exception catch (e) {
    print('db.delete → exception $e');
  }

  final storage = Storage(client);
  try {
    await storage.deleteBucket(bucketId: bucketId);
    print("Bucket 'default' deleted");
  } on Exception catch (e) {
    print('storage.deleteBucket → exception $e');
  }

  final users = Users(client);
  final userList = await users.list();
  for (final user in userList.users) {
    print('${user.name} ${user.$id}');
    await users.delete(userId: user.$id);
  }
  final userListAfterDelete = await users.list();
  print('user count: ${userListAfterDelete.total}');
}
