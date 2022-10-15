import 'dart:collection';
import 'dart:convert';

import 'package:appwrite/appwrite.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/client.dart';

final remoteFunctionCallerProvider = Provider<RemoteFunctionCaller>((ref) {
  return RemoteFunctionCaller(ref.watch(clientProvider));
});

/// [RemoteFunctionCaller] class
/// This class is used to handle the calls of remote funktions
///
class RemoteFunctionCaller {
  // We will be getting the instance of client through a provider
  final Client client;

  // Functions object to
  late Functions functions;

  // Initialize the class with the client
  RemoteFunctionCaller(this.client) {
    functions = Functions(client);
  }

  Future<String> callRemoteFunctionWithJsonArgs(
      String functionId, Map<String, dynamic> map) async {
    try {
      final execution = await functions.createExecution(
          functionId: functionId, data: jsonEncode(map));
      debugPrint('execution.status: ${execution.status}');
      debugPrint('execution.response: ${execution.response}');
      final result = json.decode(execution.response);
      final id = result['id'] as String;
      return id;
    } on AppwriteException catch (e) {
      debugPrint(e.message);
      rethrow;
    }
  }
}
