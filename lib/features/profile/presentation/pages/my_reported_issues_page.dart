import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../../providers/user_provider.dart';
import '../../../report_issue/presentation/screens/report_issue_screen.dart';
import '../../../track_issue/presentation/pages/track_issue_screen.dart';
import '../../data/repositories/firestore_reported_issues_repository.dart';
import '../../domain/models/reported_issue_case.dart';
import '../providers/my_reported_issues_provider.dart';

const Color _pageBg = Color(0xFF0A0C10);
const Color _panelBg = Color(0xFF12161D);
const Color _panelBgSoft = Color(0xFF171C24);
const Color _gold = Color(0xFFF5B62D);
const Color _goldSoft = Color(0xFF6F5420);
const Color _textPrimary = Color(0xFFF3F5F8);
const Color _textMuted = Color(0xFF9AA6B2);

const List<String> _filterOptions = <String>[
  'All',
  'Roads',
  'Water',
  'Electricity',
  'Garbage',
  'Drainage',
  'Health',
  'Traffic',
  'Street Lights',
  'Environment',
  'Public Safety',
  'Active',
  'Completed',
];

class MyReportedIssuesPage extends StatefulWidget {
  const MyReportedIssuesPage({super.key});

  @override
  State<MyReportedIssuesPage> createState() => _MyReportedIssuesPageState();
}

class _MyReportedIssuesPageState extends State<MyReportedIssuesPage>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _searchController;
  late final AnimationController _loadController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _loadController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _loadController.dispose();
    super.dispose();
  }

  void _openIssue(BuildContext context, String issueId) {
    Navigator.of(context).push<void>(
      PageRouteBuilder<void>(
        settings: RouteSettings(arguments: issueId),
        transitionDuration: const Duration(milliseconds: 280),
        reverseTransitionDuration: const Duration(milliseconds: 220),
        pageBuilder:
            (
              BuildContext context,
              Animation<double> animation,
              Animation<double> secondaryAnimation,
            ) {
              return const TrackIssueScreen();
            },
        transitionsBuilder:
            (
              BuildContext context,
              Animation<double> animation,
              Animation<double> secondaryAnimation,
              Widget child,
            ) {
              final Animation<Offset> slide =
                  Tween<Offset>(
                    begin: const Offset(0, 0.04),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    ),
                  );
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(position: slide, child: child),
              );
            },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = context.watch<UserProvider>();
    final String userId = (userProvider.firebaseUser?.uid ?? '').trim();

    return ChangeNotifierProvider<MyReportedIssuesProvider>(
      create: (_) => MyReportedIssuesProvider(
        repository: FirestoreReportedIssuesRepository(),
      )..initialize(userId),
      child: Consumer<MyReportedIssuesProvider>(
        builder: (BuildContext context, MyReportedIssuesProvider provider, _) {
          return Theme(
            data: Theme.of(context).copyWith(
              textTheme: GoogleFonts.interTextTheme(
                Theme.of(context).textTheme,
              ),
            ),
            child: Scaffold(
              backgroundColor: _pageBg,
              appBar: AppBar(
                backgroundColor: _pageBg,
                elevation: 0,
                titleSpacing: 0,
                leading: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: _textPrimary,
                  ),
                ),
                title: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'My Reported Issues',
                      style: TextStyle(
                        color: _textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'View and manage all service requests submitted by you.',
                      style: TextStyle(
                        color: _textMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              body: _buildBody(context, provider),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, MyReportedIssuesProvider provider) {
    if (provider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: _gold, strokeWidth: 2.4),
      );
    }

    if (provider.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            provider.error!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: _textMuted, fontSize: 14),
          ),
        ),
      );
    }

    final List<ReportedIssueCase> items = provider.filteredIssues;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: <Widget>[
        SliverToBoxAdapter(
          child: FadeTransition(
            opacity: CurvedAnimation(
              parent: _loadController,
              curve: const Interval(0, 0.4, curve: Curves.easeOut),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
              child: _SummaryGrid(provider: provider),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 2, 16, 10),
            child: _SearchBar(
              controller: _searchController,
              onChanged: provider.setSearch,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _filterOptions
                  .map((String filter) {
                    final bool selected = provider.filters.contains(filter);
                    return FilterChip(
                      selected: selected,
                      onSelected: (_) => provider.toggleFilter(filter),
                      label: Text(filter),
                      showCheckmark: false,
                      selectedColor: const Color(0xFF3A2A0D),
                      backgroundColor: _panelBg,
                      side: BorderSide(
                        color: selected ? _gold : const Color(0xFF293241),
                      ),
                      labelStyle: TextStyle(
                        color: selected ? _gold : _textMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  })
                  .toList(growable: false),
            ),
          ),
        ),
        if (items.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: _EmptyState(
              onReport: () {
                Navigator.of(context).push<void>(
                  MaterialPageRoute<void>(
                    builder: (_) => const ReportIssueScreen(),
                  ),
                );
              },
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            sliver: SliverList.separated(
              itemBuilder: (BuildContext context, int index) {
                final ReportedIssueCase issue = items[index];
                return _IssueCaseCard(
                  issue: issue,
                  index: index,
                  onOpen: () => _openIssue(context, issue.issueId),
                );
              },
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemCount: items.length,
            ),
          ),
      ],
    );
  }
}

class _SummaryGrid extends StatelessWidget {
  const _SummaryGrid({required this.provider});

  final MyReportedIssuesProvider provider;

  @override
  Widget build(BuildContext context) {
    final List<({String label, int value, String svg})> cards =
        <({String label, int value, String svg})>[
          (
            label: 'Total Requests',
            value: provider.totalRequests,
            svg: _summarySvg('total'),
          ),
          (
            label: 'In Progress',
            value: provider.inProgressCount,
            svg: _summarySvg('progress'),
          ),
          (
            label: 'Resolved',
            value: provider.resolvedCount,
            svg: _summarySvg('resolved'),
          ),
          (
            label: 'Pending',
            value: provider.pendingCount,
            svg: _summarySvg('pending'),
          ),
        ];

    return GridView.builder(
      itemCount: cards.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.55,
      ),
      itemBuilder: (BuildContext context, int index) {
        final ({String label, int value, String svg}) stat = cards[index];
        return TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: 1),
          duration: Duration(milliseconds: 280 + (index * 80)),
          curve: Curves.easeOutCubic,
          builder: (BuildContext context, double value, Widget? child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 12 * (1 - value)),
                child: child,
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _panelBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF2A3140)),
              boxShadow: const <BoxShadow>[
                BoxShadow(
                  color: Color(0x22000000),
                  blurRadius: 20,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: <Widget>[
                Container(
                  width: 40,
                  height: 40,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _panelBgSoft,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _goldSoft),
                  ),
                  child: SvgPicture.string(stat.svg),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        '${stat.value}',
                        style: const TextStyle(
                          color: _textPrimary,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        stat.label,
                        style: const TextStyle(
                          color: _textMuted,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
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

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: const TextStyle(color: _textPrimary, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        hintText: 'Search by Issue ID, Category, Location, Department',
        hintStyle: const TextStyle(color: _textMuted, fontSize: 13),
        prefixIcon: const Icon(Icons.search_rounded, color: _gold),
        filled: true,
        fillColor: _panelBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFF2A3140)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFF2A3140)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: _gold),
        ),
      ),
    );
  }
}

class _IssueCaseCard extends StatefulWidget {
  const _IssueCaseCard({
    required this.issue,
    required this.index,
    required this.onOpen,
  });

  final ReportedIssueCase issue;
  final int index;
  final VoidCallback onOpen;

  @override
  State<_IssueCaseCard> createState() => _IssueCaseCardState();
}

class _IssueCaseCardState extends State<_IssueCaseCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final ReportedIssueCase issue = widget.issue;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 320 + (widget.index * 60)),
      curve: Curves.easeOutCubic,
      builder: (BuildContext context, double value, Widget? child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: AnimatedScale(
        duration: const Duration(milliseconds: 120),
        scale: _pressed ? 0.988 : 1,
        child: Material(
          color: _panelBg,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            splashColor: const Color(0x22F5B62D),
            onTapDown: (_) => setState(() => _pressed = true),
            onTapUp: (_) => setState(() => _pressed = false),
            onTapCancel: () => setState(() => _pressed = false),
            onTap: widget.onOpen,
            child: Ink(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF2A3140)),
                boxShadow: const <BoxShadow>[
                  BoxShadow(
                    color: Color(0x19000000),
                    blurRadius: 20,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Hero(
                        tag: 'issue-category-${issue.issueId}',
                        child: Container(
                          width: 56,
                          height: 56,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: _panelBgSoft,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: _goldSoft),
                          ),
                          child: SvgPicture.string(
                            _categorySvg(issue.category),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              issue.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: _textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              issue.issueId,
                              style: const TextStyle(
                                color: _textMuted,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: <Widget>[
                      _StatusBadge(status: issue.status),
                      _PriorityBadge(priority: issue.priority),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _InfoRow(
                    icon: Icons.calendar_today_rounded,
                    text: _formatDate(issue.submittedAt),
                    label: 'Submitted',
                  ),
                  const SizedBox(height: 6),
                  _InfoRow(
                    icon: Icons.place_rounded,
                    text: issue.location,
                    label: 'Location',
                  ),
                  const SizedBox(height: 6),
                  _InfoRow(
                    icon: Icons.account_balance_rounded,
                    text: issue.department,
                    label: 'Department',
                  ),
                  const SizedBox(height: 6),
                  _InfoRow(
                    icon: Icons.badge_rounded,
                    text: issue.officer,
                    label: 'Officer',
                  ),
                  const SizedBox(height: 6),
                  _InfoRow(
                    icon: Icons.schedule_rounded,
                    text: _formatDate(issue.expectedResolution),
                    label: 'Expected Resolution',
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Latest Update',
                    style: TextStyle(
                      color: _textMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    issue.latestUpdate,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: <Widget>[
                      const Text(
                        'Progress',
                        style: TextStyle(
                          color: _textMuted,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${issue.progress}%',
                        style: const TextStyle(
                          color: _gold,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: issue.progress / 100,
                      minHeight: 8,
                      backgroundColor: const Color(0xFF252D3B),
                      valueColor: const AlwaysStoppedAnimation<Color>(_gold),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _QuickActions(issue: issue, onOpen: widget.onOpen),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({required this.issue, required this.onOpen});

  final ReportedIssueCase issue;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: <Widget>[
        _ActionPill(
          label: 'View Details',
          icon: Icons.visibility_outlined,
          onTap: onOpen,
          highlighted: true,
        ),
        _ActionPill(
          label: 'Track Progress',
          icon: Icons.timeline_rounded,
          onTap: onOpen,
        ),
        _ActionPill(
          label: 'Live Updates',
          icon: Icons.notifications_active_outlined,
          onTap: onOpen,
        ),
        _ActionPill(
          label: 'Share',
          icon: Icons.share_outlined,
          onTap: () async {
            await Clipboard.setData(
              ClipboardData(
                text:
                    'Issue ${issue.issueId} | ${issue.title} | ${issue.location}',
              ),
            );
            if (!context.mounted) {
              return;
            }
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                const SnackBar(
                  content: Text('Issue details copied to clipboard.'),
                ),
              );
          },
        ),
      ],
    );
  }
}

class _ActionPill extends StatelessWidget {
  const _ActionPill({
    required this.label,
    required this.icon,
    required this.onTap,
    this.highlighted = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: highlighted ? const Color(0xFF2B2210) : const Color(0xFF1A202B),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: highlighted ? _goldSoft : const Color(0xFF2D3748),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                icon,
                size: 16,
                color: highlighted ? _gold : const Color(0xFFB9C2CF),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: highlighted ? _gold : const Color(0xFFD5DBE3),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text, required this.label});

  final IconData icon;
  final String text;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(icon, color: _gold, size: 15),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            color: _textMuted,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        Expanded(
          child: Text(
            text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
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

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final ({Color bg, Color fg}) style = _statusStyle(status);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: style.bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: style.fg.withValues(alpha: 0.45)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SvgPicture.string(
            _statusSvg(status, style.fg),
            width: 14,
            height: 14,
          ),
          const SizedBox(width: 6),
          Text(
            status,
            style: TextStyle(
              color: style.fg,
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _PriorityBadge extends StatelessWidget {
  const _PriorityBadge({required this.priority});

  final String priority;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF2D2615),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _goldSoft),
      ),
      child: Text(
        '$priority Priority',
        style: const TextStyle(
          color: _gold,
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onReport});

  final VoidCallback onReport;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 138,
              height: 138,
              padding: const EdgeInsets.all(26),
              decoration: BoxDecoration(
                color: _panelBg,
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: _goldSoft),
              ),
              child: SvgPicture.string(_emptySvg),
            ),
            const SizedBox(height: 16),
            const Text(
              'No Reported Issues Yet',
              style: TextStyle(
                color: _textPrimary,
                fontSize: 19,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Your submitted service requests will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _textMuted,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onReport,
              style: ElevatedButton.styleFrom(
                backgroundColor: _gold,
                foregroundColor: Colors.black,
                elevation: 0,
                minimumSize: const Size(180, 46),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.add_circle_outline_rounded),
              label: const Text(
                'Report New Issue',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatDate(DateTime date) {
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
  return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}';
}

({Color bg, Color fg}) _statusStyle(String status) {
  switch (status.toLowerCase()) {
    case 'issue created':
      return (bg: const Color(0xFF223248), fg: const Color(0xFF80BFFF));
    case 'assigned':
      return (bg: const Color(0xFF2A2B44), fg: const Color(0xFFAFA9FF));
    case 'inspection':
      return (bg: const Color(0xFF3B2C18), fg: const Color(0xFFFFCE73));
    case 'work started':
      return (bg: const Color(0xFF1B3440), fg: const Color(0xFF73D8FF));
    case 'work in progress':
      return (bg: const Color(0xFF1E3A2A), fg: const Color(0xFF8EE4AE));
    case 'completed':
      return (bg: const Color(0xFF1B4130), fg: const Color(0xFF83E8A8));
    case 'citizen verified':
      return (bg: const Color(0xFF26321F), fg: const Color(0xFFBEEB76));
    default:
      return (bg: const Color(0xFF2B3039), fg: const Color(0xFFC3CBD6));
  }
}

String _summarySvg(String type) {
  switch (type) {
    case 'total':
      return '<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><rect x="4" y="4" width="16" height="16" rx="3" fill="#F5B62D"/><path d="M8 9h8M8 12h8M8 15h5" stroke="#0F1319" stroke-width="1.7" stroke-linecap="round"/></svg>';
    case 'progress':
      return '<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><circle cx="12" cy="12" r="9" fill="#F5B62D"/><path d="M12 7v5l3 2" stroke="#0F1319" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/></svg>';
    case 'resolved':
      return '<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><rect x="3" y="4" width="18" height="16" rx="3" fill="#F5B62D"/><path d="M8 12l2.5 2.5L16 9" stroke="#0F1319" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/></svg>';
    default:
      return '<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path d="M12 3l9 16H3l9-16z" fill="#F5B62D"/><path d="M12 9v4m0 3h.01" stroke="#0F1319" stroke-width="1.8" stroke-linecap="round"/></svg>';
  }
}

String _categorySvg(String category) {
  final String c = category.toLowerCase();
  if (c.contains('road')) {
    return '<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path d="M9 3h6l4 18H5L9 3z" fill="#F5B62D"/><path d="M12 6v2m0 3v2m0 3v2" stroke="#0F1319" stroke-width="1.6" stroke-linecap="round"/></svg>';
  }
  if (c.contains('water') || c.contains('drain')) {
    return '<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path d="M12 3c3 4 6 6.7 6 10a6 6 0 1 1-12 0c0-3.3 3-6 6-10z" fill="#F5B62D"/></svg>';
  }
  if (c.contains('electric') || c.contains('street')) {
    return '<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path d="M13 2L6 13h5l-1 9 8-12h-5l0-8z" fill="#F5B62D"/></svg>';
  }
  if (c.contains('garbage') || c.contains('environment')) {
    return '<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><rect x="7" y="7" width="10" height="13" rx="2" fill="#F5B62D"/><path d="M9 5h6M10 10v7m4-7v7" stroke="#0F1319" stroke-width="1.6" stroke-linecap="round"/></svg>';
  }
  if (c.contains('health')) {
    return '<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><rect x="5" y="5" width="14" height="14" rx="3" fill="#F5B62D"/><path d="M12 8v8M8 12h8" stroke="#0F1319" stroke-width="1.8" stroke-linecap="round"/></svg>';
  }
  if (c.contains('traffic') || c.contains('safety')) {
    return '<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><circle cx="12" cy="12" r="9" fill="#F5B62D"/><circle cx="12" cy="8" r="1.5" fill="#0F1319"/><circle cx="12" cy="12" r="1.5" fill="#0F1319"/><circle cx="12" cy="16" r="1.5" fill="#0F1319"/></svg>';
  }
  return '<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><rect x="4" y="4" width="16" height="16" rx="3" fill="#F5B62D"/><path d="M8 12h8" stroke="#0F1319" stroke-width="1.8" stroke-linecap="round"/></svg>';
}

String _statusSvg(String status, Color color) {
  final String hex = '#${color.toARGB32().toRadixString(16).substring(2)}';
  switch (status.toLowerCase()) {
    case 'issue created':
      return '<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><circle cx="12" cy="12" r="9" stroke="$hex" stroke-width="2" fill="none"/><circle cx="12" cy="12" r="3" fill="$hex"/></svg>';
    case 'assigned':
      return '<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><rect x="4" y="5" width="16" height="14" rx="3" stroke="$hex" stroke-width="2" fill="none"/><path d="M8 11h8" stroke="$hex" stroke-width="2"/></svg>';
    case 'inspection':
      return '<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><circle cx="11" cy="11" r="6" stroke="$hex" stroke-width="2" fill="none"/><path d="M16 16l4 4" stroke="$hex" stroke-width="2" stroke-linecap="round"/></svg>';
    case 'work started':
      return '<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path d="M5 18l6-6 2 2 6-6" stroke="$hex" stroke-width="2" fill="none" stroke-linecap="round" stroke-linejoin="round"/></svg>';
    case 'work in progress':
      return '<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path d="M12 4a8 8 0 1 1-8 8" stroke="$hex" stroke-width="2" fill="none"/><path d="M12 8v4l3 2" stroke="$hex" stroke-width="2" stroke-linecap="round"/></svg>';
    case 'completed':
      return '<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path d="M5 13l4 4 10-10" stroke="$hex" stroke-width="2.2" fill="none" stroke-linecap="round" stroke-linejoin="round"/></svg>';
    case 'citizen verified':
      return '<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path d="M12 3l7 3v6c0 5-3.5 7.5-7 9-3.5-1.5-7-4-7-9V6l7-3z" stroke="$hex" stroke-width="2" fill="none"/><path d="M9 12l2 2 4-4" stroke="$hex" stroke-width="2" fill="none"/></svg>';
    default:
      return '<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><circle cx="12" cy="12" r="9" stroke="$hex" stroke-width="2" fill="none"/></svg>';
  }
}

const String _emptySvg =
    '<svg viewBox="0 0 80 80" xmlns="http://www.w3.org/2000/svg"><rect x="12" y="18" width="56" height="44" rx="8" fill="#F5B62D"/><rect x="18" y="28" width="44" height="3" rx="1.5" fill="#111827"/><rect x="18" y="36" width="32" height="3" rx="1.5" fill="#111827"/><rect x="18" y="44" width="26" height="3" rx="1.5" fill="#111827"/><circle cx="58" cy="56" r="8" fill="#111827"/><path d="M58 52v8M54 56h8" stroke="#F5B62D" stroke-width="2" stroke-linecap="round"/></svg>';
