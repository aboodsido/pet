import 'package:equatable/equatable.dart';

abstract class AiAdvisorState extends Equatable {
  const AiAdvisorState();

  @override
  List<Object?> get props => [];
}

class AiAdvisorInitial extends AiAdvisorState {}

class AiAdvisorLoading extends AiAdvisorState {}

class AiAdvisorLoaded extends AiAdvisorState {
  final List<String> insights;
  final String safetyScore; // e.g. "Good", "Warning", "Critical"

  const AiAdvisorLoaded({required this.insights, required this.safetyScore});

  @override
  List<Object?> get props => [insights, safetyScore];
}

class AiAdvisorError extends AiAdvisorState {
  final String message;
  const AiAdvisorError(this.message);

  @override
  List<Object?> get props => [message];
}
