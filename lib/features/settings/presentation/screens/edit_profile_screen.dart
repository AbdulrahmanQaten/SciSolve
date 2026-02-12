import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:scisolve/core/widgets/sci_text_field.dart';
import 'package:scisolve/core/widgets/sci_dropdown.dart';
import 'package:scisolve/core/utils/sci_toast.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:scisolve/core/services/auth_service.dart';


class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  String _selectedEducationLevel = "";
  bool _isLoading = false;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    final profile = await _authService.getUserProfile();
    if (profile != null && mounted) {
      setState(() {
        _nameController.text = profile['full_name'] ?? "";
        // Only set education level if it matches one of our options (handled in build via localized list check or just string)
        // For simplicity, we just take the string, assuming it matches or we default.
        // Ideally we map IDs, but here we stored strings.
        // We will check in build if it matches localized options or keep as is.
        _selectedEducationLevel = profile['education_level'] ?? "";
      });
    }
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_selectedEducationLevel.isEmpty) {
      final l10n = AppLocalizations.of(context)!;
      // Default only if still empty after load attempt (though load is async)
      // proper way is to wait for load.
      // We'll leave it empty to show "loading" or nothing until fetched.
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);
    final l10n = AppLocalizations.of(context)!;
    
    try {
      await _authService.updateUserProfile(
        fullName: _nameController.text.trim(),
        educationLevel: _selectedEducationLevel,
      );
      
      if (mounted) {
        SciToast.show(context, l10n.changesSaved);
        Navigator.pop(context, true); // Return true to indicate update
      }
    } catch (e) {
      if (mounted) {
        SciToast.show(context, l10n.errorOccurred, isError: true);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;

    final List<String> eduOptions = [
      l10n.university,
      l10n.highSchool,
      l10n.researcher,
      l10n.hobbyist
    ];
    
    // If loaded value isn't in options (e.g. language change or old data), default to first if empty
    if (_selectedEducationLevel.isEmpty && !_isLoading) {
       _selectedEducationLevel = eduOptions.first;
    }

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(l10n.editProfile,
            style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),
              SciTextField(
                controller: _nameController,
                label: l10n.fullName,
                icon: FontAwesomeIcons.user,
                isArabic: isArabic,
              ),
              const SizedBox(height: 16),
              SciDropdown(
                  label: l10n.educationLevel,
                  value: eduOptions.contains(_selectedEducationLevel) ? _selectedEducationLevel : eduOptions.first,
                  items: eduOptions,
                  onChanged: (val) =>
                      setState(() => _selectedEducationLevel = val),
                  isArabic: isArabic),
              const Spacer(),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? Colors.white : Colors.black,
                  foregroundColor: isDark ? Colors.black : Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: _isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: isDark ? Colors.black : Colors.white))
                    : Text(l10n.save,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
