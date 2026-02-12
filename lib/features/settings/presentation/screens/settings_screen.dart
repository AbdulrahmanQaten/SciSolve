import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:scisolve/main.dart';
import 'package:scisolve/features/auth/presentation/screens/login_screen.dart';
import 'package:scisolve/core/utils/sci_toast.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:scisolve/features/subscription/presentation/screens/subscription_screen.dart';
import 'edit_profile_screen.dart';
import 'legal_screen.dart';
import 'package:scisolve/core/services/auth_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _userEmail = "";
  String _userName = "";
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = _authService.currentUser;
    if (user != null) {
      if (mounted) setState(() => _userEmail = user.email ?? "");
      
      final profile = await _authService.getUserProfile();
      if (profile != null && mounted) {
        setState(() {
          _userName = profile['full_name'] ?? "";
        });
      }
    }
  }

  final Map<String, String> _languages = {
    'en': 'English',
    'ar': 'العربية',
    'de': 'Deutsch',
    'ja': '日本語',
    'zh': '简体中文',
    'hi': 'हिन्दी',
    'ru': 'Русский',
    'es': 'Español',
    'fr': 'Français',
    'tr': 'Türkçe',
    'it': 'Italiano',
    'pt': 'Português',
    'ko': '한국어',
    'id': 'Indonesia',
    'ur': 'اردو',
    'ps': 'پښتو',
    'fa': 'فارسی',
  };

  void _changeLanguage() {
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (ctx) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final bgColor = isDark ? const Color(0xFF141414) : Colors.white;
          final textColor = isDark ? Colors.white : Colors.black;

          return DraggableScrollableSheet(
              initialChildSize: 0.7,
              minChildSize: 0.5,
              maxChildSize: 0.9,
              builder: (_, scrollController) {
                return Container(
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(2))),
                      ),
                      Text(AppLocalizations.of(context)!.chooseLanguage,
                          style: TextStyle(
                              color: textColor,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      Expanded(
                        child: ListView.separated(
                          controller: scrollController,
                          itemCount: _languages.length,
                          separatorBuilder: (_, __) => Divider(
                              height: 1, color: textColor.withOpacity(0.1)),
                          itemBuilder: (context, index) {
                            final code = _languages.keys.elementAt(index);
                            final name = _languages.values.elementAt(index);
                            final isSelected =
                                Localizations.localeOf(context).languageCode ==
                                    code;

                            return ListTile(
                                title: Text(name,
                                    style: TextStyle(
                                        color: textColor,
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal)),
                                trailing: isSelected
                                    ? FaIcon(FontAwesomeIcons.check,
                                        size: 16, color: textColor)
                                    : null,
                                onTap: () {
                                  SciSolveApp.setLocale(context, Locale(code));
                                  Navigator.pop(ctx);
                                });
                          },
                        ),
                      ),
                    ],
                  ),
                );
              });
        });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? Colors.black : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;

    final currentLangCode = Localizations.localeOf(context).languageCode;
    final currentLangName = _languages[currentLangCode] ?? "English";

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(l10n.settings,
            style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: ListView(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: isDark ? Colors.white10 : Colors.black12,
                  child: FaIcon(FontAwesomeIcons.user,
                      size: 24, color: textColor.withOpacity(0.7)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_userName,
                          style: TextStyle(
                              color: textColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 18)),
                      const SizedBox(height: 4),
                      Text(_userEmail,
                          style: TextStyle(
                              color: textColor.withOpacity(0.6), fontSize: 14)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Divider(color: textColor.withOpacity(0.1), height: 1),
          const SizedBox(height: 16),
          _buildSectionHeader(l10n.settingsGeneral, textColor),
          _buildSettingItem(
              icon: FontAwesomeIcons.globe,
              title: l10n.language,
              subtitle: currentLangName,
              onTap: _changeLanguage,
              textColor: textColor),
          _buildSettingItem(
            icon: FontAwesomeIcons.moon,
            title: l10n.theme,
            subtitle: isDark ? l10n.darkMode : l10n.lightMode,
            textColor: textColor,
            trailing: Switch(
              value: isDark,
              onChanged: (val) {
                SciSolveApp.setThemeMode(
                    context, val ? ThemeMode.dark : ThemeMode.light);
                setState(() {});
              },
              activeColor: Colors.white,
              activeTrackColor: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader(l10n.settingsAccount, textColor),
          _buildSettingItem(
            icon: FontAwesomeIcons.userPen,
            title: l10n.editProfile,
            subtitle: l10n.editProfileSubtitle,
            textColor: textColor,
            onTap: () async {
              final result = await Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const EditProfileScreen()));
              if (result == true) {
                _loadProfile();
              }
            },
          ),
          _buildSettingItem(
              icon: FontAwesomeIcons.gem,
              title: l10n.plansSubscription,
              subtitle: l10n.plansFree,
              textColor: textColor,
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const SubscriptionScreen()))),
          const SizedBox(height: 24),
          _buildSectionHeader(l10n.settingsLegal, textColor),
          _buildSettingItem(
              icon: FontAwesomeIcons.lock,
              title: l10n.privacyPolicy,
              textColor: textColor,
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => LegalScreen(
                          title: l10n.privacyPolicy,
                          content: l10n.privacyPolicyContent)))),
          _buildSettingItem(
              icon: FontAwesomeIcons.fileContract,
              title: l10n.termsConditions,
              textColor: textColor,
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => LegalScreen(
                          title: l10n.termsConditions,
                          content: l10n.termsContent)))),
          _buildSettingItem(
              icon: FontAwesomeIcons.circleQuestion,
              title: l10n.helpCenter,
              textColor: textColor,
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => LegalScreen(
                          title: l10n.helpCenter, content: l10n.helpContent)))),
          const SizedBox(height: 24),
          _buildSectionHeader(l10n.settingsApp, textColor),
          _buildSettingItem(
            icon: FontAwesomeIcons.circleInfo,
            title: l10n.about,
            textColor: textColor,
            onTap: () {
              showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                        backgroundColor:
                            isDark ? const Color(0xFF141414) : Colors.white,
                        title: Text("SciSolve v1.0.0",
                            style: TextStyle(color: textColor)),
                        content: Text(
                            "The ultimate AI assistant for Sciences.\nPowered by Gemini.\n\n© 2026 SciSolve",
                            style:
                                TextStyle(color: textColor.withOpacity(0.7))),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text("OK"))
                        ],
                      ));
            },
          ),
          const SizedBox(height: 24),
          _buildSettingItem(
            icon: FontAwesomeIcons.rightFromBracket,
            title: l10n.logout,
            isDestructive: true,
            textColor: textColor,
            onTap: () {
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false);
            },
          ),
        ],
      ),
    );
  }

  void _showPlansSheet(
      BuildContext context, AppLocalizations l10n, bool isDark) {
    showModalBottomSheet(
        context: context,
        backgroundColor: isDark ? const Color(0xFF141414) : Colors.white,
        isScrollControlled: true,
        builder: (ctx) {
          final textColor = isDark ? Colors.white : Colors.black;
          return Container(
            height: MediaQuery.of(context).size.height * 0.7,
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Center(
                      child: FaIcon(FontAwesomeIcons.crown,
                          color: Colors.amber, size: 40)),
                  const SizedBox(height: 16),
                  Text(l10n.choosePlan,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: textColor,
                          fontSize: 24,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 32),

                  // Free Tier
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                        border: Border.all(color: textColor.withOpacity(0.3)),
                        borderRadius: BorderRadius.circular(12)),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.freeTier,
                              style: TextStyle(
                                  color: textColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18)),
                          const SizedBox(height: 8),
                          _buildFeatureItem(l10n.questionsPerDay, textColor),
                          _buildFeatureItem(
                              l10n.standardExplanation, textColor),
                          _buildFeatureItem(l10n.adsSupported, textColor),
                        ]),
                  ),
                  const SizedBox(height: 16),

                  // Pro Tier
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                        color: isDark ? Colors.white : Colors.black,
                        borderRadius: BorderRadius.circular(12)),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Text(l10n.proTier,
                                style: TextStyle(
                                    color: isDark ? Colors.black : Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18)),
                            const Spacer(),
                            Text("\$9.99/mo",
                                style: TextStyle(
                                    color: isDark ? Colors.black : Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18))
                          ]),
                          const SizedBox(height: 8),
                          _buildFeatureItem(l10n.unlimitedQuestions,
                              isDark ? Colors.black : Colors.white),
                          _buildFeatureItem(l10n.detailedExplanation,
                              isDark ? Colors.black : Colors.white),
                          _buildFeatureItem(
                              l10n.noAds, isDark ? Colors.black : Colors.white),
                          _buildFeatureItem(l10n.fasterPriority,
                              isDark ? Colors.black : Colors.white),
                        ]),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        SciToast.show(context, l10n.comingSoon);
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16)),
                      child: Text(l10n.subscribeNow,
                          style: const TextStyle(fontWeight: FontWeight.bold)))
                ],
              ),
            ),
          );
        });
  }

  Widget _buildSectionHeader(String title, Color textColor) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Text(title,
            style: TextStyle(
                color: textColor.withOpacity(0.5),
                fontSize: 12,
                fontWeight: FontWeight.bold)));
  }

  Widget _buildFeatureItem(String text, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(Icons.check_circle, size: 14, color: textColor.withOpacity(0.7)),
          const SizedBox(width: 8),
          Expanded(
              child: Text(text,
                  style: TextStyle(
                      color: textColor.withOpacity(0.9), fontSize: 13))),
        ],
      ),
    );
  }

  Widget _buildSettingItem(
      {required IconData icon,
      required String title,
      required Color textColor,
      String? subtitle,
      Widget? trailing,
      bool isDestructive = false,
      VoidCallback? onTap}) {
    final effectiveColor = isDestructive ? Colors.red : textColor;
    return ListTile(
      onTap: onTap,
      leading: FaIcon(icon, size: 16, color: effectiveColor),
      title: Text(title,
          style: TextStyle(color: effectiveColor, fontWeight: FontWeight.w600)),
      subtitle: subtitle != null
          ? Text(subtitle,
              style: TextStyle(
                  color: effectiveColor.withOpacity(0.5), fontSize: 12))
          : null,
      trailing: trailing ??
          Icon(Icons.arrow_forward_ios,
              size: 14, color: effectiveColor.withOpacity(0.2)),
    );
  }
}
