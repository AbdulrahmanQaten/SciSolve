import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:scisolve/features/settings/presentation/screens/settings_screen.dart';
import 'package:scisolve/core/utils/sci_toast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:scisolve/core/services/chat_service.dart';
import 'package:scisolve/features/chat/presentation/screens/chat_screen.dart';
import 'package:shimmer/shimmer.dart';

class ChatFolder {
  String id;
  String name;
  ChatFolder({required this.id, required this.name});
}

class ChatItem {
  String id;
  String title;
  String? folderId;
  DateTime? createdAt;
  ChatItem(
      {required this.id, required this.title, this.folderId, this.createdAt});
}

class AppDrawer extends StatefulWidget {
  final String? currentChatId;
  const AppDrawer({super.key, this.currentChatId});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  final ChatService _chatService = ChatService();

  bool _isSectionsExpanded = true;
  bool _isRecentExpanded = true;

  @override
  void initState() {
    super.initState();
    _loadExpansionState();
  }

  Future<void> _loadExpansionState() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _isSectionsExpanded = prefs.getBool('isSectionsExpanded') ?? true;
        _isRecentExpanded = prefs.getBool('isRecentExpanded') ?? true;
      });
    }
  }

  Future<void> _toggleSections() async {
    setState(() => _isSectionsExpanded = !_isSectionsExpanded);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isSectionsExpanded', _isSectionsExpanded);
  }

  Future<void> _toggleRecent() async {
    setState(() => _isRecentExpanded = !_isRecentExpanded);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isRecentExpanded', _isRecentExpanded);
  }

  void _createNewFolder() {
    _showFolderDialog();
  }

  void _editFolder(ChatFolder folder) {
    _showFolderDialog(folder: folder);
  }

  void _deleteFolder(ChatFolder folder) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1F2937);

    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              backgroundColor: bgColor,
              elevation: 0, // Flat design
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text(l10n.deleteFolderConfirm,
                  style: TextStyle(color: textColor, fontWeight: FontWeight.w600)),
              content: Text("All chats inside will be moved to General.",
                  style: TextStyle(color: isDark ? Colors.white54 : Colors.black54)),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: Text(l10n.cancel, style: TextStyle(color: isDark ? Colors.white54 : Colors.black54))),
                TextButton(
                    onPressed: () async {
                      await _chatService.deleteFolder(folder.id);
                      if (ctx.mounted) Navigator.pop(ctx);
                    },
                    child: Text(l10n.delete,
                        style: const TextStyle(color: Colors.red))),
              ],
            ));
  }

  void _showFolderDialog({ChatFolder? folder}) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1F2937);
    final controller = TextEditingController(text: folder?.name ?? "");

    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              backgroundColor: bgColor,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text(folder == null ? l10n.newSection : l10n.rename,
                  style: TextStyle(color: textColor, fontWeight: FontWeight.w600)),
              content: TextField(
                  controller: controller,
                  style: TextStyle(color: textColor),
                  autofocus: true,
                  decoration: InputDecoration(
                      filled: true,
                      fillColor: isDark ? const Color(0xFF262626) : const Color(0xFFF9FAFB),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  )),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: Text(l10n.cancel, style: TextStyle(color: isDark ? Colors.white54 : Colors.black54))),
                TextButton(
                    onPressed: () async {
                      if (controller.text.isNotEmpty) {
                        if (folder == null) {
                          await _chatService.createFolder(controller.text);
                        } else {
                          await _chatService.renameFolder(
                              folder.id, controller.text);
                        }
                        if (ctx.mounted) Navigator.pop(ctx);
                      }
                    },
                    child: Text(folder == null ? l10n.create : l10n.save,
                        style: TextStyle(color: textColor))),
              ],
            ));
  }

  void _renameChat(ChatItem chat) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1F2937);
    final controller = TextEditingController(text: chat.title);

    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              backgroundColor: bgColor,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text(l10n.renameChat,
                  style: TextStyle(color: textColor, fontWeight: FontWeight.w600)),
              content: TextField(
                  controller: controller,
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                      filled: true,
                      fillColor: isDark ? const Color(0xFF262626) : const Color(0xFFF9FAFB),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  )),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: Text(l10n.cancel, style: TextStyle(color: isDark ? Colors.white54 : Colors.black54))),
                TextButton(
                    onPressed: () async {
                      await _chatService.renameChat(chat.id, controller.text);
                      if (ctx.mounted) Navigator.pop(ctx);
                    },
                    child: Text(l10n.save,
                        style: TextStyle(color: textColor))),
              ],
            ));
  }

  void _deleteChat(ChatItem chat) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1F2937);

    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              backgroundColor: bgColor,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text(l10n.deleteChatConfirm,
                  style: TextStyle(color: textColor, fontWeight: FontWeight.w600)),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: Text(l10n.cancel, style: TextStyle(color: isDark ? Colors.white54 : Colors.black54))),
                TextButton(
                    onPressed: () async {
                      Navigator.pop(ctx);
                      await _chatService.deleteChat(chat.id);

                      if (widget.currentChatId == chat.id && context.mounted) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const ChatScreen()),
                        );
                      }
                    },
                    child: Text(l10n.delete,
                        style: const TextStyle(color: Colors.red))),
              ],
            ));
  }

  void _moveChat(ChatItem chat, List<ChatFolder> folders) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1F2937);

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
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 16),
                ListTile(
                  leading: Icon(Icons.grid_view,
                      color: isDark ? Colors.white54 : Colors.black54),
                  title: Text(l10n.general, style: TextStyle(color: textColor)),
                  trailing: chat.folderId == null
                      ? const Icon(Icons.check, color: Colors.green, size: 16)
                      : null,
                  onTap: () async {
                    Navigator.pop(ctx);
                    await _chatService.moveChatToFolder(chat.id, null);
                    if (context.mounted)
                      SciToast.show(context, l10n.movedTo(l10n.general));
                  },
                ),
                ...folders.map((f) => ListTile(
                      leading: Icon(Icons.folder_outlined,
                          color: isDark ? Colors.white54 : Colors.black54),
                      title: Text(f.name, style: TextStyle(color: textColor)),
                      trailing: chat.folderId == f.id
                          ? const Icon(Icons.check,
                              color: Colors.green, size: 16)
                          : null,
                      onTap: () async {
                        Navigator.pop(ctx);
                        await _chatService.moveChatToFolder(chat.id, f.id);
                        if (context.mounted)
                          SciToast.show(context, l10n.movedTo(f.name));
                      },
                    )),
              ],
            ),
          );
        });
  }

  Widget _buildChatListSkeleton(bool isDark) {
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.white10 : Colors.grey[300]!,
      highlightColor: isDark ? Colors.white24 : Colors.grey[100]!,
      child: Column(
        children: List.generate(
            6,
            (index) => Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                              color: Colors.white, shape: BoxShape.circle)),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                              width: 150, height: 14, color: Colors.white),
                          const SizedBox(height: 6),
                          Container(width: 100, height: 10, color: Colors.white)
                        ],
                      )
                    ],
                  ),
                )),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgDrawer = isDark ? const Color(0xFF121212) : const Color(0xFFF9FAFB);
    final textPrimary = isDark ? Colors.white : const Color(0xFF1F2937);
    final textSecondary = isDark ? Colors.white : const Color(0xFF1F2937);
    final textDisabled = isDark ? Colors.white38 : Colors.black38;

    final dividerColor = isDark
        ? Colors.transparent
        : Colors.transparent; // Minimalist: No dividing lines

    return Drawer(
      backgroundColor: bgDrawer,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: Column(
        children: [
          Container(
            padding:
                const EdgeInsets.only(top: 60, bottom: 20, left: 24, right: 24),
            decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: dividerColor))),
            child: Row(children: [
              FaIcon(FontAwesomeIcons.lightbulb, color: textPrimary, size: 24), // Sparkle/Bulb instead of Atom
              const SizedBox(width: 16),
              Text("SciSolve",
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: textPrimary))
            ]),
          ),
          Expanded(
            // استخدام ListenableBuilder بدلاً من StreamBuilder
            child: ListenableBuilder(
              listenable: _chatService,
              builder: (context, _) {
                // Show skeleton only on first load
                if (_chatService.isLoading) {
                  return ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(12),
                    children: [
                      ListTile(
                        onTap: () {
                          Navigator.pop(context);
                          if (widget.currentChatId != null) {
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const ChatScreen()));
                          }
                        },
                        leading: FaIcon(FontAwesomeIcons.plus,
                            size: 16, color: textPrimary),
                        title: Text(l10n.newChat,
                            style: TextStyle(
                                color: textPrimary,
                                fontWeight: FontWeight.bold)),
                        tileColor: isDark ? Colors.white12 : Colors.grey[200],
                      ),
                      const SizedBox(height: 24),
                      _buildChatListSkeleton(isDark),
                    ],
                  );
                }

                // Parse data
                final chats = _chatService.chats
                    .map((c) => ChatItem(
                        id: c['id'],
                        title: c['title'] ?? 'New Chat',
                        folderId: c['folder_id'],
                        createdAt: c['created_at'] != null
                            ? DateTime.parse(c['created_at'])
                            : null))
                    .toList();

                final folders = _chatService.folders
                    .map((f) => ChatFolder(id: f['id'], name: f['name']))
                    .toList();

                final generalChats =
                    chats.where((c) => c.folderId == null).toList();

                return ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(12),
                  children: [
                    ListTile(
                      onTap: () {
                        Navigator.pop(context);
                        if (widget.currentChatId != null) {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const ChatScreen()));
                        }
                      },
                      leading: FaIcon(FontAwesomeIcons.plus,
                          size: 16, color: textPrimary),
                      title: Text(l10n.newChat,
                          style: TextStyle(
                              color: textPrimary, fontWeight: FontWeight.bold)),
                      tileColor: isDark ? Colors.white12 : Colors.grey[200],
                    ),
                    const SizedBox(height: 24),
                    _buildSectionHeader(l10n.sections.toUpperCase(),
                        _isSectionsExpanded, _toggleSections, textDisabled,
                        onAdd: _createNewFolder),
                    if (_isSectionsExpanded)
                      ...folders.map((folder) {
                        final chatsInFolder = chats
                            .where((c) => c.folderId == folder.id)
                            .toList();
                        return Theme(
                            data: Theme.of(context)
                                .copyWith(dividerColor: Colors.transparent),
                            child: ExpansionTile(
                                key: ValueKey(folder.id),
                                title: Text(folder.name,
                                    style: TextStyle(
                                        color: textSecondary, fontSize: 14)),
                                leading: Icon(Icons.folder_outlined,
                                    color: textDisabled, size: 18),
                                collapsedIconColor: textDisabled,
                                iconColor: textPrimary,
                                trailing: _buildFolderMenu(l10n, folder),
                                childrenPadding:
                                    const EdgeInsets.only(left: 12),
                                children: chatsInFolder.isEmpty
                                    ? [
                                        ListTile(
                                            title: Text(l10n.empty,
                                                style: TextStyle(
                                                    color: textDisabled,
                                                    fontSize: 12)))
                                      ]
                                    : chatsInFolder
                                        .map((c) => _buildChatItem(
                                            c,
                                            l10n,
                                            textSecondary,
                                            textDisabled,
                                            folders))
                                        .toList()));
                      }),
                    const SizedBox(height: 24),
                    _buildSectionHeader(l10n.recents.toUpperCase(),
                        _isRecentExpanded, _toggleRecent, textDisabled),
                    if (_isRecentExpanded)
                      if (generalChats.isEmpty)
                        Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(l10n.empty,
                                style: TextStyle(color: textDisabled)))
                      else
                        ...generalChats.map((chat) => _buildChatItem(
                            chat, l10n, textSecondary, textDisabled, folders)),
                  ],
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                border: Border(top: BorderSide(color: dividerColor))),
            child: ListTile(
                leading:
                    FaIcon(FontAwesomeIcons.gear, size: 18, color: textPrimary),
                title:
                    Text(l10n.settings, style: TextStyle(color: textPrimary)),
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const SettingsScreen()))),
          )
        ],
      ),
    );
  }

  Widget _buildChatItem(ChatItem chat, AppLocalizations l10n,
      Color textSecondary, Color textDisabled, List<ChatFolder> folders) {
    final isActive = widget.currentChatId == chat.id;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      key: ValueKey('chat_${chat.id}'),
      decoration: isActive
          ? BoxDecoration(
              color: isDark ? Colors.white10 : Colors.grey[200],
            )
          : null,
      child: ListTile(
        contentPadding: const EdgeInsets.only(left: 16, right: 8),
        leading: FaIcon(FontAwesomeIcons.message,
            size: 14, color: isActive ? textSecondary : textDisabled),
        title: Text(chat.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                color: textSecondary,
                fontSize: 14,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
        trailing: _buildChatMenu(l10n, chat, folders),
        onTap: () {
          Navigator.pop(context);
          if (widget.currentChatId != chat.id) {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => ChatScreen(chatId: chat.id)));
          }
        },
      ),
    );
  }

  Widget _buildFolderMenu(AppLocalizations l10n, ChatFolder folder) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_horiz,
          size: 16, color: isDark ? Colors.white24 : Colors.black26),
      color: isDark ? const Color(0xFF141414) : Colors.white,
      onSelected: (val) {
        if (val == 'rename') _editFolder(folder);
        if (val == 'delete') _deleteFolder(folder);
      },
      itemBuilder: (ctx) => [
        PopupMenuItem(
            value: 'rename',
            child: Text(l10n.rename,
                style: TextStyle(color: isDark ? Colors.white : Colors.black))),
        PopupMenuItem(
            value: 'delete',
            child:
                Text(l10n.delete, style: const TextStyle(color: Colors.red))),
      ],
    );
  }

  Widget _buildChatMenu(
      AppLocalizations l10n, ChatItem chat, List<ChatFolder> folders) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_horiz,
          size: 16, color: isDark ? Colors.white24 : Colors.black26),
      color: isDark ? const Color(0xFF141414) : Colors.white,
      onSelected: (val) {
        if (val == 'delete') _deleteChat(chat);
        if (val == 'rename') _renameChat(chat);
        if (val == 'move') _moveChat(chat, folders);
      },
      itemBuilder: (ctx) => [
        PopupMenuItem(
            value: 'rename',
            child: Text(l10n.rename,
                style: TextStyle(color: isDark ? Colors.white : Colors.black))),
        PopupMenuItem(
            value: 'move',
            child: Text(l10n.move,
                style: TextStyle(color: isDark ? Colors.white : Colors.black))),
        PopupMenuItem(
            value: 'delete',
            child:
                Text(l10n.delete, style: const TextStyle(color: Colors.red))),
      ],
    );
  }

  Widget _buildSectionHeader(
      String title, bool isExpanded, VoidCallback onToggle, Color color,
      {VoidCallback? onAdd}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: onToggle,
            child: Row(
              children: [
                Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_down
                        : (Localizations.localeOf(context).languageCode == 'ar'
                            ? Icons.keyboard_arrow_left
                            : Icons.keyboard_arrow_right),
                    size: 16,
                    color: color),
                const SizedBox(width: 8),
                Text(title,
                    style: TextStyle(
                        color: color,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1)),
              ],
            ),
          ),
          if (onAdd != null)
            IconButton(
                onPressed: onAdd,
                icon: Icon(Icons.add, size: 16, color: color),
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero)
        ],
      ),
    );
  }
}
