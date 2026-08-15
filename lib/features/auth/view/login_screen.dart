import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/widgets/buttons.dart';
import '../../../l10n/app_localizations.dart';
import '../bloc/auth_bloc.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key, required this.onAuthenticated});

  final VoidCallback onAuthenticated;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) =>
          previous.status != current.status &&
          current.status == AuthStatus.success,
      listener: (context, state) => onAuthenticated(),
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          return state.step == AuthStep.phoneEntry
              ? const _PhoneEntryView()
              : const _OtpView();
        },
      ),
    );
  }
}

class _PhoneEntryView extends StatefulWidget {
  const _PhoneEntryView();

  @override
  State<_PhoneEntryView> createState() => _PhoneEntryViewState();
}

class _PhoneEntryViewState extends State<_PhoneEntryView> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: context.read<AuthBloc>().state.phoneNumber,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = context.watch<AuthBloc>().state;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.authWelcomeBack,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.dark,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                l10n.authSignInPrompt,
                style: const TextStyle(fontSize: 13, color: AppColors.gray),
              ),
              const SizedBox(height: 28),
              Text(l10n.authMobileNumber, style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.dark,
              )),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFFAFBFC),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 14),
                      child: Text(
                        '🇮🇳 +91',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.dark,
                        ),
                      ),
                    ),
                    Container(width: 1, height: 24, color: AppColors.border),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        keyboardType: TextInputType.phone,
                        maxLength: 10,
                        onChanged: (value) => context
                            .read<AuthBloc>()
                            .add(PhoneNumberChanged(value)),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          counterText: '',
                          hintText: '98765 43210',
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (state.errorMessage != null) ...[
                const SizedBox(height: 10),
                Text(
                  state.errorMessage!,
                  style: const TextStyle(fontSize: 12, color: AppColors.danger),
                ),
              ],
              const SizedBox(height: 24),
              PrimaryButton(
                label: l10n.authSendOtp,
                isLoading: state.isLoading,
                onPressed: state.isPhoneValid
                    ? () => context.read<AuthBloc>().add(const OtpRequested())
                    : null,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  const Expanded(child: Divider(color: AppColors.border)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      l10n.commonOr,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.gray.withValues(alpha: 0.8),
                      ),
                    ),
                  ),
                  const Expanded(child: Divider(color: AppColors.border)),
                ],
              ),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: () =>
                      context.read<AuthBloc>().add(const GuestSignInRequested()),
                  child: Text(
                    l10n.authContinueAsGuest,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.teal,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OtpView extends StatefulWidget {
  const _OtpView();

  @override
  State<_OtpView> createState() => _OtpViewState();
}

class _OtpViewState extends State<_OtpView> {
  static const _digitCount = AuthState.otpLength;

  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;
  late int _secondsRemaining;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(_digitCount, (_) => TextEditingController());
    _focusNodes = List.generate(_digitCount, (_) => FocusNode());
    _secondsRemaining = context.read<AuthBloc>().state.resendCountdown;
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining <= 0) {
        timer.cancel();
        return;
      }
      setState(() => _secondsRemaining -= 1);
    });
  }

  void _onDigitChanged(int index, String value) {
    if (value.length > 1) {
      value = value.substring(value.length - 1);
      _controllers[index].text = value;
    }
    if (value.isNotEmpty && index < _digitCount - 1) {
      _focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    final otp = _controllers.map((c) => c.text).join();
    context.read<AuthBloc>().add(OtpChanged(otp));
    if (otp.length == _digitCount) {
      FocusScope.of(context).unfocus();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = context.watch<AuthBloc>().state;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.dark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () =>
              context.read<AuthBloc>().add(const EditPhoneNumberRequested()),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.authVerifyTitle,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.dark,
                ),
              ),
              const SizedBox(height: 6),
              Text.rich(
                TextSpan(
                  text: l10n.authOtpSentTo,
                  style: const TextStyle(fontSize: 13, color: AppColors.gray),
                  children: [
                    TextSpan(
                      text: '+91 ${state.phoneNumber}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.dark,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Six fixed-width boxes overflow a 360dp screen, so each cell
              // shares the row evenly instead.
              Row(
                children: List.generate(_digitCount, (index) {
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: index == _digitCount - 1 ? 0 : 8,
                      ),
                      child: SizedBox(
                        height: 60,
                        child: TextField(
                          controller: _controllers[index],
                          focusNode: _focusNodes[index],
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          maxLength: 1,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.dark,
                          ),
                          decoration: InputDecoration(
                            counterText: '',
                            filled: true,
                            fillColor: const Color(0xFFFAFBFC),
                            contentPadding: EdgeInsets.zero,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                              borderSide:
                                  const BorderSide(color: AppColors.border),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                              borderSide: const BorderSide(
                                color: AppColors.teal,
                                width: 1.5,
                              ),
                            ),
                          ),
                          onChanged: (value) => _onDigitChanged(index, value),
                        ),
                      ),
                    ),
                  );
                }),
              ),
              if (state.errorMessage != null) ...[
                const SizedBox(height: 16),
                Text(
                  state.errorMessage!,
                  style: const TextStyle(fontSize: 12, color: AppColors.danger),
                ),
              ],
              const SizedBox(height: 28),
              PrimaryButton(
                label: l10n.authVerifyContinue,
                isLoading: state.isLoading,
                onPressed: state.isOtpComplete
                    ? () => context.read<AuthBloc>().add(const OtpSubmitted())
                    : null,
              ),
              const SizedBox(height: 20),
              Center(
                child: _secondsRemaining > 0
                    ? Text(
                        l10n.authResendIn(
                            _secondsRemaining.toString().padLeft(2, '0')),
                        style: const TextStyle(fontSize: 13, color: AppColors.gray),
                      )
                    : TextButton(
                        onPressed: () {
                          context
                              .read<AuthBloc>()
                              .add(const OtpResendRequested());
                          setState(() {
                            _secondsRemaining =
                                context.read<AuthBloc>().state.resendCountdown;
                          });
                          _startTimer();
                        },
                        child: Text(
                          l10n.authResendCode,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.teal,
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
