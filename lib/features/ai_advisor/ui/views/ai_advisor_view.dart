import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pet/core/theme/app_theme.dart';
import 'package:pet/features/ai_advisor/logic/ai_advisor_cubit.dart';
import 'package:pet/features/ai_advisor/logic/ai_advisor_state.dart';

class AiAdvisorView extends StatelessWidget {
  const AiAdvisorView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('ai_advisor'.tr())),
      body: BlocBuilder<AiAdvisorCubit, AiAdvisorState>(
        builder: (context, state) {
          if (state is AiAdvisorInitial) {
            context.read<AiAdvisorCubit>().analyzeSpending();
            return const Center(child: CircularProgressIndicator());
          }

          if (state is AiAdvisorLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is AiAdvisorLoaded) {
            return RefreshIndicator(
              onRefresh:
                  () async => context.read<AiAdvisorCubit>().analyzeSpending(),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildSafetyCard(state.safetyScore),
                  const SizedBox(height: 24),
                  Text(
                    'personalized_insights'.tr(),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  ...state.insights.map(
                    (insight) => _buildInsightCard(context, insight),
                  ),
                ],
              ),
            );
          }

          if (state is AiAdvisorError) {
            return Center(child: Text('error'.tr(args: [state.message])));
          }

          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildSafetyCard(String score) {
    Color color;
    IconData icon;
    String text;

    switch (score) {
      case 'Critical':
        color = AppTheme.errorColor;
        icon = Icons.warning_amber_rounded;
        text = 'health_critical'.tr();
        break;
      case 'Warning':
        color = Colors.orange;
        icon = Icons.info_outline;
        text = 'health_warning'.tr();
        break;
      default:
        color = AppTheme.accentColor;
        icon = Icons.check_circle_outline;
        text = 'health_stable'.tr();
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 40),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCard(BuildContext context, String text) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.auto_awesome,
            color: AppTheme.primaryColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text.replaceAll('**', ''), // Simple markdown clean for simplicity
              style: const TextStyle(fontSize: 15, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
