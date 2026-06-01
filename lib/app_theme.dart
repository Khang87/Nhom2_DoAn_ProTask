import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─── COLOR PALETTE ──────────────────────────────────────────────────────────

class AppColors {
  // Brand Gradient
  static const Color primary = Color(0xFF6C63FF);       // Indigo-Purple
  static const Color primaryLight = Color(0xFF857DF9);
  static const Color primaryDark = Color(0xFF4F46E5);
  static const Color secondary = Color(0xFF06B6D4);     // Cyan accent
  static const Color accent = Color(0xFFF59E0B);        // Amber

  // Status Colors
  static const Color statusTodo = Color(0xFF94A3B8);    // Slate
  static const Color statusInProgress = Color(0xFF3B82F6); // Blue
  static const Color statusReview = Color(0xFFF59E0B);  // Amber
  static const Color statusDone = Color(0xFF10B981);    // Emerald

  // Priority
  static const Color priorityHigh = Color(0xFFEF4444);
  static const Color priorityMedium = Color(0xFFF59E0B);
  static const Color priorityLow = Color(0xFF10B981);

  // Dark Theme Surface
  static const Color darkBg = Color(0xFF0F0F17);
  static const Color darkSurface = Color(0xFF1A1A2E);
  static const Color darkCard = Color(0xFF242438);
  static const Color darkBorder = Color(0xFF2D2D45);

  // Light Theme Surface
  static const Color lightBg = Color(0xFFF8F7FF);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE8E5FF);

  // Text
  static const Color textPrimaryDark = Color(0xFFF1F0FF);
  static const Color textSecondaryDark = Color(0xFF9B99C9);
  static const Color textPrimaryLight = Color(0xFF1A1A2E);
  static const Color textSecondaryLight = Color(0xFF6B7280);
}

// ─── GRADIENT PRESETS ────────────────────────────────────────────────────────

class AppGradients {
  static const LinearGradient brand = LinearGradient(
    colors: [Color(0xFF6C63FF), Color(0xFF06B6D4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardPurple = LinearGradient(
    colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardCyan = LinearGradient(
    colors: [Color(0xFF0891B2), Color(0xFF06B6D4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardEmerald = LinearGradient(
    colors: [Color(0xFF059669), Color(0xFF10B981)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardAmber = LinearGradient(
    colors: [Color(0xFFD97706), Color(0xFFF59E0B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkOverlay = LinearGradient(
    colors: [Color(0x00000000), Color(0x99000000)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

// ─── TYPOGRAPHY ──────────────────────────────────────────────────────────────

class AppTextStyles {
  static TextStyle display(bool isDark) => GoogleFonts.plusJakartaSans(
    fontSize: 26,
    fontWeight: FontWeight.w800,
    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
    letterSpacing: -0.5,
  );

  static TextStyle heading1(bool isDark) => GoogleFonts.plusJakartaSans(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
    letterSpacing: -0.3,
  );

  static TextStyle heading2(bool isDark) => GoogleFonts.plusJakartaSans(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
  );

  static TextStyle heading3(bool isDark) => GoogleFonts.plusJakartaSans(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
  );

  static TextStyle body(bool isDark) => GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
    height: 1.5,
  );

  static TextStyle bodyMedium(bool isDark) => GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
  );

  static TextStyle caption(bool isDark) => GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
  );

  static TextStyle captionBold(bool isDark) => GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
  );

  static TextStyle label(bool isDark) => GoogleFonts.inter(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
  );

  static TextStyle button() => GoogleFonts.plusJakartaSans(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.3,
  );
}

// ─── SPACING ─────────────────────────────────────────────────────────────────

class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;

  static const EdgeInsets screenPadding = EdgeInsets.symmetric(horizontal: 20, vertical: 16);
  static const EdgeInsets cardPadding = EdgeInsets.all(16);
}

// ─── RADIUS ──────────────────────────────────────────────────────────────────

class AppRadius {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 28;
  static const double full = 999;
}

// ─── SHADOWS ─────────────────────────────────────────────────────────────────

class AppShadows {
  static List<BoxShadow> card(bool isDark) => isDark
      ? [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 4))]
      : [BoxShadow(color: AppColors.primary.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 4)),
         BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))];

  static List<BoxShadow> glow(Color color) => [
    BoxShadow(color: color.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 4)),
    BoxShadow(color: color.withOpacity(0.2), blurRadius: 40, offset: const Offset(0, 8)),
  ];

  static List<BoxShadow> bottomBar(bool isDark) => isDark
      ? [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 30, offset: const Offset(0, -4))]
      : [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, -4))];
}

// ─── THEME DATA ───────────────────────────────────────────────────────────────

class AppTheme {
  static ThemeData light() {
    return ThemeData(
      brightness: Brightness.light,
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.lightBg,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.lightSurface,
        onPrimary: Colors.white,
        onSurface: AppColors.textPrimaryLight,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.lightSurface,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: AppColors.textPrimaryLight),
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimaryLight,
        ),
      ),
      textTheme: GoogleFonts.interTextTheme(),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.full)),
          textStyle: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.full)),
          textStyle: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF3F2FF),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.lightBorder, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        labelStyle: GoogleFonts.inter(color: AppColors.textSecondaryLight, fontSize: 14),
        hintStyle: GoogleFonts.inter(color: AppColors.textSecondaryLight.withOpacity(0.6), fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.lightSurface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondaryLight,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: AppColors.lightCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          side: const BorderSide(color: AppColors.lightBorder, width: 1),
        ),
      ),
      dividerTheme: const DividerThemeData(color: AppColors.lightBorder, thickness: 1),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFFF3F2FF),
        selectedColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.full)),
        labelStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }

  static ThemeData dark() {
    return ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.darkBg,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.darkSurface,
        onPrimary: Colors.white,
        onSurface: AppColors.textPrimaryDark,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkSurface,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: AppColors.textPrimaryDark),
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimaryDark,
        ),
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.full)),
          textStyle: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryLight,
          side: const BorderSide(color: AppColors.primaryLight, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.full)),
          textStyle: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.darkBorder, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        labelStyle: GoogleFonts.inter(color: AppColors.textSecondaryDark, fontSize: 14),
        hintStyle: GoogleFonts.inter(color: AppColors.textSecondaryDark.withOpacity(0.6), fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        selectedItemColor: AppColors.primaryLight,
        unselectedItemColor: AppColors.textSecondaryDark,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          side: const BorderSide(color: AppColors.darkBorder, width: 1),
        ),
      ),
      dividerTheme: const DividerThemeData(color: AppColors.darkBorder, thickness: 1),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.darkCard,
        selectedColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.full)),
        labelStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimaryDark),
      ),
    );
  }
}

// ─── REUSABLE WIDGET HELPERS ─────────────────────────────────────────────────

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Gradient? gradient;

  const AppCard({super.key, required this.child, this.padding, this.onTap, this.gradient});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding ?? AppSpacing.cardPadding,
        decoration: BoxDecoration(
          color: gradient == null ? (isDark ? AppColors.darkCard : AppColors.lightCard) : null,
          gradient: gradient,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: gradient == null ? Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            width: 1,
          ) : null,
          boxShadow: AppShadows.card(isDark),
        ),
        child: child,
      ),
    );
  }
}

class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final bool small;

  const StatusBadge({super.key, required this.label, required this.color, this.small = false});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 8 : 10,
        vertical: small ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.2 : 0.12),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: small ? 10 : 11,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final Gradient gradient;
  final bool isLoading;
  final double height;
  final IconData? icon;

  const GradientButton({
    super.key,
    required this.label,
    this.onTap,
    this.gradient = AppGradients.brand,
    this.isLoading = false,
    this.height = 54,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: height,
        decoration: BoxDecoration(
          gradient: isLoading ? null : gradient,
          color: isLoading ? Colors.grey.withOpacity(0.3) : null,
          borderRadius: BorderRadius.circular(AppRadius.full),
          boxShadow: isLoading ? null : AppShadows.glow(AppColors.primary),
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, color: Colors.white, size: 18),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      label,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
