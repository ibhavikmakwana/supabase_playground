/*
 * BSD 2-Clause License
 *
 * Copyright (c) 2021, Bhavik Makwana
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice, this
 *    list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart';
import 'package:supabase_playground/screen/onboarding/store/on_boarding_store.dart';
import 'package:supabase_playground/values/extensions.dart';
import 'package:supabase_playground/widget/custom_button.dart';
import 'package:supabase_playground/widget/custom_text_field.dart';
import 'package:supabase_playground/widget/indicator_dot.dart';

class LoginSignUpScreen extends StatefulWidget {
  @override
  _LoginSignUpScreenState createState() => _LoginSignUpScreenState();
}

class _LoginSignUpScreenState extends State<LoginSignUpScreen> {
  late final OnBoardingStore _onBoardingStore;
  late final ReactionDisposer _reactionDisposer;

  @override
  void initState() {
    super.initState();
    _onBoardingStore = OnBoardingStore();
    _reactionDisposer = when(
      (_) => _onBoardingStore.errorMessage != null,
      () {
        context.showSnackBar(
          _onBoardingStore.errorMessage!,
        );
      },
    );
  }

  @override
  void dispose() {
    _onBoardingStore.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SingleChildScrollView(
            child: Observer(
              builder: (_) => Form(
                key: _onBoardingStore.onBoardingFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 32),
                    const FlutterLogo(
                      size: 64,
                      style: FlutterLogoStyle.stacked,
                    ),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        CustomOnBoardingTab(
                          onPressed: () {
                            if (!_onBoardingStore.isLogin) {
                              _onBoardingStore.isLogin = true;
                            } else {
                              return;
                            }
                          },
                          title: AppLocalizations.of(context)?.login ?? '',
                          isSelected: _onBoardingStore.isLogin,
                        ),
                        CustomOnBoardingTab(
                          onPressed: () {
                            if (_onBoardingStore.isLogin) {
                              _onBoardingStore.isLogin = false;
                            } else {
                              return;
                            }
                          },
                          title: AppLocalizations.of(context)?.signUp ?? '',
                          isSelected: !_onBoardingStore.isLogin,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      AppLocalizations.of(context)?.email ?? '',
                      style: Theme.of(context)
                          .textTheme
                          .subtitle1
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _onBoardingStore.emailController,
                      focusNode: _onBoardingStore.emailFocusNode,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: (String? value) {
                        if (value?.isEmpty ?? true) {
                          return 'Please enter valid email.';
                        }
                      },
                      hintText:
                          AppLocalizations.of(context)?.enterYourEmail ?? '',
                    ),
                    const SizedBox(height: 24),
                    Text(
                      AppLocalizations.of(context)?.password ?? '',
                      style: Theme.of(context)
                          .textTheme
                          .subtitle1
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _onBoardingStore.passwordController,
                      focusNode: _onBoardingStore.passwordFocusNode,
                      textInputAction: _onBoardingStore.isLogin
                          ? TextInputAction.done
                          : TextInputAction.next,
                      obscureText: true,
                      validator: (String? value) {
                        if (value?.isEmpty ?? true) {
                          return 'Please enter password.';
                        } else if (value != null && value.length < 6) {
                          return 'Password should be more than 6 characters.';
                        }
                      },
                      hintText:
                          AppLocalizations.of(context)?.enterYourPassword ?? '',
                    ),
                    if (_onBoardingStore.isLogin) ...{
                      const SizedBox(height: 24),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
                          child: Text(
                            AppLocalizations.of(context)?.forgotPassword ?? '',
                            style: Theme.of(context).textTheme.bodyText2,
                          ),
                        ),
                      ),
                    } else ...{
                      const SizedBox(height: 24),
                      Text(
                        AppLocalizations.of(context)?.confirmPassword ?? '',
                        style: Theme.of(context)
                            .textTheme
                            .subtitle1
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _onBoardingStore.confirmPasswordController,
                        focusNode: _onBoardingStore.confirmPasswordFocusNode,
                        textInputAction: TextInputAction.done,
                        validator: (String? value) {
                          if (!_onBoardingStore.isLogin) {
                            if (value?.isEmpty ?? true) {
                              return 'Please confirm your password.';
                            } else if (value != null &&
                                value !=
                                    _onBoardingStore.passwordController.text) {
                              return 'Password and Confirm Password should be the same.';
                            }
                          }
                        },
                        obscureText: true,
                        hintText:
                            AppLocalizations.of(context)?.confirmPassword ?? '',
                      ),
                    },
                    const SizedBox(height: 24),
                    CustomButton(
                      onPressed: () async {
                        if (_onBoardingStore.isLoading) return;
                        if (_onBoardingStore.isLogin) {
                          _onBoardingStore.login(context);
                        } else {
                          await _onBoardingStore.signUp(context);
                        }
                      },
                      isLoading: _onBoardingStore.isLoading,
                      text: _onBoardingStore.isLogin
                          ? AppLocalizations.of(context)?.login ?? ''
                          : AppLocalizations.of(context)?.signUp ?? '',
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CustomOnBoardingTab extends StatelessWidget {
  const CustomOnBoardingTab({
    Key? key,
    this.onPressed,
    this.isSelected = false,
    this.title,
  }) : super(key: key);

  final VoidCallback? onPressed;
  final bool? isSelected;
  final String? title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        TextButton(
          onPressed: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              children: [
                Text(
                  title!,
                  style: Theme.of(context).textTheme.subtitle1?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isSelected ?? false
                            ? Theme.of(context).tabBarTheme.labelColor
                            : Theme.of(context)
                                .tabBarTheme
                                .unselectedLabelColor,
                      ),
                ),
                const SizedBox(height: 8),
                IndicatorDot(isSelected: isSelected),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
