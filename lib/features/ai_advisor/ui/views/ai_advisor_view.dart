import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pet/features/ai_advisor/logic/ai_advisor_cubit.dart';
import 'package:pet/features/ai_advisor/logic/ai_advisor_state.dart';

import '../widgets/insight_card.dart';
import '../widgets/safety_card.dart';

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
                  SafetyCard(score: state.safetyScore),
                  const SizedBox(height: 24),
                  Text(
                    'personalized_insights'.tr(),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  ...state.insights.map(
                    (insight) => InsightCard(rawText: insight),
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
}
