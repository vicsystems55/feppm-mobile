import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract final class AppConfig {
  static String get apiBaseUrl {
    final value = dotenv.env['API_BASE_URL']?.trim();
    if (value == null || value.isEmpty) {
      throw StateError('API_BASE_URL is missing from the .env file.');
    }

    return value.endsWith('/') ? value.substring(0, value.length - 1) : value;
  }
}
