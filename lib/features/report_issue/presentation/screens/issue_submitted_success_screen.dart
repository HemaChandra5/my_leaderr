import 'dart:math' as math;
import 'dart:ui' show PathMetric;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../main.dart';
import '../../../track_issue/presentation/pages/track_issue_screen.dart';
import '../../models/submitted_issue.dart';

class IssueSubmittedSuccessScreen extends StatefulWidget {
  const IssueSubmittedSuccessScreen({
    super.key,
    required this.issue,
    required this.onBackHome,
  });

  final SubmittedIssue issue;
  final VoidCallback onBackHome;

  @override
  State<IssueSubmittedSuccessScreen> createState() =>
      _IssueSubmittedSuccessScreenState();
}

class _IssueSubmittedSuccessScreenState extends State<IssueSubmittedSuccessScreen>
    with TickerProviderStateMixin {
  late final AnimationController _sequence;
  late final AnimationController _particleOrbit;
  late final AnimationController _shimmer;

  late final Animation<double> _tickIn;
  late final Animation<double> _checkDraw;
  late final Animation<double> _sparkleIn;
  late final Animation<double> _ringPulse;

  late final Animation<double> _titleIn;
  late final Animation<double> _subtitleIn;
  late final Animation<double> _summaryIn;
  late final Animation<double> _nextIn;
  late final Animation<double> _buttonsIn;

  bool _hapticDone = false;
  bool _actionsEnabled = false;

  static const List<_OrbitParticle> _orbitParticles = <_OrbitParticle>[
    _OrbitParticle(18, 0.0, 0.28, Color(0x66F5B82E), 2.0),
    _OrbitParticle(24, 0.9, 0.24, Color(0x664CAF50), 4.0),
    _OrbitParticle(29, 1.6, 0.30, Color(0x66FFFFFF), 3.0),
    _OrbitParticle(34, 2.2, 0.22, Color(0x662196F3), 2.0),
    _OrbitParticle(39, 2.9, 0.26, Color(0x66F5B82E), 4.0),
    _OrbitParticle(44, 3.4, 0.20, Color(0x664CAF50), 6.0),
    _OrbitParticle(49, 4.2, 0.22, Color(0x66FFFFFF), 2.0),
    _OrbitParticle(55, 4.9, 0.18, Color(0x662196F3), 4.0),
  ];

  static const List<_SparkleEvent> _sparkles = <_SparkleEvent>[
    _SparkleEvent(0.05, 0.22, 26, -0.4),
    _SparkleEvent(0.08, 0.24, 34, 0.5),
    _SparkleEvent(0.12, 0.26, 40, 1.2),
    _SparkleEvent(0.18, 0.30, 48, 1.8),
    _SparkleEvent(0.24, 0.34, 56, 2.3),
    _SparkleEvent(0.30, 0.36, 64, 2.9),
    _SparkleEvent(0.36, 0.40, 72, 3.4),
    _SparkleEvent(0.42, 0.44, 78, 3.9),
    _SparkleEvent(0.48, 0.46, 84, 4.5),
    _SparkleEvent(0.54, 0.50, 90, 5.1),
  ];

  @override
  void initState() {
    super.initState();

    _sequence = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )
      ..addListener(() {
        if (!_hapticDone && _checkDraw.value >= 0.98) {
          HapticFeedback.mediumImpact();
          _hapticDone = true;
        }
      })
      ..addStatusListener((AnimationStatus status) {
        if (status == AnimationStatus.completed && mounted) {
          setState(() {
            _actionsEnabled = true;
          });
          _shimmer.forward();
        }
      })
      ..forward();

    _particleOrbit = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 6800),
    )..repeat();

    _shimmer = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );

    _tickIn = CurvedAnimation(
      parent: _sequence,
      curve: const Interval(0.16, 0.32, curve: Curves.easeOutBack),
    );
    _checkDraw = CurvedAnimation(
      parent: _sequence,
      curve: const Interval(0.25, 0.44, curve: Curves.easeInOutCubic),
    );
    _sparkleIn = CurvedAnimation(
      parent: _sequence,
      curve: const Interval(0.36, 0.70, curve: Curves.easeOutCubic),
    );
    _ringPulse = CurvedAnimation(
      parent: _sequence,
      curve: const Interval(0.34, 0.78, curve: Curves.easeOutExpo),
    );

    _titleIn = CurvedAnimation(
      parent: _sequence,
      curve: const Interval(0.62, 0.76, curve: Curves.easeOutCubic),
    );
    _subtitleIn = CurvedAnimation(
      parent: _sequence,
      curve: const Interval(0.68, 0.82, curve: Curves.easeOutCubic),
    );
    _summaryIn = CurvedAnimation(
      parent: _sequence,
      curve: const Interval(0.74, 0.88, curve: Curves.easeOutCubic),
    );
    _nextIn = CurvedAnimation(
      parent: _sequence,
      curve: const Interval(0.80, 0.92, curve: Curves.easeOutCubic),
    );
    _buttonsIn = CurvedAnimation(
      parent: _sequence,
      curve: const Interval(0.86, 1.0, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _sequence.dispose();
    _particleOrbit.dispose();
    _shimmer.dispose();
    super.dispose();
  }

  void _goTrackIssue() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => TrackIssueScreen(submission: widget.issue),
      ),
    );
  }

  void _goHome() {
    widget.onBackHome();
    Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.home, (r) => false);
  }

  Future<void> _copyReference() async {
    await Clipboard.setData(ClipboardData(text: widget.issue.issueId));
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Reference copied')));
  }

  Future<void> _shareReport() async {
    final String text =
        'Report ${widget.issue.issueId}\nStatus: Registered\nSubmitted: ${_formatDate(widget.issue.createdAt)}';
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Report details copied for sharing')));
  }

  Future<void> _downloadReceipt() async {
    final String text =
        'Receipt\nReference: ${widget.issue.issueId}\nDate: ${_formatDate(widget.issue.createdAt)}\nTime: ${_formatTime(widget.issue.createdAt)}';
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Receipt content copied')));
  }

  Future<void> _viewDetails() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF111111),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E2E2E),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Submitted Details',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                _SheetRow(label: 'Reference Number', value: widget.issue.issueId),
                _SheetRow(label: 'Submission Date', value: _formatDate(widget.issue.createdAt)),
                _SheetRow(label: 'Submission Time', value: _formatTime(widget.issue.createdAt)),
                _SheetRow(label: 'Status', value: 'Registered'),
                _SheetRow(label: 'Department', value: _assignedDepartment(widget.issue)),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = GoogleFonts.interTextTheme(Theme.of(context).textTheme);

    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: AnimatedBuilder(
        animation: Listenable.merge(<Listenable>[_sequence, _particleOrbit, _shimmer]),
        builder: (BuildContext context, Widget? child) {
          final double iconScale = 0.78 + (_tickIn.value * 0.22);
          final double contentScale = 0.985 + (_summaryIn.value * 0.015);
          final double orbitWave = math.sin(_particleOrbit.value * 2 * math.pi);
          final double iconYOffset = orbitWave * 3.0;

          return Stack(
            children: <Widget>[
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: const Color(0xFF000000),
                    gradient: RadialGradient(
                      center: Alignment.topCenter,
                      radius: 1.45,
                      colors: <Color>[
                        const Color(0xFF000000),
                        const Color(0xFF000000),
                      ],
                    ),
                  ),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
                  child: Column(
                    children: <Widget>[
                      const SizedBox(height: 4),
                      RepaintBoundary(
                        child: SizedBox(
                          width: 250,
                          height: 188,
                          child: Center(
                            child: Transform.translate(
                              offset: Offset(0, iconYOffset),
                              child: Transform.scale(
                                scale: iconScale,
                                child: Opacity(
                                  opacity: _tickIn.value.clamp(0.0, 1.0),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: <Widget>[
                                      CustomPaint(
                                        size: const Size.square(210),
                                        painter: _TickCrackerPainter(
                                          orbit: _particleOrbit.value,
                                          sparkleIn: _sparkleIn.value,
                                          particles: _orbitParticles,
                                          sparkles: _sparkles,
                                        ),
                                      ),
                                      CustomPaint(
                                        size: const Size.square(92),
                                        painter: _TickOnlyPainter(
                                          progress: _checkDraw.value,
                                          pulse: _ringPulse.value,
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
                      const SizedBox(height: 8),
                      FadeTransition(
                        opacity: _titleIn,
                        child: ScaleTransition(
                          scale: Tween<double>(begin: 0.97, end: 1.0).animate(_titleIn),
                          child: Text(
                            'Report Submitted Successfully',
                            textAlign: TextAlign.center,
                            style: textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              height: 1.2,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      FadeTransition(
                        opacity: _subtitleIn,
                        child: ScaleTransition(
                          scale: Tween<double>(begin: 0.98, end: 1.0).animate(_subtitleIn),
                          child: Text(
                            'Your report has been securely registered and forwarded to the concerned Government Department.\n\nA verification process has now been initiated. You will receive real-time notifications as your report progresses through every stage until resolution.',
                            textAlign: TextAlign.center,
                            style: textTheme.bodyMedium?.copyWith(
                              color: const Color(0xFFA0A0A0),
                              fontSize: 13.4,
                              fontWeight: FontWeight.w500,
                              height: 1.45,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: Transform.scale(
                          scale: contentScale,
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: Column(
                              children: <Widget>[
                                FadeTransition(
                                  opacity: _summaryIn,
                                  child: ScaleTransition(
                                    scale: Tween<double>(begin: 0.985, end: 1.0).animate(_summaryIn),
                                    child: _ReferenceSummaryCard(issue: widget.issue),
                                  ),
                                ),
                                const SizedBox(height: 12),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      FadeTransition(
                        opacity: _buttonsIn,
                        child: ScaleTransition(
                          scale: Tween<double>(begin: 0.985, end: 1.0).animate(_buttonsIn),
                          child: SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton.icon(
                              onPressed: _goTrackIssue,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFF5B82E),
                                foregroundColor: Colors.black,
                                elevation: 1.5,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              icon: const Icon(Icons.arrow_forward_rounded, size: 20),
                              label: const Text(
                                'Track Issue',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      FadeTransition(
                        opacity: _buttonsIn,
                        child: ScaleTransition(
                          scale: Tween<double>(begin: 0.99, end: 1.0).animate(_buttonsIn),
                          child: SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: OutlinedButton(
                              onPressed: _goHome,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFFE5E9EE),
                                side: const BorderSide(color: Color(0xFF2B2B2B), width: 1),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Return to Home',
                                style: TextStyle(
                                  color: Color(0xFFE5E9EE),
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
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
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatTime(DateTime date) {
    final int hour12 = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final String minute = date.minute.toString().padLeft(2, '0');
    final String period = date.hour >= 12 ? 'PM' : 'AM';
    return '$hour12:$minute $period';
  }

  String _assignedDepartment(SubmittedIssue issue) {
    if (issue.primaryAuthority != null) {
      final dynamic dept = issue.primaryAuthority!['department'];
      if (dept is String && dept.trim().isNotEmpty) {
        return dept;
      }
    }
    return 'Urban Infrastructure Department';
  }
}

class _ReferenceSummaryCard extends StatelessWidget {
  const _ReferenceSummaryCard({required this.issue});

  final SubmittedIssue issue;

  @override
  Widget build(BuildContext context) {
    final _IssueTextFormat format = _IssueTextFormat(issue: issue);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF2B2B2B)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Row(
            children: <Widget>[
              Icon(Icons.receipt_long_outlined, size: 18, color: Color(0xFFF5B82E)),
              SizedBox(width: 8),
              Text(
                'Reference Summary',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(color: Color(0xFF2B2B2B), height: 1),
          const SizedBox(height: 10),
          _InfoRow(icon: Icons.confirmation_number_outlined, label: 'Reference Number', value: issue.issueId, emphasize: true),
          _InfoRow(icon: Icons.calendar_today_outlined, label: 'Submission Date', value: format.submissionDate),
          _InfoRow(icon: Icons.schedule_outlined, label: 'Submission Time', value: format.submissionTime),
        ],
      ),
    );
  }
}

class _IssueTextFormat {
  _IssueTextFormat({required SubmittedIssue issue})
      : submissionDate = _date(issue.createdAt),
        submissionTime = _time(issue.createdAt),
        expectedReview = _date(issue.createdAt.add(const Duration(days: 1))),
        department = _department(issue),
        priority = issue.priority.trim().isEmpty ? 'Medium' : issue.priority;

  final String submissionDate;
  final String submissionTime;
  final String expectedReview;
  final String department;
  final String priority;

  static String _department(SubmittedIssue issue) {
    if (issue.primaryAuthority != null) {
      final dynamic dept = issue.primaryAuthority!['department'];
      if (dept is String && dept.trim().isNotEmpty) {
        return dept;
      }
    }
    return 'Urban Infrastructure Department';
  }

  static String _date(DateTime date) {
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
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  static String _time(DateTime date) {
    final int hour12 = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final String minute = date.minute.toString().padLeft(2, '0');
    final String period = date.hour >= 12 ? 'PM' : 'AM';
    return '$hour12:$minute $period';
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, size: 16, color: const Color(0xFFF5B82E)),
          const SizedBox(width: 8),
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFFA0A0A0),
                fontSize: 12.3,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: emphasize ? const Color(0xFF4CAF50) : Colors.white,
                fontSize: emphasize ? 13.8 : 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NextStepsCard extends StatelessWidget {
  const _NextStepsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF2B2B2B)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(Icons.shield_outlined, size: 17, color: Color(0xFFF5B82E)),
              SizedBox(width: 8),
              Text(
                'What Happens Next?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          _StepLine(text: 'Report successfully registered.'),
          _StepLine(text: 'Concerned department notified.'),
          _StepLine(text: 'Verification begins shortly.'),
          _StepLine(text: 'Officer assignment in progress.'),
          _StepLine(text: "You'll receive live updates for every status change."),
        ],
      ),
    );
  }
}

class _StepLine extends StatelessWidget {
  const _StepLine({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(Icons.shield_outlined, size: 14, color: Color(0xFF4CAF50)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xFFA0A0A0),
                fontSize: 12.8,
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OptionalActions extends StatelessWidget {
  const _OptionalActions({
    required this.enabled,
    required this.onDownload,
    required this.onShare,
    required this.onCopyRef,
    required this.onViewDetails,
  });

  final bool enabled;
  final VoidCallback onDownload;
  final VoidCallback onShare;
  final VoidCallback onCopyRef;
  final VoidCallback onViewDetails;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: <Widget>[
        _MiniAction(
          label: 'Download Receipt',
          icon: Icons.download_outlined,
          enabled: enabled,
          onTap: onDownload,
        ),
        _MiniAction(
          label: 'Share Report',
          icon: Icons.share_outlined,
          enabled: enabled,
          onTap: onShare,
        ),
        _MiniAction(
          label: 'Copy Reference Number',
          icon: Icons.content_copy_outlined,
          enabled: enabled,
          onTap: onCopyRef,
        ),
        _MiniAction(
          label: 'View Submitted Details',
          icon: Icons.visibility_outlined,
          enabled: enabled,
          onTap: onViewDetails,
        ),
      ],
    );
  }
}

class _MiniAction extends StatelessWidget {
  const _MiniAction({
    required this.label,
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: (MediaQuery.sizeOf(context).width - 56) / 2,
      height: 42,
      child: OutlinedButton.icon(
        onPressed: enabled ? onTap : null,
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFE5E9EE),
          side: const BorderSide(color: Color(0xFF2B2B2B)),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        icon: Icon(icon, size: 15),
        label: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class _SheetRow extends StatelessWidget {
  const _SheetRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 124,
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFFA0A0A0),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12.8,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShimmerSurface extends StatelessWidget {
  const _ShimmerSurface({
    required this.shimmer,
    required this.child,
  });

  final Animation<double> shimmer;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Stack(
        children: <Widget>[
          child,
          IgnorePointer(
            child: Opacity(
              opacity: shimmer.value == 0 ? 0 : 0.24,
              child: Align(
                alignment: Alignment(-1 + (2 * shimmer.value), 0),
                child: Container(
                  width: 80,
                  height: 200,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: <Color>[
                        Colors.transparent,
                        const Color(0x66F5B82E),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrbitParticle {
  const _OrbitParticle(
    this.radius,
    this.angle,
    this.alpha,
    this.color,
    this.size,
  );

  final double radius;
  final double angle;
  final double alpha;
  final Color color;
  final double size;
}

class _SparkleEvent {
  const _SparkleEvent(this.start, this.end, this.distance, this.angle);

  final double start;
  final double end;
  final double distance;
  final double angle;
}

class _TickCrackerPainter extends CustomPainter {
  _TickCrackerPainter({
    required this.orbit,
    required this.sparkleIn,
    required this.particles,
    required this.sparkles,
  });

  final double orbit;
  final double sparkleIn;
  final List<_OrbitParticle> particles;
  final List<_SparkleEvent> sparkles;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);

    for (int i = 0; i < particles.length; i++) {
      final _OrbitParticle p = particles[i];
      final double a = p.angle + ((orbit * 2 * math.pi) * (0.8 + (p.size * 0.04)));
      final Offset pos = Offset(
        center.dx + (math.cos(a) * p.radius),
        center.dy + (math.sin(a) * p.radius),
      );
      final Color c = _paletteColor(i, orbit).withValues(alpha: p.alpha.clamp(0.0, 0.55));
      final Paint paint = Paint()
        ..color = c
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.2);
      canvas.drawCircle(pos, p.size, paint);
    }

    for (final _SparkleEvent e in sparkles) {
      final double t = _segmentProgress(sparkleIn, e.start, e.end);
      if (t <= 0) {
        continue;
      }
      final double fade = 1 - t;
      final double d = e.distance * (0.2 + (0.8 * t));
      final Offset pos = Offset(
        center.dx + (math.cos(e.angle) * d),
        center.dy + (math.sin(e.angle) * d),
      );
      final Color color = _sparkleColor(e.angle).withValues(alpha: (0.52 * fade).clamp(0, 0.55));

      final Paint linePaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(pos.translate(-4, 0), pos.translate(4, 0), linePaint);
      canvas.drawLine(pos.translate(0, -4), pos.translate(0, 4), linePaint);
      canvas.drawCircle(
        pos,
        1.2 + (1.8 * t),
        Paint()
          ..color = color.withValues(alpha: 0.35 * fade)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5),
      );
    }
  }

  double _segmentProgress(double t, double start, double end) {
    if (t <= start) {
      return 0;
    }
    if (t >= end) {
      return 1;
    }
    return (t - start) / (end - start);
  }

  Color _paletteColor(int index, double time) {
    const List<Color> palette = <Color>[
      Color(0xFFF5B82E),
      Color(0xFF4CAF50),
      Color(0xFFFFFFFF),
      Color(0xFF2196F3),
    ];
    final int shift = ((time * 8).floor() + index) % palette.length;
    return palette[shift];
  }

  Color _sparkleColor(double angle) {
    final int slot = ((angle * 100).round().abs()) % 4;
    switch (slot) {
      case 0:
        return const Color(0xFFF5B82E);
      case 1:
        return const Color(0xFF4CAF50);
      case 2:
        return const Color(0xFFFFFFFF);
      default:
        return const Color(0xFF2196F3);
    }
  }

  @override
  bool shouldRepaint(covariant _TickCrackerPainter oldDelegate) {
    return oldDelegate.orbit != orbit || oldDelegate.sparkleIn != sparkleIn;
  }
}

class _TickOnlyPainter extends CustomPainter {
  _TickOnlyPainter({
    required this.progress,
    required this.pulse,
  });

  final double progress;
  final double pulse;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);

    final double outerPulseRadius = 34 + (6 * pulse);
    final Paint pulseGlow = Paint()
      ..color = const Color(0xFF4CAF50).withValues(alpha: (0.16 * (1 - pulse)).clamp(0.0, 0.16))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawCircle(center, outerPulseRadius, pulseGlow);

    final Paint ringFill = Paint()..color = const Color(0xFF1A3A23);
    canvas.drawCircle(center, 33, ringFill);

    final Paint ringStroke = Paint()
      ..color = const Color(0xFF4CAF50)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4;
    canvas.drawCircle(center, 33, ringStroke);

    final Paint innerRing = Paint()
      ..color = const Color(0xFF86D98E).withValues(alpha: 0.32)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawCircle(center, 28, innerRing);

    final Paint ringGlow = Paint()
      ..color = const Color(0xFF4CAF50).withValues(alpha: 0.25 * progress)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(center, 31, ringGlow);

    final Path checkPath = Path()
      ..moveTo(center.dx - 15, center.dy)
      ..lineTo(center.dx - 4, center.dy + 11)
      ..lineTo(center.dx + 16, center.dy - 11);

    final Path visible = Path();
    for (final PathMetric metric in checkPath.computeMetrics()) {
      visible.addPath(metric.extractPath(0, metric.length * progress), Offset.zero);
    }

    final Paint checkPaint = Paint()
      ..color = const Color(0xFF4CAF50)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(visible, checkPaint);

    final Paint glow = Paint()
      ..color = const Color(0xFF4CAF50).withValues(alpha: 0.18 * progress)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawPath(visible, glow);
  }

  @override
  bool shouldRepaint(covariant _TickOnlyPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.pulse != pulse;
  }
}
