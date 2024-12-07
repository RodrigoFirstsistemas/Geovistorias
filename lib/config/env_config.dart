import 'package:flutter/foundation.dart';

enum Environment {
  dev,
  staging,
  prod,
}

class EnvConfig {
  static Environment _environment = Environment.dev;
  static final Map<String, dynamic> _config = {};

  static void initialize(Environment env) {
    _environment = env;
    _loadConfig();
  }

  static void _loadConfig() {
    switch (_environment) {
      case Environment.dev:
        _config.addAll({
          'apiUrl': 'http://localhost:3000/api',
          'supabaseUrl': 'YOUR_DEV_SUPABASE_URL',
          'supabaseKey': 'YOUR_DEV_SUPABASE_KEY',
          'enableLogging': true,
          'syncInterval': const Duration(minutes: 5),
          'maxOfflineDays': 30,
          'maxFileSize': 10 * 1024 * 1024, // 10MB
          'maxPhotosPerInspection': 50,
          'compressionQuality': 0.8,
          'enableCrashlytics': false,
          'enableAnalytics': false,
        });
        break;

      case Environment.staging:
        _config.addAll({
          'apiUrl': 'https://staging-api.seudominio.com/api',
          'supabaseUrl': 'YOUR_STAGING_SUPABASE_URL',
          'supabaseKey': 'YOUR_STAGING_SUPABASE_KEY',
          'enableLogging': true,
          'syncInterval': const Duration(minutes: 15),
          'maxOfflineDays': 15,
          'maxFileSize': 8 * 1024 * 1024, // 8MB
          'maxPhotosPerInspection': 30,
          'compressionQuality': 0.7,
          'enableCrashlytics': true,
          'enableAnalytics': true,
        });
        break;

      case Environment.prod:
        _config.addAll({
          'apiUrl': 'https://api.seudominio.com/api',
          'supabaseUrl': 'YOUR_PROD_SUPABASE_URL',
          'supabaseKey': 'YOUR_PROD_SUPABASE_KEY',
          'enableLogging': false,
          'syncInterval': const Duration(minutes: 30),
          'maxOfflineDays': 7,
          'maxFileSize': 5 * 1024 * 1024, // 5MB
          'maxPhotosPerInspection': 20,
          'compressionQuality': 0.6,
          'enableCrashlytics': true,
          'enableAnalytics': true,
        });
        break;
    }
  }

  static T getValue<T>(String key) {
    if (!_config.containsKey(key)) {
      throw Exception('Configuration key $key not found for environment $_environment');
    }
    return _config[key] as T;
  }

  static bool get isDevelopment => _environment == Environment.dev;
  static bool get isStaging => _environment == Environment.staging;
  static bool get isProduction => _environment == Environment.prod;
  
  static Environment get environment => _environment;
  static String get apiUrl => getValue<String>('apiUrl');
  static String get supabaseUrl => getValue<String>('supabaseUrl');
  static String get supabaseKey => getValue<String>('supabaseKey');
  static bool get enableLogging => getValue<bool>('enableLogging');
  static Duration get syncInterval => getValue<Duration>('syncInterval');
  static int get maxOfflineDays => getValue<int>('maxOfflineDays');
  static int get maxFileSize => getValue<int>('maxFileSize');
  static int get maxPhotosPerInspection => getValue<int>('maxPhotosPerInspection');
  static double get compressionQuality => getValue<double>('compressionQuality');
  static bool get enableCrashlytics => getValue<bool>('enableCrashlytics');
  static bool get enableAnalytics => getValue<bool>('enableAnalytics');
}
