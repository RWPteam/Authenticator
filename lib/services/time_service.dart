import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:ntp/ntp.dart';
import 'package:neap/models/settings_model.dart';
import 'package:neap/services/setting_service.dart';

class TimeService {
  static final TimeService _instance = TimeService._internal();
  factory TimeService() => _instance;
  TimeService._internal();

  final SettingsService _settingsService = SettingsService();
  AppSettings _currentSettings = AppSettings.defaults;

  DateTime? _cachedNetworkTime;
  DateTime? _lastSyncTime;
  Timer? _syncTimer;

  bool _useNetworkTime = false;
  String _ntpServer = 'pool.ntp.org';

  Future<void> init() async {
    _currentSettings = await _settingsService.getSettings();
    _useNetworkTime = _currentSettings.useNetworkTime;
    _ntpServer = _currentSettings.ntpServer;
    _startSyncTimer();
  }

  Future<void> updateSettings(AppSettings newSettings) async {
    _currentSettings = newSettings;
    final newUseNetworkTime = newSettings.useNetworkTime;
    final newNtpServer = newSettings.ntpServer;

    if (_useNetworkTime != newUseNetworkTime) {
      _useNetworkTime = newUseNetworkTime;
      if (_useNetworkTime) {
        await _syncNetworkTime();
      } else {
        _cachedNetworkTime = null;
        _lastSyncTime = null;
      }
    }

    if (_ntpServer != newNtpServer) {
      _ntpServer = newNtpServer;
      if (_useNetworkTime) {
        await _syncNetworkTime();
      }
    }

    _startSyncTimer();
  }

  void _startSyncTimer() {
    _syncTimer?.cancel();
    if (_useNetworkTime) {
      _syncTimer = Timer.periodic(const Duration(minutes: 2), (timer) {
        _syncNetworkTime();
      });
      if (_cachedNetworkTime == null) {
        _syncNetworkTime();
      }
    } else {
      _syncTimer = null;
    }
  }

  Future<void> _syncNetworkTime() async {
    try {
      final DateTime ntpTime = await NTP.now(
        lookUpAddress: _ntpServer,
        timeout: const Duration(seconds: 3),
      );
      _cachedNetworkTime = ntpTime;
      _lastSyncTime = DateTime.now();
    } catch (e) {
      debugPrint('Failed to sync network time: $e');
    }
  }

  Future<DateTime> getCurrentTime() async {
    if (!_useNetworkTime) {
      return DateTime.now();
    }

    if (_cachedNetworkTime == null || _lastSyncTime == null) {
      await _syncNetworkTime();
      if (_cachedNetworkTime == null || _lastSyncTime == null) {
        return DateTime.now();
      }
    }

    final offset = DateTime.now().difference(_lastSyncTime!);
    final estimated = _cachedNetworkTime!.add(offset);
    return estimated;
  }

  Future<int> getCurrentTimestamp() async {
    final time = await getCurrentTime();
    return time.millisecondsSinceEpoch ~/ 1000;
  }

  void dispose() {
    _syncTimer?.cancel();
  }
}
