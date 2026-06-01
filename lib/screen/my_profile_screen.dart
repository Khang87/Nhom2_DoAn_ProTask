import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../app_theme.dart';
import '../provider/auth_provider.dart';
import '../provider/theme_provider.dart';
import '../service/storage_service.dart';

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  String? _verificationId;
  bool _isLoading = false;
  bool _isDeleting = false;

  Future<void> _sendOTP(String phone, StateSetter setModalState) async {
    if (phone.startsWith('0')) phone = '+84${phone.substring(1)}';
    else if (!phone.startsWith('+')) phone = '+84$phone';
    
    setModalState(() => _isLoading = true);

    await firebase_auth.FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phone,
      verificationCompleted: (credential) async {
        await _verifyAndProcess(credential);
      },
      verificationFailed: (e) {
        setModalState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Lỗi: ${e.message}", style: GoogleFonts.inter()),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
      },
      codeSent: (String verId, int? resendToken) {
        setModalState(() {
          _verificationId = verId;
          _isLoading = false;
        });
      },
      codeAutoRetrievalTimeout: (String verId) {
        _verificationId = verId;
      },
    );
  }

  Future<void> _verifyAndProcess(firebase_auth.AuthCredential credential) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final currentUser = firebase_auth.FirebaseAuth.instance.currentUser;
      
      if (currentUser != null) {
        // Link credential to existing account to unify login
        try {
          await currentUser.linkWithCredential(credential);
        } on firebase_auth.FirebaseAuthException catch (e) {
          if (e.code == 'credential-already-in-use') {
             // If already linked or used by another account, we just sign in or handle it.
             await firebase_auth.FirebaseAuth.instance.signInWithCredential(credential);
          } else {
             rethrow;
          }
        }
      } else {
        await firebase_auth.FirebaseAuth.instance.signInWithCredential(credential);
      }

      if (_isDeleting) {
        await authProvider.updateUserPhone("");
      } else {
        await authProvider.updateUserPhone(_phoneController.text.trim());
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isDeleting ? "✅ Đã xóa số điện thoại!" : "✅ Cập nhật số điện thoại thành công!",
              style: GoogleFonts.inter(),
            ),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
            backgroundColor: AppColors.statusDone,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Mã OTP không chính xác!", style: GoogleFonts.inter()),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  void _showPhoneEditSheet(BuildContext context, String? currentPhone, AuthProvider auth, bool isDark) {
    _phoneController.text = currentPhone ?? "";
    _otpController.clear();
    _verificationId = null;
    _isDeleting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Header
                  Row(
                    children: [
                      Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(
                          gradient: AppGradients.brand,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: Icon(
                          _verificationId == null ? Icons.phone_rounded : Icons.sms_rounded,
                          color: Colors.white, size: 22,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Text(
                        _verificationId == null
                            ? (currentPhone == null || currentPhone.isEmpty
                                ? "Thêm số điện thoại"
                                : "Cập nhật / Xóa số")
                            : "Xác thực OTP",
                        style: AppTextStyles.heading3(isDark),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  if (_verificationId == null) ...[
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      autofocus: true,
                      style: AppTextStyles.body(isDark),
                      decoration: const InputDecoration(
                        labelText: "Số điện thoại",
                        hintText: "+84 123 456 789",
                        prefixIcon: Icon(Icons.phone_rounded, color: AppColors.primary, size: 20),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.info_outline_rounded, size: 14, color: AppColors.secondary),
                        const SizedBox(width: 6),
                        Text(
                          "Bắt đầu bằng +84 (VD: +84901234567)",
                          style: AppTextStyles.caption(isDark).copyWith(color: AppColors.secondary),
                        ),
                      ],
                    ),
                  ] else ...[
                    Text(
                      "Mã xác thực đã gửi đến\n${_phoneController.text}",
                      textAlign: TextAlign.center,
                      style: AppTextStyles.body(isDark),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _otpController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      autofocus: true,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: 12,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      ),
                      decoration: InputDecoration(
                        hintText: "000000",
                        hintStyle: GoogleFonts.plusJakartaSans(
                          fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: 12,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  if (_isLoading)
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2.5),
                    )
                  else
                    Row(
                      children: [
                        if (currentPhone != null && currentPhone.isNotEmpty && _verificationId == null) ...[
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                setModalState(() => _isDeleting = true);
                                await _sendOTP(currentPhone, setModalState);
                              },
                              icon: const Icon(Icons.delete_outline_rounded, size: 16),
                              label: const Text("Xóa số"),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.priorityHigh,
                                side: const BorderSide(color: AppColors.priorityHigh, width: 1.5),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.full)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                        ],
                        Expanded(
                          flex: 2,
                          child: GradientButton(
                            label: _verificationId == null ? "Gửi mã OTP" : "Xác nhận",
                            icon: _verificationId == null ? Icons.send_rounded : Icons.check_rounded,
                            onTap: () async {
                              if (_verificationId == null) {
                                if (_phoneController.text.trim().isNotEmpty) {
                                  setModalState(() => _isDeleting = false);
                                  await _sendOTP(_phoneController.text.trim(), setModalState);
                                }
                              } else {
                                firebase_auth.PhoneAuthCredential credential =
                                    firebase_auth.PhoneAuthProvider.credential(
                                  verificationId: _verificationId!,
                                  smsCode: _otpController.text.trim(),
                                );
                                await _verifyAndProcess(credential);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),
      ),
    ).then((_) {
      if (mounted) {
        setState(() {
          _verificationId = null;
          _isLoading = false;
          _isDeleting = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = auth.userModel;
    final String username = user?.displayName ?? "User";
    final String? phone = null; // Update logic later if user phone exists

    return Scaffold(
       backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      body: Scrollbar(
        thickness: 6,
        radius: const Radius.circular(10),
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          slivers: [
            // Header as SliverAppBar
            SliverAppBar(
              expandedHeight: 260.0,
              pinned: true,
              stretch: true,
              backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
              elevation: 0,
              leading: Padding(
                padding: const EdgeInsets.only(left: 8.0, top: 8.0),
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: (isDark ? AppColors.darkCard : AppColors.lightCard),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                    ),
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      size: 20,
                    ),
                  ),
                ),
              ),
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(left: 64, bottom: 16),
                title: Text(
                  "Hồ sơ cá nhân",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20, fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                ),
                stretchModes: const [StretchMode.zoomBackground, StretchMode.blurBackground],
                background: Container(
                  color: isDark ? AppColors.darkBg : AppColors.lightBg,
                  child: SafeArea(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 10),
                        GestureDetector(
                          onTap: () async {
                            final files = await StorageService().pickFiles();
                            if (files.isNotEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Đang tải ảnh lên...")));
                              final att = await StorageService().uploadFile('avatars', files.first);
                              if (att != null) {
                                await auth.updateUserPhoto(att.fileUrl);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Đã cập nhật ảnh đại diện!"), backgroundColor: AppColors.statusDone));
                                }
                              }
                            }
                          },
                          child: Container(
                            width: 90, height: 90,
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.darkCard : AppColors.lightCard,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.primary, width: 2),
                              boxShadow: AppShadows.card(isDark),
                              image: user?.photoUrl != null && user!.photoUrl.isNotEmpty
                                  ? DecorationImage(image: NetworkImage(user.photoUrl), fit: BoxFit.cover)
                                  : null,
                            ),
                            child: user?.photoUrl == null || user!.photoUrl.isEmpty
                                ? Center(
                                    child: Text(
                                      username.isNotEmpty ? username[0].toUpperCase() : "U",
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 36, fontWeight: FontWeight.w800, color: AppColors.primary,
                                      ),
                                    ),
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              username,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 22, fontWeight: FontWeight.w700,
                                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () {
                                _showEditNameDialog(context, auth, username, isDark);
                              },
                              child: const Icon(Icons.edit_rounded, size: 18, color: AppColors.primary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppRadius.full),
                          ),
                          child: Text(
                            "Thành viên ProTask",
                            style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Info section
            SliverToBoxAdapter(
              child: Transform.translate(
                offset: const Offset(0, -20),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      // Contact info card
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkCard : AppColors.lightCard,
                          borderRadius: BorderRadius.circular(AppRadius.xl),
                          border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                          boxShadow: AppShadows.card(isDark),
                        ),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "THÔNG TIN LIÊN HỆ",
                                  style: GoogleFonts.inter(
                                    fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1.2,
                                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                  ),
                                ),
                              ),
                            ),
                            ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                              leading: Container(
                                width: 44, height: 44,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(AppRadius.md),
                                ),
                                child: const Icon(Icons.email_rounded, color: AppColors.primary, size: 22),
                              ),
                              title: Text("Email", style: AppTextStyles.captionBold(isDark).copyWith(fontSize: 14)),
                              subtitle: Text(user?.email ?? "Chưa có", style: AppTextStyles.bodyMedium(isDark).copyWith(fontSize: 14)),
                            ),
                            Divider(height: 1, indent: 76, color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                            ListTile(
                              onTap: () => _showPhoneEditSheet(context, phone, auth, isDark),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                              leading: Container(
                                width: 44, height: 44,
                                decoration: BoxDecoration(
                                  color: AppColors.secondary.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(AppRadius.md),
                                ),
                                child: const Icon(Icons.phone_rounded, color: AppColors.secondary, size: 22),
                              ),
                              title: Text("Số điện thoại", style: AppTextStyles.captionBold(isDark).copyWith(fontSize: 14)),
                              subtitle: Text(
                                (phone != null && phone.isNotEmpty) ? phone : "Thêm số điện thoại",
                                style: AppTextStyles.bodyMedium(isDark).copyWith(
                                  fontSize: 14,
                                  color: (phone != null && phone.isNotEmpty)
                                      ? null
                                      : AppColors.primary,
                                ),
                              ),
                              trailing: Icon(
                                Icons.chevron_right_rounded,
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                size: 22,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Version info
                      Text("ProTask v1.0.0 · HUIT 2025", style: AppTextStyles.caption(isDark).copyWith(fontSize: 13)),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditNameDialog(BuildContext context, AuthProvider auth, String currentName, bool isDark) {
    final TextEditingController nameCtrl = TextEditingController(text: currentName);

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
          title: Text("Đổi tên hiển thị", style: AppTextStyles.heading3(isDark)),
          content: TextField(
            controller: nameCtrl,
            style: AppTextStyles.body(isDark),
            decoration: InputDecoration(
              labelText: "Tên hiển thị",
              prefixIcon: const Icon(Icons.person_outline, color: AppColors.primary, size: 20),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text("Hủy", style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.full)),
              ),
              onPressed: () async {
                if (nameCtrl.text.trim().isNotEmpty) {
                  await auth.updateUserName(nameCtrl.text.trim());
                  if (context.mounted) Navigator.pop(ctx);
                }
              },
              child: Text("Lưu", style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}
