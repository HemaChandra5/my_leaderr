import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

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
const Color _surface = Color(0xFF151515);
const Color _gold = Color(0xFFF5B62D);
const Color _green = Color(0xFF4CAF50);
const Color _warning = Color(0xFFFF9800);
const Color _error = Color(0xFFE53935);
const Color _textPrimary = Color(0xFFFFFFFF);
const Color _textSecondary = Color(0xFFBDBDBD);
const Color _stroke = Color(0xFF2A2A2A);
const bool _enableGoogleMaps = bool.fromEnvironment(
  'ENABLE_GOOGLE_MAPS',
  defaultValue: false,
);

Future<void> _openInMaps({required double lat, required double lng}) async {
  final Uri uri = Uri.parse(
    'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
  );
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}

String _authorityAvatarUrl(AuthorityProfile authority) {
  if (authority.profilePhotoUrl != null && authority.profilePhotoUrl!.isNotEmpty) {
    return authority.profilePhotoUrl!;
  }

  const List<String> avatars = <String>[
    'https://randomuser.me/api/portraits/men/32.jpg',
    'https://randomuser.me/api/portraits/women/44.jpg',
    'https://randomuser.me/api/portraits/men/68.jpg',
    'https://randomuser.me/api/portraits/women/63.jpg',
    'https://randomuser.me/api/portraits/men/75.jpg',
    'https://randomuser.me/api/portraits/women/52.jpg',
    'https://randomuser.me/api/portraits/men/17.jpg',
    'https://randomuser.me/api/portraits/women/29.jpg',
    'https://randomuser.me/api/portraits/men/41.jpg',
    'https://randomuser.me/api/portraits/women/14.jpg',
    'https://randomuser.me/api/portraits/men/54.jpg',
    'https://randomuser.me/api/portraits/women/8.jpg',
  ];

  final int idx = authority.id.hashCode.abs() % avatars.length;
  return avatars[idx];
}

int _authorityPriorityOrder(AuthorityProfile authority) {
  final String d = authority.designation.toLowerCase();
  if (d.contains('mla')) {
    return 0;
  }
  if (d.contains('mlc')) {
    return 1;
  }
  if (d.contains('member of parliament') || RegExp(r'(^|\W)mp(\W|$)').hasMatch(d)) {
    return 2;
  }
  if (d.contains('councillor') || d.contains('councilor') || d.contains('corporator')) {
    return 3;
  }
  if (d.contains('sarpanch')) {
    return 4;
  }
  return 99;
}

bool _usesConstituency(String designation) {
  final String d = designation.toLowerCase();
  return d.contains('mla') ||
      d.contains('mlc') ||
      d.contains('member of parliament') ||
      RegExp(r'(^|\W)mp(\W|$)').hasMatch(d);
}

bool _isWardRole(String designation) {
  final String d = designation.toLowerCase();
  return d.contains('corporator') || d.contains('councillor') || d.contains('councilor');
}

bool _isSarpanchRole(String designation) {
  return designation.toLowerCase().contains('sarpanch');
}

class _AuthorityPrimaryInfo {
  const _AuthorityPrimaryInfo({required this.icon, required this.text});

  final IconData icon;
  final String text;
}

String _nonEmptyOr(String value, String fallback) {
  final String v = value.trim();
  if (v.isEmpty || v.toLowerCase() == 'n/a') {
    return fallback;
  }
  return v;
}

_AuthorityPrimaryInfo _authorityPrimaryInfo(AuthorityProfile authority) {
  if (_usesConstituency(authority.designation)) {
    return _AuthorityPrimaryInfo(
      icon: Icons.how_to_vote_rounded,
      text: 'Constituency: ${_nonEmptyOr(authority.constituency, authority.jurisdiction)}',
    );
  }
  if (_isWardRole(authority.designation)) {
    return _AuthorityPrimaryInfo(
      icon: Icons.confirmation_number_rounded,
      text: 'Ward: ${_nonEmptyOr(authority.ward, authority.jurisdiction)}',
    );
  }
  if (_isSarpanchRole(authority.designation)) {
    return _AuthorityPrimaryInfo(
      icon: Icons.terrain_rounded,
      text: 'Village: ${_nonEmptyOr(authority.mandal, authority.jurisdiction)}',
    );
  }

  return const _AuthorityPrimaryInfo(
    icon: Icons.account_balance_rounded,
    text: 'Government Officers',
  );
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
    if (provider.isSubmitting) {
      return;
    }

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
        if (provider.currentStep == 3 && !_detailsStepInitialized) {
          _detailsStepInitialized = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) {
              return;
            }
            final ReportIssueProvider freshProvider = context.read<ReportIssueProvider>();
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

        if (_locationController.text != provider.locationInput) {
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
            backgroundColor: _bg,
            appBar: AppBar(
              backgroundColor: _bg,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              leading: IconButton(
                onPressed: () {
                  if (provider.canGoBackStep) {
                    provider.previousStep();
                    return;
                  }
                  Navigator.of(context).maybePop();
                },
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
              ),
              title: const Text(
                'Issue Reporting',
                style: TextStyle(
                  color: _textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            body: SafeArea(
              top: false,
              child: Column(
                children: <Widget>[
                  _FlowProgressHeader(currentStep: provider.currentStep),
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
                    onSubmit: () => _submit(provider),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _FlowProgressHeader extends StatelessWidget {
  const _FlowProgressHeader({required this.currentStep});

  final int currentStep;

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
      margin: const EdgeInsets.fromLTRB(16, 6, 16, 2),
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF242424)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Step ${current + 1} of $total',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF9CA7B5),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                children: <Widget>[
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0, end: progress),
                      duration: const Duration(milliseconds: 240),
                      curve: Curves.easeInOut,
                      builder: (BuildContext context, double value, _) {
                        return Stack(
                          alignment: Alignment.center,
                          children: <Widget>[
                            Container(
                              width: 26,
                              height: 26,
                              decoration: const BoxDecoration(
                                color: Color(0xFF151515),
                                shape: BoxShape.circle,
                              ),
                            ),
                            CircularProgressIndicator(
                              value: value,
                              strokeWidth: 2.6,
                              backgroundColor: const Color(0xFF2E2E2E),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                _gold,
                              ),
                            ),
                            Text(
                              '$percent%',
                              style: GoogleFonts.inter(
                                color: _textPrimary,
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Complete',
                    style: GoogleFonts.inter(
                      color: Color(0xFF8C97A7),
                      fontSize: 9.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
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
        ? _green
        : active
        ? _gold
        : const Color(0xFF4A5261);
    final Color textColor = done
        ? const Color(0xFF8DDEAA)
        : active
        ? _gold
        : const Color(0xFFA3ADBB);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        AnimatedContainer(
          duration: const Duration(milliseconds: 230),
          curve: Curves.easeInOut,
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: done
                ? _green
                : active
                ? _gold
                : const Color(0xFF171D27),
            shape: BoxShape.circle,
            border: Border.all(color: border, width: 1),
            boxShadow: active
                ? <BoxShadow>[
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.14),
                      blurRadius: 6,
                      offset: const Offset(0, 1),
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
                      color: Colors.white,
                    )
                  : Text(
                      '${index + 1}',
                      key: ValueKey<String>('n-$index-$active'),
                      style: GoogleFonts.inter(
                        color: active ? Colors.white : textColor,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
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
            fontSize: 9,
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
              ? _green
              : active
              ? _gold
              : const Color(0xFF343434);
          return Stack(
            alignment: Alignment.centerLeft,
            children: <Widget>[
              Container(
                height: 1.5,
                decoration: BoxDecoration(
                  color: const Color(0xFF343434),
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
          borderRadius: BorderRadius.circular(20),
          color: const Color(0xFF111111),
          border: Border.all(color: const Color(0xFF242424)),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              decoration: BoxDecoration(
                color: const Color(0xFF0D1117),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF242424)),
              ),
              child: Hero(
                tag: 'welcome-reporting-hero',
                child: Center(
                  child: SvgPicture.string(
                    _welcomeHeroSvg,
                    height: 122,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Welcome to Citizen Issue Reporting',
              style: GoogleFonts.inter(
                color: _textPrimary,
                fontSize: 28,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Report civic issues with confidence through a secure and transparent official platform.',
              style: GoogleFonts.inter(
                color: const Color(0xFFA0A0A0),
                fontSize: 13,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            const _WelcomeInfoBlock(
              iconKey: 'quick',
              title: 'Quick',
              subtitle: 'Submit a structured report in a few guided steps.',
              showDivider: true,
            ),
            const _WelcomeInfoBlock(
              iconKey: 'official',
              title: 'Official',
              subtitle: 'Each issue is routed to the responsible authority.',
              showDivider: true,
            ),
            const _WelcomeInfoBlock(
              iconKey: 'transparent',
              title: 'Transparent',
              subtitle: 'Track progress with clear timeline updates.',
              showDivider: false,
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
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: showDivider
            ? const Border(bottom: BorderSide(color: Color(0xFF242424)))
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 22,
            height: 22,
            alignment: Alignment.center,
            child: SvgPicture.string(
              _welcomeRowIcon(iconKey),
              width: 14,
              height: 14,
              colorFilter: const ColorFilter.mode(_gold, BlendMode.srcIn),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: GoogleFonts.inter(
                    color: _textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    color: const Color(0xFFA0A0A0),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    height: 1.35,
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

  @override
  Widget build(BuildContext context) {
    final bool compact = MediaQuery.of(context).size.width < 380;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const SizedBox(height: 20),
        Text(
          'Select Issue Category',
          style: GoogleFonts.inter(
            color: _textPrimary,
            fontSize: compact ? 24 : 26,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.1,
            height: 1.18,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Choose the category that best matches your issue for faster department routing.',
          style: GoogleFonts.inter(
            color: const Color(0xFFA8A8A8),
            fontSize: 13,
            fontWeight: FontWeight.w500,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final int crossAxisCount = constraints.maxWidth >= 560 ? 4 : 3;
            const double gap = 10;
            final double itemWidth =
                (constraints.maxWidth - (gap * (crossAxisCount - 1))) /
                crossAxisCount;
            final double itemHeight = itemWidth * (compact ? 1.22 : 1.15);

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
                final bool selected = category.id == provider.selectedCategoryId;
                return _CategoryCard(
                  category: category,
                  description:
                      _categoryDescriptions[category.id] ??
                      'General civic services issue.',
                  selected: selected,
                  onTap: () => provider.selectCategory(category.id),
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

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.category,
    required this.description,
    required this.selected,
    required this.onTap,
  });

  final IssueCategory category;
  final String description;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: category.semanticLabel,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeInOut,
        scale: selected ? 1.0 : 0.98,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Ink(
            padding: const EdgeInsets.fromLTRB(10, 12, 10, 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: selected
                  ? const Color(0x0DF5B62D)
                  : const Color(0xFF111111),
              border: Border.all(
                color: selected ? _gold : const Color(0xFF262626),
                width: selected ? 1.2 : 1,
              ),
              boxShadow: selected
                  ? <BoxShadow>[
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.18),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: selected ? 1 : 0),
                  duration: const Duration(milliseconds: 240),
                  curve: Curves.easeInOut,
                  builder: (BuildContext context, double value, Widget? child) {
                    return Transform.scale(scale: 0.98 + (value * 0.02), child: child);
                  },
                  child: SvgPicture.asset(
                    category.iconAssetPath,
                    width: 28,
                    height: 28,
                    colorFilter: ColorFilter.mode(
                      selected ? _gold : const Color(0xFFA8A8A8),
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  textAlign: TextAlign.center,
                  category.title,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    color: const Color(0xFFA8A8A8),
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    height: 1.35,
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

class _TagAuthorityStage extends StatefulWidget {
  const _TagAuthorityStage({required this.provider});

  final ReportIssueProvider provider;

  @override
  State<_TagAuthorityStage> createState() => _TagAuthorityStageState();
}

class _TagAuthorityStageState extends State<_TagAuthorityStage> {
  late final FocusNode _searchFocusNode;

  @override
  void initState() {
    super.initState();
    _searchFocusNode = FocusNode()..addListener(_onFocusChanged);
  }

  @override
  void dispose() {
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

    final List<AuthorityProfile> roleMustInclude =
      provider.filteredPublicRepresentatives.where((AuthorityProfile authority) {
        final String bag =
          '${authority.name} ${authority.designation}'.toLowerCase();
        return bag.contains('hemachandra') ||
          bag.contains('mla') ||
          bag.contains('mlc') ||
          bag.contains('member of parliament') ||
          RegExp(r'(^|\W)mp(\W|$)').hasMatch(bag) ||
          bag.contains('sarpanch') ||
          bag.contains('councillor') ||
          bag.contains('councilor');
      }).toList(growable: false);

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
          padding: const EdgeInsets.fromLTRB(2, 2, 2, 0),
          child: Text(
            'Select Concerned Authority',
            style: GoogleFonts.inter(
              color: _textPrimary,
              fontSize: 27,
              fontWeight: FontWeight.w700,
              height: 1.14,
              letterSpacing: -0.2,
            ),
          ),
        ),
        const SizedBox(height: 14),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: const Color(0xFF171717),
            borderRadius: BorderRadius.circular(17),
            border: Border.all(
              color: focused ? const Color(0xFFF5B82E) : const Color(0xFF2A2A2A),
              width: 1.05,
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withValues(alpha: focused ? 0.24 : 0.16),
                blurRadius: focused ? 16 : 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Semantics(
            label: 'Search authorities',
            textField: true,
            child: TextField(
              focusNode: _searchFocusNode,
              onChanged: provider.updateAuthoritySearch,
              textInputAction: TextInputAction.search,
              style: GoogleFonts.inter(
                color: const Color(0xFFFFFFFF),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: 'Search MLA, MP, MLC, Councillor, Sarpanch...',
                hintStyle: GoogleFonts.inter(
                  color: const Color(0xFFA0A0A0),
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                ),
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(left: 2),
                  child: Icon(Icons.search_rounded, size: 20, color: Color(0xFFA0A0A0)),
                ),
                prefixIconConstraints: const BoxConstraints(minWidth: 42),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.fromLTRB(2, 15, 14, 15),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (provider.isLoadingAuthorities)
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 18),
              child: CircularProgressIndicator(color: _gold),
            ),
          )
        else if (noResults)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF141414),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF2B2B2B)),
            ),
            child: Text(
              'No result found. Try another keyword.',
              style: GoogleFonts.inter(
                color: const Color(0xFFA0A0A0),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          )
        else _AuthorityCardGrid(items: relevantAuthorities, provider: provider),
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
    if (items.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _stroke),
        ),
        child: const Text(
          'No authorities available for this section.',
          style: TextStyle(color: _textSecondary, fontSize: 12),
        ),
      );
    }

    return Column(
      children: List<Widget>.generate(items.length, (int index) {
        final AuthorityProfile authority = items[index];
        return _AuthorityCard(
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
        );
      }),
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
    final _AuthorityPrimaryInfo primaryInfo = _authorityPrimaryInfo(authority);

    return _HoverScaleCard(
      selected: selected,
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[Color(0xFF1E1E1E), Color(0xFF141414)],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? _gold : const Color(0xFF2F2F2F),
            width: selected ? 1.1 : 1,
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.34),
              blurRadius: 16,
              spreadRadius: 0.2,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 64,
                  height: 64,
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF6E5A2A),
                    ),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: _gold.withValues(alpha: 0.1),
                        blurRadius: 12,
                        spreadRadius: 0.2,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.network(
                      _authorityAvatarUrl(authority),
                      fit: BoxFit.cover,
                      errorBuilder: (_, error, stack) {
                        return Container(
                          color: const Color(0xFF2A2A2A),
                          alignment: Alignment.center,
                          child: Text(
                            authority.name.isEmpty
                                ? 'A'
                                : authority.name[0].toUpperCase(),
                            style: GoogleFonts.manrope(
                              color: _textPrimary,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(right: 36),
                        child: Text(
                          authority.name,
                          style: GoogleFonts.manrope(
                            color: _textPrimary,
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.1,
                            height: 1.15,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        authority.designation,
                        style: GoogleFonts.manrope(
                          color: _textSecondary,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _AuthorityLine(
                        icon: primaryInfo.icon,
                        text: primaryInfo.text,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onOpenProfile,
                  icon: const Icon(
                    Icons.chevron_right_rounded,
                    color: Color(0xFFD0B16E),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AuthorityLine extends StatelessWidget {
  const _AuthorityLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Icon(icon, size: 14, color: const Color(0xFFD7B874)),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.manrope(
              color: const Color(0xFFDCDCDC),
              fontSize: 12,
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
          ),
        ),
      ],
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
    final double scale = _hovered ? 1.005 : 1.0;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        scale: scale,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          transform: Matrix4.translationValues(
            0,
            _hovered ? -1 : 0,
            0,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: widget.onTap,
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
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: const BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
        border: Border(top: BorderSide(color: _stroke)),
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
              color: const Color(0xFF3A3A3A),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          Text(
            authority.name,
            style: const TextStyle(
              color: _textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${authority.designation} | ${authority.department}',
            style: const TextStyle(
              color: _textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          _ProfileStatLine(label: 'Jurisdiction', value: authority.jurisdiction),
          _ProfileStatLine(label: 'Constituency', value: authority.constituency),
          _ProfileStatLine(
            label: 'Mandal / Ward',
            value: '${authority.mandal} / ${authority.ward}',
          ),
          _ProfileStatLine(label: 'Department', value: authority.department),
          _ProfileStatLine(
            label: 'SLA / Workload',
            value: '${authority.responseSlaHours}h / ${authority.currentWorkload} open',
          ),
          _ProfileStatLine(
            label: 'Performance',
            value:
                '${authority.resolvedComplaints} resolved | ${authority.avgResolutionDays.toStringAsFixed(1)} days avg',
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
                    backgroundColor: _gold,
                    foregroundColor: Colors.black,
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

class _ProfileStatLine extends StatelessWidget {
  const _ProfileStatLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 128,
            child: Text(
              label,
              style: const TextStyle(
                color: _textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: _textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
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
          content: Text('Use keyboard voice dictation to capture speech input.'),
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
          'Issue Description',
          style: GoogleFonts.inter(
            color: _textPrimary,
            fontSize: 28,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
            height: 1.12,
          ),
        ),
        const SizedBox(height: 14),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          decoration: BoxDecoration(
            color: const Color(0xFF181818),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: hasError
                  ? _error
                  : (focused ? const Color(0xFFF5B82E) : const Color(0xFF2B2B2B)),
              width: focused ? 1.2 : 1,
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withValues(alpha: focused ? 0.24 : 0.14),
                blurRadius: focused ? 16 : 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Stack(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(bottom: 28),
                child: Semantics(
                  label: 'Issue description input',
                  textField: true,
                  child: TextField(
                    controller: _controller,
                    focusNode: _descriptionFocusNode,
                    onChanged: _provider.updateDescription,
                    maxLength: _maxLength,
                    minLines: 8,
                    maxLines: null,
                    style: GoogleFonts.inter(
                      color: _textPrimary,
                      fontSize: 15,
                      height: 1.45,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      hintText:
                          'Describe the issue in detail...\n\nExamples:\n• What happened?\n• When did it start?\n• How does it affect the public?',
                      hintStyle: GoogleFonts.inter(
                        color: const Color(0xFFA0A0A0),
                        fontSize: 14,
                        height: 1.45,
                        fontWeight: FontWeight.w500,
                      ),
                      border: InputBorder.none,
                      counterText: '',
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Text(
                  '$length/$_maxLength',
                  style: GoogleFonts.inter(
                    color: counterColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
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
        const SizedBox(height: 12),
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
                label: _provider.isGeneratingSuggestion ? 'Generating...' : 'AI Assist',
                loading: _provider.isGeneratingSuggestion,
                onTap: _provider.isGeneratingSuggestion ? null : _openAiAssistSheet,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          decoration: BoxDecoration(
            color: const Color(0xFF141414),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF2B2B2B)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const <Widget>[
              Row(
                children: <Widget>[
                  Icon(Icons.info_outline_rounded, color: _gold, size: 16),
                  SizedBox(width: 8),
                  Text(
                    'Writing Tips',
                    style: TextStyle(
                      color: _textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 9),
              _TipsBullet(text: 'Mention the exact issue.'),
              _TipsBullet(text: 'Include nearby landmarks if possible.'),
              _TipsBullet(text: 'Mention duration of the problem.'),
              _TipsBullet(text: 'Explain public impact.'),
              _TipsBullet(text: 'Add urgency if applicable.'),
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
    return AnimatedScale(
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOutCubic,
      scale: pulse ? 1.02 : 1,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: onTap,
          child: Ink(
            height: 46,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF181818),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: const Color(0xFF2B2B2B)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                if (loading)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: _gold,
                    ),
                  )
                else
                  Icon(icon, size: 16, color: _gold),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      color: _textPrimary,
                      fontSize: 12.5,
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
  const _TipsBullet({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Icon(Icons.circle, size: 5, color: Color(0xFFA0A0A0)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xFFA0A0A0),
                fontSize: 12,
                height: 1.35,
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
          'Supporting Evidence',
          style: GoogleFonts.inter(
            color: _textPrimary,
            fontSize: 28,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
            height: 1.12,
          ),
        ),
        const SizedBox(height: 12),
        const _EvidenceIntroCard(),
        const SizedBox(height: 14),
        Row(
          children: <Widget>[
            Expanded(
              child: _UploadMethodCard(
                title: 'Camera',
                icon: Icons.camera_alt_rounded,
                onTap: provider.isPickingMedia ? null : provider.addFromCamera,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _UploadMethodCard(
                title: 'Gallery',
                icon: Icons.collections_rounded,
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
                onTap: provider.isPickingMedia
                    ? null
                    : provider.addFromGalleryVideo,
              ),
            ),
          ],
        ),
        if (provider.isPickingMedia)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              decoration: BoxDecoration(
                color: const Color(0xFF141414),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF2B2B2B)),
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
                  LinearProgressIndicator(
                    minHeight: 4,
                    backgroundColor: Color(0xFF2A2A2A),
                    valueColor: AlwaysStoppedAnimation<Color>(_gold),
                  ),
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
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          decoration: BoxDecoration(
            color: const Color(0xFF141414),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF2B2B2B)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Uploaded Evidence',
                style: TextStyle(
                  color: _textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: mediaItems.isEmpty
                    ? const _EvidenceEmptyState(key: ValueKey<String>('empty-evidence'))
                    : LayoutBuilder(
                        key: const ValueKey<String>('media-grid'),
                        builder: (BuildContext context, BoxConstraints constraints) {
                          final int columns = constraints.maxWidth >= 760
                              ? 3
                              : (constraints.maxWidth >= 420 ? 2 : 1);

                          return GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: mediaItems.length,
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: columns,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              childAspectRatio: columns == 1 ? 2.75 : 1.05,
                            ),
                            itemBuilder: (BuildContext context, int idx) {
                              final PickedMedia item = mediaItems[idx];
                              return _MediaPreviewTile(
                                key: ValueKey<String>('media-$idx-${item.file.path}'),
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

class _EvidenceIntroCard extends StatelessWidget {
  const _EvidenceIntroCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2B2B2B)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(Icons.workspace_premium_rounded, size: 18, color: _gold),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Add Proof',
                  style: TextStyle(
                    color: _textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Clear photos or videos help authorities process your report faster.',
                  style: TextStyle(
                    color: Color(0xFFA0A0A0),
                    fontSize: 12,
                    height: 1.35,
                    fontWeight: FontWeight.w500,
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

class _UploadMethodCard extends StatefulWidget {
  const _UploadMethodCard({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final IconData icon;
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
            padding: const EdgeInsets.fromLTRB(8, 12, 8, 12),
            decoration: BoxDecoration(
              color: const Color(0xFF181818),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: _pressed ? _gold : const Color(0xFF2B2B2B),
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.16),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF141414),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF2B2B2B)),
                  ),
                  child: Icon(widget.icon, size: 20, color: _gold),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: _textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
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
      padding: const EdgeInsets.fromLTRB(14, 18, 14, 18),
      decoration: BoxDecoration(
        color: const Color(0xFF181818),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF2B2B2B)),
      ),
      child: const Column(
        children: <Widget>[
          Icon(
            Icons.photo_camera_back_rounded,
            color: Color(0xFF5B5B5B),
            size: 40,
          ),
          SizedBox(height: 8),
          Text(
            'No Evidence Added',
            style: TextStyle(
              color: _textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Upload photos or videos to help authorities verify your report faster.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFFA0A0A0),
              fontSize: 12,
              height: 1.35,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
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

class _MediaPreviewTile extends StatelessWidget {
  const _MediaPreviewTile({
    super.key,
    required this.item,
    required this.onDelete,
  });

  final PickedMedia item;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final bool isImage = item.type == PickedMediaType.image;
    final File file = File(item.file.path);

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
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
        decoration: BoxDecoration(
          color: const Color(0xFF181818),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF2B2B2B)),
        ),
        child: Row(
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 58,
                height: 58,
                child: isImage
                    ? Image.file(file, fit: BoxFit.cover)
                    : const ColoredBox(
                        color: Color(0xFF1F1F1F),
                        child: Icon(Icons.play_circle_fill_rounded, color: _gold),
                      ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    file.path.split('\\').last,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  FutureBuilder<int>(
                    future: file.length(),
                    builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
                      final int bytes = snapshot.data ?? 0;
                      final double kb = bytes / 1024;
                      return Text(
                        '${isImage ? 'Image' : 'Video'} • ${kb.toStringAsFixed(1)} KB',
                        style: const TextStyle(
                          color: Color(0xFFA0A0A0),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onDelete,
              icon: const Icon(
                Icons.delete_outline_rounded,
                color: _error,
                size: 20,
              ),
              tooltip: 'Delete media',
            ),
          ],
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

  static const LatLng _fallbackCenter = LatLng(13.6288, 79.4192);

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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
              child: const Text('Cancel', style: TextStyle(color: _textSecondary)),
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
    final LatLng markerPosition = hasCoordinates ? LatLng(lat, lng) : _fallbackCenter;
    final bool isFocused = _locationFocusNode.hasFocus;
    final String? locationFieldError = provider.locationFieldError;
    final bool hasLocationValidationHint = locationFieldError != null && !provider.isLocating;
    final String landmarkSuggestion = _landmarkSuggestion(provider.addressComponents);

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
        const Text(
          'Issue Location',
          style: TextStyle(
            color: _textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 12),
        const _LocationInfoCard(),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          height: 250,
          decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFF2B2B2B)),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.28),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: !_enableGoogleMaps
                ? const _LocationMapUnavailable()
                : provider.isLocating && !hasCoordinates
                ? const _LocationMapShimmer()
                : Stack(
                    children: <Widget>[
                      GoogleMap(
                        style: _darkMapStyle,
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
                      Positioned(
                        right: 12,
                        top: 12,
                        child: Column(
                          children: <Widget>[
                            _MapControlButton(
                              icon: Icons.add_rounded,
                              tooltip: 'Zoom In',
                              onTap: () => _mapController?.animateCamera(
                                CameraUpdate.zoomIn(),
                              ),
                            ),
                            const SizedBox(height: 8),
                            _MapControlButton(
                              icon: Icons.remove_rounded,
                              tooltip: 'Zoom Out',
                              onTap: () => _mapController?.animateCamera(
                                CameraUpdate.zoomOut(),
                              ),
                            ),
                            const SizedBox(height: 8),
                            _MapControlButton(
                              icon: Icons.navigation_rounded,
                              tooltip: 'Recenter',
                              onTap: () => _mapController?.animateCamera(
                                CameraUpdate.newLatLng(markerPosition),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        left: 12,
                        bottom: 12,
                        child: _MapControlButton(
                          icon: provider.isLocating
                              ? Icons.gps_fixed_rounded
                              : Icons.my_location_rounded,
                          tooltip: 'Current Location',
                          onTap: provider.isLocating ? null : provider.detectLocation,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 12),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isFocused ? _gold : const Color(0xFF2B2B2B),
            ),
            boxShadow: <BoxShadow>[
              if (isFocused)
                BoxShadow(
                  color: _gold.withValues(alpha: 0.12),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: TextField(
            controller: locationController,
            focusNode: _locationFocusNode,
            enabled: true,
            onChanged: provider.updateLocationInput,
            onSubmitted: provider.searchAndResolveLocation,
            style: const TextStyle(color: _textPrimary, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Search address, landmark, street or locality...',
              hintStyle: const TextStyle(color: Color(0xFFA0A0A0)),
              filled: true,
              fillColor: Colors.transparent,
              contentPadding: const EdgeInsets.fromLTRB(14, 16, 14, 16),
              border: InputBorder.none,
              prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFFA0A0A0)),
              suffixIcon: IconButton(
                onPressed: () => provider.searchAndResolveLocation(locationController.text),
                icon: const Icon(Icons.my_location_rounded, color: _gold),
                tooltip: 'Search Location',
              ),
            ),
          ),
        ),
        if (hasLocationValidationHint)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: _LocationHelperCard(
              icon: Icons.info_outline_rounded,
              message: locationFieldError,
              borderColor: _warning.withValues(alpha: 0.7),
              textColor: const Color(0xFFFFD180),
            ),
          ),
        const SizedBox(height: 12),
        Row(
          children: <Widget>[
            Expanded(
              child: ElevatedButton(
                onPressed: provider.isLocating ? null : provider.detectLocation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1C1C1C),
                  foregroundColor: _textPrimary,
                  disabledBackgroundColor: const Color(0xFF2A2A2A),
                  disabledForegroundColor: const Color(0xFF8E8E8E),
                  elevation: 2,
                  minimumSize: const Size.fromHeight(56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: Color(0xFF2B2B2B)),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    provider.isLocating
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: _gold,
                            ),
                          )
                        : const Icon(Icons.gps_fixed_rounded, color: _gold),
                    const SizedBox(width: 10),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          provider.isLocating ? 'Detecting Location' : 'Use Current Location',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 1),
                        const Text(
                          'Detect location automatically',
                          style: TextStyle(
                            color: Color(0xFFA0A0A0),
                            fontSize: 10.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (hasCoordinates) ...<Widget>[
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _openInMaps(lat: lat, lng: lng),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _textPrimary,
                    side: const BorderSide(color: _stroke),
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.open_in_new_rounded, color: _gold),
                  label: const Text('Open Maps'),
                ),
              ),
            ],
          ],
        ),
        if (provider.autoLocationText != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: _LocationDetectedBanner(locationText: provider.autoLocationText!),
          ),
        if (provider.hasResolvedLocation)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: _SelectedLocationCard(
              address: provider.effectiveLocation,
              components: provider.addressComponents,
              latitude: lat,
              longitude: lng,
              onEdit: () {
                _locationFocusNode.requestFocus();
                locationController.selection = TextSelection(
                  baseOffset: 0,
                  extentOffset: locationController.text.length,
                );
              },
              onRefresh: () {
                if (hasCoordinates) {
                  provider.reverseGeocodeForCoordinates(latitude: lat, longitude: lng);
                } else {
                  provider.detectLocation();
                }
              },
              onCopy: () {
                Clipboard.setData(
                  ClipboardData(text: provider.effectiveLocation),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Location copied'),
                    duration: Duration(milliseconds: 1200),
                  ),
                );
              },
              accuracyLabel: hasCoordinates ? 'Excellent' : 'Estimating',
              accuracyValue: hasCoordinates ? 'Coordinates locked' : 'Pending lock',
            ),
          ),
        if (landmarkSuggestion.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              decoration: BoxDecoration(
                color: _surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF2B2B2B)),
              ),
              child: Row(
                children: <Widget>[
                  const Icon(Icons.place_outlined, size: 16, color: _gold),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Nearby Landmark: $landmarkSuggestion',
                      style: const TextStyle(
                        color: Color(0xFFA0A0A0),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        if (provider.locationError != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: _LocationHelperCard(
              icon: Icons.warning_amber_rounded,
              message: provider.locationError!,
              borderColor: _error.withValues(alpha: 0.7),
              textColor: const Color(0xFFFFB3AB),
            ),
          ),
      ],
    );
  }

  String _landmarkSuggestion(Map<String, String> components) {
    final List<String> preferredKeys = <String>[
      'landmark',
      'neighbourhood',
      'subLocality',
      'locality',
      'area',
    ];
    for (final String key in preferredKeys) {
      for (final MapEntry<String, String> entry in components.entries) {
        if (entry.key.toLowerCase().contains(key) && entry.value.trim().isNotEmpty) {
          return entry.value;
        }
      }
    }
    return '';
  }
}

class _LocationMapShimmer extends StatefulWidget {
  const _LocationMapShimmer();

  @override
  State<_LocationMapShimmer> createState() => _LocationMapShimmerState();
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
              colors: const <Color>[
                Color(0xFF121212),
                Color(0xFF232323),
                Color(0xFF121212),
              ],
            ),
          ),
          child: const Center(
            child: Icon(Icons.location_searching_rounded, color: _gold, size: 34),
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
      color: const Color(0xFF121212),
      padding: const EdgeInsets.all(16),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(Icons.map_outlined, color: Color(0xFFA0A0A0), size: 34),
          SizedBox(height: 10),
          Text(
            'Map Preview Unavailable',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Location detection and manual address entry are fully available.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFFA0A0A0),
              fontSize: 12,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationInfoCard extends StatelessWidget {
  const _LocationInfoCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2B2B2B)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(Icons.location_on_outlined, size: 18, color: _gold),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Location Information',
                  style: TextStyle(
                    color: _textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Provide the exact location of the issue to help the concerned department identify and resolve it quickly.',
                  style: TextStyle(
                    color: Color(0xFFA0A0A0),
                    fontSize: 12,
                    height: 1.35,
                    fontWeight: FontWeight.w500,
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
        color: const Color(0xFF181818),
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF2B2B2B)),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.24),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(icon, color: _gold, size: 19),
          ),
        ),
      ),
    );
  }
}

class _LocationDetectedBanner extends StatelessWidget {
  const _LocationDetectedBanner({required this.locationText});

  final String locationText;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: const Color(0xFF173425),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2D6D4A)),
      ),
      child: Row(
        children: <Widget>[
          const Icon(Icons.check_circle_rounded, color: _green, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Detected: $locationText',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFFBFE7CD),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectedLocationCard extends StatelessWidget {
  const _SelectedLocationCard({
    required this.address,
    required this.components,
    required this.latitude,
    required this.longitude,
    required this.onEdit,
    required this.onRefresh,
    required this.onCopy,
    required this.accuracyLabel,
    required this.accuracyValue,
  });

  final String address;
  final Map<String, String> components;
  final double? latitude;
  final double? longitude;
  final VoidCallback onEdit;
  final VoidCallback onRefresh;
  final VoidCallback onCopy;
  final String accuracyLabel;
  final String accuracyValue;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      builder: (BuildContext context, double value, Widget? child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 8),
            child: child,
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        decoration: BoxDecoration(
          color: const Color(0xFF141414),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF2B2B2B)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                const Icon(Icons.location_on_rounded, size: 18, color: _gold),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Selected Location',
                    style: TextStyle(
                      color: _textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                _AccuracyChip(label: accuracyLabel, value: accuracyValue),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              address,
              style: const TextStyle(
                color: _textPrimary,
                fontSize: 13,
                height: 1.4,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (components.isNotEmpty) ...<Widget>[
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: components.entries
                    .take(5)
                    .map(
                      (MapEntry<String, String> entry) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF181818),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: const Color(0xFF2B2B2B)),
                        ),
                        child: Text(
                          '${entry.key}: ${entry.value}',
                          style: const TextStyle(
                            color: Color(0xFFA0A0A0),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    )
                    .toList(growable: false),
              ),
            ],
            if (latitude != null && longitude != null) ...<Widget>[
              const SizedBox(height: 8),
              Text(
                'Coordinates: ${latitude!.toStringAsFixed(6)}, ${longitude!.toStringAsFixed(6)}',
                style: const TextStyle(
                  color: Color(0xFFA0A0A0),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                _LocationActionMiniButton(
                  icon: Icons.edit_outlined,
                  label: 'Edit',
                  onTap: onEdit,
                ),
                _LocationActionMiniButton(
                  icon: Icons.refresh_rounded,
                  label: 'Refresh',
                  onTap: onRefresh,
                ),
                _LocationActionMiniButton(
                  icon: Icons.content_copy_rounded,
                  label: 'Copy',
                  onTap: onCopy,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LocationActionMiniButton extends StatelessWidget {
  const _LocationActionMiniButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: _textPrimary,
        side: const BorderSide(color: Color(0xFF2B2B2B)),
        backgroundColor: const Color(0xFF181818),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      icon: Icon(icon, size: 16, color: _gold),
      label: Text(
        label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _AccuracyChip extends StatelessWidget {
  const _AccuracyChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: _gold.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _gold.withValues(alpha: 0.34)),
      ),
      child: Column(
        children: <Widget>[
          Text(
            label,
            style: const TextStyle(
              color: _gold,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFFF8D98A),
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationHelperCard extends StatelessWidget {
  const _LocationHelperCard({
    required this.icon,
    required this.message,
    required this.borderColor,
    required this.textColor,
  });

  final IconData icon;
  final String message;
  final Color borderColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: const Color(0xFF181818),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, size: 15, color: textColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: textColor,
                fontSize: 12,
                height: 1.35,
                fontWeight: FontWeight.w600,
              ),
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
  bool _expandedDescription = false;

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
    final bool hasLongDescription = provider.description.length > 180;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          'Review Your Report',
          style: TextStyle(
            color: _textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 12),
        const _ReviewSummaryCard(),
        const SizedBox(height: 12),
        _GovReviewCard(
          icon: Icons.category_rounded,
          title: 'Category',
          onEdit: () => provider.goToStep(1),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              _ReviewChip(
                icon: Icons.label_rounded,
                label: selectedCategory?.title ?? 'Not selected',
              ),
            ],
          ),
        ),
        _GovReviewCard(
          icon: Icons.account_balance_rounded,
          title: 'Concerned Authority',
          onEdit: () => provider.goToStep(2),
          child: provider.selectedAuthorities.isEmpty
              ? const Text(
                  'No authority selected',
                  style: TextStyle(color: Color(0xFFA0A0A0), fontSize: 13),
                )
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: provider.selectedAuthorities
                      .map(
                        (AuthorityProfile item) => _ReviewChip(
                          icon: Icons.person_rounded,
                          label: '${item.name} • ${item.designation}',
                        ),
                      )
                      .toList(growable: false),
                ),
        ),
        _GovReviewCard(
          icon: Icons.description_rounded,
          title: 'Issue Details',
          onEdit: () => provider.goToStep(3),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              AnimatedCrossFade(
                duration: const Duration(milliseconds: 200),
                firstCurve: Curves.easeOutCubic,
                secondCurve: Curves.easeOutCubic,
                crossFadeState: _expandedDescription
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                firstChild: Text(
                  provider.description.isEmpty
                      ? 'No description provided'
                      : provider.description,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _textPrimary,
                    fontSize: 13,
                    height: 1.45,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                secondChild: Text(
                  provider.description.isEmpty
                      ? 'No description provided'
                      : provider.description,
                  style: const TextStyle(
                    color: _textPrimary,
                    fontSize: 13,
                    height: 1.45,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (hasLongDescription)
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _expandedDescription = !_expandedDescription;
                    });
                  },
                  icon: Icon(
                    _expandedDescription
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    size: 18,
                  ),
                  label: Text(_expandedDescription ? 'Show Less' : 'Show More'),
                  style: TextButton.styleFrom(
                    foregroundColor: _gold,
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                  ),
                ),
            ],
          ),
        ),
        _GovReviewCard(
          icon: Icons.photo_library_rounded,
          title: 'Evidence',
          onEdit: () => provider.goToStep(4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                hasEvidence
                    ? '$imageCount Photos • $videoCount Videos'
                    : 'No Evidence Uploaded',
                style: const TextStyle(
                  color: _textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (hasEvidence)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Row(
                    children: provider.mediaItems
                        .where((PickedMedia m) => m.type == PickedMediaType.image)
                        .take(3)
                        .map(
                          (PickedMedia item) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                width: 46,
                                height: 46,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF181818),
                                  border: Border.all(color: const Color(0xFF2B2B2B)),
                                ),
                                child: Image.file(
                                  File(item.file.path),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(growable: false),
                  ),
                ),
            ],
          ),
        ),
        _GovReviewCard(
          icon: Icons.location_on_rounded,
          title: 'Location',
          onEdit: () => provider.goToStep(5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                provider.effectiveLocation.isEmpty
                    ? 'Location missing'
                    : provider.effectiveLocation,
                style: const TextStyle(
                  color: _textPrimary,
                  fontSize: 13,
                  height: 1.4,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (provider.addressComponents.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: <Widget>[
                      if (_v(provider.addressComponents['landmark']) != null)
                        _ReviewChip(
                          icon: Icons.place_outlined,
                          label: _v(provider.addressComponents['landmark'])!,
                        ),
                      if (_v(provider.addressComponents['district']) != null)
                        _ReviewChip(
                          icon: Icons.apartment_rounded,
                          label: _v(provider.addressComponents['district'])!,
                        ),
                      if (_v(provider.addressComponents['state']) != null)
                        _ReviewChip(
                          icon: Icons.public_rounded,
                          label: _v(provider.addressComponents['state'])!,
                        ),
                      if (_v(provider.addressComponents['postalCode']) != null)
                        _ReviewChip(
                          icon: Icons.pin_drop_outlined,
                          label: 'PIN ${_v(provider.addressComponents['postalCode'])!}',
                        ),
                    ],
                  ),
                ),
              if (provider.detectedLatitude != null && provider.detectedLongitude != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Coordinates: ${provider.detectedLatitude!.toStringAsFixed(6)}, ${provider.detectedLongitude!.toStringAsFixed(6)}',
                    style: const TextStyle(
                      color: Color(0xFFA0A0A0),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (provider.detectedLatitude != null && provider.detectedLongitude != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _openInMaps(
                  lat: provider.detectedLatitude!,
                  lng: provider.detectedLongitude!,
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _textPrimary,
                  side: const BorderSide(color: _stroke),
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.map_rounded, color: _gold),
                label: const Text('Open Location In Google Maps'),
              ),
            ),
          ),
        _GovReviewCard(
          icon: Icons.schedule_rounded,
          title: 'Estimated Resolution',
          hideEdit: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Expected Completion',
                style: TextStyle(
                  color: Color(0xFFA0A0A0),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _estimateResolution(),
                style: const TextStyle(
                  color: _textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              _ResolutionRow(
                icon: Icons.account_balance_rounded,
                label: 'Department',
                value: _departmentByCategory(selectedCategory?.id),
              ),
              const SizedBox(height: 6),
              _ResolutionRow(
                icon: Icons.flag_rounded,
                label: 'Priority',
                value: _priorityByCategory(selectedCategory?.id),
              ),
            ],
          ),
        ),
        _GovReviewCard(
          icon: Icons.fact_check_rounded,
          title: 'Final Checklist',
          hideEdit: true,
          child: Column(
            children: <Widget>[
              _ChecklistRow(
                label: 'Category Selected',
                done: selectedCategory != null,
              ),
              _ChecklistRow(
                label: 'Authority Tagged',
                done: provider.selectedAuthorities.isNotEmpty,
              ),
              _ChecklistRow(
                label: 'Description Added',
                done: provider.description.trim().isNotEmpty,
              ),
              _ChecklistRow(
                label: 'Location Verified',
                done: provider.effectiveLocation.trim().isNotEmpty,
              ),
              _ChecklistRow(
                label: 'Evidence Attached (optional)',
                done: hasEvidence,
                optional: true,
              ),
            ],
          ),
        ),
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF141414),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF2B2B2B)),
          ),
          child: Material(
            color: Colors.transparent,
            child: CheckboxListTile(
              value: widget.reviewConfirmed,
              onChanged: (bool? value) {
                widget.onReviewConfirmationChanged(value ?? false);
              },
              dense: false,
              controlAffinity: ListTileControlAffinity.leading,
              activeColor: _gold,
              checkColor: Colors.black,
              side: const BorderSide(color: Color(0xFF3A3A3A)),
              title: const Text(
                'I confirm that the provided information is accurate to the best of my knowledge.',
                style: TextStyle(
                  color: _textPrimary,
                  fontSize: 12.5,
                  height: 1.35,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String? _v(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    return value.trim();
  }

  String _estimateResolution() {
    final DateTime eta = DateTime.now().add(const Duration(days: 3));
    const List<String> months = <String>[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[eta.month - 1]} ${eta.day}, ${eta.year}';
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
        return 'Normal';
    }
  }
}

class _ReviewSummaryCard extends StatelessWidget {
  const _ReviewSummaryCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2B2B2B)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(Icons.shield_rounded, size: 18, color: _gold),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Submission Summary',
                  style: TextStyle(
                    color: _textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Please review all information carefully before submitting your report. You can edit any section before final submission.',
                  style: TextStyle(
                    color: Color(0xFFA0A0A0),
                    fontSize: 12,
                    height: 1.35,
                    fontWeight: FontWeight.w500,
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

class _GovReviewCard extends StatelessWidget {
  const _GovReviewCard({
    required this.icon,
    required this.title,
    required this.child,
    this.onEdit,
    this.hideEdit = false,
  });

  final IconData icon;
  final String title;
  final Widget child;
  final VoidCallback? onEdit;
  final bool hideEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF2B2B2B)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(icon, size: 17, color: _gold),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: _textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (!hideEdit && onEdit != null)
                OutlinedButton.icon(
                  onPressed: onEdit,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _gold,
                    side: const BorderSide(color: Color(0xFF3B3220)),
                    minimumSize: const Size(0, 34),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.edit_outlined, size: 14),
                  label: const Text(
                    'Edit',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: Color(0xFF2B2B2B)),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _ReviewChip extends StatelessWidget {
  const _ReviewChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF181818),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFF3B3220)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 13, color: _gold),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: _textPrimary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ResolutionRow extends StatelessWidget {
  const _ResolutionRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Icon(icon, size: 15, color: _gold),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            color: Color(0xFFA0A0A0),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: _textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _ChecklistRow extends StatelessWidget {
  const _ChecklistRow({
    required this.label,
    required this.done,
    this.optional = false,
  });

  final String label;
  final bool done;
  final bool optional;

  @override
  Widget build(BuildContext context) {
    final Color color = done
        ? const Color(0xFF8DDEAA)
        : (optional ? const Color(0xFFA0A0A0) : const Color(0xFFFFB3AB));
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        children: <Widget>[
          Icon(
            done ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
            size: 16,
            color: done ? _green : const Color(0xFF666666),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomActionBar extends StatelessWidget {
  const _BottomActionBar({
    required this.provider,
    required this.reviewConfirmed,
    required this.onSubmit,
  });

  final ReportIssueProvider provider;
  final bool reviewConfirmed;
  final Future<void> Function() onSubmit;

  @override
  Widget build(BuildContext context) {
    final bool isStart = provider.currentStep == 0;
    final bool isSubmit = provider.isLastStep;
    final bool canProceed = provider.canProceedCurrentStep && (!isSubmit || reviewConfirmed);

    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        10,
        16,
        12 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF000000),
        border: const Border(top: BorderSide(color: Color(0xFF2B2B2B))),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 16,
            offset: const Offset(0, -3),
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
                      foregroundColor: _textPrimary,
                      side: const BorderSide(color: Color(0xFF2B2B2B)),
                      minimumSize: const Size.fromHeight(54),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text('Back'),
                  ),
                ),
              if (provider.currentStep > 0) const SizedBox(width: 10),
              Expanded(
                flex: isStart ? 1 : 2,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child: ElevatedButton(
                    key: ValueKey<bool>(canProceed),
                    onPressed: canProceed
                        ? () async {
                            FocusScope.of(context).unfocus();
                            if (isSubmit) {
                              await onSubmit();
                              return;
                            }
                            provider.nextStep();
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _gold,
                      foregroundColor: Colors.black,
                      disabledBackgroundColor: const Color(0xFF383028),
                      disabledForegroundColor: const Color(0xFF8E857A),
                      minimumSize: Size.fromHeight(isStart ? 56 : 56),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      elevation: 1.8,
                      shadowColor: Colors.black.withValues(alpha: 0.18),
                      surfaceTintColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: provider.isSubmitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.black,
                            ),
                          )
                        : Text(
                            isStart
                                ? 'Start Reporting'
                                : isSubmit
                                ? 'Submit Issue'
                                : 'Continue',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
          if (isSubmit && !reviewConfirmed)
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
    return Dialog(
      backgroundColor: _surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            AnimatedBuilder(
              animation: _controller,
              builder: (BuildContext context, Widget? child) {
                return Transform.rotate(
                  angle: _controller.value * 6.283185307,
                  child: child,
                );
              },
              child: const Icon(Icons.sync_rounded, color: _gold, size: 34),
            ),
            const SizedBox(height: 12),
            const Text(
              'Submitting your issue...',
              style: TextStyle(
                color: _textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Encrypting details, uploading evidence, and notifying the department.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: const LinearProgressIndicator(
                minHeight: 5,
                backgroundColor: Color(0xFF2D2D2D),
                valueColor: AlwaysStoppedAnimation<Color>(_green),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


