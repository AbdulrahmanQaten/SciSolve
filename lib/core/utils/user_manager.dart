import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserManager {
  static const int _dailyMsgLimit = 5;
  static const int _dailyImgLimit = 2;

  static bool _isPro = false;
  static int _serverMsgCount = 0;
  static int _serverImgCount = 0;

  static bool get isPro => _isPro;

  // Sync with server (call on app start)
  static Future<void> syncUsage() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    try {
      final res = await Supabase.instance.client
          .from('user_usage')
          .select()
          .eq('user_id', user.id)
          .maybeSingle();

      if (res == null) {
        // Create initial record
        await Supabase.instance.client.from('user_usage').insert({
          'user_id': user.id,
          'daily_requests': 0,
          'daily_images': 0,
          'is_pro': false
        });
        _isPro = false;
        _serverMsgCount = 0;
        _serverImgCount = 0;
      } else {
        // Check date reset
        final lastReset = DateTime.parse(res['last_reset_date'].toString());
        final now = DateTime.now();
        final isSameDay = lastReset.year == now.year &&
            lastReset.month == now.month &&
            lastReset.day == now.day;

        if (!isSameDay) {
          // Reset on server
          await Supabase.instance.client.from('user_usage').update({
            'daily_requests': 0,
            'daily_images': 0,
            'last_reset_date': DateTime.now().toIso8601String()
          }).eq('user_id', user.id);
          _serverMsgCount = 0;
          _serverImgCount = 0;
        } else {
          _serverMsgCount = res['daily_requests'] ?? 0;
          _serverImgCount = res['daily_images'] ?? 0;
        }
        _isPro = res['is_pro'] ?? false;
      }
    } catch (e) {
      print('Sync Error: $e');
    }
  }

  static Future<bool> canSendMessage(BuildContext context,
      {bool isImage = false}) async {
    if (_isPro) return true;

    // Optimistic check
    // 1. Check Total Limit (Requests) - includes images
    if (_serverMsgCount >= _dailyMsgLimit) {
      return false;
    }

    // 2. Check Image Limit
    if (isImage && _serverImgCount >= _dailyImgLimit) {
      return false;
    }
    return true;
  }

  static Future<void> incrementUsage({bool isImage = false}) async {
    if (_isPro) return;

    // Increment Total ALWAYS (Logic: Image is also a message request)
    _serverMsgCount++;

    if (isImage) {
      _serverImgCount++;
    }

    // Update server
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      // Direct update
      await Supabase.instance.client.from('user_usage').update({
        'daily_requests': _serverMsgCount,
        'daily_images': _serverImgCount
      }).eq('user_id', user.id);
    }
  }

  static Future<String> getAIStyle() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('ai_style') ?? 'balanced';
  }

  static Future<void> setAIStyle(String style) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('ai_style', style);
  }

  static Future<int> getRemainingQuestions() async {
    if (_isPro) return 999;
    return (_dailyMsgLimit - _serverMsgCount).clamp(0, _dailyMsgLimit);
  }
}
