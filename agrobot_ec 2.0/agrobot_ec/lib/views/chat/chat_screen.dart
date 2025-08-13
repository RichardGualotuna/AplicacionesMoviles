import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../viewmodels/chat_viewmodel.dart';
import '../../widgets/chat/chat_bubble.dart';
import '../../widgets/chat/chat_input.dart';
import '../../widgets/chat/typing_indicator.dart';
import '../../widgets/chat/voice_button.dart';
import '../../routes/app_routes.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _scrollController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatViewModel>(
      builder: (context, viewModel, child) {
        // Auto scroll when new messages are added
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

        return Scaffold(
          appBar: AppBar(
            title: Column(
              children: [
                const Text('🌾 AgroBot Assistant'),
                Text(
                  '${viewModel.currentCrop} - ${viewModel.currentLocation}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.successGreen,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'En línea',
                      style: TextStyle(fontSize: 10),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'profile':
                      context.push(AppRoutes.profile);
                      break;
                    case 'history':
                      context.push(AppRoutes.history);
                      break;
                    case 'clear':
                      viewModel.clearChat();
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'profile',
                    child: Row(
                      children: [
                        Icon(Icons.person),
                        SizedBox(width: 8),
                        Text('Mi Perfil'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'history',
                    child: Row(
                      children: [
                        Icon(Icons.history),
                        SizedBox(width: 8),
                        Text('Historial'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'clear',
                    child: Row(
                      children: [
                        Icon(Icons.clear_all),
                        SizedBox(width: 8),
                        Text('Limpiar Chat'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: Column(
            children: [
              // Chat messages
              Expanded(
                child: Container(
                  color: AppColors.backgroundLight,
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: viewModel.messages.length + (viewModel.isTyping ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index < viewModel.messages.length) {
                        final message = viewModel.messages[index];
                        return ChatBubble(message: message);
                      } else {
                        // Typing indicator
                        return const TypingIndicator();
                      }
                    },
                  ),
                ),
              ),

              // Quick suggestions
              if (viewModel.quickSuggestions.isNotEmpty)
                Container(
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: viewModel.quickSuggestions.length,
                    itemBuilder: (context, index) {
                      final suggestion = viewModel.quickSuggestions[index];
                      return Container(
                        margin: const EdgeInsets.only(right: 8),
                        child: ActionChip(
                          label: Text(suggestion),
                          onPressed: () => viewModel.sendQuickSuggestion(suggestion),
                          backgroundColor: AppColors.backgroundGray,
                          side: const BorderSide(color: AppColors.borderGray),
                        ),
                      );
                    },
                  ),
                ),

              // Input area
              ChatInput(
                controller: _messageController,
                onSendMessage: (message) {
                  viewModel.sendMessage(message);
                  _messageController.clear();
                },
                isLoading: viewModel.isLoading,
              ),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: 0,
            onTap: (index) {
              switch (index) {
                case 0:
                  // Already on chat
                  break;
                case 1:
                  context.push(AppRoutes.notifications);
                  break;
                case 2:
                  context.push(AppRoutes.profile);
                  break;
                case 3:
                  context.push(AppRoutes.settings);
                  break;
              }
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.chat),
                label: 'Chat',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.notifications),
                label: 'Alertas',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Perfil',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings),
                label: 'Config',
              ),
            ],
          ),
        );
      },
    );
  }
}