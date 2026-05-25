import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/auth_provider.dart';
import '../provider/locale_provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

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
  bool _isDeleting = false; // Biến đánh dấu đang thực hiện luồng xóa

  // --- HÀM 1: GỬI OTP QUA FIREBASE ---
  Future<void> _sendOTP(String phone, StateSetter setModalState, LocaleProvider localeProvider) async {
    setModalState(() => _isLoading = true);

    await firebase_auth.FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phone,
      verificationCompleted: (firebase_auth.PhoneAuthCredential credential) async {
        await _verifyAndProcess(credential, localeProvider);
      },
      verificationFailed: (firebase_auth.FirebaseAuthException e) {
        setModalState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("${localeProvider.getText('error_prefix')} ${e.message}")),
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

  // --- HÀM 2: XÁC THỰC VÀ XỬ LÝ (LƯU HOẶC XÓA) ---
  Future<void> _verifyAndProcess(firebase_auth.AuthCredential credential, LocaleProvider localeProvider) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // Xác thực mã với Firebase
      await firebase_auth.FirebaseAuth.instance.signInWithCredential(credential);

      if (_isDeleting) {
        // Nếu đang trong luồng xóa -> Cập nhật chuỗi rỗng
        await authProvider.updateUserPhone("");
      } else {
        // Nếu đang trong luồng thêm/sửa -> Cập nhật số mới
        await authProvider.updateUserPhone(_phoneController.text.trim());
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_isDeleting ? localeProvider.getText('phone_delete_success') : localeProvider.getText('phone_update_success'))),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localeProvider.getText('otp_error'))),
      );
    }
  }

  // --- HÀM 3: HIỂN THỊ SHEET ---
  void _showPhoneEditSheet(BuildContext context, String? currentPhone, AuthProvider auth, bool isDark, LocaleProvider localeProvider) {
    _phoneController.text = currentPhone ?? "";
    _otpController.clear();
    _verificationId = null;
    _isDeleting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 20, right: 20, top: 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 20), decoration: BoxDecoration(color: Colors.grey[600], borderRadius: BorderRadius.circular(2))),

                Text(
                  _verificationId == null
                      ? (currentPhone == null || currentPhone.isEmpty ? localeProvider.getText('add_phone') : localeProvider.getText('update_delete_phone'))
                      : localeProvider.getText('verify_otp'),
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black),
                ),
                const SizedBox(height: 20),

                if (_verificationId == null) ...[
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    autofocus: true,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black),
                    decoration: InputDecoration(
                      hintText: localeProvider.getText('phone_hint'),
                      helperText: localeProvider.getText('phone_helper'),
                      prefixIcon: const Icon(Icons.phone, color: Colors.blue),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ] else ...[
                  Text("${localeProvider.getText('otp_sent_to')} ${_phoneController.text}", style: const TextStyle(color: Colors.grey, fontSize: 13)),
                  const SizedBox(height: 15),
                  TextField(
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    autofocus: true,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 8,
                    ),
                    decoration: InputDecoration(
                      hintText: localeProvider.getText('otp_hint'),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],

                const SizedBox(height: 25),

                if (_isLoading)
                  const Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator())
                else
                  Row(
                    children: [
                      // NÚT XÓA SỐ (Cần gửi OTP)
                      if (currentPhone != null && currentPhone.isNotEmpty && _verificationId == null)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () async {
                              setModalState(() => _isDeleting = true);
                              await _sendOTP(currentPhone, setModalState, localeProvider);
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.red),
                              padding: const EdgeInsets.symmetric(vertical: 15),
                            ),
                            child: Text(localeProvider.getText('delete_phone'), style: const TextStyle(color: Colors.red)),
                          ),
                        ),

                      if (currentPhone != null && currentPhone.isNotEmpty && _verificationId == null) const SizedBox(width: 10),

                      // NÚT GỬI/XÁC NHẬN OTP
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            if (_verificationId == null) {
                              if (_phoneController.text.trim().isNotEmpty) {
                                setModalState(() => _isDeleting = false); // Đánh dấu là cập nhật
                                await _sendOTP(_phoneController.text.trim(), setModalState, localeProvider);
                              }
                            } else {
                              // Xác nhận mã OTP
                              firebase_auth.PhoneAuthCredential credential = firebase_auth.PhoneAuthProvider.credential(
                                verificationId: _verificationId!,
                                smsCode: _otpController.text.trim(),
                              );
                              await _verifyAndProcess(credential, localeProvider);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: Text(
                            _verificationId == null ? localeProvider.getText('send_otp') : localeProvider.getText('confirm_otp'),
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    ).then((_) {
      setState(() {
        _verificationId = null;
        _isLoading = false;
        _isDeleting = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = auth.currentUser;
    final String username = user?['username'] ?? "User";
    final String? phone = user?['phone'];
    final Color textColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey[100],
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: textColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(localeProvider.getText('my_profile_title'), style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 30),
          CircleAvatar(
            radius: 60,
            backgroundColor: Colors.green,
            child: Text(
              username.isNotEmpty ? username[0].toUpperCase() : "U",
              style: const TextStyle(fontSize: 40, color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 20),
          Text(username, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textColor)),
          const SizedBox(height: 30),

          _infoCard(localeProvider.getText('contact_info'), isDark, [
            _infoRow(Icons.email_outlined, user?['email'] ?? localeProvider.getText('no_email'), textColor),
            GestureDetector(
              onTap: () => _showPhoneEditSheet(context, phone, auth, isDark, localeProvider),
              child: _infoRow(
                  Icons.phone_outlined,
                  (phone != null && phone.isNotEmpty) ? phone : localeProvider.getText('add_phone'),
                  (phone != null && phone.isNotEmpty) ? textColor : Colors.blue
              ),
            ),
          ]),
        ],
      ),
    );
  }

  // Các Widget Helper giữ nguyên
  Widget _infoCard(String title, bool isDark, List<Widget> children) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      borderRadius: BorderRadius.circular(15),
      boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
      const SizedBox(height: 10),
      ...children
    ]),
  );

  Widget _infoRow(IconData icon, String text, Color color) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Row(children: [
      Icon(icon, color: Colors.grey, size: 20),
      const SizedBox(width: 15),
      Text(text, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
      const Spacer(),
      const Icon(Icons.chevron_right, color: Colors.grey, size: 18),
    ]),
  );
}