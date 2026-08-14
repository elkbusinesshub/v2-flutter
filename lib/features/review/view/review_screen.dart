import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/state_views.dart';
import '../../../l10n/app_localizations.dart';
import '../cubit/review_cubit.dart';

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({super.key, required this.bookingId, required this.onDone});

  final String bookingId;
  final VoidCallback onDone;

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<ReviewCubit>().loadTarget(widget.bookingId);
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(l10n.rateYourExperience),
        backgroundColor: AppColors.dark,
        foregroundColor: Colors.white,
      ),
      body: BlocConsumer<ReviewCubit, ReviewState>(
        listenWhen: (previous, current) =>
            previous.status != current.status ||
            previous.errorMessage != current.errorMessage,
        listener: (context, state) {
          if (state.status == ReviewStatus.submitted) {
            widget.onDone();
          } else if (state.errorMessage != null && state.target != null) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          }
        },
        builder: (context, state) {
          if (state.status == ReviewStatus.loading || state.status == ReviewStatus.initial) {
            return const LoadingView();
          }
          if (state.status == ReviewStatus.guest) {
            return SignInRequiredView(
              message: l10n.reviewSignInPrompt,
            );
          }
          if (state.status == ReviewStatus.error && state.target == null) {
            return ErrorRetryView(
              message: state.errorMessage ?? l10n.errorGeneric,
              onRetry: () => context.read<ReviewCubit>().loadTarget(widget.bookingId),
            );
          }

          final target = state.target;
          if (target == null) return const SizedBox.shrink();

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    Center(
                      child: Column(
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: const BoxDecoration(
                              color: AppColors.teal,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                target.providerInitials,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            target.providerName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.dark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${target.serviceName} · ${target.durationLabel}',
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    Center(
                      child: Text(
                        l10n.howWasExperience,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.dark,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        final starIndex = index + 1;
                        final filled = starIndex <= state.rating;
                        return GestureDetector(
                          onTap: () => context.read<ReviewCubit>().setRating(starIndex),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Icon(
                              filled ? Icons.star_rounded : Icons.star_outline_rounded,
                              size: 38,
                              color: filled ? AppColors.yellow : AppColors.border,
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      l10n.whatWentWell,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.dark,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: target.quickTags.map((tag) {
                        final selected = state.selectedTags.contains(tag);
                        return GestureDetector(
                          onTap: () => context.read<ReviewCubit>().toggleTag(tag),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: selected ? AppColors.tealLight : AppColors.grayLight,
                              borderRadius: BorderRadius.circular(AppRadius.xl),
                              border: Border.all(
                                color: selected ? AppColors.teal : Colors.transparent,
                              ),
                            ),
                            child: Text(
                              tag,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: selected ? AppColors.tealDark : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      l10n.addCommentOptional,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.dark,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.grayLight,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: TextField(
                        controller: _commentController,
                        maxLines: 4,
                        onChanged: context.read<ReviewCubit>().commentChanged,
                        decoration: InputDecoration(
                          hintText: l10n.shareDetailsHint,
                          hintStyle: TextStyle(fontSize: 13, color: AppColors.gray),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(14),
                        ),
                        style: const TextStyle(fontSize: 13, color: AppColors.dark),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.yellowLight,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.card_giftcard, color: AppColors.yellow, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Earn ${target.rewardPoints} reward points for completing this review.',
                              style: const TextStyle(fontSize: 12, color: AppColors.dark),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.fromLTRB(
                  20,
                  14,
                  20,
                  14 + MediaQuery.of(context).padding.bottom,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                        color: Color(0x14000000), blurRadius: 12, offset: Offset(0, -4)),
                  ],
                ),
                child: PrimaryButton(
                  label: l10n.submitReview,
                  isLoading: state.status == ReviewStatus.submitting,
                  onPressed: state.canSubmit
                      ? () => context.read<ReviewCubit>().submit(widget.bookingId)
                      : null,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
