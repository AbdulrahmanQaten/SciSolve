import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:scisolve/core/constants/supabase_constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatService extends ChangeNotifier {
  // Singleton
  static final ChatService _instance = ChatService._internal();
  factory ChatService() => _instance;
  ChatService._internal() {
    _initStreams();
  }

  final SupabaseClient _supabase = Supabase.instance.client;
  final String _functionUrl =
      '${SupabaseConstants.url}/functions/v1/chat-completion';

  // Data
  List<Map<String, dynamic>> _chats = [];
  List<Map<String, dynamic>> _folders = [];
  bool _isLoading = true;

  // Getters
  List<Map<String, dynamic>> get chats => _chats;
  List<Map<String, dynamic>> get folders => _folders;
  bool get isLoading => _isLoading;

  // Stream subscriptions
  StreamSubscription? _chatsSubscription;
  StreamSubscription? _foldersSubscription;

  void _initStreams() {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    // Subscribe to chats
    _chatsSubscription = _supabase
        .from('chats')
        .stream(primaryKey: ['id'])
        .eq('user_id', user.id)
        .order('updated_at', ascending: false)
        .listen((data) {
          _chats = List<Map<String, dynamic>>.from(data);
          _isLoading = false;
          notifyListeners();
        });

    // Subscribe to folders
    _foldersSubscription = _supabase
        .from('folders')
        .stream(primaryKey: ['id'])
        .eq('user_id', user.id)
        .order('created_at', ascending: false)
        .listen((data) {
          _folders = List<Map<String, dynamic>>.from(data);
          notifyListeners();
        });
  }

  // Reinitialize streams (e.g., after login)
  void reinitialize() {
    _chatsSubscription?.cancel();
    _foldersSubscription?.cancel();
    _chats = [];
    _folders = [];
    _isLoading = true;
    notifyListeners();
    _initStreams();
  }

  @override
  void dispose() {
    _chatsSubscription?.cancel();
    _foldersSubscription?.cancel();
    super.dispose();
  }

  // --- CRUD Operations ---

  Future<String> createChat(String title, {String? folderId}) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    final res = await _supabase
        .from('chats')
        .insert({'user_id': user.id, 'title': title, 'folder_id': folderId})
        .select()
        .single();

    return res['id'];
  }

  Future<void> createFolder(String name) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;
    await _supabase.from('folders').insert({'user_id': user.id, 'name': name});
  }

  Future<void> deleteFolder(String folderId) async {
    await _supabase.from('folders').delete().eq('id', folderId);
  }

  Future<void> renameFolder(String folderId, String newName) async {
    await _supabase
        .from('folders')
        .update({'name': newName}).eq('id', folderId);
  }

  Future<void> moveChatToFolder(String chatId, String? folderId) async {
    await _supabase
        .from('chats')
        .update({'folder_id': folderId}).eq('id', chatId);
  }

  Future<void> deleteChat(String chatId) async {
    await _supabase.from('chats').delete().eq('id', chatId);
  }

  Future<void> renameChat(String chatId, String newTitle) async {
    await _supabase.from('chats').update({'title': newTitle}).eq('id', chatId);
  }

  Future<List<Map<String, dynamic>>> getMessages(String chatId) async {
    final res = await _supabase
        .from('messages')
        .select()
        .eq('chat_id', chatId)
        .order('created_at', ascending: true);
    return List<Map<String, dynamic>>.from(res);
  }

  Future<void> saveMessage({
    required String chatId,
    required String role,
    required String content,
    String? image,
  }) async {
    await _supabase.from('messages').insert(
        {'chat_id': chatId, 'role': role, 'content': content, 'image': image});

    await _supabase.from('chats').update(
        {'updated_at': DateTime.now().toIso8601String()}).eq('id', chatId);
  }

  Stream<String> streamMessage(List<Map<String, dynamic>> messages,
      {String aiStyle = 'balanced'}) async* {
    final client = http.Client();
    final request = http.Request('POST', Uri.parse(_functionUrl));

    request.headers.addAll({
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${SupabaseConstants.anonKey}',
      'apikey': SupabaseConstants.anonKey,
    });

    final validMessages =
        messages.where((m) => m['content'].toString().isNotEmpty).toList();

    final contextMessages = validMessages.length > 20
        ? validMessages.sublist(validMessages.length - 20)
        : validMessages;

    request.body =
        jsonEncode({'messages': contextMessages, 'aiStyle': aiStyle});

    try {
      final response = await client.send(request);

      if (response.statusCode != 200) {
        final errorBody = await response.stream.bytesToString();
        try {
          final jsonError = jsonDecode(errorBody);
          throw Exception(
              jsonError['error'] ?? 'Server Error: ${response.statusCode}');
        } catch (_) {
          throw Exception('Server Error: ${response.statusCode} - $errorBody');
        }
      }

      await for (final chunk in response.stream.transform(utf8.decoder)) {
        final lines = chunk.split('\n');
        for (final line in lines) {
          if (line.startsWith('data: ')) {
            final dataStr = line.substring(6).trim();
            if (dataStr == '[DONE]') return;

            try {
              final json = jsonDecode(dataStr);
              if (json['candidates'] != null) {
                final candidates = json['candidates'] as List;
                if (candidates.isNotEmpty) {
                  final content = candidates[0]['content'];
                  if (content != null && content['parts'] != null) {
                    final parts = content['parts'] as List;
                    if (parts.isNotEmpty) {
                      final text = parts[0]['text'];
                      if (text != null) yield text;
                    }
                  }
                }
              } else if (json['text'] != null) {
                yield json['text'];
              }
            } catch (e) {
              // Skip malformed
            }
          }
        }
      }
    } catch (e) {
      throw Exception('Connection Error: $e');
    } finally {
      client.close();
    }
  }
}
