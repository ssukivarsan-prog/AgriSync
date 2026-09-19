import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/farm_provider.dart';
import '../core/app_localization.dart';
import '../core/theme.dart';

class LanguageToggleChip extends StatelessWidget {
  final bool isCompact;
  const LanguageToggleChip({super.key, this.isCompact = false});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FarmProvider>();
    final isTamil = provider.isTamil;

    return Container(
      padding: const EdgeInsets.all(2.5),
      decoration: BoxDecoration(
        color: const Color(0xFFE6EFE8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFC7DBCB), width: 1.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // English Pill
          GestureDetector(
            onTap: () {
              if (isTamil) provider.setLanguage(AppLanguage.english);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeInOut,
              padding: EdgeInsets.symmetric(
                horizontal: isCompact ? 8 : 10,
                vertical: isCompact ? 3.5 : 5,
              ),
              decoration: BoxDecoration(
                color: !isTamil ? AppTheme.primaryGreen : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                boxShadow: !isTamil
                    ? [
                        BoxShadow(
                          color: AppTheme.primaryGreen.withValues(alpha: 0.25),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        )
                      ]
                    : null,
              ),
              child: Text(
                'EN',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: isCompact ? 11 : 12,
                  fontWeight: !isTamil ? FontWeight.w800 : FontWeight.w600,
                  color: !isTamil ? Colors.white : const Color(0xFF4B5E52),
                ),
              ),
            ),
          ),
          const SizedBox(width: 2),
          // Tamil Pill
          GestureDetector(
            onTap: () {
              if (!isTamil) provider.setLanguage(AppLanguage.tamil);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeInOut,
              padding: EdgeInsets.symmetric(
                horizontal: isCompact ? 8 : 10,
                vertical: isCompact ? 3.5 : 5,
              ),
              decoration: BoxDecoration(
                color: isTamil ? AppTheme.primaryGreen : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                boxShadow: isTamil
                    ? [
                        BoxShadow(
                          color: AppTheme.primaryGreen.withValues(alpha: 0.25),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        )
                      ]
                    : null,
              ),
              child: Text(
                'தமிழ்',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: isCompact ? 11 : 12,
                  fontWeight: isTamil ? FontWeight.w800 : FontWeight.w600,
                  color: isTamil ? Colors.white : const Color(0xFF4B5E52),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
