import 'package:equatable/equatable.dart';

abstract class AiAdvisorState extends Equatable {
  const AiAdvisorState();

  @override
  List<Object?> get props => [];
}

class AiAdvisorInitial extends AiAdvisorState {}

class AiAdvisorLoading extends AiAdvisorState {
  final String? userQuestion;
  const AiAdvisorLoading({this.userQuestion});

  @override
  List<Object?> get props => [userQuestion];
}

class AiAdvisorLoaded extends AiAdvisorState {
  final List<String> insights;
  final String safetyScore;
  final String? aiResponse;
  final List<Map<String, String>> chatHistory;

  const AiAdvisorLoaded({
    required this.insights,
    required this.safetyScore,
    this.aiResponse,
    this.chatHistory = const [],
  });

  @override
  List<Object?> get props => [insights, safetyScore, aiResponse, chatHistory];

  AiAdvisorLoaded copyWith({
    List<String>? insights,
    String? safetyScore,
    String? aiResponse,
    List<Map<String, String>>? chatHistory,
  }) {
    return AiAdvisorLoaded(
      insights: insights ?? this.insights,
      safetyScore: safetyScore ?? this.safetyScore,
      aiResponse: aiResponse ?? this.aiResponse,
      chatHistory: chatHistory ?? this.chatHistory,
    );
  }
}

class AiAdvisorError extends AiAdvisorState {
  final String message;
  const AiAdvisorError(this.message);

  @override
  List<Object?> get props => [message];
}
