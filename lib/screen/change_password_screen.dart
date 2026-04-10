import 'package:flutter/material.dart';

class ChangePasswordScreen extends StatelessWidget {
  const ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // 1. Định nghĩa màu chữ linh hoạt
    final Color textColor = isDark ? Colors.white : Colors.black;
    final Color subTextColor = isDark ? Colors.white70 : Colors.black87;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey[100],
      appBar: AppBar(
        // AppBar cũng cần đổi màu chữ tiêu đề
        title: Text("Đổi mật khẩu", style: TextStyle(color: textColor)),
        centerTitle: true,
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor), // Màu nút back
      ),
      body: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            _input("Mật khẩu hiện tại", isDark, textColor),
            const SizedBox(height: 20),
            _input("Mật khẩu mới", isDark, textColor),
            Align(
                alignment: Alignment.centerRight,
                child: Text("0/64", style: TextStyle(color: isDark ? Colors.grey : Colors.grey.shade600))
            ),
            const SizedBox(height: 20),

            // 2. Truyền màu subTextColor vào các dòng check
            _check("Từ 9 đến 64 ký tự", subTextColor),
            _check("Ít nhất một chữ cái", subTextColor),
            _check("Ít nhất một chữ số", subTextColor),
            _check("Chỉ chữ cái, chữ số, khoảng trắng và ký tự đặc biệt", subTextColor),

            const Spacer(),

            // 3. Nút LƯU cũng cần đổi màu theo trạng thái (thường nút này sẽ nổi bật)
            SizedBox(
              width: double.infinity, height: 55,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                    shape: const StadiumBorder()
                ),
                child: Text(
                    "LƯU",
                    style: TextStyle(
                        color: isDark ? Colors.grey : Colors.grey.shade700,
                        fontWeight: FontWeight.bold
                    )
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Cập nhật Widget Input để nhận textColor
  Widget _input(String label, bool isDark, Color textColor) => TextField(
    obscureText: true,
    style: TextStyle(color: textColor), // Chữ người dùng gõ vào
    decoration: InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: isDark ? Colors.grey : Colors.grey.shade700),
      suffixIcon: const Icon(Icons.visibility_outlined, color: Colors.grey),
      // Màu nền của ô nhập liệu
      filled: true,
      fillColor: isDark ? Colors.white10 : Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: isDark ? Colors.grey.shade800 : Colors.grey.shade400),
      ),
    ),
  );

  // Cập nhật Widget Check để nhận màu linh hoạt
  Widget _check(String text, Color color) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      children: [
        const Icon(Icons.radio_button_off, size: 16, color: Colors.grey),
        const SizedBox(width: 10),
        Expanded(
            child: Text(
                text,
                style: TextStyle(color: color) // Sửa lỗi mất chữ ở đây
            )
        )
      ],
    ),
  );
}