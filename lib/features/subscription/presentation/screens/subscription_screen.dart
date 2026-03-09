import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  String _selectedPlan = 'yearly'; // 'monthly', 'yearly'

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? Colors.black : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    // Header Icon
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: textColor.withOpacity(0.05),
                      ),
                      child: FaIcon(FontAwesomeIcons.crown,
                          size: 60, color: const Color(0xFFFFD700)),
                    )
                        .animate()
                        .scale(duration: 600.ms, curve: Curves.easeOutBack),
                    const SizedBox(height: 32),

                    // Title
                    Text(l10n.proTier,
                            style: TextStyle(
                                color: textColor,
                                fontSize: 32,
                                fontWeight: FontWeight.bold))
                        .animate()
                        .fadeIn()
                        .slideY(begin: 0.3, end: 0),
                    const SizedBox(height: 16),
                    Text(
                      l10n.onboardingDesc1,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: textColor.withOpacity(0.6), fontSize: 16),
                    ),

                    const SizedBox(height: 48),

                    // Features List
                    _buildFeatureItem(l10n.feature1, textColor),
                    _buildFeatureItem(l10n.feature2, textColor),
                    _buildFeatureItem(l10n.feature6, textColor),
                    _buildFeatureItem(l10n.feature3, textColor),
                    _buildFeatureItem(l10n.feature4, textColor),

                    const SizedBox(height: 48),

                    // Plan Selection
                    _buildPlanOption(
                      id: 'yearly',
                      title: l10n.planYearly,
                      price: l10n.priceYearly,
                      subtitle: l10n.bestValue,
                      isBestValue: true,
                      textColor: textColor,
                      bgColor: textColor.withOpacity(0.05),
                    ),
                    const SizedBox(height: 16),
                    _buildPlanOption(
                      id: 'monthly',
                      title: l10n.planMonthly,
                      price: l10n.priceMonthly,
                      subtitle: null,
                      isBestValue: false,
                      textColor: textColor,
                      bgColor: textColor.withOpacity(0.05),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Action Area
            Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        // Implement purchase logic
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: textColor,
                        foregroundColor: bgColor,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        textStyle: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      child: Text(l10n.subscribeNow),
                    ),
                  ),
                  const SizedBox(height: 16),
                  /*
                  TextButton(
                    onPressed: () {},
                    child: Text(l10n.restorePurchases,
                        style: TextStyle(
                            color: textColor.withOpacity(0.5), fontSize: 12)),
                  ),
                  */
                  Text(
                    l10n.subscriptionNote,
                    style: TextStyle(
                        color: textColor.withOpacity(0.4), fontSize: 10),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String text, Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 20),
          const SizedBox(width: 12),
          Text(text,
              style: TextStyle(
                  color: textColor, fontSize: 16, fontWeight: FontWeight.w500)),
        ],
      ),
    ).animate().fadeIn().slideX(begin: -0.1, end: 0);
  }

  Widget _buildPlanOption({
    required String id,
    required String title,
    required String price,
    String? subtitle,
    required bool isBestValue,
    required Color textColor,
    required Color bgColor,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final isSelected = _selectedPlan == id;
    final border = isSelected
        ? Border.all(color: textColor, width: 2)
        : Border.all(color: Colors.transparent, width: 2);

    return GestureDetector(
      onTap: () => setState(() => _selectedPlan = id),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(20),
              border: border,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: TextStyle(
                              color: textColor,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(subtitle,
                            style: const TextStyle(
                                color: Color(0xFFFFD700),
                                fontSize: 12,
                                fontWeight: FontWeight.bold)),
                      ]
                    ],
                  ),
                ),
                Text(price,
                    style: TextStyle(
                        color: textColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
                const SizedBox(width: 16),
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: isSelected
                            ? textColor
                            : textColor.withOpacity(0.3),
                        width: 2),
                    color: isSelected ? textColor : Colors.transparent,
                  ),
                  child: isSelected
                      ? Icon(Icons.check, size: 16, color: bgColor) // Inverse color for check
                      : null,
                ),
              ],
            ),
          ),
          if (isBestValue)
            Positioned(
              top: -10,
              right: 24,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  l10n.savePercent,
                  style: const TextStyle(
                      color: Colors.black,
                      fontSize: 10,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
