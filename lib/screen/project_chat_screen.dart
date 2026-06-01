import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../app_theme.dart';
import '../model/message_model.dart';
import '../provider/auth_provider.dart';
import '../provider/chat_provider.dart';

class ProjectChatScreen extends StatefulWidget {
  final String projectId;
  final String projectName;

  const ProjectChatScreen({
    super.key,
    required this.projectId,
    required this.projectName,
  });

  @override
  State<ProjectChatScreen> createState() => _ProjectChatScreenState();
}

class _ProjectChatScreenState extends State<ProjectChatScreen> {
  final TextEditingController _msgController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ChatProvider>(context, listen: false).listenToMessages(widget.projectId);
    });
  }

  @override
  void dispose() {
    _msgController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final userId = auth.userModel?.uid ?? 'unknown';
    final userName = auth.userModel?.displayName ?? 'Anonymous';

    final message = MessageModel(
      messageId: '',
      projectId: widget.projectId,
      senderId: userId,
      senderName: userName,
      text: text,
      timestamp: DateTime.now(),
    );

    Provider.of<ChatProvider>(context, listen: false).sendMessage(message);
    _msgController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final chatProvider = Provider.of<ChatProvider>(context);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final currentUserId = auth.userModel?.uid ?? '';

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : const Color(0xFFF3F2FF),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 16,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Chat Dự án", style: AppTextStyles.heading3(isDark)),
            Text(widget.projectName, style: AppTextStyles.caption(isDark).copyWith(color: AppColors.primary)),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: chatProvider.isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : chatProvider.messages.isEmpty
                    ? Center(
                        child: Text("Bắt đầu trò chuyện với nhóm của bạn!", style: AppTextStyles.body(isDark)),
                      )
                    : ListView.builder(
                        reverse: true, // Show latest messages at the bottom
                        padding: const EdgeInsets.all(16),
                        itemCount: chatProvider.messages.length,
                        itemBuilder: (context, index) {
                          final msg = chatProvider.messages[index];
                          final isMe = msg.senderId == currentUserId;
                          return _buildMessageItem(msg, isMe, isDark);
                        },
                      ),
          ),
          _buildMessageInput(isDark),
        ],
      ),
    );
  }

  Widget _buildMessageItem(MessageModel msg, bool isMe, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe)
            Container(
              width: 32, height: 32,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                gradient: AppGradients.brand,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  msg.senderName.isNotEmpty ? msg.senderName[0].toUpperCase() : 'U',
                  style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            ),
          
          Flexible(
            child: Column(
              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (!isMe)
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 4),
                    child: Text(msg.senderName, style: AppTextStyles.caption(isDark).copyWith(fontSize: 12)),
                  ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isMe ? AppColors.primary : (isDark ? AppColors.darkCard : const Color(0xFFF3F2FF)),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: isMe ? const Radius.circular(16) : const Radius.circular(4),
                      bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(16),
                    ),
                  ),
                  child: Text(
                    msg.text,
                    style: AppTextStyles.body(isDark).copyWith(color: isMe ? Colors.white : null),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4, right: 4),
                  child: Text(
                    DateFormat('HH:mm').format(msg.timestamp),
                    style: AppTextStyles.caption(isDark).copyWith(fontSize: 10),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput(bool isDark) {
    return Container(
      padding: EdgeInsets.only(
        left: 16, right: 12, top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        boxShadow: AppShadows.bottomBar(isDark),
        border: Border(top: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _msgController,
              style: AppTextStyles.body(isDark),
              decoration: InputDecoration(
                hintText: "Nhập tin nhắn...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: isDark ? AppColors.darkCard : const Color(0xFFF3F2FF),
                contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                gradient: AppGradients.brand,
                shape: BoxShape.circle,
                boxShadow: AppShadows.glow(AppColors.primary),
              ),
              child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
