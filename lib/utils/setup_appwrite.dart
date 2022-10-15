// ignore_for_file: avoid_print

import 'package:dart_appwrite/dart_appwrite.dart';

/// Function to setup User Collection and bucket for project 'signal2'
/// Just run this function setting your endpoint, ProjectID and APIKey
void main() async {
  Client client = Client()
      .setEndpoint('https://192.168.2.23/v1') // Replace with the endpoint
      .setProject('signal2') // Replace with your Project ID
      .setKey(
          '6d7b1dc4d15f9a4c78381b051c133b352305be9a8c3955653aa7275ae90dfaeda25c6d846a8e6eb61d905b5fc55f82eb8422f0a847b16ed20e47bc8124a05ac94a76477766a5f6df1673ae43e7d821cf509a7147f80e7598a7796484cc6c6f369d0a142330c25c7cc9a8d26ba38fbb08d49e127374ebdac82c6b9f2211d75db8') // Replace with your API Key
      .setSelfSigned(status: true);

  Databases db = Databases(client);

  const dbId = 'db';
  const bucketId = 'default';

  await db.create(databaseId: dbId, name: dbId);

  Storage storage = Storage(client);
  await db.createCollection(
    databaseId: dbId, 
    collectionId: 'users',
    name: 'Users',
    documentSecurity: true,
    permissions: [
      Permission.read(Role.any()),
      Permission.create(Role.users()),
      Permission.update(Role.users()),
    ],
  );
  await db.createStringAttribute(
      databaseId: dbId, 
      collectionId: 'users', key: 'name', size: 256, xrequired: true);
  await db.createStringAttribute(
      databaseId: dbId, 
      collectionId: 'users', key: 'bio', size: 256, xrequired: false);
  await db.createStringAttribute(
      databaseId: dbId, 
      collectionId: 'users', key: 'imgId', size: 256, xrequired: false);
  await db.createEmailAttribute(
      databaseId: dbId, 
      collectionId: 'users', key: 'email', xrequired: true);
  await db.createStringAttribute(
      databaseId: dbId, 
      collectionId: 'users', key: 'id', size: 256, xrequired: true);
  print("Collection created");

  // Creating a new Bucket to store Profile Photos
  await storage.createBucket(
    bucketId: bucketId,
    name: 'Profile Photos',
    fileSecurity: true,
    permissions: [
      Permission.read(Role.users()),
      Permission.create(Role.users()),
      Permission.update(Role.users()),
    ],
  );
  print('Bucket Created');
}
