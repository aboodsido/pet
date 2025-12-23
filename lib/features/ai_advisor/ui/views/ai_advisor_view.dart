import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pet/features/ai_advisor/logic/ai_advisor_cubit.dart';
import 'package:pet/features/ai_advisor/logic/ai_advisor_state.dart';

import '../widgets/insight_card.dart';
import '../widgets/safety_card.dart';

class AiAdvisorView extends StatefulWidget {
  const AiAdvisorView({super.key});

  @override
  State<AiAdvisorView> createState() => _AiAdvisorViewState();
}

class _AiAdvisorViewState extends State<AiAdvisorView> {
  final TextEditingController _questionController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<AiAdvisorCubit>().analyzeSpending();
  }

  @override
  void dispose() {
    _questionController.dispose();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ai_advisor'.tr()),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined),
            onPressed: () => context.read<AiAdvisorCubit>().clearChat(),
            tooltip: 'Clear Chat',
          ),
        ],
      ),
      body: BlocConsumer<AiAdvisorCubit, AiAdvisorState>(
        listener: (context, state) {
          if (state is AiAdvisorLoaded && state.aiResponse != null) {
            _scrollToBottom();
          }
        },
        builder: (context, state) {
          if (state is AiAdvisorInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  onRefresh:
                      () async =>
                          context.read<AiAdvisorCubit>().analyzeSpending(),
                  child: ListView(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    children: [
                      if (state is AiAdvisorLoaded ||
                          (state is AiAdvisorLoading &&
                              state.userQuestion == null)) ...[
                        _buildSummarySection(state),
                      ],
                      if (state is AiAdvisorLoaded) ...[
                        ...state.chatHistory.map(
                          (msg) => _buildChatBubble(msg),
                        ),
                      ],
                      if (state is AiAdvisorLoading &&
                          state.userQuestion != null) ...[
                        _buildChatBubble({
                          'role': 'user',
                          'content': state.userQuestion!,
                        }),
                        _buildAiLoadingBubble(),
                      ],
                      if (state is AiAdvisorError) ...[
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              'error'.tr(args: [state.message]),
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              if (state is AiAdvisorLoaded ||
                  (state is AiAdvisorLoading && state.userQuestion != null))
                _buildInputArea(context, state),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSummarySection(AiAdvisorState state) {
    if (state is AiAdvisorLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (state is AiAdvisorLoaded) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SafetyCard(score: state.safetyScore),
          const SizedBox(height: 24),
          Text(
            'personalized_insights'.tr(),
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...state.insights.map((insight) => InsightCard(rawText: insight)),
          const Divider(height: 48),
          Text(
            'Ask Gemini Advisor',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Try asking: "Can I afford a coffee today?" or "Summarize my spending"',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 16),
        ],
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildChatBubble(Map<String, String> msg) {
    final isUser = msg['role'] == 'user';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser)
            Container(
              margin: const EdgeInsets.only(right: 8, top: 4),
              child: const CircleAvatar(
                radius: 14,
                backgroundColor: Colors.blueAccent,
                child: Icon(Icons.auto_awesome, size: 16, color: Colors.white),
              ),
            ),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color:
                    isUser
                        ? Theme.of(context).primaryColor
                        : Theme.of(context).cardColor,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 0),
                  bottomRight: Radius.circular(isUser ? 0 : 16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                msg['content'] ?? '',
                style: TextStyle(
                  color:
                      isUser
                          ? Colors.white
                          : Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ),
          ),
          if (isUser)
            Container(
              margin: const EdgeInsets.only(left: 8, top: 4),
              child: const CircleAvatar(
                radius: 14,
                backgroundColor: Colors.grey,
                child: Icon(Icons.person, size: 16, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAiLoadingBubble() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const CircleAvatar(
            radius: 14,
            backgroundColor: Colors.blueAccent,
            child: Icon(Icons.auto_awesome, size: 16, color: Colors.white),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea(BuildContext context, AiAdvisorState state) {
    final isLoading = state is AiAdvisorLoading;
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        8,
        16,
        16 + MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _questionController,
              decoration: InputDecoration(
                hintText: 'Ask your financial advisor...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
              ),
              onSubmitted:
                  isLoading ? null : (val) => _sendQuestion(context, val),
            ),
          ),
          const SizedBox(width: 8),
          FloatingActionButton.small(
            onPressed:
                isLoading
                    ? null
                    : () => _sendQuestion(context, _questionController.text),
            elevation: 0,
            child:
                isLoading
                    ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                    : const Icon(Icons.send_rounded),
          ),
        ],
      ),
    );
  }

  void _sendQuestion(BuildContext context, String text) {
    if (text.trim().isEmpty) return;
    context.read<AiAdvisorCubit>().askAi(text.trim());
    _questionController.clear();
  }
}
