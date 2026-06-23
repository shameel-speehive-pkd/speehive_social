import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speehive_social/core/utils/extensions.dart';
import 'package:speehive_social/presentation/chat/notifier/chat_notifier.dart';
import 'package:speehive_social/presentation/chat/widgets/chat_input_bar.dart';
import 'package:speehive_social/presentation/chat/widgets/chat_message_bubble.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleSend(String text) {
    debugPrint('[CHAT] ChatScreen._handleSend: "$text"');
    ref.read(chatProvider.notifier).streamMessage(text);
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.colorScheme;
    final chatState = ref.watch(chatProvider);

    ref.listen<bool>(
      chatProvider.select((s) => s.isStreaming || s.isLoading),
      (prev, next) {
        if (next) {
          _scrollToBottom();
        }
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [cs.primary, cs.tertiary],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.auto_awesome, size: 18, color: Colors.white),
            ),
            const SizedBox(width: 10),
            Text(
              'Speehive AI',
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.delete_outline, color: cs.onSurfaceVariant),
            tooltip: 'Clear chat',
            onPressed: () => ref.read(chatProvider.notifier).clearMessages(),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _buildBody(chatState, cs),
          ),
          ChatInputBar(
            onSend: _handleSend,
            isLoading: chatState.isLoading || chatState.isStreaming,
          ),
        ],
      ),
    );
  }

  Widget _buildBody(ChatState state, ColorScheme cs) {
    if (state.messages.isEmpty && !state.isStreaming) {
      if (state.error != null) {
        return _buildError(state.error!, cs);
      }
      return _buildWelcome(cs);
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: state.messages.length + (state.isStreaming ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < state.messages.length) {
          return ChatMessageBubble(
            message: state.messages[index],
            isLastMessage: index == state.messages.length - 1,
          );
        }
        return _buildStreamingBubble(cs, state);
      },
    );
  }

  Widget _buildWelcome(ColorScheme cs) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [cs.primary, cs.tertiary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(Icons.chat_bubble_outline_rounded,
                  size: 40, color: Colors.white),
            ),
            const SizedBox(height: 24),
            Text(
              'Welcome to Speehive AI',
              style: context.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Your social media automation assistant.\nSchedule posts, generate content, and manage your accounts.',
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _suggestionChip('Schedule a Twitter post', cs),
                _suggestionChip('Generate LinkedIn content', cs),
                _suggestionChip('Analyze my engagement', cs),
                _suggestionChip('Create an Instagram caption', cs),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _suggestionChip(String label, ColorScheme cs) {
    return ActionChip(
      label: Text(label, style: const TextStyle(fontSize: 13)),
      onPressed: () => _handleSend(label),
      backgroundColor: cs.surfaceContainerHighest,
      side: BorderSide(color: cs.outlineVariant.withAlpha(80)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }

  Widget _buildError(String message, ColorScheme cs) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded, size: 48, color: cs.error),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: context.textTheme.bodyLarge?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStreamingBubble(ColorScheme cs, ChatState state) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 64, top: 4, bottom: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomLeft: Radius.circular(4),
            bottomRight: Radius.circular(20),
          ),
        ),
        child: state.streamingContent.isNotEmpty
            ? Text(
                state.streamingContent,
                style: context.textTheme.bodyMedium,
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: cs.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text('Thinking...',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      )),
                ],
              ),
      ),
    );
  }
}
