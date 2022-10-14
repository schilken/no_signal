import 'dart:convert';

import 'package:dart_appwrite/dart_appwrite.dart';
import 'package:dart_appwrite/models.dart';

/*
  'req' variable has:
    'headers' - object with request headers
    'payload' - request body data as a string
    'variables' - object with function variables

  'res' variable has:
    'send(text, status: status)' - function to return text response. Status code defaults to 200
    'json(obj, status: status)' - function to return JSON response. Status code defaults to 200
  
  If an error is thrown, a response with code 500 will be returned.
*/

void returnFailure(final res, final message) {
  res.json({
    'success': false,
    'message': message,
  });
}

Future<void> start(final req, final res) async {
  Client client = Client();

  // You can remove services you don't use
  Databases database = Databases(client);

  String user1Id;
  String user2Id;
  String dbId;
  String id = '';
  try {
    final payload = jsonDecode(req.payload);
    user1Id = payload["user1Id"];
    user2Id = payload["user2Id"];
    dbId = payload["dbId"];
  } catch (err) {
    returnFailure(res, "Payload is invalid");
    return;
  }

  if (req.variables['APPWRITE_FUNCTION_ENDPOINT'] == null ||
      req.variables['APPWRITE_FUNCTION_API_KEY'] == null) {
    print(
        "Environment variables are not set. Function cannot use Appwrite SDK.");
  } else {
    client
        .setEndpoint(req.variables['APPWRITE_FUNCTION_ENDPOINT'])
        .setProject(req.variables['APPWRITE_FUNCTION_PROJECT_ID'])
        .setKey(req.variables['APPWRITE_FUNCTION_API_KEY'])
        .setSelfSigned(status: true);
    id = await createConversation(user1Id, user2Id, database, dbId);
  }

  res.json({
    'id': id,
  });
}

String createConversationId(String user1Id, String user2Id) {
  String sortedFirst;
  String sortedSecond;

  if (user1Id.compareTo(user2Id) < 0) {
    sortedFirst = user1Id.splitByLength((user1Id.length) ~/ 2)[0];
    sortedSecond = user2Id.splitByLength((user2Id.length) ~/ 2)[0];
  } else {
    sortedFirst = user2Id.splitByLength((user2Id.length) ~/ 2)[0];
    sortedSecond = user1Id.splitByLength((user1Id.length) ~/ 2)[0];
  }
  return ('${sortedFirst}_$sortedSecond');
}

/// This function will create a new Convo Collection between two users
/// If the collection exists or not, it will return the collection Id.
Future<String> createConversation(
    String user1Id, String user2Id, Databases database, String dbId) async {
  /// For collection id, we are using the combination of the two user id
  /// collectionId = '${curruserId/2}_${otheruserId/2}'; or
  /// Because curruser and otheruserId is interchangable for both the users
  /// Divide by 2 means we are creating a substring of the user id of length
  /// half of the current userId.
  /// Then We are concatenating those two substring with '_'.
  /// This is the collection id.
  /// Currently this is the way, I am making the collection.
  /// OfCourse, this can be improved a lot better.
  Collection? collection;
  final conversationId = createConversationId(user1Id, user2Id);
  // Check if the collection exists or not
  try {
    // We will try to get the collection in the first try
    collection = await database.getCollection(
      databaseId: dbId,
      collectionId: conversationId,
    );
  } on AppwriteException catch (e) {
    // If the collection doesn't exist, we will create it
    if (e.code == 404) {
      // Create a new collection
      collection = await database.createCollection(
        databaseId: dbId,
        collectionId: conversationId,
        name: conversationId,
        permissions: [
          Permission.read(Role.user(user1Id)),
          Permission.read(Role.user(user2Id)),
          Permission.write(Role.user(user1Id)),
          Permission.write(Role.user(user2Id)),
        ],
        documentSecurity: true,
      );
    } else {
      // If there is any other error, we will throw it
      rethrow;
    }
  }

  /// If the collection attributes are empty, then we will define those attributes
  if (collection.attributes.isEmpty) {
    await _defineDocument(collection.$id, database, dbId);
  }
  // Return the collection id
  return collection.$id;
}

/// This function will define the attributes of the collection
/// This function will be called only once when the collection is created
/// A private function cause we don't want that to be called from outside
Future<void> _defineDocument(
    String collectionId, Databases database, String dbId) async {
  // Defining attributes
  try {
    // You are free to choose your own key name.
    // But make to sure to replace those things in the model too.
    await database.createStringAttribute(
        databaseId: dbId,
        collectionId: collectionId,
        key: "sender_name",
        size: 255,
        xrequired: true);
    await database.createStringAttribute(
        databaseId: dbId,
        collectionId: collectionId,
        key: "sender_id",
        size: 255,
        xrequired: true);
    await database.createStringAttribute(
        databaseId: dbId,
        collectionId: collectionId,
        key: "message",
        size: 255,
        xrequired: true);
    await database.createStringAttribute(
        databaseId: dbId,
        collectionId: collectionId,
        key: "time",
        size: 255,
        xrequired: true);
    await database.createEnumAttribute(
        databaseId: dbId,
        collectionId: collectionId,
        key: "message_type",
        elements: ["IMAGE", "VIDEO", "TEXT"],
        xdefault: "TEXT",
        xrequired: false);
  } on AppwriteException {
    rethrow;
  }
}

extension SplitString on String {
  List<String> splitByLength(int length) =>
      [substring(0, length), substring(length)];
}
