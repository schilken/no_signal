import 'dart:convert' as convert;
import 'dart:convert';
import 'dart:io';

import 'package:appwrite_function/main.dart';
import 'package:test/test.dart';

class Request {
  Map<String, String> headers = {};
  String payload = '';
  Map<String, String> variables = {
    'APPWRITE_FUNCTION_ENDPOINT': 'http://192.168.2.23/v1',
    'APPWRITE_FUNCTION_PROJECT_ID': 'signal2',
    'APPWRITE_FUNCTION_API_KEY':
        'a5fecd32356ccf97560af133cdc396196edf3847903d82dbedd2e9f24a636a54492737bb390c594c2c7662b00367442edd5641370a433810598404a15f1df9b0ea7f1f34111fb7ca248959f7f34a003b83a7d852e0fa6a4a61df8426f8b935d9032a72df53a8cc9c15fb27cc7d2c3ae4868c7672f22fa74b7c269a8b7ca0d53d',
  };
}

class Response {
  String responseAsString = '';
  int statusCode = 0;
  void send(text, {int status = 200}) {
    responseAsString = text;
    statusCode = status;
  }

  void json(obj, {int status = 200}) {
    responseAsString = convert.json.encode(obj);
    statusCode = status;
  }
}

void main() {
// activate to monitor requests with Proxyman
//  HttpOverrides.global = ProxyHttpOverrides();
  test('call remote function', () async {
    final req = Request();
    req.payload = payload;

    final res = Response();
    try {
      await start(req, res);
    } on Exception catch (e) {
      print('on Exception: $e');
    }
    expect(res.responseAsString, '{"id":"1234_abcd"}');
  });

  test('createConversationId lower id first', () {
    final newId = createConversationId('12345678', 'abcdefgh');
    expect(newId, '1234_abcd');
  });

  test('createConversationId upper id first', () {
    final newId = createConversationId('abcdefgh', '12345678');
    expect(newId, '1234_abcd');
  });
}

String get payload {
  final payloadAsJson = {
    "user1Id": "12345678",
    "user2Id": "abcdefgh",
    "dbId": "db"
  };
  String payLoadAsString = jsonEncode(payloadAsJson);
  return payLoadAsString;
}

class ProxyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    const proxyUrl = '192.168.2.104:9090';
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) {
        return true;
      }
      ..findProxy = (uri) {
        if (uri.host.contains('localhost')) {
          return 'DIRECT';
        }
        print('main_with_proxy URI: $uri  -> $proxyUrl\n');
        return 'PROXY $proxyUrl';
      };
  }
}
