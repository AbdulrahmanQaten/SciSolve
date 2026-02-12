import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:scisolve/core/utils/sci_toast.dart';
import '../widgets/message_bubble.dart';
import '../widgets/app_drawer.dart';
import 'package:scisolve/core/utils/user_manager.dart';
import 'package:scisolve/features/subscription/presentation/screens/subscription_screen.dart';
import 'package:scisolve/core/services/chat_service.dart';
import 'dart:math';
import 'package:scisolve/core/services/chat_service.dart';
import 'dart:io';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class ChatScreen extends StatefulWidget {
  final String? initialQuery;
  final String? chatId;
  const ChatScreen({super.key, this.initialQuery, this.chatId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  XFile? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  final ChatService _chatService = ChatService();

  bool _isGenerating = false;
  String? _customChatTitle;
  String? _currentChatId;
  List<Map<String, dynamic>> _messages = [];
  bool _showScrollButton = false;

  @override
  void initState() {
    super.initState();
    _currentChatId = widget.chatId;
    UserManager.syncUsage();

    // Listen to scroll position
    _scrollController.addListener(_onScroll);

    if (_currentChatId != null) {
      _loadMessages();
    } else if (widget.initialQuery != null) {
      _handleSearch(widget.initialQuery!);
    }
  }

  void _onScroll() {
    if (_scrollController.hasClients) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.offset;
      final threshold = 200.0; // Show button if 200px from bottom

      final shouldShow = (maxScroll - currentScroll) > threshold;

      if (shouldShow != _showScrollButton) {
        setState(() => _showScrollButton = shouldShow);
      }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    try {
      final history = await _chatService.getMessages(_currentChatId!);
      if (!mounted) return;
      setState(() {
        _messages = history.map((m) {
          return {
            "id": m['id'] ?? "",
            "content": m['content'] ?? "",
            "isUser": m['role'] == 'user',
            "image": m['image'] // Assuming base64 string
          };
        }).toList();
      });
      // Scroll to bottom after frame
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    } catch (e) {
      if (mounted) {
        SciToast.show(context, "Error loading chat: $e", isError: true);
      }
    }
  }

  String _getGreeting(AppLocalizations l10n) {
    return l10n.welcomeMessage;
  }

  void _renameChat(AppLocalizations l10n) async {
    if (_currentChatId == null) return;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF141414) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;

    final controller =
        TextEditingController(text: _customChatTitle ?? l10n.newChat);
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              backgroundColor: bgColor,
              title: Text(l10n.renameChat, style: TextStyle(color: textColor)),
              content: TextField(
                controller: controller,
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                    enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: isDark ? Colors.white24 : Colors.black12))),
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: Text(l10n.cancel)),
                TextButton(
                    onPressed: () async {
                      final newTitle = controller.text;
                      await _chatService.renameChat(_currentChatId!, newTitle);
                      setState(() => _customChatTitle = newTitle);
                      Navigator.pop(ctx);
                    },
                    child: Text(l10n.save, style: TextStyle(color: textColor))),
              ],
            ));
  }

  void _deleteChat(AppLocalizations l10n) async {
    if (_currentChatId == null) {
      setState(() {
        _messages.clear();
        _selectedImage = null;
      });
      return;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF141414) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;

    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              backgroundColor: bgColor,
              title: Text(l10n.deleteChat, style: TextStyle(color: textColor)),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: Text(l10n.cancel)),
                TextButton(
                    onPressed: () async {
                      await _chatService.deleteChat(_currentChatId!);
                      setState(() {
                        _messages.clear();
                        _customChatTitle = null;
                        _currentChatId = null; // Reset to new chat mode
                      });
                      Navigator.pop(ctx);
                    },
                    child: Text(l10n.delete,
                        style: const TextStyle(color: Colors.red))),
              ],
            ));
  }

  ChatFolder? _currentChatFolder; // Track current folder (mock)

  void _moveToFolder(AppLocalizations l10n) {
    // ... existing implementation (Folder logic needs update later) ...
    // For now keep mock folder logic or update if folders are in DB
    // Skipping complex folder DB logic for now to focus on persistence
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF141414) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    // ... (Rest of UI)
    // Since this block is replacing top to 170, I can leave folder logic as is
    // but the signature of replace changed.
    // I will just put the original folder logic here for now.
    final iconColor = isDark ? Colors.white54 : Colors.black54;

    showModalBottomSheet(
        context: context,
        backgroundColor: bgColor,
        builder: (ctx) {
          return Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l10n.moveTo,
                    style: TextStyle(
                        color: textColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                // Mock items
                ListTile(
                  leading: Icon(Icons.grid_view, color: iconColor),
                  title: Text(l10n.general, style: TextStyle(color: textColor)),
                  onTap: () {
                    Navigator.pop(ctx);
                  },
                )
              ],
            ),
          );
        });
  }

  void _showAttachmentMenu(AppLocalizations l10n) {
    // ... existing
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF141414) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;

    showModalBottomSheet(
        context: context,
        backgroundColor: bgColor,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (ctx) {
          return Container(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text(l10n.attachFile,
                    style: TextStyle(
                        color: textColor.withOpacity(0.5), fontSize: 14)),
                const SizedBox(height: 16),
                ListTile(
                    leading: FaIcon(FontAwesomeIcons.camera, color: textColor),
                    title:
                        Text(l10n.camera, style: TextStyle(color: textColor)),
                    onTap: () {
                      Navigator.pop(ctx);
                      _pickImage(ImageSource.camera);
                    }),
                ListTile(
                    leading: FaIcon(FontAwesomeIcons.image, color: textColor),
                    title:
                        Text(l10n.gallery, style: TextStyle(color: textColor)),
                    onTap: () {
                      Navigator.pop(ctx);
                      _pickImage(ImageSource.gallery);
                    }),
              ]));
        });
  }

  // ... scanDocument ...
  Future<void> _scanDocument() async {
    // ... existing ...
    if (kIsWeb) {
      SciToast.show(context, "Scanning not supported on Web", isError: true);
      return;
    }
    try {
      final List<String>? pictures = await CunningDocumentScanner.getPictures();
      if (pictures != null && pictures.isNotEmpty) {
        setState(() {
          _selectedImage = XFile(pictures[0]);
        });
      }
    } catch (e) {
      SciToast.show(context, "Failed to scan: $e", isError: true);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(
      source: source,
      imageQuality: 50, // Compress image
      maxWidth: 800, // Limit resolution
    );
    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  Future<List<Map<String, dynamic>>> _prepareHistoryForApi() async {
    // Exclude the last message (AI placeholder)
    final allMsgs = _messages.take(_messages.length - 1).toList();

    // IMPORTANT: Limit to last 20 messages (10 exchanges) to prevent context overflow
    final msgs =
        allMsgs.length > 20 ? allMsgs.sublist(allMsgs.length - 20) : allMsgs;

    return msgs.asMap().entries.map((entry) {
      final index = entry.key;
      final msg = entry.value;
      final isCurrentMessage =
          (index == msgs.length - 1); // Last in history = current user msg

      // Send image ONLY for the current message, not old ones
      if (isCurrentMessage && msg['image'] != null) {
        return {
          "role": msg['isUser'] ? "user" : "assistant",
          "content": [
            {"type": "text", "text": msg['content']},
            {
              "type": "image_url",
              "image_url": {"url": "data:image/jpeg;base64,${msg['image']}"}
            }
          ]
        };
      } else {
        // Old messages: text only (images already OCR'd)
        return {
          "role": msg['isUser'] ? "user" : "assistant",
          "content": msg['content']
        };
      }
    }).toList();
  }

  void _handleSearch(String query) {
    if (query.trim().isEmpty) return;
    if (_messages.isEmpty && _currentChatId == null) {
      // Optimistic title set
      setState(() => _customChatTitle =
          query.length > 20 ? "${query.substring(0, 20)}..." : query);
    }
    _handleLimitAndSend(query);
  }

  Future<void> _handleLimitAndSend(String query) async {
    final l10n = AppLocalizations.of(context)!;

    // Check Daily Limit
    final canProceed = await UserManager.canSendMessage(context,
        isImage: _selectedImage != null);

    if (!canProceed) {
      if (!mounted) return;
      _showLimitDialog(l10n);
      return;
    }

    // Increment local/server count
    await UserManager.incrementUsage(isImage: _selectedImage != null);

    if (!mounted) return;

    String? imageBase64;
    if (_selectedImage != null) {
      final bytes = await _selectedImage!.readAsBytes();
      imageBase64 = base64Encode(bytes);
    }

    final messageId = DateTime.now().toString();
    setState(() {
      _messages.add({
        "id": messageId,
        "content": query,
        "isUser": true,
        "image": imageBase64
      });
      _selectedImage = null; // Clear after sending
      _isGenerating = true;
      _controller.clear();

      // Add placeholder for AI response
      _messages.add({
        "id": "ai_$messageId",
        "content": "", // Start empty
        "isUser": false
      });
    });

    _scrollToBottom();

    try {
      // 1. Create Chat if needed
      if (_currentChatId == null) {
        final title =
            query.length > 30 ? "${query.substring(0, 30)}..." : query;
        _currentChatId = await _chatService.createChat(title);
        if (mounted) setState(() => _customChatTitle = title);
      }

      // 2. Save User Message
      await _chatService.saveMessage(
          chatId: _currentChatId!,
          role: 'user',
          content: query,
          image: imageBase64);

      final style = await UserManager.getAIStyle();
      final historyToSend = await _prepareHistoryForApi();

      String fullResponse = "";

      await for (final chunk
          in _chatService.streamMessage(historyToSend, aiStyle: style)) {
        fullResponse += chunk;
        if (!mounted) return;
        setState(() {
          // Update the last message (AI placeholder)
          _messages.last['content'] = fullResponse;
        });
        _scrollToBottom();
      }

      // 3. Save Assistant Message
      await _chatService.saveMessage(
          chatId: _currentChatId!, role: 'assistant', content: fullResponse);

      if (!mounted) return;
      setState(() => _isGenerating = false);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isGenerating = false;
        // If error validation, maybe remove the empty AI message or show error in it
        if (_messages.last['content'] == "") {
          _messages.removeLast();
        }
      });
      SciToast.show(context, l10n.errorOccurred + ": $e", isError: true);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(_scrollController.position.maxScrollExtent,
            duration: 300.ms, curve: Curves.easeOut);
      }
    });
  }

  void _showStyleDialog() async {
    final l10n = AppLocalizations.of(context)!;
    final current = await UserManager.getAIStyle();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final bgColor = isDark ? const Color(0xFF141414) : Colors.white;

    if (!mounted) return;

    showDialog(
        context: context,
        builder: (ctx) => SimpleDialog(
                backgroundColor: bgColor,
                title:
                    Text(l10n.chooseStyle, style: TextStyle(color: textColor)),
                children: [
                  _buildStyleOption(
                      ctx, l10n.styleDetailed, "detailed", current, textColor),
                  _buildStyleOption(
                      ctx, l10n.styleBalanced, "balanced", current, textColor),
                  _buildStyleOption(
                      ctx, l10n.styleConcise, "concise", current, textColor),
                ]));
  }

  Widget _buildStyleOption(BuildContext ctx, String label, String value,
      String current, Color textColor) {
    final l10n = AppLocalizations.of(context)!;
    return SimpleDialogOption(
        onPressed: () async {
          await UserManager.setAIStyle(value);
          if (!mounted) return;
          Navigator.pop(ctx);
          SciToast.show(context, l10n.styleSet(label));
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(children: [
            Icon(
                current == value
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off,
                size: 16,
                color: textColor),
            const SizedBox(width: 12),
            Text(label, style: TextStyle(color: textColor, fontSize: 16))
          ]),
        ));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? Colors.black : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    final chatTitle = _customChatTitle ?? l10n.newChat;

    return Scaffold(
      backgroundColor: bgColor,
      drawer: AppDrawer(currentChatId: _currentChatId),
      appBar: AppBar(
        titleSpacing: 0,
        backgroundColor: bgColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: textColor),
        title: GestureDetector(
          onTap: () => _renameChat(l10n),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Flexible(
                child: Text(chatTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textColor))),
            if (_messages.isNotEmpty)
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Icon(Icons.edit_outlined,
                      size: 12, color: textColor.withOpacity(0.3)))
          ]),
        ),
        actions: [
          if (_messages.isNotEmpty)
            PopupMenuButton<String>(
                icon: Icon(Icons.more_horiz, color: textColor.withOpacity(0.5)),
                color: isDark ? const Color(0xFF141414) : Colors.white,
                onSelected: (val) {
                  if (val == 'style') _showStyleDialog();
                  if (val == 'rename') _renameChat(l10n);
                  if (val == 'move') _moveToFolder(l10n);
                  if (val == 'delete') _deleteChat(l10n);
                },
                itemBuilder: (ctx) => [
                      PopupMenuItem(
                          value: 'style',
                          child: Text(l10n.aiStyle,
                              style: TextStyle(color: textColor))),
                      PopupMenuItem(
                          value: 'rename',
                          child: Text(l10n.renameChat,
                              style: TextStyle(color: textColor))),
                      PopupMenuItem(
                          value: 'move',
                          child: Text(l10n.moveToFolder,
                              style: TextStyle(color: textColor))),
                      PopupMenuItem(
                          value: 'delete',
                          child: Text(l10n.delete,
                              style: const TextStyle(color: Colors.red)))
                    ])
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                  child: _messages.isEmpty
                      ? Center(
                          child: Padding(
                              padding: const EdgeInsets.all(32),
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    FaIcon(FontAwesomeIcons.atom,
                                        size: 48,
                                        color: textColor.withOpacity(0.1)),
                                    const SizedBox(height: 24),
                                    Text(_getGreeting(l10n),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: textColor.withOpacity(0.4),
                                            fontSize: 16,
                                            letterSpacing: 1))
                                  ])))
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 20),
                          itemCount: _messages.length + (_isGenerating ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == _messages.length) {
                              return Padding(
                                  padding: const EdgeInsets.only(
                                      left: 20, top: 10, right: 20),
                                  child: Text(l10n.thinking,
                                      style: TextStyle(
                                          color: textColor.withOpacity(0.4),
                                          fontSize: 12)));
                            }
                            final msg = _messages[index];
                            // Hide actions only if this is the generic AI message AND we are currently generating
                            // Since new messages are added to the end, the last one is the partial one.
                            final isLastAndGenerating =
                                _isGenerating && index == _messages.length - 1;

                            return MessageBubble(
                              key: ValueKey(msg['id'] ??
                                  index), // Add key to prevent rebuilds
                              content: msg['content'],
                              isUser: msg['isUser'],
                              imageBase64: msg['image'],
                              showActions: !isLastAndGenerating,
                            );
                          })),
              _buildInputArea(l10n),
            ],
          ),
          // Floating scroll-to-bottom button
          if (_showScrollButton)
            Positioned(
              bottom: 100,
              right: 16,
              child: FloatingActionButton(
                mini: true,
                backgroundColor: isDark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.05),
                onPressed: _scrollToBottom,
                child: Icon(
                  Icons.keyboard_arrow_down,
                  color: textColor,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInputArea(AppLocalizations l10n) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final containerColor = isDark ? const Color(0xFF1A1A1A) : Colors.grey[100];
    final borderColor =
        isDark ? Colors.white.withOpacity(0.08) : Colors.black12;
    final textColor = isDark ? Colors.white : Colors.black;
    final hintColor = isDark ? Colors.white38 : Colors.black38;
    final footerColor = isDark ? Colors.white24 : Colors.black38;

    return Container(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: SafeArea(
            child: Column(children: [
          if (_selectedImage != null)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              height: 100,
              width: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                    image: kIsWeb
                        ? NetworkImage(_selectedImage!.path)
                        : FileImage(File(_selectedImage!.path))
                            as ImageProvider,
                    fit: BoxFit.cover),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedImage = null),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                            color: Colors.black54, shape: BoxShape.circle),
                        child: const Icon(Icons.close,
                            size: 16, color: Colors.white),
                      ),
                    ),
                  )
                ],
              ),
            ),
          Container(
              decoration: BoxDecoration(
                  color: containerColor,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: borderColor)),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                IconButton(
                    icon: FaIcon(FontAwesomeIcons.plus,
                        size: 16, color: hintColor),
                    onPressed: () => _showAttachmentMenu(l10n)),
                Expanded(
                    child: ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 120),
                        child: TextField(
                            controller: _controller,
                            focusNode: _focusNode,
                            enabled: true,
                            style: TextStyle(color: textColor, fontSize: 16),
                            maxLines: null,
                            textInputAction: TextInputAction.send,
                            decoration: InputDecoration(
                                hintText: l10n.typeMessage,
                                hintStyle: TextStyle(color: hintColor),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 12)),
                            onChanged: (_) => setState(() {})))),
                Container(
                    margin: const EdgeInsets.only(bottom: 4, right: 4),
                    decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF333333) : Colors.white,
                        shape: BoxShape.circle),
                    child: IconButton(
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 40,
                          minHeight: 40,
                        ),
                        onPressed: (_isGenerating ||
                                (_controller.text.isEmpty &&
                                    _selectedImage == null))
                            ? null
                            : () => _handleSearch(_controller.text),
                        icon: _isGenerating
                            ? SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: textColor))
                            : FaIcon(FontAwesomeIcons.arrowUp,
                                size: 14,
                                color: (_controller.text.isEmpty &&
                                        _selectedImage == null)
                                    ? (isDark ? Colors.white38 : Colors.grey)
                                    : textColor)))
              ])),
          const SizedBox(height: 8),
          Text(l10n.poweredBy,
              style: TextStyle(color: footerColor, fontSize: 10))
        ])));
  }

  void _showLimitDialog(AppLocalizations l10n) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF141414) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: bgColor,
        title: Text(l10n.dailyLimitReached, style: TextStyle(color: textColor)),
        content: Text(
          l10n.upgradeForUnlimited,
          style: TextStyle(color: textColor.withOpacity(0.8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel,
                style: TextStyle(color: textColor.withOpacity(0.6))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const SubscriptionScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: textColor,
              foregroundColor: bgColor,
            ),
            child: Text(l10n.upgradePro),
          ),
        ],
      ),
    );
  }
}
