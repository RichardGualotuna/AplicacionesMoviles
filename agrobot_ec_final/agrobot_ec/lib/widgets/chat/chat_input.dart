import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class ChatInput extends StatefulWidget {
  final TextEditingController controller;
  final Function(String) onSendMessage;
  final bool isLoading;

  const ChatInput({
    super.key,
    required this.controller,
    required this.onSendMessage,
    this.isLoading = false,
  });

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  bool _isRecording = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: AppColors.borderLight),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Text input
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.backgroundLight,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: AppColors.borderGray),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: widget.controller,
                        decoration: const InputDecoration(
                          hintText: 'Escribe tu consulta agrícola...',
                          hintStyle: TextStyle(
                            color: AppColors.textGray,
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textDark,
                        ),
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                        textInputAction: TextInputAction.newline,
                        onSubmitted: (text) {
                          if (text.trim().isNotEmpty && !widget.isLoading) {
                            widget.onSendMessage(text.trim());
                          }
                        },
                      ),
                    ),
                    // Voice button
                    GestureDetector(
                      onTapDown: (_) => _startRecording(),
                      onTapUp: (_) => _stopRecording(),
                      onTapCancel: () => _stopRecording(),
                      child: Container(
                        margin: const EdgeInsets.only(right: 4),
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: _isRecording ? AppColors.errorRed : AppColors.textGray,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Icon(
                          _isRecording ? Icons.mic : Icons.mic_none,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            
            // Send button
            GestureDetector(
              onTap: () {
                final text = widget.controller.text.trim();
                if (text.isNotEmpty && !widget.isLoading) {
                  widget.onSendMessage(text);
                }
              },
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: widget.controller.text.trim().isNotEmpty && !widget.isLoading
                      ? AppColors.primaryGradient
                      : null,
                  color: widget.controller.text.trim().isEmpty || widget.isLoading
                      ? AppColors.borderGray
                      : null,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: widget.controller.text.trim().isNotEmpty && !widget.isLoading
                      ? [
                          BoxShadow(
                            color: AppColors.primaryGreen.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: widget.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 20,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _startRecording() {
    setState(() {
      _isRecording = true;
    });
    
    // TODO: Implement voice recording
    // Here you would start the speech recognition
    print('Started recording');
  }

  void _stopRecording() {
    setState(() {
      _isRecording = false;
    });
    
    // TODO: Implement voice recording stop
    // Here you would stop the speech recognition and process the result
    print('Stopped recording');
  }
}