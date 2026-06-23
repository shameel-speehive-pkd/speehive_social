import 'package:speehive_social/domain/entities/chat_message.dart';
import 'package:speehive_social/domain/repositories/chat_repository.dart';

class GenerateTextUseCase {
  final ChatRepository _repository;

  GenerateTextUseCase(this._repository);

  Future<Result<Stream<String>>> call({
    required List<ChatMessage> messages,
    required Map<String, dynamic> tools,
    int maxSteps = 10,
  }) {
    return _repository.streamResponse(
      messages: messages,
      tools: tools,
      maxSteps: maxSteps,
    );
  }
}
