import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// 本地存储服务
/// 负责处理应用的本地数据持久化
class LocalStorage {
  static LocalStorage? _instance;
  static SharedPreferences? _preferences;

  // 存储键常量
  static const String _keyUserSettings = 'user_settings';
  static const String _keyAppState = 'app_state';
  static const String _keyLastSync = 'last_sync';
  static const String _keyCachedData = 'cached_data';

  /// 获取单例实例
  static Future<LocalStorage> getInstance() async {
    _instance ??= LocalStorage();
    _preferences ??= await SharedPreferences.getInstance();
    return _instance!;
  }

  /// 保存用户设置
  Future<bool> saveUserSettings(Map<String, dynamic> settings) async {
    return await _preferences!.setString(
      _keyUserSettings,
      json.encode(settings),
    );
  }

  /// 获取用户设置
  Map<String, dynamic>? getUserSettings() {
    final String? data = _preferences!.getString(_keyUserSettings);
    if (data == null) return null;
    return json.decode(data) as Map<String, dynamic>;
  }

  /// 保存应用状态
  Future<bool> saveAppState(Map<String, dynamic> state) async {
    return await _preferences!.setString(
      _keyAppState,
      json.encode(state),
    );
  }

  /// 获取应用状态
  Map<String, dynamic>? getAppState() {
    final String? data = _preferences!.getString(_keyAppState);
    if (data == null) return null;
    return json.decode(data) as Map<String, dynamic>;
  }

  /// 更新最后同步时间
  Future<bool> updateLastSync() async {
    return await _preferences!.setInt(
      _keyLastSync,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// 获取最后同步时间
  DateTime? getLastSync() {
    final int? timestamp = _preferences!.getInt(_keyLastSync);
    if (timestamp == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }

  /// 缓存数据
  Future<bool> cacheData(String key, dynamic data) async {
    final Map<String, dynamic> cache = getCachedData() ?? {};
    cache[key] = data;
    return await _preferences!.setString(
      _keyCachedData,
      json.encode(cache),
    );
  }

  /// 获取缓存数据
  Map<String, dynamic>? getCachedData() {
    final String? data = _preferences!.getString(_keyCachedData);
    if (data == null) return null;
    return json.decode(data) as Map<String, dynamic>;
  }

  /// 获取特定缓存数据
  dynamic getCachedItem(String key) {
    final cache = getCachedData();
    return cache?[key];
  }

  /// 清除特定缓存数据
  Future<bool> clearCacheItem(String key) async {
    final cache = getCachedData();
    if (cache != null && cache.containsKey(key)) {
      cache.remove(key);
      return await _preferences!.setString(
        _keyCachedData,
        json.encode(cache),
      );
    }
    return true;
  }

  /// 清除所有缓存数据
  Future<bool> clearAllCache() async {
    return await _preferences!.setString(_keyCachedData, '{}');
  }

  /// 保存布尔值
  Future<bool> setBool(String key, bool value) async {
    return await _preferences!.setBool(key, value);
  }

  /// 获取布尔值
  bool? getBool(String key) {
    return _preferences!.getBool(key);
  }

  /// 保存整数
  Future<bool> setInt(String key, int value) async {
    return await _preferences!.setInt(key, value);
  }

  /// 获取整数
  int? getInt(String key) {
    return _preferences!.getInt(key);
  }

  /// 保存双精度浮点数
  Future<bool> setDouble(String key, double value) async {
    return await _preferences!.setDouble(key, value);
  }

  /// 获取双精度浮点数
  double? getDouble(String key) {
    return _preferences!.getDouble(key);
  }

  /// 保存字符串
  Future<bool> setString(String key, String value) async {
    return await _preferences!.setString(key, value);
  }

  /// 获取字符串
  String? getString(String key) {
    return _preferences!.getString(key);
  }

  /// 保存字符串列表
  Future<bool> setStringList(String key, List<String> value) async {
    return await _preferences!.setStringList(key, value);
  }

  /// 获取字符串列表
  List<String>? getStringList(String key) {
    return _preferences!.getStringList(key);
  }

  /// 检查键是否存在
  bool containsKey(String key) {
    return _preferences!.containsKey(key);
  }

  /// 删除特定键的数据
  Future<bool> remove(String key) async {
    return await _preferences!.remove(key);
  }

  /// 清除所有数据
  Future<bool> clear() async {
    return await _preferences!.clear();
  }

  /// 重新加载数据
  Future<void> reload() async {
    await _preferences!.reload();
  }
}
