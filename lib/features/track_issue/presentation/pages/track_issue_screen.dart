import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../main.dart';
import '../../../../providers/user_provider.dart';
import '../../../report_issue/models/issue_category.dart';
import '../../../report_issue/models/submitted_issue.dart';
import '../../data/repositories/firebase_track_issue_repository.dart';
import '../../domain/entities/track_issue_models.dart';
import '../../providers/track_issue_provider.dart';

const Color _bg = Color(0xFF000000);
const Color _surface = Color(0xFF000000);
const Color _surfaceSoft = Color(0xFF000000);
const Color _surfaceRaised = Color(0xFF0D0D0D);
const Color _surfaceBorder = Color(0xFF2A2A2A);
const Color _primary = Color(0xFFF5B62D);
const Color _success = Color(0xFF3DDC84);
const Color _info = Color(0xFF5CC8FF);
const Color _danger = Color(0xFFFF7D7D);
const Color _textPrimary = Colors.white;
const Color _textSecondary = Color(0xFFB5B5B5);

const List<String> _fallbackLiveImages = <String>[
  'https://images.unsplash.com/photo-1581093458791-9f3c3900df4b?auto=format&fit=crop&w=1200&q=80',
  'https://images.unsplash.com/photo-1531834685032-c34bf0d84c77?auto=format&fit=crop&w=1200&q=80',
  'https://images.unsplash.com/photo-1599707367072-cd6ada2bc375?auto=format&fit=crop&w=1200&q=80',
  'https://images.unsplash.com/photo-1504307651254-35680f356dfd?auto=format&fit=crop&w=1200&q=80',
  'https://images.unsplash.com/photo-1473448912268-2022ce9509d8?auto=format&fit=crop&w=1200&q=80',
];

const List<String> _fallbackProfileImages = <String>[
  'https://i.pravatar.cc/300?img=12',
  'https://i.pravatar.cc/300?img=22',
  'https://i.pravatar.cc/300?img=28',
  'https://i.pravatar.cc/300?img=36',
  'https://i.pravatar.cc/300?img=47',
  'https://i.pravatar.cc/300?img=55',
];

enum _DashboardSection { overview, timeline }

class TrackIssueScreen extends StatefulWidget {
  const TrackIssueScreen({super.key, this.submission});

  final SubmittedIssue? submission;

  @override
  State<TrackIssueScreen> createState() => _TrackIssueScreenState();
}

class _TrackIssueScreenState extends State<TrackIssueScreen>
    with TickerProviderStateMixin {
  late final TrackIssueProvider _provider;
  late final AnimationController _entryController;
  final TextEditingController _issueIdController = TextEditingController();

  bool _initialized = false;
  _DashboardSection _activeSection = _DashboardSection.overview;

  @override
  void initState() {
    super.initState();
    _provider = TrackIssueProvider(repository: FirebaseTrackIssueRepository());

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    )..forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) {
      return;
    }

    final Object? args = ModalRoute.of(context)?.settings.arguments;
    String? routeIssueId;

    if (args is String) {
      routeIssueId = args;
    } else if (args is Map<String, dynamic>) {
      routeIssueId = args['issueId'] as String?;
    } else if (args is SubmittedIssue) {
      routeIssueId = args.issueId;
    }

    final String? currentUserId = context
        .read<UserProvider>()
        .firebaseUser
        ?.uid;

    _provider.initialize(
      seedSubmission: widget.submission,
      routeIssueId: routeIssueId,
      currentUserId: currentUserId,
    );
    _initialized = true;
  }

  @override
  void dispose() {
    _provider.dispose();
    _entryController.dispose();
    _issueIdController.dispose();
    super.dispose();
  }

  Future<void> _onBackPressed() async {
    final bool popped = await Navigator.of(context).maybePop();
    if (!popped && mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.home,
        (Route<dynamic> route) => false,
      );
    }
  }

  void _openLiveUpdates(String issueId) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => _LiveUpdatesPage(issueId: issueId),
      ),
    );
  }

  Future<void> _submitCitizenVerification(TrackIssueProvider provider) async {
    final _VerificationInput? input = await _showVerificationDialog(context);
    if (input == null) {
      return;
    }

    final bool ok = await provider.submitCitizenVerification(
      remarks: input.remarks,
      rating: input.rating,
    );

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            ok
                ? 'Verification submitted successfully.'
                : (provider.errorMessage ?? 'Verification failed.'),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData baseTheme = Theme.of(context);

    return ChangeNotifierProvider<TrackIssueProvider>.value(
      value: _provider,
      child: Consumer<TrackIssueProvider>(
        builder:
            (BuildContext context, TrackIssueProvider provider, Widget? child) {
              final TrackedIssue? issue = provider.issue;
              final String errorMessage =
                  provider.errorMessage ?? 'Unable to load issue status.';
              final bool canLoadByIssueId =
                  issue == null &&
                  errorMessage.toLowerCase().contains('issue id is missing');
              final String lowerError = errorMessage.toLowerCase();
              final String? currentUserId = context
                  .read<UserProvider>()
                  .firebaseUser
                  ?.uid;
              final bool showCategoryFallback =
                  issue == null &&
                  (lowerError.contains('issue id is missing') ||
                      lowerError.contains('no issues found for your account') ||
                      lowerError.contains('unable to find your latest issue') ||
                      lowerError.contains('issue not found for id'));

              return AnnotatedRegion<SystemUiOverlayStyle>(
                value: SystemUiOverlayStyle.light,
                child: Theme(
                  data: baseTheme.copyWith(
                    textTheme: GoogleFonts.plusJakartaSansTextTheme(
                      baseTheme.textTheme,
                    ),
                  ),
                  child: Scaffold(
                    backgroundColor: _bg,
                    appBar: AppBar(
                      backgroundColor: _bg,
                      elevation: 0,
                      scrolledUnderElevation: 0,
                      leading: IconButton(
                        onPressed: _onBackPressed,
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: _textPrimary,
                          size: 17,
                        ),
                      ),
                      title: const Text(
                        'Track Your Issue',
                        style: TextStyle(
                          color: _textPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      actions: <Widget>[
                        if (issue != null)
                          IconButton(
                            tooltip: 'Live Updates',
                            onPressed: () => _openLiveUpdates(issue.issueId),
                            icon: const Icon(
                              Icons.wifi_tethering_rounded,
                              color: _primary,
                              size: 20,
                            ),
                          ),
                        IconButton(
                          onPressed: provider.isRefreshing
                              ? null
                              : provider.refresh,
                          icon: provider.isRefreshing
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: _primary,
                                  ),
                                )
                              : const Icon(
                                  Icons.refresh_rounded,
                                  color: _textPrimary,
                                  size: 20,
                                ),
                        ),
                      ],
                    ),
                    body: RefreshIndicator(
                      onRefresh: provider.refresh,
                      color: _primary,
                      backgroundColor: _surface,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 240),
                        child: provider.isLoading && issue == null
                            ? const _LoadingState(
                                key: ValueKey<String>('loading'),
                              )
                            : showCategoryFallback
                            ? _CategoryWorkflowFallback(
                                key: const ValueKey<String>(
                                  'category-fallback',
                                ),
                                onSelectCategory: (String category) {
                                  provider.loadCategoryWorkflowPreview(
                                    category: category,
                                    userId: currentUserId,
                                  );
                                },
                                onTryLatestIssue: () {
                                  provider.initialize(
                                    currentUserId: currentUserId,
                                  );
                                },
                              )
                            : provider.hasError && issue == null
                            ? _ErrorState(
                                key: const ValueKey<String>('error'),
                                message: errorMessage,
                                onRetry: provider.refresh,
                                onHome: () {
                                  Navigator.of(context).pushNamedAndRemoveUntil(
                                    AppRoutes.home,
                                    (Route<dynamic> route) => false,
                                  );
                                },
                                showIssueIdInput: canLoadByIssueId,
                                issueIdController: _issueIdController,
                                onLoadIssueId: (String issueId) {
                                  provider.initialize(
                                    routeIssueId: issueId.trim(),
                                  );
                                },
                              )
                            : _DashboardBody(
                                key: const ValueKey<String>('content'),
                                issue: issue!,
                                provider: provider,
                                section: _activeSection,
                                entryController: _entryController,
                                onSectionChanged: (_DashboardSection next) {
                                  setState(() {
                                    _activeSection = next;
                                  });
                                },
                                onVerify: () =>
                                    _submitCitizenVerification(provider),
                                onOpenLiveUpdates: () =>
                                    _openLiveUpdates(issue.issueId),
                                onBackHome: () {
                                  Navigator.of(context).pushNamedAndRemoveUntil(
                                    AppRoutes.home,
                                    (Route<dynamic> route) => false,
                                  );
                                },
                              ),
                      ),
                    ),
                  ),
                ),
              );
            },
      ),
    );
  }
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody({
    super.key,
    required this.issue,
    required this.provider,
    required this.section,
    required this.entryController,
    required this.onSectionChanged,
    required this.onVerify,
    required this.onOpenLiveUpdates,
    required this.onBackHome,
  });

  final TrackedIssue issue;
  final TrackIssueProvider provider;
  final _DashboardSection section;
  final AnimationController entryController;
  final ValueChanged<_DashboardSection> onSectionChanged;
  final VoidCallback onVerify;
  final VoidCallback onOpenLiveUpdates;
  final VoidCallback onBackHome;

  @override
  Widget build(BuildContext context) {
    final Animation<double> fade = CurvedAnimation(
      parent: entryController,
      curve: Curves.easeOutCubic,
    );
    final Animation<Offset> slide = Tween<Offset>(
      begin: const Offset(0, 0.03),
      end: Offset.zero,
    ).animate(fade);

    return SlideTransition(
      position: slide,
      child: FadeTransition(
        opacity: fade,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: <Widget>[
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 18),
              sliver: SliverList(
                delegate: SliverChildListDelegate(<Widget>[
                  _HeroCard(issue: issue),
                  const SizedBox(height: 12),
                  _SectionSegmented(
                    current: section,
                    onChanged: onSectionChanged,
                  ),
                  const SizedBox(height: 12),
                  if (section == _DashboardSection.overview) ...<Widget>[
                    _KpiGrid(issue: issue),
                    const SizedBox(height: 12),
                    _TaggedAuthorityCard(issue: issue),
                    const SizedBox(height: 12),
                    _AssignedOfficerCard(issue: issue),
                    const SizedBox(height: 12),
                    _ActionRail(
                      issue: issue,
                      onOpenLiveUpdates: onOpenLiveUpdates,
                    ),
                    const SizedBox(height: 12),
                    _NarrativeCard(issue: issue),
                    const SizedBox(height: 12),
                    _EvidenceSection(issue: issue),
                    if (provider.canSubmitCitizenVerification) ...<Widget>[
                      const SizedBox(height: 12),
                      _VerificationCard(
                        isSubmitting: provider.isSubmittingVerification,
                        onSubmit: provider.isSubmittingVerification
                            ? null
                            : onVerify,
                      ),
                    ],
                  ] else ...<Widget>[_WorkflowTimelineCard(issue: issue)],
                  const SizedBox(height: 14),
                  _BottomActions(issue: issue, onBackHome: onBackHome),
                  const SizedBox(height: 26),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.issue});

  final TrackedIssue issue;

  @override
  Widget build(BuildContext context) {
    final Color statusColor = _statusColor(issue.currentStatus);
    final double progress = _managerProgress(issue);

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: _surfaceRaised,
        border: Border.all(color: _surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Text(
                  _issueTitle(issue),
                  style: const TextStyle(
                    color: _textPrimary,
                    fontSize: 18,
                    height: 1.2,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              _StatusPill(
                icon: Icons.flag_circle_rounded,
                label: issue.currentStatus.title,
                color: statusColor,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              _ContextBadge(
                icon: Icons.calendar_today_rounded,
                label: 'Expected ${_formatDate(issue.expectedResolutionAt)}',
              ),
              _ContextBadge(
                icon: Icons.account_balance_rounded,
                label: _safeText(issue.department),
              ),
              _ContextBadge(icon: Icons.tag_rounded, label: issue.issueId),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 7,
              backgroundColor: const Color(0xFF1F1F1F),
              valueColor: const AlwaysStoppedAnimation<Color>(_primary),
            ),
          ),
          const SizedBox(height: 7),
          Row(
            children: <Widget>[
              Text(
                '${(progress * 100).round()}% completion',
                style: const TextStyle(
                  color: _textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                'Public Tracking',
                style: const TextStyle(
                  color: _textSecondary,
                  fontSize: 10.8,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionSegmented extends StatelessWidget {
  const _SectionSegmented({required this.current, required this.onChanged});

  final _DashboardSection current;
  final ValueChanged<_DashboardSection> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _surfaceBorder),
      ),
      child: Row(
        children: <Widget>[
          _SegmentButton(
            label: 'Overview',
            selected: current == _DashboardSection.overview,
            onTap: () => onChanged(_DashboardSection.overview),
          ),
          const SizedBox(width: 6),
          _SegmentButton(
            label: 'Workflow',
            selected: current == _DashboardSection.timeline,
            onTap: () => onChanged(_DashboardSection.timeline),
          ),
        ],
      ),
    );
  }
}

class _SegmentButton extends StatelessWidget {
  const _SegmentButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? _primary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selected ? Colors.black : _textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _KpiGrid extends StatelessWidget {
  const _KpiGrid({required this.issue});

  final TrackedIssue issue;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          'Quick Information',
          style: TextStyle(
            color: _textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 4,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            mainAxisExtent: 106,
          ),
          itemBuilder: (BuildContext context, int index) {
            switch (index) {
              case 0:
                return _InfoTile(
                  icon: Icons.calendar_today_rounded,
                  title: 'Submitted',
                  value: _formatDate(issue.createdAt),
                );
              case 1:
                return _InfoTile(
                  icon: Icons.account_balance_rounded,
                  title: 'Department',
                  value: _safeText(issue.department),
                );
              case 2:
                return _InfoTile(
                  icon: Icons.badge_rounded,
                  title: 'Officer',
                  value: _safeText(issue.assignedOfficer),
                );
              default:
                return _InfoTile(
                  icon: Icons.flag_circle_rounded,
                  title: 'Expected Resolution',
                  value: _formatDate(issue.expectedResolutionAt),
                );
            }
          },
        ),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
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
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFF121212),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _surfaceBorder),
            ),
            child: Icon(icon, color: _primary, size: 16),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              color: _textSecondary,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _textPrimary,
              fontSize: 15,
              height: 1.2,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _AssignedOfficerCard extends StatelessWidget {
  const _AssignedOfficerCard({required this.issue});

  final TrackedIssue issue;

  @override
  Widget build(BuildContext context) {
    final String? photoUrl = (issue.officerAvatarUrl ?? '').trim().isEmpty
        ? null
        : issue.officerAvatarUrl!.trim();
    final String? officerPhone = _officerPhone(issue);

    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const _CardHeader(
            title: 'Assigned Officer',
            badgeLabel: 'Government Officer',
            badgeIcon: Icons.verified_user_rounded,
            badgeTone: _info,
          ),
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              _ProfileAvatar(
                imageUrl: photoUrl,
                displayName: _safeText(issue.assignedOfficer),
                radius: 30,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      _safeText(issue.assignedOfficer),
                      style: const TextStyle(
                        color: _textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _safeText(issue.assignedOfficerDesignation),
                      style: const TextStyle(
                        color: _textSecondary,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  _AuthorityIconAction(
                    icon: Icons.person_outline_rounded,
                    tooltip: 'Profile',
                    onTap: photoUrl == null
                        ? null
                        : () => _openEvidencePreview(context, photoUrl),
                  ),
                  const SizedBox(width: 6),
                  _AuthorityIconAction(
                    icon: Icons.call_outlined,
                    tooltip: 'Call',
                    onTap: officerPhone == null
                        ? null
                        : () => _launchPhone(officerPhone),
                  ),
                  const SizedBox(width: 6),
                  _AuthorityIconAction(
                    icon: Icons.message_outlined,
                    tooltip: 'Message',
                    onTap: officerPhone == null
                        ? null
                        : () => _launchSms(officerPhone),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          _DataLine(label: 'Name', value: _safeText(issue.assignedOfficer)),
          _DataLine(
            label: 'Designation',
            value: _safeText(issue.assignedOfficerDesignation),
          ),
          _DataLine(label: 'Department', value: _safeText(issue.department)),
          _DataLine(
            label: 'Employee ID',
            value: _safeText(issue.assignedOfficerEmployeeId),
          ),
          _DataLine(
            label: 'Phone',
            value: _safeText(issue.assignedOfficerPhone),
          ),
          _DataLine(
            label: 'Email',
            value: _safeText(issue.assignedOfficerEmail),
          ),
        ],
      ),
    );
  }
}

class _TaggedAuthorityCard extends StatelessWidget {
  const _TaggedAuthorityCard({required this.issue});

  final TrackedIssue issue;

  @override
  Widget build(BuildContext context) {
    final String? photoUrl = _taggedAuthorityPhoto(issue);
    final String? authorityPhone = _taggedAuthorityPhone(issue);

    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const _CardHeader(
            title: 'Tagged Authority',
            badgeLabel: 'Official Authority',
            badgeIcon: Icons.account_balance_rounded,
            badgeTone: _primary,
          ),
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              _ProfileAvatar(
                imageUrl: photoUrl,
                displayName: _safeText(issue.taggedAuthorityName),
                radius: 30,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      _safeText(issue.taggedAuthorityName),
                      style: const TextStyle(
                        color: _textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _safeText(issue.taggedAuthorityDesignation),
                      style: const TextStyle(
                        color: _textSecondary,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  _AuthorityIconAction(
                    icon: Icons.person_outline_rounded,
                    tooltip: 'Profile',
                    onTap: photoUrl == null
                        ? null
                        : () => _openEvidencePreview(context, photoUrl),
                  ),
                  const SizedBox(width: 6),
                  _AuthorityIconAction(
                    icon: Icons.call_outlined,
                    tooltip: 'Call',
                    onTap: authorityPhone == null
                        ? null
                        : () => _launchPhone(authorityPhone),
                  ),
                  const SizedBox(width: 6),
                  _AuthorityIconAction(
                    icon: Icons.message_outlined,
                    tooltip: 'Message',
                    onTap: authorityPhone == null
                        ? null
                        : () => _launchSms(authorityPhone),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          _DataLine(label: 'Name', value: _safeText(issue.taggedAuthorityName)),
          _DataLine(
            label: 'Designation',
            value: _safeText(issue.taggedAuthorityDesignation),
          ),
          _DataLine(
            label: 'Department',
            value: _safeText(issue.taggedAuthorityDepartment),
          ),
          _DataLine(label: 'Area', value: _safeText(issue.taggedAuthorityArea)),
        ],
      ),
    );
  }
}

class _DataLine extends StatelessWidget {
  const _DataLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 88,
            child: Text(
              label,
              style: const TextStyle(
                color: _textSecondary,
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: _textPrimary,
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthorityIconAction extends StatelessWidget {
  const _AuthorityIconAction({
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
        color: const Color(0xFF101010),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: 34,
            height: 34,
            child: Icon(
              icon,
              color: onTap == null ? const Color(0xFF666666) : _primary,
              size: 16,
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionRail extends StatelessWidget {
  const _ActionRail({required this.issue, required this.onOpenLiveUpdates});

  final TrackedIssue issue;
  final VoidCallback onOpenLiveUpdates;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          'Quick Actions',
          style: TextStyle(
            color: _textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: <Widget>[
            _ActionButton(
              icon: Icons.wifi_tethering_rounded,
              label: 'View Live Updates',
              onTap: onOpenLiveUpdates,
              wide: true,
            ),
            _ActionButton(
              icon: Icons.map_outlined,
              label: 'Open Map',
              onTap: (issue.latitude == null || issue.longitude == null)
                  ? null
                  : () => _openIssueMap(issue),
            ),
            _ActionButton(
              icon: Icons.call_outlined,
              label: 'Call Officer',
              onTap: _hasPhone(issue.assignedOfficerPhone)
                  ? () => _launchPhone(issue.assignedOfficerPhone)
                  : null,
            ),
            _ActionButton(
              icon: Icons.sms_outlined,
              label: 'Send SMS',
              onTap: _hasPhone(issue.assignedOfficerPhone)
                  ? () => _launchSms(issue.assignedOfficerPhone)
                  : null,
            ),
          ],
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.wide = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final double width = wide
        ? MediaQuery.sizeOf(context).width - 28
        : (MediaQuery.sizeOf(context).width - 44) / 3;

    return Material(
      color: _surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: width,
          height: 46,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _surfaceBorder),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                icon,
                color: onTap == null ? const Color(0xFF666666) : _primary,
                size: 16,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: onTap == null
                        ? const Color(0xFF666666)
                        : _textPrimary,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
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

class _NarrativeCard extends StatelessWidget {
  const _NarrativeCard({required this.issue});

  final TrackedIssue issue;

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Issue Details',
            style: TextStyle(
              color: _textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _issueTitle(issue),
            style: const TextStyle(
              color: _textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _safeText(issue.address),
            style: const TextStyle(
              color: _textSecondary,
              fontSize: 12,
              height: 1.4,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Container(height: 1, color: _surfaceBorder),
          const SizedBox(height: 10),
          _DataLine(label: 'Citizen Name', value: _safeText(issue.createdBy)),
          const _DataLine(label: 'Citizen Role', value: 'Public User'),
          _DataLine(
            label: 'Officer Name',
            value: _safeText(issue.assignedOfficer),
          ),
          _DataLine(
            label: 'Officer Designation',
            value: _safeText(issue.assignedOfficerDesignation),
          ),
        ],
      ),
    );
  }
}

class _EvidenceSection extends StatelessWidget {
  const _EvidenceSection({required this.issue});

  final TrackedIssue issue;

  @override
  Widget build(BuildContext context) {
    final List<String> urls = issue.imageUrls
        .map((String value) => value.trim())
        .where((String value) => value.isNotEmpty)
        .toList(growable: false);

    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Evidence',
            style: TextStyle(
              color: _textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          if (urls.isEmpty)
            const Text(
              'No evidence uploaded by user.',
              style: TextStyle(
                color: _textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: urls.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 1,
              ),
              itemBuilder: (BuildContext context, int index) {
                final String url = urls[index];
                return Material(
                  color: _surface,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    onTap: () => _openEvidencePreview(context, url),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _surfaceBorder),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(11),
                        child: Container(
                          color: Colors.black,
                          child: Image.network(
                            url,
                            fit: BoxFit.contain,
                            errorBuilder:
                                (
                                  BuildContext context,
                                  Object error,
                                  StackTrace? stackTrace,
                                ) {
                                  return const Center(
                                    child: Icon(
                                      Icons.broken_image_outlined,
                                      color: _textSecondary,
                                    ),
                                  );
                                },
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _VerificationCard extends StatelessWidget {
  const _VerificationCard({required this.isSubmitting, required this.onSubmit});

  final bool isSubmitting;
  final VoidCallback? onSubmit;

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Citizen Verification',
            style: TextStyle(
              color: _textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Work is marked completed. Verify quality and submit your rating.',
            style: TextStyle(
              color: _textSecondary,
              fontSize: 12,
              height: 1.4,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onSubmit,
              icon: isSubmitting
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.black,
                      ),
                    )
                  : const Icon(Icons.verified_rounded, size: 16),
              label: Text(
                isSubmitting ? 'Submitting...' : 'Submit Verification',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                foregroundColor: Colors.black,
                minimumSize: const Size.fromHeight(44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                textStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkflowTimelineCard extends StatelessWidget {
  const _WorkflowTimelineCard({required this.issue});

  final TrackedIssue issue;

  @override
  Widget build(BuildContext context) {
    final int currentIndex = issue.currentStatusIndex;
    final Map<IssueWorkflowStatus, IssueTimelineEvent> eventMap =
        _eventByStatus(issue.timeline);

    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Workflow Timeline',
            style: TextStyle(
              color: _textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          for (int i = 0; i < workflowOrder.length; i++)
            _WorkflowStepRow(
              status: workflowOrder[i],
              event: eventMap[workflowOrder[i]],
              fallbackDepartment: _safeText(issue.department),
              fallbackOfficer: _safeText(issue.assignedOfficer),
              state: i < currentIndex
                  ? _WorkflowVisualState.completed
                  : i == currentIndex
                  ? _WorkflowVisualState.active
                  : _WorkflowVisualState.pending,
              drawConnector: i != workflowOrder.length - 1,
            ),
        ],
      ),
    );
  }
}

enum _WorkflowVisualState { completed, active, pending }

class _WorkflowStepRow extends StatelessWidget {
  const _WorkflowStepRow({
    required this.status,
    required this.event,
    required this.fallbackDepartment,
    required this.fallbackOfficer,
    required this.state,
    required this.drawConnector,
  });

  final IssueWorkflowStatus status;
  final IssueTimelineEvent? event;
  final String fallbackDepartment;
  final String fallbackOfficer;
  final _WorkflowVisualState state;
  final bool drawConnector;

  @override
  Widget build(BuildContext context) {
    final Color dotColor = state == _WorkflowVisualState.active
        ? _primary
        : const Color(0xFF575757);
    final String timeLabel = event == null
        ? 'Awaiting update'
        : _formatDateTime(event!.timestamp);
    final String remarks = _safeText(event?.remarks);
    final String ownerDepartment = _safeText(
      event?.department ?? fallbackDepartment,
    );
    final String ownerOfficer = _safeText(
      event?.officerName ?? fallbackOfficer,
    );
    final String slaLabel = _stageSlaBadge(status);
    final Color slaColor = _stageSlaColor(state);
    final String stateLabel = _workflowStateLabel(state);
    final Color stateColor = _workflowStateColor(state);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Column(
          children: <Widget>[
            if (state == _WorkflowVisualState.completed)
              Container(
                width: 16,
                height: 16,
                decoration: const BoxDecoration(
                  color: _success,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.black,
                  size: 12,
                ),
              )
            else
              Container(
                width: 13,
                height: 13,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                ),
              ),
            if (drawConnector)
              Container(
                width: 2,
                height: 52,
                color: state == _WorkflowVisualState.completed
                    ? _success
                    : const Color(0xFF303030),
              ),
          ],
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.fromLTRB(10, 9, 10, 9),
            decoration: BoxDecoration(
              color: _surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _surfaceBorder),
            ),
            child: Theme(
              data: Theme.of(context).copyWith(
                dividerColor: Colors.transparent,
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
              ),
              child: ExpansionTile(
                tilePadding: EdgeInsets.zero,
                childrenPadding: EdgeInsets.zero,
                initiallyExpanded: state == _WorkflowVisualState.active,
                iconColor: _textSecondary,
                collapsedIconColor: _textSecondary,
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            status.title,
                            style: const TextStyle(
                              color: _textPrimary,
                              fontSize: 12.8,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          alignment: WrapAlignment.end,
                          children: <Widget>[
                            _MicroBadge(
                              label: stateLabel,
                              color: stateColor,
                              icon: state == _WorkflowVisualState.completed
                                  ? Icons.check_circle_rounded
                                  : state == _WorkflowVisualState.active
                                  ? Icons.autorenew_rounded
                                  : Icons.schedule_rounded,
                            ),
                            _MicroBadge(
                              label: slaLabel,
                              color: slaColor,
                              icon: Icons.timer_outlined,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: <Widget>[
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF111111),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: _surfaceBorder),
                            ),
                            child: Text(
                              ownerDepartment,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: _textPrimary,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          timeLabel,
                          style: const TextStyle(
                            color: _textSecondary,
                            fontSize: 10.8,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                children: <Widget>[
                  const SizedBox(height: 6),
                  Container(height: 1, color: _surfaceBorder),
                  const SizedBox(height: 8),
                  _OfficialNoteLine(label: 'Latest Note', value: remarks),
                  _OfficialNoteLine(
                    label: 'Updated By',
                    value: _safeText(event?.updatedBy),
                  ),
                  _OfficialNoteLine(
                    label: 'Assigned Officer',
                    value: ownerOfficer,
                  ),
                  _OfficialNoteLine(
                    label: 'Owner Department',
                    value: ownerDepartment,
                  ),
                  _OfficialNoteLine(label: 'Updated At', value: timeLabel),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _OfficialNoteLine extends StatelessWidget {
  const _OfficialNoteLine({required this.label, required this.value});

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
            width: 104,
            child: Text(
              label,
              style: const TextStyle(
                color: _textSecondary,
                fontSize: 10.8,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: _textPrimary,
                fontSize: 11.6,
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

class _BottomActions extends StatelessWidget {
  const _BottomActions({required this.issue, required this.onBackHome});

  final TrackedIssue issue;
  final VoidCallback onBackHome;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _shareIssueDetails(context, issue),
            icon: const Icon(Icons.share_rounded, size: 16),
            label: const Text('Share Details'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(44),
              backgroundColor: _primary,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              textStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: <Widget>[
            Expanded(
              child: OutlinedButton(
                onPressed: onBackHome,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(44),
                  side: const BorderSide(color: _surfaceBorder),
                  foregroundColor: _textPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Return to Home',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  final String text =
                      'Issue ID: ${issue.issueId}\nStatus: ${issue.currentStatus.title}\nDepartment: ${_safeText(issue.department)}\nExpected Resolution: ${_formatDate(issue.expectedResolutionAt)}';
                  Clipboard.setData(ClipboardData(text: text));
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      const SnackBar(content: Text('Tracking details copied')),
                    );
                },
                icon: const Icon(Icons.copy_rounded, size: 16),
                label: const Text('Copy Details'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(44),
                  backgroundColor: const Color(0xFF232323),
                  foregroundColor: _textPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _CardShell extends StatelessWidget {
  const _CardShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        color: _surfaceRaised,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _surfaceBorder),
      ),
      child: child,
    );
  }
}

class _CardHeader extends StatelessWidget {
  const _CardHeader({
    required this.title,
    required this.badgeLabel,
    required this.badgeIcon,
    required this.badgeTone,
  });

  final String title;
  final String badgeLabel;
  final IconData badgeIcon;
  final Color badgeTone;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: _textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: 8),
        _MicroBadge(label: badgeLabel, color: badgeTone),
      ],
    );
  }
}

class _ContextBadge extends StatelessWidget {
  const _ContextBadge({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF121212),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _surfaceBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 12, color: _textSecondary),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: _textPrimary,
              fontSize: 10.8,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _MicroBadge extends StatelessWidget {
  const _MicroBadge({required this.label, required this.color, this.icon});

  final String label;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 170),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF121212),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _surfaceBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: _textPrimary,
                fontSize: 10.2,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({this.icon, required this.label, required this.color});

  final IconData? icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 190),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFF121212),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _surfaceBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: _textPrimary,
                fontSize: 10.8,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: const <Widget>[
        SizedBox(height: 180),
        Center(child: CircularProgressIndicator(color: _primary)),
        SizedBox(height: 12),
        Center(
          child: Text(
            'Loading issue tracking...',
            style: TextStyle(
              color: _textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({
    super.key,
    required this.message,
    required this.onRetry,
    required this.onHome,
    required this.showIssueIdInput,
    required this.issueIdController,
    required this.onLoadIssueId,
  });

  final String message;
  final Future<void> Function() onRetry;
  final VoidCallback onHome;
  final bool showIssueIdInput;
  final TextEditingController issueIdController;
  final ValueChanged<String> onLoadIssueId;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 120, 16, 20),
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _surfaceBorder),
          ),
          child: Column(
            children: <Widget>[
              const Icon(Icons.error_outline_rounded, color: _danger, size: 32),
              const SizedBox(height: 8),
              const Text(
                'Unable to load tracking',
                style: TextStyle(
                  color: _textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: _textSecondary,
                  fontSize: 12,
                  height: 1.4,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (showIssueIdInput) ...<Widget>[
                const SizedBox(height: 12),
                TextField(
                  controller: issueIdController,
                  textInputAction: TextInputAction.done,
                  style: const TextStyle(color: _textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Enter issue ID to view tracking',
                    hintStyle: const TextStyle(color: _textSecondary),
                    filled: true,
                    fillColor: _surfaceRaised,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: _surfaceBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: _primary),
                    ),
                  ),
                  onSubmitted: onLoadIssueId,
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => onLoadIssueId(issueIdController.text),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _surfaceRaised,
                      foregroundColor: _textPrimary,
                    ),
                    child: const Text('Load Issue'),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: <Widget>[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onHome,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: _surfaceBorder),
                        foregroundColor: _textPrimary,
                      ),
                      child: const Text('Return Home'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onRetry,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primary,
                        foregroundColor: Colors.black,
                      ),
                      child: const Text('Retry'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _VerificationInput {
  const _VerificationInput({required this.rating, required this.remarks});

  final int rating;
  final String remarks;
}

class _CategoryWorkflowFallback extends StatelessWidget {
  const _CategoryWorkflowFallback({
    super.key,
    required this.onSelectCategory,
    required this.onTryLatestIssue,
  });

  final ValueChanged<String> onSelectCategory;
  final VoidCallback onTryLatestIssue;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _surfaceBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Choose Category Workflow',
                style: TextStyle(
                  color: _textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'No issue ID was available. Select a category to view the exact workflow stages.',
                style: TextStyle(
                  color: _textSecondary,
                  fontSize: 12,
                  height: 1.35,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onTryLatestIssue,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: _surfaceBorder),
                    foregroundColor: _textPrimary,
                  ),
                  icon: const Icon(Icons.history_rounded, size: 18),
                  label: const Text('Try My Latest Issue'),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: IssueCategoryCatalog.all
                    .map(
                      (IssueCategory category) => ActionChip(
                        backgroundColor: _surfaceRaised,
                        side: const BorderSide(color: _surfaceBorder),
                        label: Text(
                          category.title,
                          style: const TextStyle(
                            color: _textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                        onPressed: () => onSelectCategory(category.title),
                      ),
                    )
                    .toList(growable: false),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

Future<_VerificationInput?> _showVerificationDialog(
  BuildContext context,
) async {
  int selectedRating = 4;
  final TextEditingController remarksController = TextEditingController();

  final _VerificationInput? result = await showDialog<_VerificationInput>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: _surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text(
          'Submit Verification',
          style: TextStyle(
            color: _textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        content: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Rate the resolution quality',
                  style: TextStyle(
                    color: _textSecondary,
                    fontSize: 11.8,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: List<Widget>.generate(5, (int index) {
                    final int value = index + 1;
                    final bool active = value <= selectedRating;
                    return IconButton(
                      onPressed: () {
                        setState(() {
                          selectedRating = value;
                        });
                      },
                      icon: Icon(
                        active ? Icons.star_rounded : Icons.star_border_rounded,
                        color: active ? _primary : _textSecondary,
                        size: 20,
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: remarksController,
                  maxLines: 3,
                  style: const TextStyle(color: _textPrimary, fontSize: 12),
                  decoration: InputDecoration(
                    hintText: 'Add remarks (optional)',
                    hintStyle: const TextStyle(
                      color: _textSecondary,
                      fontSize: 12,
                    ),
                    filled: true,
                    fillColor: _surfaceSoft,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: _surfaceBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: _surfaceBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: _primary),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: _textSecondary, fontSize: 12),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(
                _VerificationInput(
                  rating: selectedRating,
                  remarks: remarksController.text.trim(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _primary,
              foregroundColor: Colors.black,
            ),
            child: const Text(
              'Submit',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      );
    },
  );

  remarksController.dispose();
  return result;
}

class _LiveUpdatesPage extends StatefulWidget {
  const _LiveUpdatesPage({required this.issueId});

  final String issueId;

  @override
  State<_LiveUpdatesPage> createState() => _LiveUpdatesPageState();
}

class _LiveUpdatesPageState extends State<_LiveUpdatesPage> {
  late final FirebaseTrackIssueRepository _repository;
  bool _isRealtimeEnabled = false;

  @override
  void initState() {
    super.initState();
    _repository = FirebaseTrackIssueRepository();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Live Updates',
          style: TextStyle(
            color: _textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: StreamBuilder<TrackedIssue?>(
        stream: _repository.watchIssue(widget.issueId),
        builder: (BuildContext context, AsyncSnapshot<TrackedIssue?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: _primary),
            );
          }

          final TrackedIssue? issue = snapshot.data;
          if (issue == null) {
            return const Center(
              child: Text(
                'No live updates available.',
                style: TextStyle(
                  color: _textSecondary,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }

          final List<IssueTimelineEvent> events =
              List<IssueTimelineEvent>.from(issue.timeline)..sort(
                (IssueTimelineEvent a, IssueTimelineEvent b) =>
                    b.timestamp.compareTo(a.timestamp),
              );
          final List<IssueTimelineEvent> uniqueEvents = _deduplicateLiveEvents(
            events,
          );
          final List<DateTime> displayTimestamps = _buildLiveDisplayTimestamps(
            uniqueEvents,
          );

          return Column(
            children: <Widget>[
              const Padding(
                padding: EdgeInsets.fromLTRB(14, 12, 14, 10),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Live Updates',
                    style: TextStyle(
                      color: _textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                  itemCount: uniqueEvents.length,
                  itemBuilder: (BuildContext context, int index) {
                    final IssueTimelineEvent event = uniqueEvents[index];
                    return TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0, end: 1),
                      duration: Duration(milliseconds: 260 + (index * 120)),
                      curve: Curves.easeOut,
                      builder:
                          (BuildContext context, double value, Widget? child) {
                            return Opacity(
                              opacity: value,
                              child: Transform.translate(
                                offset: Offset(0, (1 - value) * 16),
                                child: child,
                              ),
                            );
                          },
                      child: _LiveUpdatePostCard(
                        event: event,
                        displayTimestamp: displayTimestamps[index],
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 6, 14, 16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _isRealtimeEnabled = !_isRealtimeEnabled;
                      });
                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(
                          SnackBar(
                            content: Text(
                              _isRealtimeEnabled
                                  ? 'Realtime updates enabled for this issue'
                                  : 'Realtime updates disabled for this issue',
                            ),
                          ),
                        );
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(42),
                      foregroundColor: Colors.black,
                      backgroundColor: _isRealtimeEnabled ? _success : _primary,
                      side: BorderSide(
                        color: _isRealtimeEnabled ? _success : _primary,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: Icon(
                      _isRealtimeEnabled
                          ? Icons.track_changes_rounded
                          : Icons.notifications_outlined,
                      size: 16,
                    ),
                    label: Text(
                      _isRealtimeEnabled
                          ? 'Notifications On'
                          : 'Enable Notifications',
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 18),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        AppRoutes.home,
                        (Route<dynamic> route) => false,
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(42),
                      foregroundColor: _textPrimary,
                      side: const BorderSide(color: _surfaceBorder),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Back to Home',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
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

class _LiveUpdatePostCard extends StatefulWidget {
  const _LiveUpdatePostCard({
    required this.event,
    required this.displayTimestamp,
  });

  final IssueTimelineEvent event;
  final DateTime displayTimestamp;

  @override
  State<_LiveUpdatePostCard> createState() => _LiveUpdatePostCardState();
}

class _LiveUpdatePostCardState extends State<_LiveUpdatePostCard> {
  late final PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final IssueTimelineEvent event = widget.event;
    final Color eventStatusColor = _statusColor(event.status);

    final String updaterName = _liveUpdaterName(event);
    final String updaterRole = _safeText(event.department);
    final String remarks = _liveRemarks(event);
    final List<String> photos = event.photoAttachments
        .map((String value) => value.trim())
        .where((String value) => value.isNotEmpty)
        .toList(growable: false);
    final List<String> images = photos.isEmpty
        ? _relatedImagesForEvent(event)
        : photos;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _ProfileAvatar(
                imageUrl: null,
                displayName: updaterName,
                radius: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      updaterName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _textPrimary,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      updaterRole,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _textSecondary,
                        fontSize: 10.8,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _MicroBadge(
                      label: event.status.title,
                      color: eventStatusColor,
                    ),
                  ],
                ),
              ),
              Text(
                _formatDateTime(widget.displayTimestamp),
                style: const TextStyle(
                  color: _textSecondary,
                  fontSize: 10.8,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            remarks,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _textPrimary,
              fontSize: 12.4,
              height: 1.35,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 154,
            width: double.infinity,
            child: PageView.builder(
              itemCount: images.length,
              controller: _pageController,
              onPageChanged: (int page) {
                if (!mounted) {
                  return;
                }
                setState(() {
                  _currentPage = page;
                });
              },
              itemBuilder: (BuildContext context, int index) {
                final String imageUrl = images[index];
                return ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (
                          BuildContext context,
                          Object error,
                          StackTrace? stackTrace,
                        ) {
                          return const ColoredBox(
                            color: Color(0xFF171717),
                            child: Center(
                              child: Icon(
                                Icons.broken_image_outlined,
                                color: _textSecondary,
                              ),
                            ),
                          );
                        },
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List<Widget>.generate(images.length, (int index) {
              final bool active = index == _currentPage;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: active ? 16 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: active ? _primary : const Color(0xFF4A4A4A),
                  borderRadius: BorderRadius.circular(999),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

Future<void> _openIssueMap(TrackedIssue issue) async {
  final double? lat = issue.latitude;
  final double? lng = issue.longitude;
  if (lat == null || lng == null) {
    return;
  }
  final Uri uri = Uri.parse(
    'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
  );
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}

Future<void> _launchPhone(String? phone) async {
  final String value = (phone ?? '').trim();
  if (value.isEmpty) {
    return;
  }
  final Uri uri = Uri.parse('tel:$value');
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}

Future<void> _launchSms(String? phone) async {
  final String value = (phone ?? '').trim();
  if (value.isEmpty) {
    return;
  }
  final Uri uri = Uri.parse('sms:$value');
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}

void _openEvidencePreview(BuildContext context, String imageUrl) {
  showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: Colors.black,
        insetPadding: const EdgeInsets.all(10),
        child: Stack(
          children: <Widget>[
            Positioned.fill(
              child: InteractiveViewer(
                minScale: 0.6,
                maxScale: 4,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder:
                      (
                        BuildContext context,
                        Object error,
                        StackTrace? stackTrace,
                      ) {
                        return const Center(
                          child: Icon(
                            Icons.broken_image_outlined,
                            color: _textSecondary,
                          ),
                        );
                      },
                ),
              ),
            ),
            Positioned(
              right: 8,
              top: 8,
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded, color: Colors.white),
              ),
            ),
          ],
        ),
      );
    },
  );
}

String _issueTitle(TrackedIssue issue) {
  final String title = (issue.issueTitle ?? '').trim();
  if (title.isNotEmpty) {
    return title;
  }
  final String category = issue.category.trim();
  if (category.isNotEmpty) {
    return category;
  }
  return 'Issue';
}

String _safeText(String? value) {
  final String normalized = (value ?? '').trim();
  if (normalized.isEmpty ||
      normalized.toLowerCase() == 'unassigned' ||
      normalized.toLowerCase() == 'not available') {
    return '--';
  }
  return normalized;
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({
    required this.imageUrl,
    required this.displayName,
    required this.radius,
  });

  final String? imageUrl;
  final String displayName;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final String? normalized = (imageUrl ?? '').trim().isEmpty
        ? null
        : imageUrl!.trim();
    final String fallbackUrl = _randomAvatarForName(displayName);
    final String activeUrl = normalized ?? fallbackUrl;

    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: _surfaceBorder),
        color: const Color(0xFF141414),
      ),
      child: ClipOval(
        child: Image.network(
          activeUrl,
          fit: BoxFit.cover,
          frameBuilder:
              (
                BuildContext context,
                Widget child,
                int? frame,
                bool wasSynchronouslyLoaded,
              ) {
                if (wasSynchronouslyLoaded || frame != null) {
                  return child;
                }
                return _AvatarFallback(
                  initials: _initials(displayName),
                  radius: radius,
                );
              },
          errorBuilder:
              (BuildContext context, Object error, StackTrace? stackTrace) {
                return _AvatarFallback(
                  initials: _initials(displayName),
                  radius: radius,
                );
              },
        ),
      ),
    );
  }
}

class _AvatarFallback extends StatelessWidget {
  const _AvatarFallback({required this.initials, required this.radius});

  final String initials;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1D1D1D),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          color: _textPrimary,
          fontSize: radius * 0.38,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

String _liveUpdaterName(IssueTimelineEvent event) {
  final String officer = (event.officerName ?? '').trim();
  if (officer.isNotEmpty) {
    return officer;
  }
  return _safeText(event.updatedBy);
}

String _randomAvatarForName(String value) {
  final String source = value.trim().isEmpty ? 'citizen' : value.trim();
  final int seed = source.codeUnits.fold<int>(0, (int a, int b) => a + b);
  return _fallbackProfileImages[seed % _fallbackProfileImages.length];
}

String _liveRemarks(IssueTimelineEvent event) {
  final String raw = (event.remarks ?? '').trim();
  if (raw.isNotEmpty) {
    return raw;
  }
  switch (event.status) {
    case IssueWorkflowStatus.issueCreated:
      return 'Issue has been logged by citizen and sent for assignment.';
    case IssueWorkflowStatus.departmentAssigned:
      return 'Department has been mapped and the case is routed to field team.';
    case IssueWorkflowStatus.officerAccepted:
      return 'Assigned officer accepted this issue and started planning action.';
    case IssueWorkflowStatus.inspectionScheduled:
      return 'Site inspection has been scheduled for verification and planning.';
    case IssueWorkflowStatus.workStarted:
      return 'Ground work has started for this issue.';
    case IssueWorkflowStatus.workInProgress:
      return 'Work is currently in progress. Progress updates will continue in realtime.';
    case IssueWorkflowStatus.workCompleted:
      return 'Resolution work was completed and moved for citizen verification.';
    case IssueWorkflowStatus.citizenVerification:
      return 'Citizen verification is pending to confirm resolution quality.';
    case IssueWorkflowStatus.issueClosed:
      return 'Issue has been closed after completion and confirmation.';
    case IssueWorkflowStatus.unknown:
      return 'Realtime update posted for this issue.';
  }
}

String _initials(String value) {
  final List<String> parts = value
      .split(RegExp(r'\s+'))
      .where((String item) => item.trim().isNotEmpty)
      .toList(growable: false);
  if (parts.isEmpty) {
    return 'NA';
  }
  if (parts.length == 1) {
    final String head = parts.first;
    return head.length >= 2
        ? head.substring(0, 2).toUpperCase()
        : head.toUpperCase();
  }
  return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
}

List<String> _relatedImagesForEvent(IssueTimelineEvent event) {
  final int seed = event.timestamp.millisecondsSinceEpoch.abs();
  final int start = seed % _fallbackLiveImages.length;
  return <String>[
    _fallbackLiveImages[start],
    _fallbackLiveImages[(start + 1) % _fallbackLiveImages.length],
    _fallbackLiveImages[(start + 2) % _fallbackLiveImages.length],
  ];
}

List<DateTime> _buildLiveDisplayTimestamps(List<IssueTimelineEvent> events) {
  final List<DateTime> resolved = <DateTime>[];
  DateTime? previous;

  for (int index = 0; index < events.length; index++) {
    final IssueTimelineEvent event = events[index];
    DateTime candidate = event.timestamp;

    // Keep timeline strictly descending and distinct even when backend timestamps collide.
    if (previous != null && !candidate.isBefore(previous)) {
      final int minuteOffset = 2 + (index % 4);
      candidate = previous.subtract(Duration(minutes: minuteOffset));
    }

    resolved.add(candidate);
    previous = candidate;
  }

  return resolved;
}

List<IssueTimelineEvent> _deduplicateLiveEvents(
  List<IssueTimelineEvent> events,
) {
  final Set<String> seen = <String>{};
  final List<IssueTimelineEvent> result = <IssueTimelineEvent>[];

  for (final IssueTimelineEvent event in events) {
    final String key =
        '${event.status.name}|${event.timestamp.toIso8601String()}|${event.updatedBy}|${(event.remarks ?? '').trim()}';
    if (seen.add(key)) {
      result.add(event);
    }
  }

  return result;
}

bool _hasPhone(String? value) {
  final String normalized = (value ?? '').trim();
  return normalized.isNotEmpty && normalized.toLowerCase() != 'not available';
}

String? _taggedAuthorityPhoto(TrackedIssue issue) {
  final String direct = (issue.taggedAuthorityProfileUrl ?? '').trim();
  if (direct.isNotEmpty) {
    return direct;
  }
  if (issue.taggedAuthorityProfiles.isNotEmpty) {
    final String fromProfile =
        (issue.taggedAuthorityProfiles.first.profilePhotoUrl ?? '').trim();
    if (fromProfile.isNotEmpty) {
      return fromProfile;
    }
  }
  return null;
}

String? _taggedAuthorityPhone(TrackedIssue issue) {
  final String mobile = (issue.taggedAuthorityMobile ?? '').trim();
  if (mobile.isNotEmpty) {
    return mobile;
  }
  final String office = (issue.taggedAuthorityOfficePhone ?? '').trim();
  if (office.isNotEmpty) {
    return office;
  }
  if (issue.taggedAuthorityProfiles.isNotEmpty) {
    final String p = (issue.taggedAuthorityProfiles.first.phoneNumber ?? '')
        .trim();
    if (p.isNotEmpty) {
      return p;
    }
  }
  return null;
}

String? _officerPhone(TrackedIssue issue) {
  final String direct = (issue.assignedOfficerPhone ?? '').trim();
  if (direct.isNotEmpty) {
    return direct;
  }
  final String office = (issue.assignedOfficerExtension ?? '').trim();
  if (office.isNotEmpty) {
    return office;
  }
  return null;
}

Future<void> _shareIssueDetails(
  BuildContext context,
  TrackedIssue issue,
) async {
  final String text =
      'Issue ID: ${issue.issueId}\nStatus: ${issue.currentStatus.title}\nDepartment: ${_safeText(issue.department)}\nExpected Resolution: ${_formatDate(issue.expectedResolutionAt)}';
  await SharePlus.instance.share(
    ShareParams(text: text, subject: 'Issue ${issue.issueId} Tracking Update'),
  );
}

double _managerProgress(TrackedIssue issue) {
  final double source = issue.progress.clamp(0.0, 1.0);
  if (issue.currentStatus == IssueWorkflowStatus.workInProgress) {
    return source > 0.5 ? 0.5 : source;
  }
  return source;
}

Map<IssueWorkflowStatus, IssueTimelineEvent> _eventByStatus(
  List<IssueTimelineEvent> timeline,
) {
  final Map<IssueWorkflowStatus, IssueTimelineEvent> result =
      <IssueWorkflowStatus, IssueTimelineEvent>{};
  final List<IssueTimelineEvent> sorted =
      List<IssueTimelineEvent>.from(timeline)..sort(
        (IssueTimelineEvent a, IssueTimelineEvent b) =>
            b.timestamp.compareTo(a.timestamp),
      );
  for (final IssueTimelineEvent event in sorted) {
    result.putIfAbsent(event.status, () => event);
  }
  return result;
}

Color _statusColor(IssueWorkflowStatus status) {
  switch (status) {
    case IssueWorkflowStatus.issueClosed:
      return _success;
    case IssueWorkflowStatus.workCompleted:
    case IssueWorkflowStatus.citizenVerification:
      return const Color(0xFF6EE0A5);
    case IssueWorkflowStatus.workInProgress:
    case IssueWorkflowStatus.workStarted:
      return _primary;
    case IssueWorkflowStatus.inspectionScheduled:
    case IssueWorkflowStatus.departmentAssigned:
    case IssueWorkflowStatus.officerAccepted:
      return _info;
    case IssueWorkflowStatus.issueCreated:
      return const Color(0xFF8F9CA8);
    case IssueWorkflowStatus.unknown:
      return const Color(0xFF747474);
  }
}

String _stageSlaBadge(IssueWorkflowStatus status) {
  switch (status) {
    case IssueWorkflowStatus.issueCreated:
      return 'SLA 0-4h';
    case IssueWorkflowStatus.departmentAssigned:
      return 'SLA 24h';
    case IssueWorkflowStatus.officerAccepted:
      return 'SLA 12h';
    case IssueWorkflowStatus.inspectionScheduled:
      return 'SLA 1d';
    case IssueWorkflowStatus.workStarted:
      return 'SLA 2d';
    case IssueWorkflowStatus.workInProgress:
      return 'SLA 3d';
    case IssueWorkflowStatus.workCompleted:
      return 'SLA 4d';
    case IssueWorkflowStatus.citizenVerification:
      return 'SLA 24h';
    case IssueWorkflowStatus.issueClosed:
      return 'SLA Closed';
    case IssueWorkflowStatus.unknown:
      return 'SLA TBD';
  }
}

Color _stageSlaColor(_WorkflowVisualState state) {
  switch (state) {
    case _WorkflowVisualState.completed:
      return _success;
    case _WorkflowVisualState.active:
      return _primary;
    case _WorkflowVisualState.pending:
      return const Color(0xFF8A8A8A);
  }
}

String _workflowStateLabel(_WorkflowVisualState state) {
  switch (state) {
    case _WorkflowVisualState.completed:
      return 'Completed';
    case _WorkflowVisualState.active:
      return 'Work in Progress';
    case _WorkflowVisualState.pending:
      return 'Pending';
  }
}

Color _workflowStateColor(_WorkflowVisualState state) {
  switch (state) {
    case _WorkflowVisualState.completed:
      return _success;
    case _WorkflowVisualState.active:
      return _primary;
    case _WorkflowVisualState.pending:
      return const Color(0xFF8A8A8A);
  }
}

String _formatDate(DateTime value) {
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
  return '${months[value.month - 1]} ${value.day}, ${value.year}';
}

String _formatDateTime(DateTime value) {
  final int hour12 = value.hour % 12 == 0 ? 12 : value.hour % 12;
  final String minute = value.minute.toString().padLeft(2, '0');
  final String period = value.hour >= 12 ? 'PM' : 'AM';
  return '${_formatDate(value)} • $hour12:$minute $period';
}
