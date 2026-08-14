import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/location/current_location.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/buttons.dart';
import '../../../l10n/app_localizations.dart';
import '../cubit/onboarding_cubit.dart';

class _OnboardPage {
  const _OnboardPage({
    required this.emoji,
    required this.title,
    required this.description,
  });

  final String emoji;
  final String title;
  final String description;
}

List<_OnboardPage> _pagesFor(AppLocalizations l10n) => [
      _OnboardPage(
        emoji: '🏙️',
        title: l10n.onboardServicesTitle,
        description: l10n.onboardServicesBody,
      ),
      _OnboardPage(
        emoji: '📍',
        title: l10n.onboardTrackingTitle,
        description: l10n.onboardTrackingBody,
      ),
      _OnboardPage(
        emoji: '💳',
        title: l10n.onboardPaymentsTitle,
        description: l10n.onboardPaymentsBody,
      ),
    ];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.onFinished});

  final VoidCallback onFinished;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late final PageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await context.read<OnboardingCubit>().complete();
    // Asked once here so pickup addresses are pre-filled everywhere from the
    // first booking. Declining is fine — every screen falls back to the picker.
    await requestLocationPermissionOnce();
    if (!mounted) return;
    widget.onFinished();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final pages = _pagesFor(l10n);

    return BlocBuilder<OnboardingCubit, OnboardingState>(
      builder: (context, state) {
        final isLast = state.pageIndex == pages.length - 1;
        return Scaffold(
          backgroundColor: Colors.white,
          body: Column(
            children: [
              SizedBox(
                height: 320,
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      height: double.infinity,
                      decoration: const BoxDecoration(
                        gradient: AppColors.navyHeader,
                      ),
                    ),
                    PageView.builder(
                      controller: _controller,
                      itemCount: pages.length,
                      onPageChanged: context.read<OnboardingCubit>().pageChanged,
                      itemBuilder: (context, index) => Center(
                        child: Text(
                          pages[index].emoji,
                          style: const TextStyle(fontSize: 88),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 16,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(pages.length, (i) {
                          final active = i == state.pageIndex;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            width: active ? 28 : 18,
                            height: 4,
                            decoration: BoxDecoration(
                              color: active
                                  ? AppColors.yellow
                                  : Colors.white.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pages[state.pageIndex].title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.dark,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        pages[state.pageIndex].description,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.gray,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
                child: Column(
                  children: [
                    PrimaryButton(
                      label: isLast ? l10n.getStarted : l10n.commonNext,
                      onPressed: () {
                        if (isLast) {
                          _finish();
                        } else {
                          _controller.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOut,
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 8),
                    SecondaryButton(label: l10n.signIn, onPressed: _finish),
                    const SizedBox(height: 12),
                    Text.rich(
                      TextSpan(
                        text: l10n.byContinuingYouAgree,
                        style: const TextStyle(fontSize: 11, color: Color(0xFFBBBBBB)),
                        children: [
                          TextSpan(
                            text: l10n.termsAndConditions,
                            style: const TextStyle(
                                color: AppColors.teal,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
