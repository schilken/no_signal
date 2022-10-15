import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  //static const String url = "http://192.168.2.23/v1";
  static String url =
      dotenv.env['APPWRITE_FUNCTION_ENDPOINT'] ?? 'not defined in .env';
  static String projectId =
      dotenv.env['APPWRITE_FUNCTION_PROJECT_ID'] ?? 'not defined in .env';
  static const String databaseId = "db";
}
