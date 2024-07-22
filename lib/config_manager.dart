import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ConfigManager {
  static late Map<String, dynamic> _config;
  static const String _configUrl =
      'https://raw.githubusercontent.com/Ishan3842/Visitor-Badge/main/assets/config.json';
  static bool _isInitialized = false;
  static bool _needsForceUpdate = false;

  static Future<void> initialize() async {
    await _fetchRemoteConfig();
    await _checkAppVersion();
    _isInitialized = true;
  }

  static Future<void> _fetchRemoteConfig() async {
    try {
      final response = await http.get(Uri.parse(_configUrl));
      if (response.statusCode == 200) {
        print("Successfully fetched remote config");
        print("Raw config content: ${response.body}"); // Add this line
        _config = json.decode(response.body);
        await _saveConfigLocally(_config);
      } else {
        throw Exception('Failed to load config');
      }
    } catch (e) {
      print('Error fetching remote config: $e');
      await _loadLocalConfig();
    }
  }

  static Future<void> _saveConfigLocally(Map<String, dynamic> config) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('config', json.encode(config));
  }

  static Future<void> _loadLocalConfig() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? configString = prefs.getString('config');
    if (configString != null) {
      _config = json.decode(configString);
    } else {
      throw Exception('No local config available');
    }
  }

  static Future<void> _checkAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String currentVersion = packageInfo.version;
    String minRequiredVersion = _config['app_settings']['min_required_version'];

    if (_compareVersions(currentVersion, minRequiredVersion) < 0) {
      _needsForceUpdate = true;
    }
  }

  static int _compareVersions(String v1, String v2) {
    List<int> v1Parts = v1.split('.').map(int.parse).toList();
    List<int> v2Parts = v2.split('.').map(int.parse).toList();

    for (int i = 0; i < 3; i++) {
      if (v1Parts[i] > v2Parts[i]) return 1;
      if (v1Parts[i] < v2Parts[i]) return -1;
    }
    return 0;
  }

  static Future<void> showForceUpdateDialog(BuildContext context) async {
    if (_needsForceUpdate) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Update Required'),
            content: const Text(
                'A new version of the app is available. Please update the app from the store to continue using it.'),
            actions: <Widget>[
              TextButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blue,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () {
                  SystemNavigator.pop(); // This will exit the app
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  static String get appTitle => _config['app_settings']['appTitle'];
  static String get updateTitle => _config['app_settings']['update_title'];
  static String get updateMessage => _config['app_settings']['update_message'];
  static String get maintenanceTitle =>
      _config['app_settings']['maintenance_title'];
  static String get maintenanceMessage =>
      _config['app_settings']['maintenance_message'];
  static bool get isInitialized => _isInitialized;
  static bool get needsForceUpdate => _needsForceUpdate;
  static bool get maintenanceMode =>
      _config['app_settings']['maintenance_mode'];
  static String get apiBaseUrl => _config['api']['base_url'];
  static String get addVisitorEndpoint =>
      _config['api']['endpoints']['add_visitor'];
  static String get getDeviceInfoEndpoint =>
      _config['api']['endpoints']['get_device_info'];
  static String get getCompanyInfoEndpoint =>
      _config['api']['endpoints']['get_company_info'];
  static Color get primaryColor =>
      Color(int.parse(_config['ui_settings']['primary_color'].substring(1, 7),
              radix: 16) +
          0xFF000000);
  static int get apiRequestTimeout => _config['timeouts']['api_request'];
}
