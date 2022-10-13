import 'dart:convert';

import 'package:appwrite/appwrite.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/client.dart';

final remoteFunctionCallNotifierProvider =
    StateNotifierProvider<RemoteFunctionCallNotifier, String>((ref) {
  return RemoteFunctionCallNotifier(ref.watch(clientProvider));
});

/// [RemoteFunctionCaller] class
/// This class is used to handle the calls of remote funktions
///
class RemoteFunctionCallNotifier extends StateNotifier<String> {
  // We will be getting the instance of client through a provider
  final Client client;

  // Functions object to
  late Functions functions;

  // Initialize the class with the client
  RemoteFunctionCallNotifier(this.client) : super('') {
    functions = Functions(client);
  }

  Future<void> callRemoteFunction(String functionId) async {
    try {
      final execution = await functions.createExecution(
          functionId: functionId, data: "arg1:string-argument");
      debugPrint('execution.status: ${execution.status}');
      debugPrint('execution.response: ${execution.response}');
      final result = json.decode(execution.response);
      final totalMessageCount = result['totalMessageCount'];
      state = '$totalMessageCount';
    } on AppwriteException catch (e) {
      debugPrint(e.message);
    }
  }
}
