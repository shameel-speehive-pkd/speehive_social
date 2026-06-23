import 'package:speehive_social/core/errors/failures.dart';
import 'package:speehive_social/domain/entities/chat_message.dart';

abstract class ChatRepository {
  Future<Result<Stream<String>>> streamResponse({
    required List<ChatMessage> messages,
    required Map<String, dynamic> tools,
    int? maxSteps,
  });

  Future<Result<Stream<String>>> streamResponseWithToolCalls({
    required List<ChatMessage> messages,
    required Map<String, dynamic> tools,
    int? maxSteps,
    void Function(List<ToolCallData>)? onToolCalls,
  });

  Future<Result<String>> generateResponse({
    required List<ChatMessage> messages,
    required Map<String, dynamic> tools,
    int? maxSteps,
  });
}

class Result<T> {
  final T? data;
  final Failure? error;

  const Result._({this.data, this.error});

  factory Result.success(T data) => Result._(data: data);

  factory Result.failure(Failure error) => Result._(error: error);

  bool get isSuccess => data != null;

  bool get isFailure => error != null;
}
