import 'dart:collection';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../../../main.dart';
import '../../../../providers/user_provider.dart';
import '../../models/authority_profile.dart';
import '../../models/issue_category.dart';
import '../../providers/report_issue_provider.dart';
import '../../services/authority_service.dart';
import '../../services/issue_submission_service.dart';
import '../../services/location_service.dart';
import '../../services/media_picker_service.dart';
import 'issue_submitted_success_screen.dart';

const Color _bg = Color(0xFF0B0B0B);
const Color _gold = Color(0xFFF5B62D);
const Color _green = Color(0xFF4CAF50);
const Color _warning = Color(0xFFFF9800);
const Color _error = Color(0xFFE53935);
const Color _textPrimary = Color(0xFFFFFFFF);
const Color _textSecondary = Color(0xFFBDBDBD);
const Color _surfaceSoft = Color(0xFF121214);
const Color _surfaceElevated = Color(0xFF1A1A1D);
const Color _textPrimarySoft = Color(0xFFF5F5F5);
const Color _textMuted = Color(0xFF9A9A9E);
const Color _successMuted = Color(0xFF5E9770);
const Color _dividerSoft = Color(0xFF26262A);
const Color _authBg = Color(0xFF080808);
const Color _authSurface = Color(0xFF14161C);
const Color _authCard = Color(0xFF181A20);
const Color _authBorder = Color(0x0DFFFFFF);
const Color _authDivider = Color(0x0AFFFFFF);
const Color _authGold = Color(0xFFF4B400);
const Color _authGoldDeep = Color(0xFFE2A400);
const Color _authTextPrimary = Color(0xFFFFFFFF);
const Color _authTextSecondary = Color(0xFFB6BEC9);
const Color _authHint = Color(0xFF7E8591);
const bool _enableGoogleMaps = bool.fromEnvironment(
  'ENABLE_GOOGLE_MAPS',
  defaultValue: false,
);

int _authorityPriorityOrder(AuthorityProfile authority) {
  final String d = authority.designation.toLowerCase();
  if (d.contains('mla')) {
    return 0;
  }
  if (d.contains('mlc')) {
    return 1;
  }
  if (d.contains('member of parliament') ||
      RegExp(r'(^|\W)mp(\W|$)').hasMatch(d)) {
    return 2;
  }
  if (d.contains('councillor') ||
      d.contains('councilor') ||
      d.contains('corporator')) {
    return 3;
  }
  if (d.contains('sarpanch')) {
    return 4;
  }
  return 99;
}

class _IssueTickIcon extends StatelessWidget {
  const _IssueTickIcon({this.size = 14, this.color = const Color(0xFF34C759)});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.verified_rounded, size: size, color: color);
  }
}

String _nonEmptyOr(String value, String fallback) {
  final String v = value.trim();
  if (v.isEmpty || v.toLowerCase() == 'n/a') {
    return fallback;
  }
  return v;
}

String _cleanConstituencyDisplay(String rawValue) {
  String value = rawValue.trim();
  if (value.isEmpty || value.toLowerCase() == 'n/a') {
    return value;
  }

  value = value.replaceAll(
    RegExp(
      r'\s*,?\s*(parliamentary\s+)?constituency\s*$',
      caseSensitive: false,
    ),
    '',
  );
  value = value.replaceAll(RegExp(r'\s{2,}'), ' ').trim();
  return value.isEmpty ? rawValue.trim() : value;
}

String _constituencyDisplayValue(AuthorityProfile authority) {
  final String raw = _nonEmptyOr(
    authority.constituency,
    authority.jurisdiction,
  );
  return _cleanConstituencyDisplay(raw);
}

double? _normalizedResolutionRate(double? rawRate) {
  if (rawRate == null || rawRate.isNaN) {
    return null;
  }
  final double value = rawRate <= 1 ? rawRate * 100 : rawRate;
  return value.clamp(0, 100).toDouble();
}

class ReportIssueScreen extends StatelessWidget {
  const ReportIssueScreen({super.key, this.onCompleted});

  final VoidCallback? onCompleted;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ReportIssueProvider>(
      create: (_) => ReportIssueProvider(
        mediaPickerService: MediaPickerService(),
        locationService: const LocationService(),
        submissionService: IssueSubmissionService(),
        authorityService: AuthorityService(),
      ),
      child: _ReportIssueView(onCompleted: onCompleted),
    );
  }
}

class _ReportIssueView extends StatefulWidget {
  const _ReportIssueView({required this.onCompleted});

  final VoidCallback? onCompleted;

  @override
  State<_ReportIssueView> createState() => _ReportIssueViewState();
}

class _ReportIssueViewState extends State<_ReportIssueView>
    with TickerProviderStateMixin {
  late final TextEditingController _descriptionController;
  late final TextEditingController _locationController;
  bool _detailsStepInitialized = false;
  bool _reviewConfirmed = false;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController();
    _locationController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      context.read<ReportIssueProvider>().restoreDraft();
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _submit(ReportIssueProvider provider) async {
    final UserProvider? userProvider = Provider.of<UserProvider?>(
      context,
      listen: false,
    );
    final String rawUserId = userProvider?.firebaseUser?.uid ?? '';
    final String userId = rawUserId.trim().isEmpty ? 'anonymous' : rawUserId;

    bool loadingShown = false;
    showDialog<void>(
      context: context,
      useRootNavigator: true,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const _SubmittingDialog();
      },
    );
    loadingShown = true;

    try {
      final issue = await provider.submitIssue(userId: userId);

      if (!mounted) {
        return;
      }

      final NavigatorState navigator = Navigator.of(
        context,
        rootNavigator: true,
      );
      if (loadingShown && navigator.canPop()) {
        navigator.pop();
        loadingShown = false;
      }

      await Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => IssueSubmittedSuccessScreen(
            issue: issue,
            onBackHome: () {
              provider.resetForm();
              widget.onCompleted?.call();
            },
          ),
        ),
      );
    } on IssueSubmissionFailure catch (error) {
      if (!mounted) {
        return;
      }
      final NavigatorState navigator = Navigator.of(
        context,
        rootNavigator: true,
      );
      if (loadingShown && navigator.canPop()) {
        navigator.pop();
        loadingShown = false;
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: const Color(0xFF1D1D1D),
            content: Text(error.message),
          ),
        );
    } catch (error) {
      if (!mounted) {
        return;
      }
      final NavigatorState navigator = Navigator.of(
        context,
        rootNavigator: true,
      );
      if (loadingShown && navigator.canPop()) {
        navigator.pop();
        loadingShown = false;
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: const Color(0xFF1D1D1D),
            content: Text('Submission failed: $error'),
          ),
        );
    } finally {
      if (mounted && loadingShown) {
        final NavigatorState navigator = Navigator.of(
          context,
          rootNavigator: true,
        );
        if (navigator.canPop()) {
          navigator.pop();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ReportIssueProvider>(
      builder: (BuildContext context, ReportIssueProvider provider, _) {
        final bool isAuthorityStep = provider.currentStep == 2;

        if (provider.currentStep == 3 && !_detailsStepInitialized) {
          _detailsStepInitialized = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) {
              return;
            }
            final ReportIssueProvider freshProvider = context
                .read<ReportIssueProvider>();
            if (freshProvider.description.isNotEmpty ||
                _descriptionController.text.isNotEmpty) {
              _descriptionController.clear();
              freshProvider.updateDescription('');
            }
          });
        }

        if (_descriptionController.text != provider.description) {
          _descriptionController.value = TextEditingValue(
            text: provider.description,
            selection: TextSelection.collapsed(
              offset: provider.description.length,
            ),
          );
        }

        if (provider.currentStep != 5 &&
            _locationController.text != provider.locationInput) {
          _locationController.value = TextEditingValue(
            text: provider.locationInput,
            selection: TextSelection.collapsed(
              offset: provider.locationInput.length,
            ),
          );
        }

        final ThemeData baseTheme = Theme.of(context);
        return Theme(
          data: baseTheme.copyWith(
            textTheme: GoogleFonts.interTextTheme(baseTheme.textTheme),
          ),
          child: Scaffold(
            backgroundColor: isAuthorityStep ? _authBg : _bg,
            appBar: AppBar(
              backgroundColor: isAuthorityStep ? _authBg : _bg,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              scrolledUnderElevation: 0,
              centerTitle: true,
              toolbarHeight: isAuthorityStep ? 72 : 64,
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(1),
                child: Container(
                  height: 1,
                  color: isAuthorityStep ? _authDivider : _dividerSoft,
                ),
              ),
              leading: IconButton(
                onPressed: () async {
                  if (provider.canGoBackStep) {
                    provider.previousStep();
                    return;
                  }

                  final bool popped = await Navigator.of(context).maybePop();
                  if (!popped && context.mounted) {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      AppRoutes.home,
                      (Route<dynamic> route) => false,
                    );
                  }
                },
                icon: Container(
                  width: isAuthorityStep ? 40 : 36,
                  height: isAuthorityStep ? 40 : 36,
                  decoration: BoxDecoration(
                    color: isAuthorityStep
                        ? _authSurface.withValues(alpha: 0.85)
                        : _surfaceSoft,
                    borderRadius: BorderRadius.circular(
                      isAuthorityStep ? 13 : 11,
                    ),
                    border: Border.all(
                      color: isAuthorityStep ? _authBorder : _dividerSoft,
                    ),
                    boxShadow: isAuthorityStep
                        ? <BoxShadow>[
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.35),
                              blurRadius: 14,
                              offset: const Offset(0, 6),
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: isAuthorityStep ? 17 : 16,
                    color: isAuthorityStep
                        ? _authTextPrimary
                        : _textPrimarySoft,
                  ),
                ),
              ),
              title: Text(
                'Issue Reporting',
                style: GoogleFonts.inter(
                  color: isAuthorityStep ? _authTextPrimary : _textPrimarySoft,
                  fontSize: isAuthorityStep ? 22 : 19,
                  fontWeight: FontWeight.w700,
                  letterSpacing: isAuthorityStep ? -0.2 : 0.1,
                ),
              ),
            ),
            body: SafeArea(
              top: false,
              child: DecoratedBox(
                decoration: isAuthorityStep
                    ? const BoxDecoration(
                        gradient: RadialGradient(
                          center: Alignment(0, -0.95),
                          radius: 1.35,
                          colors: <Color>[Color(0x120F1118), _authBg],
                          stops: <double>[0, 1],
                        ),
                      )
                    : const BoxDecoration(),
                child: Column(
                  children: <Widget>[
                    _FlowProgressHeader(
                      currentStep: provider.currentStep,
                      authorityMode: isAuthorityStep,
                    ),
                    const SizedBox(height: 4),
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 18),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 320),
                          switchInCurve: Curves.easeOutCubic,
                          transitionBuilder:
                              (Widget child, Animation<double> animation) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: SlideTransition(
                                    position: Tween<Offset>(
                                      begin: const Offset(0.03, 0),
                                      end: Offset.zero,
                                    ).animate(animation),
                                    child: child,
                                  ),
                                );
                              },
                          child: _StageView(
                            key: ValueKey<int>(provider.currentStep),
                            provider: provider,
                            descriptionController: _descriptionController,
                            locationController: _locationController,
                            reviewConfirmed: _reviewConfirmed,
                            onReviewConfirmationChanged: (bool value) {
                              setState(() {
                                _reviewConfirmed = value;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                    _BottomActionBar(
                      provider: provider,
                      reviewConfirmed: _reviewConfirmed,
                      authorityMode: isAuthorityStep,
                      onSubmit: () => _submit(provider),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _FlowProgressHeader extends StatelessWidget {
  const _FlowProgressHeader({
    required this.currentStep,
    this.authorityMode = false,
  });

  final int currentStep;
  final bool authorityMode;

  static const List<String> _labels = <String>[
    'Welcome',
    'Category',
    'Authority',
    'Details',
    'Evidence',
    'Location',
    'Review',
  ];

  @override
  Widget build(BuildContext context) {
    final int total = _labels.length;
    final int current = currentStep.clamp(0, total - 1);
    final double progress = (current + 1) / total;
    final int percent = (progress * 100).round();

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 6),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: authorityMode
            ? _authSurface.withValues(alpha: 0.9)
            : _surfaceSoft,
        borderRadius: BorderRadius.circular(authorityMode ? 24 : 18),
        border: Border.all(color: authorityMode ? _authBorder : _dividerSoft),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: authorityMode ? 0.34 : 0.24),
            blurRadius: authorityMode ? 30 : 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Step ${current + 1} of $total',
                      style: GoogleFonts.inter(
                        color: authorityMode ? _authHint : _textMuted,
                        fontSize: 12,
                        fontWeight: authorityMode
                            ? FontWeight.w600
                            : FontWeight.w500,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _labels[current],
                      style: GoogleFonts.inter(
                        color: authorityMode
                            ? _authTextPrimary
                            : _textPrimarySoft,
                        fontSize: authorityMode ? 20 : 18,
                        fontWeight: authorityMode
                            ? FontWeight.w700
                            : FontWeight.w500,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                children: <Widget>[
                  _ProgressRing(
                    progress: progress,
                    percent: percent,
                    authorityMode: authorityMode,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Complete',
                    style: GoogleFonts.inter(
                      color: authorityMode ? _authHint : _textMuted,
                      fontSize: 10.5,
                      fontWeight: authorityMode
                          ? FontWeight.w600
                          : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: List<Widget>.generate(total, (int idx) {
                final bool done = idx < current;
                final bool active = idx == current;
                return Row(
                  children: <Widget>[
                    _WorkflowStepItem(
                      index: idx,
                      label: _labels[idx],
                      done: done,
                      active: active,
                    ),
                    if (idx != total - 1)
                      _WorkflowConnector(
                        done: idx < current,
                        active: idx == current,
                      ),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkflowStepItem extends StatelessWidget {
  const _WorkflowStepItem({
    required this.index,
    required this.label,
    required this.done,
    required this.active,
  });

  final int index;
  final String label;
  final bool done;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final Color border = done
        ? _successMuted
        : active
        ? _gold
        : const Color(0xFF47474D);
    final Color textColor = done
        ? const Color(0xFFAAD2B7)
        : active
        ? _gold
        : _textMuted;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        AnimatedContainer(
          duration: const Duration(milliseconds: 230),
          curve: Curves.easeInOut,
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: done
                ? _successMuted
                : active
                ? _gold
                : _surfaceElevated,
            shape: BoxShape.circle,
            border: Border.all(color: border, width: active ? 1.2 : 1),
            boxShadow: active
                ? <BoxShadow>[
                    BoxShadow(
                      color: _gold.withValues(alpha: 0.28),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              child: done
                  ? const Icon(
                      Icons.check_rounded,
                      key: ValueKey<String>('done'),
                      size: 12,
                      color: Colors.black,
                    )
                  : Text(
                      '${index + 1}',
                      key: ValueKey<String>('n-$index-$active'),
                      style: GoogleFonts.inter(
                        color: active ? Colors.white : textColor,
                        fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: GoogleFonts.inter(
            color: textColor,
            fontSize: 9.5,
            fontWeight: active ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _WorkflowConnector extends StatelessWidget {
  const _WorkflowConnector({required this.done, required this.active});

  final bool done;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 18,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: done ? 1 : (active ? 1 : 0)),
        duration: const Duration(milliseconds: 230),
        curve: Curves.easeInOut,
        builder: (BuildContext context, double value, _) {
          final Color color = done
              ? _successMuted
              : active
              ? _gold
              : const Color(0xFF35353A);
          return Stack(
            alignment: Alignment.centerLeft,
            children: <Widget>[
              Container(
                height: 1.5,
                decoration: BoxDecoration(
                  color: const Color(0xFF35353A),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              FractionallySizedBox(
                widthFactor: done || active ? value : 0,
                child: Container(
                  height: 1.5,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ProgressRing extends StatelessWidget {
  const _ProgressRing({
    required this.progress,
    required this.percent,
    this.authorityMode = false,
  });

  final double progress;
  final int percent;
  final bool authorityMode;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: progress),
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
      builder: (BuildContext context, double value, _) {
        return Semantics(
          label: 'Issue report completion',
          value: '$percent percent',
          child: SizedBox(
            width: 56,
            height: 56,
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                SizedBox(
                  width: 56,
                  height: 56,
                  child: CircularProgressIndicator(
                    value: value,
                    strokeWidth: 4,
                    backgroundColor: authorityMode
                        ? const Color(0xFF282B33)
                        : const Color(0xFF2C2C32),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      authorityMode ? _authGold : _gold,
                    ),
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: authorityMode ? _authCard : _surfaceElevated,
                    border: Border.all(
                      color: authorityMode ? _authBorder : _dividerSoft,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$percent%',
                    style: GoogleFonts.inter(
                      color: authorityMode
                          ? _authTextPrimary
                          : _textPrimarySoft,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StageView extends StatelessWidget {
  const _StageView({
    required super.key,
    required this.provider,
    required this.descriptionController,
    required this.locationController,
    required this.reviewConfirmed,
    required this.onReviewConfirmationChanged,
  });

  final ReportIssueProvider provider;
  final TextEditingController descriptionController;
  final TextEditingController locationController;
  final bool reviewConfirmed;
  final ValueChanged<bool> onReviewConfirmationChanged;

  @override
  Widget build(BuildContext context) {
    switch (provider.currentStep) {
      case 0:
        return const _WelcomeStage();
      case 1:
        return _CategoryStage(provider: provider);
      case 2:
        return _TagAuthorityStage(provider: provider);
      case 3:
        return _DetailsStage(
          provider: provider,
          descriptionController: descriptionController,
        );
      case 4:
        return _EvidenceStage(provider: provider);
      case 5:
        return _LocationStage(
          provider: provider,
          locationController: locationController,
        );
      case 6:
        return _ReviewStage(
          provider: provider,
          reviewConfirmed: reviewConfirmed,
          onReviewConfirmationChanged: onReviewConfirmationChanged,
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

class _WelcomeStage extends StatelessWidget {
  const _WelcomeStage();

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeInOut,
      builder: (BuildContext context, double value, Widget? child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 6 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          color: _surfaceSoft,
          border: Border.all(color: _dividerSoft),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.28),
              blurRadius: 28,
              offset: const Offset(0, 14),
            ),
            BoxShadow(
              color: _gold.withValues(alpha: 0.06),
              blurRadius: 30,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[Color(0xFF131A25), Color(0xFF0F141D)],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF2D3340)),
              ),
              child: Stack(
                children: <Widget>[
                  Positioned.fill(
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: RadialGradient(
                            center: const Alignment(-0.5, -0.9),
                            radius: 1.15,
                            colors: <Color>[
                              _gold.withValues(alpha: 0.16),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Hero(
                    tag: 'welcome-reporting-hero',
                    child: Center(
                      child: SvgPicture.string(_welcomeHeroSvg, height: 128),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Welcome to Citizen Issue Reporting',
              style: GoogleFonts.inter(
                color: _textPrimarySoft,
                fontSize: 29,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.35,
                height: 1.16,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Report civic issues with confidence through a secure and transparent official platform.',
              style: GoogleFonts.inter(
                color: _textMuted,
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: _surfaceElevated,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _dividerSoft),
              ),
              child: const Column(
                children: <Widget>[
                  _WelcomeInfoBlock(
                    iconKey: 'quick',
                    title: 'Quick',
                    subtitle:
                        'Submit a structured report in a few guided steps.',
                    showDivider: true,
                  ),
                  _WelcomeInfoBlock(
                    iconKey: 'official',
                    title: 'Official',
                    subtitle:
                        'Each issue is routed to the responsible authority.',
                    showDivider: true,
                  ),
                  _WelcomeInfoBlock(
                    iconKey: 'transparent',
                    title: 'Transparent',
                    subtitle: 'Track progress with clear timeline updates.',
                    showDivider: false,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WelcomeInfoBlock extends StatelessWidget {
  const _WelcomeInfoBlock({
    required this.iconKey,
    required this.title,
    required this.subtitle,
    required this.showDivider,
  });

  final String iconKey;
  final String title;
  final String subtitle;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        border: showDivider
            ? const Border(bottom: BorderSide(color: _dividerSoft))
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _gold.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(9),
              border: Border.all(color: _gold.withValues(alpha: 0.25)),
            ),
            child: SvgPicture.string(
              _welcomeRowIcon(iconKey),
              width: 15,
              height: 15,
              colorFilter: const ColorFilter.mode(_gold, BlendMode.srcIn),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: GoogleFonts.inter(
                    color: _textPrimarySoft,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.08,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    color: _textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _welcomeRowIcon(String key) {
  switch (key) {
    case 'quick':
      return '<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path d="M13 2L5 13h6l-1 9 9-12h-6V2z" fill="currentColor"/></svg>';
    case 'official':
      return '<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path d="M4 10l8-4 8 4M6 10v8M10 10v8M14 10v8M18 10v8M4 19h16" stroke="currentColor" stroke-width="1.8" fill="none" stroke-linecap="round"/></svg>';
    default:
      return '<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path d="M12 20s6-5.2 6-10a6 6 0 1 0-12 0c0 4.8 6 10 6 10z" stroke="currentColor" stroke-width="1.8" fill="none"/><circle cx="12" cy="10" r="2" fill="currentColor"/></svg>';
  }
}

const String _welcomeHeroSvg =
    '<svg viewBox="0 0 520 260" xmlns="http://www.w3.org/2000/svg"><rect x="0" y="0" width="520" height="260" rx="24" fill="#121822"/><rect x="28" y="30" width="210" height="170" rx="16" fill="#1E2736"/><rect x="46" y="48" width="174" height="94" rx="12" fill="#0F151F"/><circle cx="90" cy="96" r="18" fill="#F5B62D"/><rect x="122" y="82" width="72" height="10" rx="5" fill="#8FA0B5"/><rect x="122" y="100" width="56" height="10" rx="5" fill="#6E8198"/><rect x="46" y="156" width="104" height="26" rx="8" fill="#223147"/><path d="M59 169h36" stroke="#F5B62D" stroke-width="5" stroke-linecap="round"/><circle cx="170" cy="169" r="11" fill="#2E7D32"/><path d="M165 169l4 4 8-8" stroke="#C9E8D0" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"/><rect x="270" y="44" width="222" height="34" rx="12" fill="#1A2331"/><circle cx="294" cy="61" r="8" fill="#F5B62D"/><rect x="310" y="56" width="155" height="10" rx="5" fill="#8D9EB2"/><rect x="270" y="94" width="188" height="34" rx="12" fill="#1A2331"/><circle cx="294" cy="111" r="8" fill="#4CAF50"/><rect x="310" y="106" width="120" height="10" rx="5" fill="#8D9EB2"/><rect x="270" y="144" width="212" height="34" rx="12" fill="#1A2331"/><circle cx="294" cy="161" r="8" fill="#7B8798"/><rect x="310" y="156" width="146" height="10" rx="5" fill="#8D9EB2"/><path d="M430 210c18-24 52-24 70 0" stroke="#2B3545" stroke-width="8" stroke-linecap="round"/><path d="M465 192v36" stroke="#F5B62D" stroke-width="6" stroke-linecap="round"/><path d="M448 208h34" stroke="#F5B62D" stroke-width="6" stroke-linecap="round"/></svg>';

class _CategoryStage extends StatelessWidget {
  const _CategoryStage({required this.provider});

  final ReportIssueProvider provider;

  static const Map<String, String> _categoryDescriptions = <String, String>{
    'roads': 'Road damage and potholes.',
    'water': 'Leakage and supply issues.',
    'electricity': 'Power outages and electrical faults.',
    'drainage': 'Blocked drains and sewage overflow.',
    'garbage': 'Waste collection and sanitation.',
    'health': 'Public health concerns.',
    'traffic': 'Signals, congestion and safety.',
    'street_lights': 'Street lighting and visibility problems.',
    'environment': 'Pollution and environment concerns.',
    'public_safety': 'Emergency and public security.',
    'education': 'Schools and education facilities.',
    'real_estate': 'Land and construction complaints.',
    'other': 'General civic concerns.',
  };

  static const Map<String, Color> _categoryAccent = <String, Color>{
    'roads': Color(0xFF5C6F96),
    'water': Color(0xFF4E7D86),
    'electricity': Color(0xFF9C8357),
    'drainage': Color(0xFF4E7A74),
    'garbage': Color(0xFF4F7F6A),
    'health': Color(0xFF9D5D5D),
    'education': Color(0xFF66708E),
    'real_estate': Color(0xFF81694F),
    'traffic': Color(0xFF8F6A4E),
    'street_lights': Color(0xFF9A875A),
    'environment': Color(0xFF557A63),
    'public_safety': Color(0xFF75658B),
    'other': Color(0xFF94A3B8),
  };

  @override
  Widget build(BuildContext context) {
    final bool compact = MediaQuery.of(context).size.width < 380;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const SizedBox(height: 22),
        Text(
          'Select Issue Category',
          style: GoogleFonts.inter(
            color: _textPrimarySoft,
            fontSize: compact ? 32 : 34,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.36,
            height: 1.04,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Choose the category that best matches your issue for faster department routing.',
          style: GoogleFonts.inter(
            color: const Color(0xFF9096A2),
            fontSize: 15.8,
            fontWeight: FontWeight.w500,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 20),
        LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            const int crossAxisCount = 3;
            const double gap = 12;
            final double itemWidth =
                (constraints.maxWidth - (gap * (crossAxisCount - 1))) /
                crossAxisCount;
            final double itemHeight = compact ? 192 : 202;

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: provider.categories.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: gap,
                crossAxisSpacing: gap,
                childAspectRatio: itemWidth / itemHeight,
              ),
              itemBuilder: (BuildContext context, int index) {
                final IssueCategory category = provider.categories[index];
                final bool selected =
                    category.id == provider.selectedCategoryId;
                return _CategoryCard(
                  index: index,
                  category: category,
                  description:
                      _categoryDescriptions[category.id] ??
                      'General civic services issue.',
                  accentColor:
                      _categoryAccent[category.id] ?? const Color(0xFF82868F),
                  selected: selected,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    provider.selectCategory(category.id);
                  },
                );
              },
            );
          },
        ),
        if (provider.categoryError != null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              provider.categoryError!,
              style: GoogleFonts.inter(
                color: _error,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}

class _CategoryCard extends StatefulWidget {
  const _CategoryCard({
    required this.index,
    required this.category,
    required this.description,
    required this.accentColor,
    required this.selected,
    required this.onTap,
  });

  final int index;
  final IssueCategory category;
  final String description;
  final Color accentColor;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<_CategoryCard> {
  bool _pressed = false;
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final int delayIndex = widget.index > 10 ? 10 : widget.index;
    final Duration entryDuration = Duration(
      milliseconds: 260 + (delayIndex * 24),
    );
    final bool selected = widget.selected;

    final bool hovered = _hovered && !selected;
    final Color iconBg = selected
        ? const Color(0xFF2A2620)
        : const Color(0xFF22242B).withValues(alpha: 0.94);
    final Color iconOverlay = selected
        ? _gold.withValues(alpha: 0.08)
        : widget.accentColor.withValues(alpha: 0.06);
    final Color iconBorder = selected
        ? _gold.withValues(alpha: 0.46)
        : widget.accentColor.withValues(alpha: 0.2);

    return Semantics(
      button: true,
      selected: selected,
      label:
          '${widget.category.semanticLabel}. ${selected ? 'Selected' : 'Not selected'}',
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: 1),
        duration: entryDuration,
        curve: Curves.easeOutCubic,
        builder: (BuildContext context, double value, Widget? child) {
          return Opacity(
            opacity: value,
            child: Transform.translate(
              offset: Offset(0, (1 - value) * 10),
              child: child,
            ),
          );
        },
        child: AnimatedScale(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          scale: hovered ? 1.02 : (_pressed ? 0.985 : 1),
          child: MouseRegion(
            onEnter: (_) {
              if (!_hovered) {
                setState(() {
                  _hovered = true;
                });
              }
            },
            onExit: (_) {
              if (_hovered) {
                setState(() {
                  _hovered = false;
                });
              }
            },
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(22),
                splashColor: _gold.withValues(alpha: 0.1),
                highlightColor: _gold.withValues(alpha: 0.06),
                onHighlightChanged: (bool value) {
                  if (_pressed == value) {
                    return;
                  }
                  setState(() {
                    _pressed = value;
                  });
                },
                onTap: widget.onTap,
                child: Ink(
                  padding: const EdgeInsets.fromLTRB(10, 12, 10, 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    color: hovered
                        ? const Color(0xFF191B22)
                        : const Color(0xFF16171D),
                    border: Border.all(
                      color: selected
                          ? const Color(0xFFE0B44D)
                          : Colors.white.withValues(alpha: 0.05),
                      width: selected ? 2 : 1,
                    ),
                    boxShadow: selected
                        ? <BoxShadow>[
                            BoxShadow(
                              color: const Color(
                                0xFFE0B44D,
                              ).withValues(alpha: 0.12),
                              blurRadius: 14,
                              offset: const Offset(0, 5),
                            ),
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 9,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : <BoxShadow>[
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.16),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                  ),
                  child: Stack(
                    children: <Widget>[
                      if (selected)
                        Positioned.fill(
                          child: IgnorePointer(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(22),
                                color: _gold.withValues(alpha: 0.06),
                              ),
                            ),
                          ),
                        ),
                      Positioned(
                        top: 2,
                        right: 2,
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 250),
                          opacity: selected ? 1 : 0,
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE0B44D),
                              shape: BoxShape.circle,
                              boxShadow: <BoxShadow>[
                                BoxShadow(
                                  color: const Color(
                                    0xFFE0B44D,
                                  ).withValues(alpha: 0.18),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.verified_rounded,
                              size: 10,
                              color: Color(0xFF221A08),
                            ),
                          ),
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          TweenAnimationBuilder<double>(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeInOut,
                            tween: Tween<double>(
                              begin: 1,
                              end: selected ? 1.06 : 1,
                            ),
                            builder:
                                (
                                  BuildContext context,
                                  double value,
                                  Widget? child,
                                ) {
                                  return Transform.scale(
                                    scale: value,
                                    child: child,
                                  );
                                },
                            child: Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                color: iconBg,
                                border: Border.all(color: iconBorder, width: 1),
                                boxShadow: <BoxShadow>[
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.12),
                                    blurRadius: 5,
                                    offset: const Offset(0, 2),
                                  ),
                                  BoxShadow(
                                    color: iconOverlay,
                                    blurStyle: BlurStyle.inner,
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: SvgPicture.asset(
                                widget.category.iconAssetPath,
                                width: 24,
                                height: 24,
                                colorFilter: ColorFilter.mode(
                                  selected
                                      ? _gold.withValues(alpha: 0.9)
                                      : widget.accentColor.withValues(
                                          alpha: 0.92,
                                        ),
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            widget.category.title,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              color: _textPrimarySoft,
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              height: 1.15,
                            ),
                          ),
                          const SizedBox(height: 7),
                          Text(
                            widget.description,
                            textAlign: TextAlign.center,
                            maxLines: 3,
                            overflow: TextOverflow.clip,
                            softWrap: true,
                            style: GoogleFonts.inter(
                              color: const Color(0xFFC5CBD5),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TagAuthorityStage extends StatefulWidget {
  const _TagAuthorityStage({required this.provider});

  final ReportIssueProvider provider;

  @override
  State<_TagAuthorityStage> createState() => _TagAuthorityStageState();
}

class _TagAuthorityStageState extends State<_TagAuthorityStage> {
  late final FocusNode _searchFocusNode;
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchFocusNode = FocusNode()..addListener(_onFocusChanged);
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode
      ..removeListener(_onFocusChanged)
      ..dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final ReportIssueProvider provider = widget.provider;

    if (!_searchFocusNode.hasFocus &&
        _searchController.text != provider.authoritySearchQuery) {
      _searchController.value = TextEditingValue(
        text: provider.authoritySearchQuery,
        selection: TextSelection.collapsed(
          offset: provider.authoritySearchQuery.length,
        ),
      );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) {
        return;
      }
      provider.loadAuthoritiesIfNeeded();
    });

    final String query = provider.authoritySearchQuery.trim();
    final List<AuthorityProfile> recommendedAuthorities = provider
        .recommendedAuthorities
        .where(
          (AuthorityProfile authority) =>
              query.isEmpty || authority.matchesQuery(query),
        )
        .toList(growable: false);

    final List<AuthorityProfile> fallbackAuthorities = <AuthorityProfile>[];
    final Set<String> seen = <String>{};
    for (final AuthorityProfile authority
        in provider.filteredGovernmentAuthorities) {
      if (seen.add(authority.id)) {
        fallbackAuthorities.add(authority);
      }
    }
    for (final AuthorityProfile authority
        in provider.filteredPublicRepresentatives) {
      if (seen.add(authority.id)) {
        fallbackAuthorities.add(authority);
      }
    }

    final List<AuthorityProfile> roleMustInclude = provider
        .filteredPublicRepresentatives
        .where((AuthorityProfile authority) {
          final String bag = '${authority.name} ${authority.designation}'
              .toLowerCase();
          return bag.contains('hemachandra') ||
              bag.contains('mla') ||
              bag.contains('mlc') ||
              bag.contains('member of parliament') ||
              RegExp(r'(^|\W)mp(\W|$)').hasMatch(bag) ||
              bag.contains('sarpanch') ||
              bag.contains('councillor') ||
              bag.contains('councilor');
        })
        .toList(growable: false);

    final List<AuthorityProfile> relevantAuthorities =
        recommendedAuthorities.isNotEmpty
        ? <AuthorityProfile>[...recommendedAuthorities]
        : <AuthorityProfile>[...fallbackAuthorities];

    final Set<String> relevantIds = relevantAuthorities
        .map((AuthorityProfile item) => item.id)
        .toSet();
    for (final AuthorityProfile authority in roleMustInclude) {
      if (relevantIds.add(authority.id)) {
        relevantAuthorities.add(authority);
      }
    }

    relevantAuthorities.sort((AuthorityProfile a, AuthorityProfile b) {
      final int rankA = _authorityPriorityOrder(a);
      final int rankB = _authorityPriorityOrder(b);
      if (rankA != rankB) {
        return rankA.compareTo(rankB);
      }
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });

    final bool focused = _searchFocusNode.hasFocus;
    final bool noResults = relevantAuthorities.isEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(2, 2, 4, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Select Your Representative',
                style: GoogleFonts.inter(
                  color: _authTextPrimary,
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  height: 1.04,
                  letterSpacing: -0.35,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Choose the elected representative responsible for resolving your issue based on your location.',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  color: _authTextSecondary,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: focused ? const Color(0xFF1B1D24) : const Color(0xFF181A20),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: focused ? _authGold : Colors.white.withValues(alpha: 0.06),
              width: 0.9,
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.17),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Semantics(
            label: 'Search authorities',
            textField: true,
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              onChanged: provider.updateAuthoritySearch,
              textInputAction: TextInputAction.search,
              cursorColor: _authGold,
              style: GoogleFonts.inter(
                color: _authTextPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: 'Search Representative...',
                hintStyle: GoogleFonts.inter(
                  color: const Color(0xFF8A919C),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 13),
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(right: 7),
                  child: Icon(Icons.search_rounded, size: 22, color: _authGold),
                ),
                prefixIconConstraints: const BoxConstraints(
                  minWidth: 28,
                  minHeight: 32,
                ),
                suffixIcon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeOutCubic,
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                  child: _searchController.text.isNotEmpty
                      ? Padding(
                          key: const ValueKey<String>('clear-search'),
                          padding: const EdgeInsets.only(left: 6),
                          child: IconButton(
                            tooltip: 'Clear search',
                            onPressed: () {
                              _searchController.clear();
                              provider.updateAuthoritySearch('');
                              setState(() {});
                            },
                            splashRadius: 16,
                            icon: Icon(
                              Icons.close_rounded,
                              size: 16,
                              color: _authHint,
                            ),
                          ),
                        )
                      : const SizedBox(key: ValueKey<String>('no-clear')),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (provider.isLoadingAuthorities)
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: CircularProgressIndicator(color: _authGold),
            ),
          )
        else if (noResults)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
            decoration: BoxDecoration(
              color: _authCard,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _authBorder),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.28),
                  blurRadius: 20,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            child: Column(
              children: <Widget>[
                Icon(Icons.account_tree_outlined, size: 30, color: _authHint),
                const SizedBox(height: 10),
                Text(
                  'No Representatives Found',
                  style: GoogleFonts.inter(
                    color: _authTextPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Try searching another constituency.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    color: _authTextSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: provider.loadAuthoritiesIfNeeded,
                  icon: Icon(Icons.refresh_rounded, size: 16, color: _authGold),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: _authBorder),
                    foregroundColor: _authTextPrimary,
                    backgroundColor: _authSurface.withValues(alpha: 0.9),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  label: Text(
                    'Retry',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontSize: 12.5,
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          _AuthorityCardGrid(items: relevantAuthorities, provider: provider),
      ],
    );
  }
}

class _AuthorityCardGrid extends StatelessWidget {
  const _AuthorityCardGrid({required this.items, required this.provider});

  final List<AuthorityProfile> items;
  final ReportIssueProvider provider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List<Widget>.generate(items.length, (int index) {
        final AuthorityProfile authority = items[index];
        return TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: 1),
          duration: Duration(milliseconds: 220 + (index * 25)),
          curve: Curves.easeOutCubic,
          builder: (BuildContext context, double value, Widget? child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, (1 - value) * 12),
                child: Transform.scale(
                  scale: 0.985 + (0.015 * value),
                  child: child,
                ),
              ),
            );
          },
          child: _AuthorityCard(
            authority: authority,
            selected: provider.isAuthoritySelected(authority.id),
            onToggle: () => provider.toggleAuthority(authority),
            onOpenProfile: () {
              showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (BuildContext context) {
                  return _AuthorityProfileSheet(
                    authority: authority,
                    isSelected: provider.isAuthoritySelected(authority.id),
                    onToggle: () {
                      provider.toggleAuthority(authority);
                      Navigator.of(context).pop();
                    },
                  );
                },
              );
            },
          ),
        );
      }),
    );
  }
}

enum _RoleType { mla, mlc, mp, councillor, sarpanch, other }

_RoleType _roleTypeForDesignation(String designation) {
  final String d = designation.toLowerCase();
  if (d.contains('mla')) {
    return _RoleType.mla;
  }
  if (d.contains('mlc')) {
    return _RoleType.mlc;
  }
  if (d.contains('member of parliament') ||
      RegExp(r'(^|\W)mp(\W|$)').hasMatch(d)) {
    return _RoleType.mp;
  }
  if (d.contains('councillor') ||
      d.contains('councilor') ||
      d.contains('corporator')) {
    return _RoleType.councillor;
  }
  if (d.contains('sarpanch')) {
    return _RoleType.sarpanch;
  }
  return _RoleType.other;
}

Color _roleChipTint(_RoleType role) {
  switch (role) {
    case _RoleType.mla:
      return const Color(0xFF6D81A2);
    case _RoleType.mlc:
      return const Color(0xFF7A74A4);
    case _RoleType.mp:
      return const Color(0xFF8D7A58);
    case _RoleType.councillor:
      return const Color(0xFF6D9276);
    case _RoleType.sarpanch:
      return const Color(0xFF8E7F5D);
    case _RoleType.other:
      return const Color(0xFF82868F);
  }
}

String _initialsFromName(String fullName) {
  final List<String> parts = fullName
      .trim()
      .split(RegExp(r'\s+'))
      .where((String p) => p.isNotEmpty)
      .toList(growable: false);
  if (parts.isEmpty) {
    return 'A';
  }
  if (parts.length == 1) {
    return parts.first.characters.take(2).toString().toUpperCase();
  }
  return (parts.first[0] + parts.last[0]).toUpperCase();
}

String _roleAbbreviation(_RoleType roleType) {
  switch (roleType) {
    case _RoleType.mla:
      return 'MLA';
    case _RoleType.mlc:
      return 'MLC';
    case _RoleType.mp:
      return 'MP';
    case _RoleType.councillor:
      return 'Councillor';
    case _RoleType.sarpanch:
      return 'Sarpanch';
    case _RoleType.other:
      return 'Authority';
  }
}

String _roleFullTitle(_RoleType roleType, String designation) {
  switch (roleType) {
    case _RoleType.mla:
      return 'Member of Legislative Assembly';
    case _RoleType.mlc:
      return 'Member of Legislative Council';
    case _RoleType.mp:
      return 'Member of Parliament';
    case _RoleType.councillor:
      return 'Councillor';
    case _RoleType.sarpanch:
      return 'Sarpanch';
    case _RoleType.other:
      return designation.trim().isEmpty ? 'Public Authority' : designation;
  }
}

bool _showAuthorityVerifiedTick(AuthorityProfile authority) {
  if (!authority.isVerified) {
    return false;
  }
  final int marker = authority.id.codeUnits.fold(
    0,
    (int acc, int char) => acc + char,
  );
  // Demo rule: keep verification hidden for a subset of authorities.
  return marker % 3 != 0;
}

class _AuthorityAvatar extends StatelessWidget {
  const _AuthorityAvatar({required this.authority, required this.selected});

  final AuthorityProfile authority;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final String? photoUrl = authority.profilePhotoUrl;
    final bool hasPhoto = photoUrl != null && photoUrl.trim().isNotEmpty;

    return Container(
      width: 72,
      height: 72,
      padding: const EdgeInsets.all(2.5),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF11141B),
        border: Border.all(
          color: _authGold.withValues(alpha: selected ? 0.7 : 0.42),
          width: 1,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.24),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(1.5),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.06),
            width: 1,
          ),
        ),
        child: ClipOval(
          child: hasPhoto
              ? Image.network(
                  photoUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, Object error, StackTrace? stackTrace) =>
                      _InitialsAvatar(name: authority.name),
                )
              : _InitialsAvatar(name: authority.name),
        ),
      ),
    );
  }
}

class _InitialsAvatar extends StatelessWidget {
  const _InitialsAvatar({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF232732),
      alignment: Alignment.center,
      child: Text(
        _initialsFromName(name),
        style: GoogleFonts.inter(
          color: _authTextPrimary,
          fontSize: 19,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _RoleChip extends StatelessWidget {
  const _RoleChip({required this.label, required this.tint});

  final String label;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _authGold.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          color: _authGoldDeep,
          fontSize: 10.4,
          fontWeight: FontWeight.w600,
          height: 1,
        ),
      ),
    );
  }
}

class _AuthorityCard extends StatelessWidget {
  const _AuthorityCard({
    required this.authority,
    required this.selected,
    required this.onToggle,
    required this.onOpenProfile,
  });

  final AuthorityProfile authority;
  final bool selected;
  final VoidCallback onToggle;
  final VoidCallback onOpenProfile;

  @override
  Widget build(BuildContext context) {
    final _RoleType roleType = _roleTypeForDesignation(authority.designation);
    final Color roleTint = _roleChipTint(roleType);
    final String roleShortLabel = _roleAbbreviation(roleType);
    final String constituency = _constituencyDisplayValue(authority);
    final String resolved = authority.resolutionRate == null
        ? '98%'
        : '${_normalizedResolutionRate(authority.resolutionRate)!.round()}%';
    final String avgDays = authority.avgResolutionDays > 0
        ? '${authority.avgResolutionDays.toStringAsFixed(1)} Avg. Days'
        : '2.7 Avg. Days';
    final String rating = authority.citizenRating > 0
        ? '${authority.citizenRating.toStringAsFixed(1)} Rating'
        : '4.6 Rating';

    return Semantics(
      button: true,
      selected: selected,
      label: '${authority.name}, ${authority.designation}, $constituency',
      child: _HoverScaleCard(
        selected: selected,
        onTap: onToggle,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.only(bottom: 10),
          constraints: const BoxConstraints(minHeight: 86),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF181A20),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: selected ? _authGold : _authBorder,
              width: selected ? 2 : 1,
            ),
            boxShadow: selected
                ? <BoxShadow>[
                    BoxShadow(
                      color: _authGold.withValues(alpha: 0.1),
                      blurRadius: 14,
                      spreadRadius: 0.08,
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.22),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : <BoxShadow>[
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 16,
                      offset: const Offset(0, 7),
                    ),
                  ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  _AuthorityAvatar(authority: authority, selected: selected),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Flexible(
                              child: Text(
                                authority.name,
                                maxLines: 2,
                                softWrap: true,
                                style: GoogleFonts.inter(
                                  color: _authTextPrimary,
                                  fontSize: 16.5,
                                  fontWeight: FontWeight.w700,
                                  height: 1.1,
                                ),
                              ),
                            ),
                            if (_showAuthorityVerifiedTick(authority))
                              Padding(
                                padding: const EdgeInsets.only(left: 6),
                                child: const _IssueTickIcon(size: 13),
                              ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: <Widget>[
                            _RoleChip(label: roleShortLabel, tint: roleTint),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                '\u2022 $constituency Constituency',
                                maxLines: 2,
                                softWrap: true,
                                style: GoogleFonts.inter(
                                  color: _authTextSecondary,
                                  fontSize: 11.8,
                                  fontWeight: FontWeight.w500,
                                  height: 1.1,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: _AuthorityStatChip(
                                icon: Icons.grade_rounded,
                                label: rating,
                                tint: const Color(0x17F4B400),
                              ),
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: _AuthorityStatChip(
                                icon: Icons.task_alt_rounded,
                                label: '$resolved Solved',
                                tint: const Color(0x1734C759),
                                dotColor: const Color(0xFF34C759),
                              ),
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: _AuthorityStatChip(
                                icon: Icons.hourglass_top_rounded,
                                label: avgDays,
                                tint: const Color(0x174A90E2),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: onOpenProfile,
                    behavior: HitTestBehavior.opaque,
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Icon(
                          Icons.arrow_forward_rounded,
                          size: 18,
                          color: _authTextSecondary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AuthorityStatChip extends StatelessWidget {
  const _AuthorityStatChip({
    required this.icon,
    required this.label,
    required this.tint,
    this.dotColor,
  });

  final IconData icon;
  final String label;
  final Color tint;
  final Color? dotColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 13),
      decoration: BoxDecoration(
        color: tint,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Icon(icon, size: 13.5, color: _authTextSecondary),
          const SizedBox(width: 5),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                label,
                style: GoogleFonts.inter(
                  color: _authTextPrimary,
                  fontSize: 12.2,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          if (dotColor != null) ...<Widget>[
            const SizedBox(width: 5),
            Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _HoverScaleCard extends StatefulWidget {
  const _HoverScaleCard({
    required this.child,
    required this.onTap,
    required this.selected,
  });

  final Widget child;
  final VoidCallback onTap;
  final bool selected;

  @override
  State<_HoverScaleCard> createState() => _HoverScaleCardState();
}

class _HoverScaleCardState extends State<_HoverScaleCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final double scale = _hovered ? 1.01 : 1.0;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        scale: scale,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          transform: Matrix4.translationValues(0, _hovered ? -1 : 0, 0),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                HapticFeedback.selectionClick();
                widget.onTap();
              },
              splashColor: _gold.withValues(alpha: 0.16),
              highlightColor: _gold.withValues(alpha: 0.08),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthorityProfileSheet extends StatelessWidget {
  const _AuthorityProfileSheet({
    required this.authority,
    required this.isSelected,
    required this.onToggle,
  });

  final AuthorityProfile authority;
  final bool isSelected;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final _RoleType roleType = _roleTypeForDesignation(authority.designation);
    final Color roleTint = _roleChipTint(roleType);
    final String roleShortLabel = _roleAbbreviation(roleType);
    final String roleSubtitle = _roleFullTitle(roleType, authority.designation);
    final String constituency = _constituencyDisplayValue(authority);
    final String solved = authority.resolutionRate == null
        ? '98%'
        : '${_normalizedResolutionRate(authority.resolutionRate)!.round()}%';

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
      decoration: BoxDecoration(
        color: _authSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(top: BorderSide(color: _authBorder)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 42,
            height: 4,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: _authDivider,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _AuthorityAvatar(authority: authority, selected: isSelected),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            authority.name,
                            maxLines: 2,
                            overflow: TextOverflow.fade,
                            softWrap: true,
                            style: GoogleFonts.inter(
                              color: _authTextPrimary,
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              height: 1.12,
                            ),
                          ),
                        ),
                        if (_showAuthorityVerifiedTick(authority))
                          Tooltip(
                            message: 'Verified Government Representative',
                            child: const _IssueTickIcon(
                              size: 18,
                              color: _successMuted,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 7),
                    _RoleChip(label: roleShortLabel, tint: roleTint),
                    const SizedBox(height: 6),
                    Text(
                      roleSubtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        color: _authTextSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '📍 $constituency Constituency',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        color: _authTextSecondary,
                        fontSize: 13.4,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(height: 1, color: _authDivider),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              _ProfileMetricCard(
                icon: Icons.task_alt_rounded,
                title: 'Issues Solved',
                value: solved,
              ),
              _ProfileMetricCard(
                icon: Icons.hourglass_top_rounded,
                title: 'Average Resolution',
                value: authority.avgResolutionDays > 0
                    ? '${authority.avgResolutionDays.toStringAsFixed(1)} Avg. Days'
                    : '2.7 Avg. Days',
              ),
              _ProfileMetricCard(
                icon: Icons.grade_rounded,
                title: 'Citizen Rating',
                value: authority.citizenRating > 0
                    ? '${authority.citizenRating.toStringAsFixed(1)} Rating'
                    : '4.6 Rating',
              ),
              _ProfileMetricCard(
                icon: Icons.folder_copy_rounded,
                title: 'Cases Resolved',
                value: '${authority.resolvedComplaints}',
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Dedicated public representative with an excellent record of resolving citizen grievances efficiently.',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              color: _authHint,
              fontSize: 13,
              fontWeight: FontWeight.w500,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: <Widget>[
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onToggle,
                  icon: Icon(
                    isSelected
                        ? Icons.remove_circle_outline_rounded
                        : Icons.add_circle_outline_rounded,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _authGold,
                    foregroundColor: Colors.black,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  label: Text(isSelected ? 'Remove Tag' : 'Tag Authority'),
                ),
              ),
            ],
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}

class _ProfileMetricCard extends StatelessWidget {
  const _ProfileMetricCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 132),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: _authCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _authBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 14, color: _authHint),
          const SizedBox(width: 7),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                title,
                style: GoogleFonts.inter(
                  color: _authHint,
                  fontSize: 11.2,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.inter(
                  color: _authTextPrimary,
                  fontSize: 13.8,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DetailsStage extends StatefulWidget {
  const _DetailsStage({
    required this.provider,
    required this.descriptionController,
  });

  final ReportIssueProvider provider;
  final TextEditingController descriptionController;

  @override
  State<_DetailsStage> createState() => _DetailsStageState();
}

class _DetailsStageState extends State<_DetailsStage> {
  static const int _maxLength = 500;
  late final FocusNode _descriptionFocusNode;
  bool _voicePulse = false;

  ReportIssueProvider get _provider => widget.provider;
  TextEditingController get _controller => widget.descriptionController;

  @override
  void initState() {
    super.initState();
    _descriptionFocusNode = FocusNode()..addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _descriptionFocusNode
      ..removeListener(_onFocusChanged)
      ..dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _startVoiceInput() async {
    setState(() {
      _voicePulse = true;
    });
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (mounted) {
      setState(() {
        _voicePulse = false;
      });
    }
    if (!mounted) {
      return;
    }
    FocusScope.of(context).requestFocus(FocusNode());
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text(
            'Use keyboard voice dictation to capture speech input.',
          ),
        ),
      );
  }

  Future<void> _openAiAssistSheet() async {
    if (_provider.isGeneratingSuggestion) {
      return;
    }
    await _provider.generateDescriptionSuggestion();
  }

  @override
  Widget build(BuildContext context) {
    final bool hasError = _provider.descriptionError != null;
    final bool focused = _descriptionFocusNode.hasFocus;
    final int length = _provider.descriptionLength;
    final Color counterColor = length >= (_maxLength - 75)
        ? _gold
        : const Color(0xFFA0A0A0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Describe Your Issue',
          style: GoogleFonts.inter(
            color: _textPrimary,
            fontSize: 29,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
            height: 1.12,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          'Provide a clear description so the concerned authority can review and resolve your issue efficiently.',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.inter(
            color: const Color(0xFF9BA2AD),
            fontSize: 15,
            fontWeight: FontWeight.w500,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 10),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          decoration: BoxDecoration(
            color: const Color(0xFF1B1E25),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: hasError
                  ? _error
                  : (focused
                        ? const Color(0xFFF5B82E)
                        : Colors.white.withValues(alpha: 0.05)),
              width: focused ? 1.15 : 1,
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.white.withValues(alpha: focused ? 0.03 : 0),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: focused ? 0.22 : 0.16),
                blurRadius: focused ? 18 : 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Align(
                alignment: Alignment.centerRight,
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 240),
                  curve: Curves.easeOutCubic,
                  style: GoogleFonts.inter(
                    color: counterColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                  child: Text('$length / $_maxLength'),
                ),
              ),
              const SizedBox(height: 8),
              AnimatedOpacity(
                duration: const Duration(milliseconds: 220),
                opacity: focused ? 1 : 0,
                child: Container(
                  height: 1,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
              const SizedBox(height: 8),
              Semantics(
                label: 'Issue description input',
                textField: true,
                child: TextField(
                  controller: _controller,
                  focusNode: _descriptionFocusNode,
                  onChanged: (String value) {
                    _provider.updateDescription(value);
                    if (mounted) {
                      setState(() {});
                    }
                  },
                  maxLength: _maxLength,
                  minLines: 4,
                  maxLines: null,
                  cursorColor: _gold,
                  style: GoogleFonts.inter(
                    color: _textPrimary,
                    fontSize: 15,
                    height: 1.45,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText:
                        'Example: Streetlight not functioning near City Hospital entrance for the past 3 days.',
                    hintStyle: GoogleFonts.inter(
                      color: const Color(0xFF9FA5B0),
                      fontSize: 16,
                      height: 1.4,
                      fontWeight: FontWeight.w500,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                    counterText: '',
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          child: hasError
              ? Padding(
                  padding: const EdgeInsets.only(top: 7, left: 4),
                  child: Text(
                    _provider.descriptionError!,
                    style: GoogleFonts.inter(
                      color: _error,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              : const SizedBox(height: 0),
        ),
        const SizedBox(height: 8),
        Row(
          children: <Widget>[
            Expanded(
              child: _DetailActionPill(
                icon: Icons.mic_rounded,
                label: 'Voice Input',
                pulse: _voicePulse,
                onTap: _startVoiceInput,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _DetailActionPill(
                icon: Icons.auto_awesome_rounded,
                label: _provider.isGeneratingSuggestion
                    ? 'Generating...'
                    : 'Improve with AI',
                loading: _provider.isGeneratingSuggestion,
                onTap: _provider.isGeneratingSuggestion
                    ? null
                    : _openAiAssistSheet,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          decoration: BoxDecoration(
            color: const Color(0xFF151921),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Icon(Icons.lightbulb_outline_rounded, color: _gold, size: 16),
                  SizedBox(width: 8),
                  Text(
                    'Tips for a Better Report',
                    style: TextStyle(
                      color: _textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4),
              Text(
                'Write a clear and complete issue description for faster resolution.',
                style: TextStyle(
                  color: Color(0xFF9BA2AD),
                  fontSize: 11.8,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 10),
              _TipsBullet(
                text: 'What happened',
                color: Color(0xFF55B071),
                icon: Icons.task_alt_rounded,
              ),
              _TipsBullet(
                text: 'Where did it happen',
                color: Color(0xFF4A8FD8),
                icon: Icons.place_rounded,
              ),
              _TipsBullet(
                text: 'When did it start',
                color: Color(0xFFE0A93E),
                icon: Icons.schedule_rounded,
              ),
              _TipsBullet(
                text: 'Public impact',
                color: Color(0xFF8F79D8),
                icon: Icons.groups_rounded,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DetailActionPill extends StatelessWidget {
  const _DetailActionPill({
    required this.icon,
    required this.label,
    this.loading = false,
    this.pulse = false,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final bool loading;
  final bool pulse;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bool isAi =
        label.contains('Improve with AI') || label.contains('Generating');

    return AnimatedScale(
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOutCubic,
      scale: pulse ? 1.03 : 1,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Ink(
            height: 58,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF181A20),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: pulse || loading
                    ? _gold.withValues(alpha: 0.7)
                    : Colors.white.withValues(alpha: 0.06),
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: pulse ? 16 : 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                if (loading)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: _gold,
                    ),
                  )
                else if (isAi)
                  ShaderMask(
                    shaderCallback: (Rect bounds) {
                      return const LinearGradient(
                        colors: <Color>[Color(0xFFC6B8FF), Color(0xFFF4B400)],
                      ).createShader(bounds);
                    },
                    child: Icon(icon, size: 18, color: Colors.white),
                  )
                else
                  Icon(icon, size: 18, color: _gold),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      color: _textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TipsBullet extends StatelessWidget {
  const _TipsBullet({
    required this.text,
    required this.color,
    required this.icon,
  });

  final String text;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Icon(icon, size: 13, color: color),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                color: _textPrimary,
                fontSize: 12.4,
                height: 1.3,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EvidenceStage extends StatelessWidget {
  const _EvidenceStage({required this.provider});

  final ReportIssueProvider provider;

  @override
  Widget build(BuildContext context) {
    final List<PickedMedia> mediaItems = provider.mediaItems;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Evidence',
          style: GoogleFonts.inter(
            color: _textPrimary,
            fontSize: 30,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
            height: 1.12,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Upload photos or videos that clearly show the reported issue.',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.inter(
            color: const Color(0xFF9BA2AD),
            fontSize: 15,
            fontWeight: FontWeight.w500,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: <Widget>[
            Expanded(
              child: _UploadMethodCard(
                title: 'Camera',
                icon: Icons.camera_alt_rounded,
                iconColor: _authGold,
                onTap: provider.isPickingMedia ? null : provider.addFromCamera,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _UploadMethodCard(
                title: 'Gallery',
                icon: Icons.collections_rounded,
                iconColor: const Color(0xFF4A8FD8),
                onTap: provider.isPickingMedia
                    ? null
                    : provider.addFromGalleryImages,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _UploadMethodCard(
                title: 'Video',
                icon: Icons.movie_creation_rounded,
                iconColor: const Color(0xFF8F79D8),
                onTap: provider.isPickingMedia
                    ? null
                    : provider.addFromGalleryVideo,
              ),
            ),
          ],
        ),
        if (provider.isPickingMedia)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              decoration: BoxDecoration(
                color: const Color(0xFF171B22),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.18),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        'Uploading media...',
                        style: TextStyle(
                          color: _textPrimary,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      _UploadStatusChip(
                        label: 'Uploading',
                        icon: Icons.hourglass_top_rounded,
                        color: _gold,
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  _PremiumUploadProgress(),
                ],
              ),
            ),
          ),
        if (provider.mediaError != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              decoration: BoxDecoration(
                color: const Color(0xFF181818),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _error.withValues(alpha: 0.65)),
              ),
              child: Text(
                provider.mediaError!,
                style: const TextStyle(
                  color: _error,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        if (provider.mediaWarning != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              decoration: BoxDecoration(
                color: const Color(0xFF181818),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _warning.withValues(alpha: 0.65)),
              ),
              child: Text(
                provider.mediaWarning!,
                style: const TextStyle(
                  color: _warning,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
          decoration: BoxDecoration(
            color: const Color(0xFF161A21),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Evidence',
                style: GoogleFonts.inter(
                  color: _textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: mediaItems.isEmpty
                    ? const _EvidenceEmptyState(
                        key: ValueKey<String>('empty-evidence'),
                      )
                    : LayoutBuilder(
                        key: const ValueKey<String>('media-grid'),
                        builder:
                            (BuildContext context, BoxConstraints constraints) {
                              final int columns = constraints.maxWidth >= 760
                                  ? 3
                                  : (constraints.maxWidth >= 420 ? 2 : 1);

                              return GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: mediaItems.length,
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: columns,
                                      crossAxisSpacing: 10,
                                      mainAxisSpacing: 10,
                                      childAspectRatio: columns == 1
                                          ? 1.35
                                          : 1.02,
                                    ),
                                itemBuilder: (BuildContext context, int idx) {
                                  final PickedMedia item = mediaItems[idx];
                                  return _MediaPreviewTile(
                                    key: ValueKey<String>(
                                      'media-$idx-${item.file.path}',
                                    ),
                                    item: item,
                                    onDelete: () => provider.removeMediaAt(idx),
                                  );
                                },
                              );
                            },
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _UploadMethodCard extends StatefulWidget {
  const _UploadMethodCard({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final Color iconColor;
  final VoidCallback? onTap;

  @override
  State<_UploadMethodCard> createState() => _UploadMethodCardState();
}

class _UploadMethodCardState extends State<_UploadMethodCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final bool enabled = widget.onTap != null;

    return AnimatedScale(
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOutCubic,
      scale: _pressed ? 0.985 : 1,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: widget.onTap,
          onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
          onTapCancel: enabled ? () => setState(() => _pressed = false) : null,
          onTapUp: enabled ? (_) => setState(() => _pressed = false) : null,
          child: Ink(
            height: 106,
            padding: const EdgeInsets.fromLTRB(10, 12, 10, 12),
            decoration: BoxDecoration(
              color: const Color(0xFF181A20),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: _pressed
                    ? _authGold
                    : Colors.white.withValues(alpha: enabled ? 0.05 : 0.03),
                width: _pressed ? 1.4 : 1,
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withValues(alpha: _pressed ? 0.24 : 0.18),
                  blurRadius: _pressed ? 16 : 12,
                  offset: const Offset(0, 5),
                ),
                if (_pressed)
                  BoxShadow(
                    color: _authGold.withValues(alpha: 0.14),
                    blurRadius: 14,
                    offset: const Offset(0, 2),
                  ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(widget.icon, size: 30, color: widget.iconColor),
                const SizedBox(height: 10),
                Text(
                  widget.title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    color: _textPrimary,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EvidenceEmptyState extends StatelessWidget {
  const _EvidenceEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 14),
      decoration: BoxDecoration(
        color: const Color(0xFF171B22),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: <Widget>[
          Icon(
            Icons.collections_outlined,
            size: 28,
            color: _authTextSecondary.withValues(alpha: 0.9),
          ),
          const SizedBox(height: 8),
          Text(
            'No media uploaded yet',
            style: GoogleFonts.inter(
              color: _textPrimary,
              fontSize: 12.8,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Add clear photos or a short video for faster resolution.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: _authTextSecondary,
              fontSize: 11.6,
              height: 1.35,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _PremiumUploadProgress extends StatelessWidget {
  const _PremiumUploadProgress();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: const LinearProgressIndicator(
        minHeight: 5,
        backgroundColor: Color(0xFF242A35),
        valueColor: AlwaysStoppedAnimation<Color>(_authGold),
      ),
    );
  }
}

class _UploadStatusChip extends StatelessWidget {
  const _UploadStatusChip({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.32)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _MediaPreviewTile extends StatefulWidget {
  const _MediaPreviewTile({
    super.key,
    required this.item,
    required this.onDelete,
  });

  final PickedMedia item;
  final VoidCallback onDelete;

  @override
  State<_MediaPreviewTile> createState() => _MediaPreviewTileState();
}

class _MediaPreviewTileState extends State<_MediaPreviewTile> {
  bool _selected = false;

  Future<void> _openPreview() async {
    final bool isImage = widget.item.type == PickedMediaType.image;
    final File file = File(widget.item.file.path);
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: const Color(0xFF181A20),
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: isImage
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(file, fit: BoxFit.contain),
                  )
                : AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: const Color(0xFF0F1218),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.play_circle_fill_rounded,
                          size: 46,
                          color: _authGold,
                        ),
                      ),
                    ),
                  ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isImage = widget.item.type == PickedMediaType.image;
    final File file = File(widget.item.file.path);

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      builder: (BuildContext context, double value, Widget? child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 10),
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTap: () async {
          setState(() => _selected = !_selected);
          await _openPreview();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: const Color(0xFF181A20),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _selected
                  ? _authGold
                  : Colors.white.withValues(alpha: 0.05),
              width: _selected ? 1.4 : 1,
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
              if (_selected)
                BoxShadow(
                  color: _authGold.withValues(alpha: 0.14),
                  blurRadius: 14,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: Stack(
            children: <Widget>[
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: isImage
                      ? Image.file(file, fit: BoxFit.cover)
                      : Container(
                          color: const Color(0xFF10131A),
                          child: const Center(
                            child: Icon(
                              Icons.play_circle_fill_rounded,
                              color: _authGold,
                              size: 34,
                            ),
                          ),
                        ),
                ),
              ),
              Positioned(
                top: 6,
                right: 6,
                child: InkWell(
                  onTap: widget.onDelete,
                  borderRadius: BorderRadius.circular(999),
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.12),
                      ),
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      color: Colors.white,
                      size: 14,
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

class _LocationStage extends StatefulWidget {
  const _LocationStage({
    required this.provider,
    required this.locationController,
  });

  final ReportIssueProvider provider;
  final TextEditingController locationController;

  @override
  State<_LocationStage> createState() => _LocationStageState();
}

class _LocationStageState extends State<_LocationStage> {
  GoogleMapController? _mapController;
  LatLng? _lastCameraTarget;
  final FocusNode _locationFocusNode = FocusNode();
  MapType _mapType = MapType.normal;
  bool _showSearchSuggestions = false;
  int _searchDebounceToken = 0;
  List<String> _searchSuggestions = <String>[];

  static const LatLng _fallbackCenter = LatLng(13.6288, 79.4192);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      if (widget.locationController.text.isNotEmpty) {
        widget.locationController.clear();
      }
    });
    _locationFocusNode.addListener(() {
      if (!mounted) {
        return;
      }
      setState(() {
        if (!_locationFocusNode.hasFocus) {
          _showSearchSuggestions = false;
        }
      });
    });
  }

  @override
  void dispose() {
    _locationFocusNode.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _showLocationPermissionDialog() async {
    if (!mounted) {
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF181818),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Location Permission Required',
            style: TextStyle(color: _textPrimary, fontWeight: FontWeight.w700),
          ),
          content: const Text(
            'Location permission is required to detect your current address automatically.',
            style: TextStyle(color: _textSecondary, height: 1.4),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: _textSecondary),
              ),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: _gold,
                foregroundColor: Colors.black,
              ),
              onPressed: () async {
                Navigator.of(context).pop();
                await openAppSettings();
              },
              child: const Text('Open Settings'),
            ),
          ],
        );
      },
    );
  }

  void _updateSearchSuggestions({
    required String query,
    required ReportIssueProvider provider,
  }) {
    final String q = query.trim();
    if (q.isEmpty || !_locationFocusNode.hasFocus) {
      setState(() {
        _searchSuggestions = <String>[];
        _showSearchSuggestions = false;
      });
      return;
    }

    final String city = _readComponent(provider.addressComponents, <String>[
      'city',
      'locality',
      'district',
      'administrative_area_level_2',
    ]);
    final String state = _readComponent(provider.addressComponents, <String>[
      'state',
      'administrative_area_level_1',
    ]);

    final LinkedHashSet<String> options = LinkedHashSet<String>()..add(q);
    if (city.isNotEmpty && state.isNotEmpty) {
      options.add('$q, $city, $state');
    } else if (city.isNotEmpty) {
      options.add('$q, $city');
    } else if (state.isNotEmpty) {
      options.add('$q, $state');
    }

    setState(() {
      _searchSuggestions = options.take(2).toList(growable: false);
      _showSearchSuggestions = _searchSuggestions.isNotEmpty;
    });
  }

  void _handleLocationQueryChange({
    required String value,
    required ReportIssueProvider provider,
  }) {
    provider.updateLocationInput(value);
    _updateSearchSuggestions(query: value, provider: provider);

    final String q = value.trim();
    if (q.length < 6) {
      return;
    }

    final int token = ++_searchDebounceToken;
    Future<void>.delayed(const Duration(milliseconds: 720), () {
      if (!mounted || token != _searchDebounceToken) {
        return;
      }
      if (provider.isLocating) {
        return;
      }
      if (_locationFocusNode.hasFocus &&
          widget.locationController.text.trim() == q) {
        provider.searchAndResolveLocation(q);
      }
    });
  }

  String _readComponent(Map<String, String> components, List<String> keys) {
    for (final String key in keys) {
      for (final MapEntry<String, String> entry in components.entries) {
        if (entry.key.toLowerCase().contains(key.toLowerCase()) &&
            entry.value.trim().isNotEmpty) {
          return entry.value.trim();
        }
      }
    }
    return '';
  }

  void _toggleMapLayer() {
    setState(() {
      switch (_mapType) {
        case MapType.normal:
          _mapType = MapType.terrain;
          break;
        case MapType.terrain:
          _mapType = MapType.hybrid;
          break;
        case MapType.hybrid:
        case MapType.satellite:
        case MapType.none:
          _mapType = MapType.normal;
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final ReportIssueProvider provider = widget.provider;
    if (provider.showLocationPermissionDialog) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        if (provider.consumeLocationPermissionDialogRequest()) {
          _showLocationPermissionDialog();
        }
      });
    }

    final TextEditingController locationController = widget.locationController;
    final double? lat = provider.detectedLatitude;
    final double? lng = provider.detectedLongitude;
    final bool hasCoordinates = lat != null && lng != null;
    final LatLng markerPosition = hasCoordinates
        ? LatLng(lat, lng)
        : _fallbackCenter;
    final bool isFocused = _locationFocusNode.hasFocus;
    final String? locationFieldError = provider.locationFieldError;
    final bool hasLocationValidationHint =
        locationFieldError != null && !provider.isLocating;
    final double mapHeroHeight = (MediaQuery.of(context).size.height * 0.66)
        .clamp(460.0, 640.0);
    final List<String> addressParts = provider.effectiveLocation
        .split(',')
        .map((String item) => item.trim())
        .where((String item) => item.isNotEmpty)
        .toList(growable: false);
    final String lineOne =
        _readComponent(provider.addressComponents, <String>[
          'landmark',
          'premise',
          'road',
          'street',
          'route',
          'locality',
        ]).trim().isNotEmpty
        ? _readComponent(provider.addressComponents, <String>[
            'landmark',
            'premise',
            'road',
            'street',
            'route',
            'locality',
          ])
        : (addressParts.isNotEmpty ? addressParts.first : 'Selected location');
    final String city = _readComponent(provider.addressComponents, <String>[
      'city',
      'district',
      'administrative_area_level_2',
      'locality',
    ]);
    final String state = _readComponent(provider.addressComponents, <String>[
      'state',
      'administrative_area_level_1',
    ]);
    final String lineTwo = city.isNotEmpty && state.isNotEmpty
        ? '$city, $state'
        : (city.isNotEmpty
              ? city
              : (state.isNotEmpty
                    ? state
                    : (addressParts.length > 1
                          ? addressParts.skip(1).take(2).join(', ')
                          : 'Choose a point on the map')));

    void focusSearch() {
      _locationFocusNode.requestFocus();
      final int length = locationController.text.length;
      locationController.selection = TextSelection(
        baseOffset: 0,
        extentOffset: length,
      );
    }

    if (hasCoordinates &&
        (_lastCameraTarget == null ||
            _lastCameraTarget!.latitude != markerPosition.latitude ||
            _lastCameraTarget!.longitude != markerPosition.longitude)) {
      _lastCameraTarget = markerPosition;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _mapController?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: markerPosition, zoom: 16),
          ),
        );
      });
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Issue Location',
          style: GoogleFonts.inter(
            color: _textPrimary,
            fontSize: 32,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Select the exact issue location using search or by tapping the map.',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.inter(
            color: const Color(0xFF9BA2AD),
            fontSize: 14.5,
            fontWeight: FontWeight.w500,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: mapHeroHeight,
          child: Stack(
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF12161D),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.06),
                  ),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.28),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Stack(
                    children: <Widget>[
                      if (!_enableGoogleMaps)
                        const _LocationMapUnavailable()
                      else
                        GoogleMap(
                          style: _darkMapStyle,
                          mapType: _mapType,
                          initialCameraPosition: CameraPosition(
                            target: markerPosition,
                            zoom: hasCoordinates ? 16 : 14,
                          ),
                          onMapCreated: (GoogleMapController controller) {
                            _mapController = controller;
                          },
                          myLocationEnabled: false,
                          myLocationButtonEnabled: false,
                          zoomControlsEnabled: false,
                          mapToolbarEnabled: false,
                          compassEnabled: true,
                          markers: <Marker>{
                            if (hasCoordinates)
                              Marker(
                                markerId: const MarkerId('current_location'),
                                position: markerPosition,
                                draggable: true,
                                icon: BitmapDescriptor.defaultMarkerWithHue(
                                  BitmapDescriptor.hueYellow,
                                ),
                                onDragEnd: (LatLng value) {
                                  provider.reverseGeocodeForCoordinates(
                                    latitude: value.latitude,
                                    longitude: value.longitude,
                                  );
                                },
                              ),
                          },
                          onTap: (LatLng value) {
                            provider.reverseGeocodeForCoordinates(
                              latitude: value.latitude,
                              longitude: value.longitude,
                            );
                          },
                        ),
                      if (!_enableGoogleMaps)
                        const SizedBox.shrink()
                      else ...<Widget>[
                        if (provider.isLocating && !hasCoordinates)
                          const Positioned.fill(
                            child: IgnorePointer(child: _LocationMapShimmer()),
                          ),
                        if (hasCoordinates)
                          const Positioned.fill(
                            child: IgnorePointer(
                              child: Center(child: _MapPinPulse()),
                            ),
                          ),
                      ],
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 16,
                right: 16,
                top: 16,
                child: AnimatedContainer(
                  height: 56,
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  decoration: BoxDecoration(
                    color: const Color(0xEE181A20),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.24),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                      if (isFocused)
                        BoxShadow(
                          color: _authGold.withValues(alpha: 0.13),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                    ],
                  ),
                  child: TextField(
                    controller: locationController,
                    focusNode: _locationFocusNode,
                    enabled: true,
                    onChanged: (String value) => _handleLocationQueryChange(
                      value: value,
                      provider: provider,
                    ),
                    onSubmitted: (String value) {
                      _showSearchSuggestions = false;
                      provider.searchAndResolveLocation(value);
                    },
                    onEditingComplete: () {
                      provider.searchAndResolveLocation(
                        locationController.text,
                      );
                    },
                    textInputAction: TextInputAction.search,
                    style: GoogleFonts.inter(
                      color: _textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search address, landmark or area',
                      hintStyle: GoogleFonts.inter(
                        color: const Color(0xFF8A929D),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide(
                          color: Colors.white.withValues(alpha: 0.05),
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide(
                          color: _authGold.withValues(alpha: 0.85),
                          width: 1,
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide(
                          color: Colors.white.withValues(alpha: 0.05),
                          width: 1,
                        ),
                      ),
                      filled: true,
                      fillColor: Colors.transparent,
                      contentPadding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: Color(0xFFC7A85F),
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
              if (_showSearchSuggestions && _searchSuggestions.isNotEmpty)
                Positioned(
                  left: 16,
                  right: 16,
                  top: 78,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xF2181A20),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.05),
                      ),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.22),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: _searchSuggestions
                          .asMap()
                          .entries
                          .map((MapEntry<int, String> entry) {
                            final int index = entry.key;
                            final String suggestion = entry.value;
                            final List<String> parts = suggestion
                                .split(',')
                                .map((String item) => item.trim())
                                .where((String item) => item.isNotEmpty)
                                .toList(growable: false);
                            final String primary = parts.isNotEmpty
                                ? parts.first
                                : suggestion;
                            final String secondary = parts.length > 1
                                ? parts.skip(1).take(2).join(', ')
                                : '';
                            return InkWell(
                              onTap: () {
                                locationController.value = TextEditingValue(
                                  text: suggestion,
                                  selection: TextSelection.collapsed(
                                    offset: suggestion.length,
                                  ),
                                );
                                _showSearchSuggestions = false;
                                provider.updateLocationInput(suggestion);
                                provider.searchAndResolveLocation(suggestion);
                                setState(() {});
                              },
                              child: Container(
                                padding: const EdgeInsets.fromLTRB(
                                  12,
                                  10,
                                  12,
                                  10,
                                ),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color:
                                          index == _searchSuggestions.length - 1
                                          ? Colors.transparent
                                          : Colors.white.withValues(
                                              alpha: 0.04,
                                            ),
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: <Widget>[
                                    const Icon(
                                      Icons.place_outlined,
                                      size: 16,
                                      color: Color(0xFFC7A85F),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            primary,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.inter(
                                              color: const Color(0xFFDDE3EC),
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          if (secondary.isNotEmpty)
                                            Text(
                                              secondary,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.inter(
                                                color: const Color(0xFF97A1AF),
                                                fontSize: 10.5,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    const Icon(
                                      Icons.chevron_right_rounded,
                                      color: Color(0xFF9BA2AD),
                                      size: 18,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          })
                          .toList(growable: false),
                    ),
                  ),
                ),
              Positioned(
                right: 16,
                top: 88,
                child: Column(
                  children: <Widget>[
                    _MapControlButton(
                      icon: Icons.add_rounded,
                      tooltip: 'Zoom In',
                      onTap: () =>
                          _mapController?.animateCamera(CameraUpdate.zoomIn()),
                    ),
                    const SizedBox(height: 8),
                    _MapControlButton(
                      icon: Icons.remove_rounded,
                      tooltip: 'Zoom Out',
                      onTap: () =>
                          _mapController?.animateCamera(CameraUpdate.zoomOut()),
                    ),
                    const SizedBox(height: 8),
                    _MapControlButton(
                      icon: Icons.layers_rounded,
                      tooltip: 'Map Layers',
                      onTap: !_enableGoogleMaps ? null : _toggleMapLayer,
                    ),
                  ],
                ),
              ),
              Positioned(
                right: 16,
                bottom: 112,
                child: _MyLocationPill(
                  isLoading: provider.isLocating,
                  onTap: provider.isLocating ? null : provider.detectLocation,
                ),
              ),
              Positioned.fill(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: DraggableScrollableSheet(
                    initialChildSize: 0.25,
                    minChildSize: 0.20,
                    maxChildSize: 0.52,
                    builder:
                        (
                          BuildContext context,
                          ScrollController scrollController,
                        ) {
                          return _LocationBottomSheet(
                            scrollController: scrollController,
                            hasSelection: provider.hasResolvedLocation,
                            lineOne: lineOne,
                            lineTwo: lineTwo,
                            onChangeLocation: focusSearch,
                            onUseCurrentLocation: provider.isLocating
                                ? null
                                : provider.detectLocation,
                            isLocating: provider.isLocating,
                            locationError: provider.locationError,
                            validationHint: hasLocationValidationHint
                                ? locationFieldError
                                : null,
                          );
                        },
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LocationMapShimmer extends StatefulWidget {
  const _LocationMapShimmer();

  @override
  State<_LocationMapShimmer> createState() => _LocationMapShimmerState();
}

class _LocationBottomSheet extends StatelessWidget {
  const _LocationBottomSheet({
    required this.scrollController,
    required this.hasSelection,
    required this.lineOne,
    required this.lineTwo,
    required this.onChangeLocation,
    required this.onUseCurrentLocation,
    required this.isLocating,
    this.locationError,
    this.validationHint,
  });

  final ScrollController scrollController;
  final bool hasSelection;
  final String lineOne;
  final String lineTwo;
  final VoidCallback onChangeLocation;
  final VoidCallback? onUseCurrentLocation;
  final bool isLocating;
  final String? locationError;
  final String? validationHint;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xF2171B22),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.28),
            blurRadius: 18,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SingleChildScrollView(
        controller: scrollController,
        physics: const ClampingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Align(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Selected Location',
                style: GoogleFonts.inter(
                  color: const Color(0xFFCCD3DD),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                hasSelection ? lineOne : 'Select Issue Location',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  color: _textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                hasSelection
                    ? lineTwo
                    : 'Tap map or search to confirm location',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  color: const Color(0xFFA9B1BD),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 8),
              const _AccuracyChip(text: 'High GPS Accuracy'),
              const SizedBox(height: 8),
              InkWell(
                onTap: onChangeLocation,
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        'Change Location',
                        style: GoogleFonts.inter(
                          color: _authGold,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        color: _authGold,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Divider(color: Colors.white.withValues(alpha: 0.08), height: 1),
              const SizedBox(height: 10),
              InkWell(
                onTap: onUseCurrentLocation,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: <Widget>[
                      isLocating
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: _authGold,
                              ),
                            )
                          : const Icon(
                              Icons.my_location_rounded,
                              color: _authGold,
                              size: 16,
                            ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          isLocating
                              ? 'Detecting current location'
                              : 'Use Current Location',
                          style: GoogleFonts.inter(
                            color: _textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 12,
                        color: Color(0xFF95A0AF),
                      ),
                    ],
                  ),
                ),
              ),
              if (validationHint != null || locationError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    locationError ?? validationHint!,
                    style: GoogleFonts.inter(
                      color: locationError != null
                          ? const Color(0xFFFFB3AB)
                          : const Color(0xFFFFD180),
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
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

class _LocationMapShimmerState extends State<_LocationMapShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(-1 + (_controller.value * 2), -0.3),
              end: Alignment(1 + (_controller.value * 2), 0.3),
              colors: <Color>[
                const Color(0xFF11151D).withValues(alpha: 0.52),
                const Color(0xFF1F2631).withValues(alpha: 0.65),
                const Color(0xFF11151D).withValues(alpha: 0.52),
              ],
            ),
          ),
          child: const Center(
            child: Icon(
              Icons.location_searching_rounded,
              color: _gold,
              size: 34,
            ),
          ),
        );
      },
    );
  }
}

class _LocationMapUnavailable extends StatelessWidget {
  const _LocationMapUnavailable();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF11161E),
      padding: const EdgeInsets.all(18),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(Icons.location_on_outlined, color: Color(0xFF8A929D), size: 38),
          SizedBox(height: 10),
          Text(
            'Select Issue Location',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Tap anywhere on the map or search for an address.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF9EA5AF),
              fontSize: 12,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _MapControlButton extends StatelessWidget {
  const _MapControlButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: const Color(0xFF171B22),
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.24),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(icon, color: _authGold, size: 19),
          ),
        ),
      ),
    );
  }
}

class _MyLocationPill extends StatelessWidget {
  const _MyLocationPill({required this.isLoading, required this.onTap});

  final bool isLoading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xF2171B22),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.22),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (isLoading)
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: _authGold,
                  ),
                )
              else
                const Icon(
                  Icons.my_location_rounded,
                  size: 15,
                  color: _authGold,
                ),
              const SizedBox(width: 6),
              Text(
                'My Location',
                style: GoogleFonts.inter(
                  color: _textPrimary,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MapPinPulse extends StatefulWidget {
  const _MapPinPulse();

  @override
  State<_MapPinPulse> createState() => _MapPinPulseState();
}

class _MapPinPulseState extends State<_MapPinPulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 54,
      height: 54,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (BuildContext context, Widget? child) {
          final double t = _controller.value;
          final double scale = 0.7 + (t * 0.9);
          return Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Transform.scale(
                scale: scale,
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _authGold.withValues(alpha: (1 - t) * 0.2),
                  ),
                ),
              ),
              Container(
                width: 14,
                height: 14,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: _authGold,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CurrentLocationActionCard extends StatefulWidget {
  const _CurrentLocationActionCard({
    required this.isLoading,
    required this.onTap,
  });

  final bool isLoading;
  final VoidCallback? onTap;

  @override
  State<_CurrentLocationActionCard> createState() =>
      _CurrentLocationActionCardState();
}

class _CurrentLocationActionCardState
    extends State<_CurrentLocationActionCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final bool enabled = widget.onTap != null;
    return GestureDetector(
      onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
      onTapCancel: enabled ? () => setState(() => _pressed = false) : null,
      onTapUp: enabled ? (_) => setState(() => _pressed = false) : null,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 140),
        scale: _pressed ? 0.985 : 1,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(18),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              height: 56,
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
              decoration: BoxDecoration(
                color: const Color(0xFF181A20),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: Colors.white.withValues(alpha: enabled ? 0.06 : 0.03),
                ),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: _pressed ? 16 : 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: <Widget>[
                  widget.isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            color: _authGold,
                          ),
                        )
                      : const Icon(
                          Icons.my_location_rounded,
                          color: _authGold,
                          size: 22,
                        ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.isLoading
                          ? 'Detecting Location'
                          : 'Use My Current Location',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        color: _textPrimary,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    color: Color(0xFF95A0AF),
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AccuracyChip extends StatelessWidget {
  const _AccuracyChip({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0x1A4CAF50),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0x3D4CAF50)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const _IssueTickIcon(size: 13, color: _green),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Color(0xFFBFE7CD),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

const String _darkMapStyle = '''
[
  {"elementType":"geometry","stylers":[{"color":"#1d1d1d"}]},
  {"elementType":"labels.icon","stylers":[{"visibility":"off"}]},
  {"elementType":"labels.text.fill","stylers":[{"color":"#8b8b8b"}]},
  {"elementType":"labels.text.stroke","stylers":[{"color":"#1d1d1d"}]},
  {"featureType":"administrative","elementType":"geometry","stylers":[{"color":"#2d2d2d"}]},
  {"featureType":"poi","elementType":"geometry","stylers":[{"color":"#242424"}]},
  {"featureType":"road","elementType":"geometry","stylers":[{"color":"#2f2f2f"}]},
  {"featureType":"road","elementType":"geometry.stroke","stylers":[{"color":"#1f1f1f"}]},
  {"featureType":"water","elementType":"geometry","stylers":[{"color":"#11161c"}]}
]
''';

class _ReviewStage extends StatefulWidget {
  const _ReviewStage({
    required this.provider,
    required this.reviewConfirmed,
    required this.onReviewConfirmationChanged,
  });

  final ReportIssueProvider provider;
  final bool reviewConfirmed;
  final ValueChanged<bool> onReviewConfirmationChanged;

  @override
  State<_ReviewStage> createState() => _ReviewStageState();
}

class _ReviewStageState extends State<_ReviewStage> {
  ReportIssueProvider get provider => widget.provider;

  @override
  Widget build(BuildContext context) {
    final IssueCategory? selectedCategory = provider.categories
        .where((IssueCategory item) => item.id == provider.selectedCategoryId)
        .cast<IssueCategory?>()
        .firstWhere((IssueCategory? item) => item != null, orElse: () => null);
    final int imageCount = provider.mediaItems
        .where((PickedMedia x) => x.type == PickedMediaType.image)
        .length;
    final int videoCount = provider.mediaItems
        .where((PickedMedia x) => x.type == PickedMediaType.video)
        .length;
    final bool hasEvidence = provider.mediaItems.isNotEmpty;
    final AuthorityProfile? primaryAuthority = provider.selectedAuthorities
        .cast<AuthorityProfile?>()
        .firstWhere(
          (AuthorityProfile? item) => item != null,
          orElse: () => null,
        );
    final String locationPrimary = _locationPrimaryText();
    final String? locationSecondary = _locationSecondaryText();
    final String evidenceSummary = hasEvidence
        ? '$imageCount Photos${videoCount > 0 ? ' • $videoCount Videos' : ''}'
        : 'Not Attached';
    final String turnaround = _turnaroundByCategory(selectedCategory?.id);
    final String defaultPriority = _priorityByCategory(selectedCategory?.id);
    final String selectedPriority =
        provider.selectedPriority ?? defaultPriority;
    final String representativeRole = primaryAuthority == null
        ? 'Not selected'
        : _roleAbbreviation(
            _roleTypeForDesignation(primaryAuthority.designation),
          );
    final String representativeConstituency = primaryAuthority == null
        ? ''
        : _constituencyDisplayValue(primaryAuthority);
    final bool readyForSubmission =
        selectedCategory != null &&
        provider.selectedAuthorities.isNotEmpty &&
        provider.description.trim().isNotEmpty &&
        provider.effectiveLocation.trim().isNotEmpty;
    final IconData categoryIcon = _categoryIconById(selectedCategory?.id);
    final Color categoryColor = _categoryColorById(selectedCategory?.id);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _StaggerReveal(
          delay: const Duration(milliseconds: 30),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                'Review Your Report',
                style: GoogleFonts.inter(
                  color: _textPrimary,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.28,
                  height: 1.02,
                ),
              ),
              const SizedBox(width: 5),
              Transform.translate(
                offset: Offset(0, -1),
                child: SizedBox(
                  width: 28,
                  height: 28,
                  child: Icon(
                    Icons.gpp_good_outlined,
                    color: _authGold,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        _StaggerReveal(
          delay: const Duration(milliseconds: 70),
          child: Text(
            'Please review all information before submitting your report.',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              color: const Color(0xFF9BA2AD),
              fontSize: 12.6,
              fontWeight: FontWeight.w500,
              height: 1.35,
            ),
          ),
        ),
        const SizedBox(height: 12),
        _StaggerReveal(
          delay: const Duration(milliseconds: 120),
          child: _PremiumOverviewCard(
            category: selectedCategory?.title ?? 'Not selected',
            categoryIcon: categoryIcon,
            categoryColor: categoryColor,
            representativeName: primaryAuthority?.name ?? 'Not selected',
            representativeRole: representativeRole,
            location: locationPrimary,
            priority: selectedPriority,
            eta: turnaround,
            evidence: hasEvidence ? evidenceSummary : 'Not Attached',
            ready: readyForSubmission,
          ),
        ),
        const SizedBox(height: 12),
        _StaggerReveal(
          delay: const Duration(milliseconds: 180),
          child: _ReviewTimelineRow(
            icon: categoryIcon,
            accent: categoryColor,
            title: 'Category',
            primary: selectedCategory?.title ?? 'Not selected',
            onEdit: () => provider.goToStep(1),
          ),
        ),
        _StaggerReveal(
          delay: const Duration(milliseconds: 220),
          child: _ReviewTimelineRow(
            icon: Icons.person_rounded,
            accent: const Color(0xFFB388FF),
            title: 'Representative',
            primary: primaryAuthority?.name ?? 'Not selected',
            secondary: primaryAuthority == null
                ? null
                : '$representativeRole, $representativeConstituency Constituency',
            onEdit: () => provider.goToStep(2),
          ),
        ),
        _StaggerReveal(
          delay: const Duration(milliseconds: 260),
          child: _ReviewTimelineRow(
            icon: Icons.description_rounded,
            accent: const Color(0xFFFFC043),
            title: 'Issue Details',
            primary: provider.description.trim().isEmpty
                ? 'No description provided'
                : provider.description.trim(),
            maxPrimaryLines: 1,
            onEdit: () => provider.goToStep(3),
          ),
        ),
        _StaggerReveal(
          delay: const Duration(milliseconds: 300),
          child: _ReviewTimelineRow(
            icon: Icons.image_rounded,
            accent: const Color(0xFFFFA14F),
            title: 'Evidence',
            primary: hasEvidence ? evidenceSummary : 'No Evidence Attached',
            onEdit: () => provider.goToStep(4),
          ),
        ),
        _StaggerReveal(
          delay: const Duration(milliseconds: 340),
          child: _ReviewTimelineRow(
            icon: Icons.location_on_rounded,
            accent: const Color(0xFF65D56E),
            title: 'Location',
            primary: locationPrimary,
            secondary: locationSecondary,
            onEdit: () => provider.goToStep(5),
          ),
        ),
        const SizedBox(height: 10),
        _StaggerReveal(
          delay: const Duration(milliseconds: 380),
          child: _EstimatedResolutionCard(
            turnaround: turnaround,
            department: _departmentByCategory(selectedCategory?.id),
            priority: selectedPriority,
          ),
        ),
        const SizedBox(height: 10),
        _StaggerReveal(
          delay: const Duration(milliseconds: 420),
          child: _ChecklistCard(
            rows: <_ChecklistItemData>[
              _ChecklistItemData(
                label: 'Category Selected',
                done: selectedCategory != null,
              ),
              _ChecklistItemData(
                label: 'Representative Selected',
                done: provider.selectedAuthorities.isNotEmpty,
              ),
              _ChecklistItemData(
                label: 'Description Added',
                done: provider.description.trim().isNotEmpty,
              ),
              _ChecklistItemData(
                label: 'Location Confirmed',
                done: provider.effectiveLocation.trim().isNotEmpty,
              ),
              _ChecklistItemData(
                label: 'Evidence Optional',
                done: hasEvidence,
                optional: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        _StaggerReveal(
          delay: const Duration(milliseconds: 460),
          child: _DeclarationCard(
            value: widget.reviewConfirmed,
            onChanged: (bool value) {
              widget.onReviewConfirmationChanged(value);
            },
          ),
        ),
      ],
    );
  }

  String _locationPrimaryText() {
    final String landmark =
        _v(provider.addressComponents['landmark']) ??
        _v(provider.addressComponents['road']) ??
        _v(provider.addressComponents['street']) ??
        _v(provider.addressComponents['locality']) ??
        '';
    if (landmark.isNotEmpty) {
      return landmark;
    }
    final List<String> parts = provider.effectiveLocation
        .split(',')
        .map((String item) => item.trim())
        .where((String item) => item.isNotEmpty)
        .toList(growable: false);
    return parts.isNotEmpty ? parts.first : 'Location missing';
  }

  String? _locationSecondaryText() {
    final String city =
        _v(provider.addressComponents['city']) ??
        _v(provider.addressComponents['district']) ??
        '';
    final String state = _v(provider.addressComponents['state']) ?? '';
    if (city.isNotEmpty && state.isNotEmpty) {
      return '$city, $state';
    }
    if (city.isNotEmpty) {
      return city;
    }
    if (state.isNotEmpty) {
      return state;
    }
    return null;
  }

  String _turnaroundByCategory(String? categoryId) {
    switch (categoryId) {
      case 'public_safety':
      case 'electricity':
      case 'water':
        return '2-4 Working Days';
      case 'roads':
      case 'drainage':
      case 'traffic':
        return '3-6 Working Days';
      default:
        return '4-7 Working Days';
    }
  }

  String? _v(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    return value.trim();
  }

  String _departmentByCategory(String? categoryId) {
    switch (categoryId) {
      case 'roads':
      case 'traffic':
      case 'street_lights':
        return 'Urban Infrastructure Department';
      case 'water':
      case 'drainage':
        return 'Water & Sanitation Department';
      case 'garbage':
      case 'environment':
        return 'Solid Waste & Environment Department';
      case 'health':
        return 'Public Health Department';
      case 'education':
        return 'Education Department';
      case 'electricity':
        return 'Power Distribution Department';
      default:
        return 'Citizen Services Department';
    }
  }

  String _priorityByCategory(String? categoryId) {
    switch (categoryId) {
      case 'public_safety':
      case 'electricity':
      case 'water':
        return 'High';
      case 'roads':
      case 'drainage':
      case 'traffic':
        return 'Medium';
      default:
        return 'Low';
    }
  }

  IconData _categoryIconById(String? categoryId) {
    switch (categoryId) {
      case 'water':
      case 'drainage':
        return Icons.water_drop_rounded;
      case 'roads':
        return Icons.route_rounded;
      case 'traffic':
        return Icons.traffic_rounded;
      case 'electricity':
      case 'street_lights':
        return Icons.bolt_rounded;
      case 'garbage':
        return Icons.delete_outline_rounded;
      case 'health':
        return Icons.local_hospital_outlined;
      case 'education':
        return Icons.school_outlined;
      default:
        return Icons.category_rounded;
    }
  }

  Color _categoryColorById(String? categoryId) {
    switch (categoryId) {
      case 'water':
      case 'drainage':
        return const Color(0xFF4DA3FF);
      case 'roads':
      case 'traffic':
      case 'electricity':
      case 'street_lights':
        return const Color(0xFFFFC043);
      case 'garbage':
        return const Color(0xFFFFA14F);
      case 'health':
        return const Color(0xFFFF5959);
      case 'education':
        return const Color(0xFFB388FF);
      default:
        return const Color(0xFF4DA3FF);
    }
  }
}

class _PremiumOverviewCard extends StatelessWidget {
  const _PremiumOverviewCard({
    required this.category,
    required this.categoryIcon,
    required this.categoryColor,
    required this.representativeName,
    required this.representativeRole,
    required this.location,
    required this.priority,
    required this.eta,
    required this.evidence,
    required this.ready,
  });

  final String category;
  final IconData categoryIcon;
  final Color categoryColor;
  final String representativeName;
  final String representativeRole;
  final String location;
  final String priority;
  final String eta;
  final String evidence;
  final bool ready;

  @override
  Widget build(BuildContext context) {
    return _LiftCard(
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0x1AFFFFFF)),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[Color(0xFF0B1118), Color(0xFF080D13)],
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.34),
              blurRadius: 16,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0x2E66D89A)),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: <Color>[Color(0xFF12261B), Color(0xFF0E1D16)],
                      ),
                    ),
                    child: Center(
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: <Widget>[
                          const Icon(
                            Icons.assessment_rounded,
                            color: Color(0xFF71DBA0),
                            size: 33,
                          ),
                          Positioned(
                            right: -2,
                            bottom: -2,
                            child: Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: const Color(0xFF163324),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFF58D196),
                                  width: 1,
                                ),
                              ),
                              child: const Icon(
                                Icons.check_rounded,
                                size: 10,
                                color: Color(0xFF79E3AB),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Report Summary',
                          style: GoogleFonts.inter(
                            color: _textPrimary,
                            fontSize: 15.2,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.12,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(999),
                            color: const Color(0x14131B20),
                            border: Border.all(
                              color:
                                  (ready ? const Color(0xFF58D196) : _warning)
                                      .withValues(alpha: 0.28),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Icon(
                                ready
                                    ? Icons.check_rounded
                                    : Icons.error_outline_rounded,
                                color: ready
                                    ? const Color(0xFF58D196)
                                    : _warning,
                                size: 10.8,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                ready
                                    ? 'Ready for Submission'
                                    : 'Needs Attention',
                                style: GoogleFonts.inter(
                                  color: ready
                                      ? const Color(0xFFB8EFD2)
                                      : const Color(0xFFFFD8A0),
                                  fontSize: 8.8,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Divider(height: 1, color: Color(0x24FFFFFF)),
              const SizedBox(height: 12),
              _OverviewLine(
                icon: categoryIcon,
                accent: categoryColor,
                label: 'Category',
                value: category,
              ),
              _OverviewLine(
                icon: Icons.person_rounded,
                accent: const Color(0xFFB388FF),
                label: 'Representative',
                value: '$representativeName ($representativeRole)',
              ),
              _OverviewLine(
                icon: Icons.location_on_rounded,
                accent: const Color(0xFF67D46A),
                label: 'Location',
                value: location,
              ),
              _OverviewLine(
                icon: Icons.image_rounded,
                accent: const Color(0xFFFFA14F),
                label: 'Evidence',
                value: evidence,
              ),
              _OverviewLine(
                icon: Icons.outlined_flag_rounded,
                accent: const Color(0xFFFF5959),
                label: 'Priority',
                value: priority,
              ),
              _OverviewLine(
                icon: Icons.schedule_rounded,
                accent: const Color(0xFFFFC048),
                label: 'Estimated Resolution',
                value: eta,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OverviewLine extends StatelessWidget {
  const _OverviewLine({
    required this.icon,
    required this.accent,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color accent;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(width: 26, child: Icon(icon, size: 22, color: accent)),
          const SizedBox(width: 14),
          SizedBox(
            width: 156,
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                color: const Color(0xFFC7CBD3),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                color: _textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewTimelineRow extends StatefulWidget {
  const _ReviewTimelineRow({
    required this.icon,
    required this.accent,
    required this.title,
    required this.primary,
    required this.onEdit,
    this.secondary,
    this.maxPrimaryLines = 1,
  });

  final IconData icon;
  final Color accent;
  final String title;
  final String primary;
  final String? secondary;
  final int maxPrimaryLines;
  final VoidCallback onEdit;

  @override
  State<_ReviewTimelineRow> createState() => _ReviewTimelineRowState();
}

class _ReviewTimelineRowState extends State<_ReviewTimelineRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(0, _hovered ? -1.5 : 0, 0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0x20FFFFFF)),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              _hovered ? const Color(0xFF151C24) : const Color(0xFF121922),
              _hovered ? const Color(0xFF111720) : const Color(0xFF0F141C),
            ],
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: _hovered ? 0.26 : 0.2),
              blurRadius: _hovered ? 14 : 9,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: MouseRegion(
            onEnter: (_) => setState(() => _hovered = true),
            onExit: (_) => setState(() => _hovered = false),
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: widget.onEdit,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 72),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: widget.accent.withValues(alpha: 0.07),
                          border: Border.all(
                            color: widget.accent.withValues(alpha: 0.13),
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          widget.icon,
                          size: 25,
                          color: widget.accent,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              widget.title,
                              style: GoogleFonts.inter(
                                color: const Color(0xFFAFB6C2),
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              widget.primary,
                              maxLines: widget.maxPrimaryLines,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                color: _textPrimary,
                                fontSize: 11.8,
                                fontWeight: FontWeight.w700,
                                height: 1.3,
                              ),
                            ),
                            if (widget.secondary != null) ...<Widget>[
                              const SizedBox(height: 1),
                              Text(
                                widget.secondary!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.inter(
                                  color: const Color(0xFF8E97A4),
                                  fontSize: 10.2,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: widget.onEdit,
                        style: TextButton.styleFrom(
                          foregroundColor: _gold,
                          minimumSize: const Size(0, 40),
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(
                              'Edit',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 1),
                            const Icon(
                              Icons.chevron_right_rounded,
                              size: 17,
                              color: _authGold,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EstimatedResolutionCard extends StatelessWidget {
  const _EstimatedResolutionCard({
    required this.turnaround,
    required this.department,
    required this.priority,
  });

  final String turnaround;
  final String department;
  final String priority;

  @override
  Widget build(BuildContext context) {
    return _LiftCard(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[Color(0xFF101720), Color(0xFF0D141C)],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0x20FFFFFF)),
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              flex: 2,
              child: _ResolutionInfo(
                icon: Icons.schedule_rounded,
                iconColor: const Color(0xFFB983FF),
                label: 'Estimated',
                value: turnaround,
              ),
            ),
            Container(width: 1, height: 44, color: const Color(0x1FFFFFFF)),
            Expanded(
              flex: 3,
              child: _ResolutionInfo(
                icon: Icons.corporate_fare_rounded,
                iconColor: const Color(0xFF50BCFF),
                label: 'Department',
                value: _shortDepartment(department),
              ),
            ),
            Container(width: 1, height: 44, color: const Color(0x1FFFFFFF)),
            Expanded(
              flex: 2,
              child: _ResolutionInfo(
                icon: Icons.outlined_flag_rounded,
                iconColor: const Color(0xFFFF5555),
                label: 'Priority',
                value: priority,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChecklistItemData {
  const _ChecklistItemData({
    required this.label,
    required this.done,
    this.optional = false,
  });

  final String label;
  final bool done;
  final bool optional;
}

class _ChecklistCard extends StatelessWidget {
  const _ChecklistCard({required this.rows});

  final List<_ChecklistItemData> rows;

  @override
  Widget build(BuildContext context) {
    return _LiftCard(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(14, 11, 14, 10),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[Color(0xFF101720), Color(0xFF0D141C)],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0x20FFFFFF)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                const Icon(
                  Icons.assignment_turned_in_rounded,
                  color: Color(0xFF70DFA3),
                  size: 19,
                ),
                const SizedBox(width: 8),
                Text(
                  'Submission Checklist',
                  style: GoogleFonts.inter(
                    color: _textPrimary,
                    fontSize: 12.6,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              runSpacing: 6,
              children: rows
                  .asMap()
                  .entries
                  .map((MapEntry<int, _ChecklistItemData> item) {
                    final bool leftColumn = item.key.isEven;
                    return SizedBox(
                      width: (MediaQuery.of(context).size.width - 72) / 2,
                      child: _ChecklistRow(
                        label: item.value.label,
                        done: item.value.done,
                        optional: item.value.optional,
                        alignLeft: leftColumn,
                      ),
                    );
                  })
                  .toList(growable: false),
            ),
          ],
        ),
      ),
    );
  }
}

class _LiftCard extends StatefulWidget {
  const _LiftCard({required this.child});

  final Widget child;

  @override
  State<_LiftCard> createState() => _LiftCardState();
}

class _LiftCardState extends State<_LiftCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 210),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(0, _hovered ? -2 : 0, 0),
        child: widget.child,
      ),
    );
  }
}

class _StaggerReveal extends StatefulWidget {
  const _StaggerReveal({required this.child, this.delay = Duration.zero});

  final Widget child;
  final Duration delay;

  @override
  State<_StaggerReveal> createState() => _StaggerRevealState();
}

class _StaggerRevealState extends State<_StaggerReveal> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (widget.delay > Duration.zero) {
        await Future<void>.delayed(widget.delay);
      }
      if (!mounted) {
        return;
      }
      setState(() {
        _visible = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
      opacity: _visible ? 1 : 0,
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
        offset: _visible ? Offset.zero : const Offset(0, 0.06),
        child: widget.child,
      ),
    );
  }
}

class _DeclarationCard extends StatefulWidget {
  const _DeclarationCard({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  State<_DeclarationCard> createState() => _DeclarationCardState();
}

class _DeclarationCardState extends State<_DeclarationCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    const Color border = Color(0x22FFFFFF);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            _hovered ? const Color(0xFF151C25) : const Color(0xFF101720),
            _hovered ? const Color(0xFF121821) : const Color(0xFF0D141B),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
      ),
      child: Material(
        color: Colors.transparent,
        child: MouseRegion(
          onEnter: (_) => setState(() => _hovered = true),
          onExit: (_) => setState(() => _hovered = false),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => widget.onChanged(!widget.value),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 12, 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Transform.scale(
                    scale: 0.96,
                    child: Checkbox(
                      value: widget.value,
                      onChanged: (bool? value) {
                        widget.onChanged(value ?? false);
                      },
                      activeColor: _gold,
                      checkColor: Colors.black,
                      side: BorderSide(
                        color: widget.value
                            ? _gold.withValues(alpha: 0.8)
                            : const Color(0xFF4A515D),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'I confirm that the information provided is accurate to the best of my knowledge.',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        color: _textPrimary,
                        fontSize: 12.1,
                        height: 1.28,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ChecklistRow extends StatelessWidget {
  const _ChecklistRow({
    required this.label,
    required this.done,
    this.optional = false,
    this.alignLeft = true,
  });

  final String label;
  final bool done;
  final bool optional;
  final bool alignLeft;

  @override
  Widget build(BuildContext context) {
    final Color color = done
        ? const Color(0xFF8DDEAA)
        : (optional ? const Color(0xFFA0A0A0) : const Color(0xFFFFB3AB));
    return Row(
      mainAxisAlignment: alignLeft
          ? MainAxisAlignment.start
          : MainAxisAlignment.start,
      children: <Widget>[
        done
            ? const Icon(Icons.check_circle_rounded, size: 14, color: _green)
            : const Icon(
                Icons.radio_button_unchecked_rounded,
                size: 14,
                color: Color(0xFF666666),
              ),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.inter(
              color: color,
              fontSize: 11.8,
              fontWeight: FontWeight.w600,
              height: 1.25,
            ),
          ),
        ),
      ],
    );
  }
}

class _ResolutionInfo extends StatelessWidget {
  const _ResolutionInfo({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(icon, size: 18, color: iconColor),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    color: iconColor,
                    fontSize: 10.8,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 1,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: _textPrimary,
              fontSize: 13.4,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomActionBar extends StatefulWidget {
  const _BottomActionBar({
    required this.provider,
    required this.reviewConfirmed,
    required this.authorityMode,
    required this.onSubmit,
  });

  final ReportIssueProvider provider;
  final bool reviewConfirmed;
  final bool authorityMode;
  final Future<void> Function() onSubmit;

  @override
  State<_BottomActionBar> createState() => _BottomActionBarState();
}

class _BottomActionBarState extends State<_BottomActionBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ReportIssueProvider provider = widget.provider;
    final bool isStart = provider.currentStep == 0;
    final bool isSubmit = provider.isLastStep;
    final bool canProceed =
        provider.canProceedCurrentStep && (!isSubmit || widget.reviewConfirmed);

    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        10,
        16,
        10 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: widget.authorityMode ? _authBg.withValues(alpha: 0.96) : _bg,
        border: Border(
          top: BorderSide(
            color: widget.authorityMode
                ? _authBorder.withValues(alpha: 0.9)
                : _dividerSoft,
          ),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(
              alpha: widget.authorityMode ? 0.38 : 0.3,
            ),
            blurRadius: widget.authorityMode ? 28 : 22,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            children: <Widget>[
              if (provider.currentStep > 0)
                Expanded(
                  child: OutlinedButton(
                    onPressed: provider.previousStep,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: widget.authorityMode
                          ? _authTextPrimary
                          : _textPrimarySoft,
                      backgroundColor: widget.authorityMode
                          ? _authSurface.withValues(alpha: 0.88)
                          : _surfaceSoft,
                      side: BorderSide(
                        color: widget.authorityMode
                            ? _authBorder
                            : _dividerSoft,
                      ),
                      minimumSize: const Size.fromHeight(56),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: Text(
                      'Back',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              if (provider.currentStep > 0) const SizedBox(width: 10),
              Expanded(
                flex: isStart ? 1 : 1,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child: TweenAnimationBuilder<double>(
                    key: ValueKey<bool>(canProceed),
                    tween: Tween<double>(
                      begin: 0.995,
                      end: isSubmit && canProceed ? 1.01 : 1,
                    ),
                    duration: const Duration(milliseconds: 280),
                    curve: Curves.easeOutCubic,
                    builder:
                        (BuildContext context, double scale, Widget? child) {
                          final double pulse = isSubmit && canProceed
                              ? (0.99 + (_pulseController.value * 0.02))
                              : 1;
                          return Transform.scale(
                            scale: scale * pulse,
                            child: child,
                          );
                        },
                    child: ElevatedButton(
                      onPressed: canProceed
                          ? () async {
                              FocusScope.of(context).unfocus();
                              if (isSubmit) {
                                await widget.onSubmit();
                                return;
                              }
                              provider.nextStep();
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: canProceed
                            ? Colors.transparent
                            : (widget.authorityMode
                                      ? _authSurface
                                      : _surfaceSoft)
                                  .withValues(alpha: 0.45),
                        foregroundColor: canProceed
                            ? Colors.black
                            : Colors.white.withValues(alpha: 0.42),
                        disabledForegroundColor: Colors.white.withValues(
                          alpha: 0.4,
                        ),
                        minimumSize: const Size.fromHeight(56),
                        padding: EdgeInsets.zero,
                        elevation: canProceed ? 0 : 0,
                        surfaceTintColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: Ink(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: canProceed
                              ? <BoxShadow>[
                                  BoxShadow(
                                    color: const Color(
                                      0xFFF2B74A,
                                    ).withValues(alpha: 0.34),
                                    blurRadius: 18,
                                    offset: const Offset(0, 8),
                                  ),
                                ]
                              : null,
                          gradient: canProceed
                              ? const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: <Color>[
                                    Color(0xFFF8C75A),
                                    Color(0xFFE8A72C),
                                  ],
                                )
                              : null,
                        ),
                        child: SizedBox(
                          height: 56,
                          child: Center(
                            child: provider.isSubmitting
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.black,
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Text(
                                        isStart
                                            ? 'Start Reporting'
                                            : isSubmit
                                            ? 'Submit Report'
                                            : 'Continue',
                                        style: GoogleFonts.inter(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 0.1,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Icon(
                                        isSubmit
                                            ? Icons.send_rounded
                                            : Icons.arrow_forward_rounded,
                                        size: 18,
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (isSubmit && !widget.reviewConfirmed)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                'Please confirm the declaration before submitting.',
                style: TextStyle(
                  color: Color(0xFFA0A0A0),
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SubmittingDialog extends StatefulWidget {
  const _SubmittingDialog();

  @override
  State<_SubmittingDialog> createState() => _SubmittingDialogState();
}

class _SubmittingDialogState extends State<_SubmittingDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  static const List<String> _steps = <String>[
    'Validating Details',
    'Tagging Representative',
    'Assigning Department',
    'Generating Tracking ID',
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 26),
      child: Padding(
        padding: const EdgeInsets.only(top: 2),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (BuildContext context, Widget? _) {
            final double progress = _controller.value.clamp(0, 1);
            final double phase = progress * _steps.length;
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0x26FFFFFF)),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[Color(0xFF0F1621), Color(0xFF0C1017)],
                ),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.34),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: const LinearGradient(
                            colors: <Color>[
                              Color(0xFFF8C75A),
                              Color(0xFFE6A629),
                            ],
                          ),
                        ),
                        child: const Icon(
                          Icons.upload_rounded,
                          color: Colors.black,
                          size: 19,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Submitting Report',
                              style: GoogleFonts.inter(
                                color: _textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              'Uploading Information...',
                              style: GoogleFonts.inter(
                                color: const Color(0xFFAAB3C0),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ..._steps.asMap().entries.map((MapEntry<int, String> item) {
                    final int idx = item.key;
                    final bool done = phase >= idx + 0.9;
                    final bool active = !done && phase >= idx;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 7),
                      child: Row(
                        children: <Widget>[
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(999),
                              color: done
                                  ? const Color(0xFF58D196)
                                  : active
                                  ? const Color(0xFFF5B62D)
                                  : const Color(0xFF344051),
                            ),
                            child: done
                                ? const Icon(
                                    Icons.check_rounded,
                                    size: 11,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            item.value,
                            style: GoogleFonts.inter(
                              color: done
                                  ? const Color(0xFFC1EFD7)
                                  : active
                                  ? const Color(0xFFF9DEA8)
                                  : const Color(0xFF97A2B1),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 2),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      minHeight: 6,
                      value: progress,
                      backgroundColor: const Color(0xFF273040),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF58D196),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

String _shortDepartment(String department) {
  if (department == 'Water & Sanitation Department') {
    return 'Municipal Department';
  }
  return department;
}
