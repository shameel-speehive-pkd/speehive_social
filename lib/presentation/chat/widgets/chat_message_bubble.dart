import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:speehive_social/core/utils/extensions.dart';
import 'package:speehive_social/domain/entities/chat_message.dart';

class ChatMessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isLastMessage;

  const ChatMessageBubble({
    super.key,
    required this.message,
    this.isLastMessage = false,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == MessageRole.user;
    final cs = context.colorScheme;

    return Padding(
      padding: EdgeInsets.only(
        left: isUser ? 64 : 16,
        right: isUser ? 16 : 64,
        top: 4,
        bottom: isLastMessage ? 16 : 4,
      ),
      child: Column(
        crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (message.hasToolCalls && !isUser) _buildToolCalls(context, cs),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isUser
                  ? cs.primaryContainer
                  : cs.surfaceContainerHighest,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(20),
                topRight: const Radius.circular(20),
                bottomLeft: Radius.circular(isUser ? 20 : 4),
                bottomRight: Radius.circular(isUser ? 4 : 20),
              ),
            ),
            child: isUser
                ? Text(message.content, style: context.textTheme.bodyMedium)
                : MarkdownBody(
                    data: message.content,
                    styleSheet: MarkdownStyleSheet(
                      p: context.textTheme.bodyMedium,
                      code: TextStyle(
                        backgroundColor: cs.tertiaryContainer,
                        color: cs.onTertiaryContainer,
                        fontFamily: 'monospace',
                        fontSize: 13,
                      ),
                      codeblockDecoration: BoxDecoration(
                        color: cs.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
          ),
          if (!isUser)
            Padding(
              padding: const EdgeInsets.only(left: 12, top: 4),
              child: Text(
                message.timestamp.timeOnly,
                style: context.textTheme.labelSmall?.copyWith(
                  color: cs.onSurfaceVariant.withAlpha(150),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildToolCalls(BuildContext context, ColorScheme cs) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.secondaryContainer.withAlpha(120),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant.withAlpha(80)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, size: 14, color: cs.onSecondaryContainer),
              const SizedBox(width: 6),
              Text(
                'AI Actions',
                style: context.textTheme.labelSmall?.copyWith(
                  color: cs.onSecondaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ...message.toolCalls.map((tool) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, size: 14, color: cs.primary),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '${tool.name}${tool.result != null ? " ✓" : " ..."}',
                        style: context.textTheme.bodySmall?.copyWith(
                          color: cs.onSecondaryContainer,
                        ),
                      ),
                    ),
                    if (tool.result != null)
                      Text(
                        'Done',
                        style: context.textTheme.labelSmall?.copyWith(
                          color: cs.primary,
                        ),
                      ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
