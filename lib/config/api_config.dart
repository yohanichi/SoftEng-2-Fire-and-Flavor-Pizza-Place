import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiConfig {
  static Future<String> getBaseUrl() async {
    if (kIsWeb) {
      return "http://localhost/my_application/my_php_api";
    } else if (Platform.isAndroid) {
      return "http://10.0.2.2/my_application/my_php_api";
    } else {
      final ip = await _getHostIP();
      return "http://${ip ?? '127.0.0.1'}/my_application/my_php_api";
    }
  }

  static Future<String?> _getHostIP() async {
    try {
      for (var interface in await NetworkInterface.list()) {
        for (var addr in interface.addresses) {
          if (addr.type == InternetAddressType.IPv4 && !addr.isLoopback) {
            return addr.address;
          }
        }
      }
    } catch (_) {}
    return null;
  }
}
