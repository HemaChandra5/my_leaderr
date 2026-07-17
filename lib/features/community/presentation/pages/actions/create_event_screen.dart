import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:async';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../providers/user_provider.dart';
import '../../../../events/models/event_model.dart';
import '../../../../events/widgets/event_card.dart';
import '../../../domain/models/community_hub_models.dart';
import '../../../state/community_hub_controller.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  static const int _totalSteps = 4;
  static const String _draftKey = 'create_event';

  final ImagePicker _picker = ImagePicker();

  final TextEditingController _title = TextEditingController();
  final TextEditingController _description = TextEditingController();
  final TextEditingController _hashtags = TextEditingController();
  final TextEditingController _mentions = TextEditingController();

  final TextEditingController _address = TextEditingController();
  final TextEditingController _ward = TextEditingController();
  final TextEditingController _city = TextEditingController();
  final TextEditingController _state = TextEditingController();

  final TextEditingController _agendaPdf = TextEditingController();
  final TextEditingController _documents = TextEditingController();
  final TextEditingController _livestreamLink = TextEditingController();
  final TextEditingController _maxParticipants = TextEditingController(text: '200');

  final TextEditingController _organizerName = TextEditingController();
  final TextEditingController _organizerPhone = TextEditingController();
  final TextEditingController _organizerEmail = TextEditingController();
  final TextEditingController _organizerWebsite = TextEditingController();
  final TextEditingController _socialLinks = TextEditingController();

  final TextEditingController _youtubeUrl = TextEditingController();
  final TextEditingController _facebookUrl = TextEditingController();
  final TextEditingController _customStream = TextEditingController();

  int _step = 0;
  bool _isSavingDraft = false;
  bool _isPublishing = false;
  bool _showSuccess = false;
  bool _hasUnsavedChanges = false;
  bool _showValidation = false;
  String? _friendlyValidation;

  Timer? _autoSaveTimer;
  Timer? _draftSavedTimer;

  String? _bannerPath;
  int _photoAssets = 0;
  int _videoAssets = 0;
  int _docAssets = 0;

  EventCategory _category = EventCategory.local;
  String _visibility = 'Public';

  DateTime? _startDate;
  DateTime? _endDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  DateTime? _registrationDeadline;

  bool _googleMapsPicker = true;
  bool _currentLocation = true;
  bool _dropPin = true;

  bool _unlimitedParticipants = false;
  bool _registrationRequired = true;

  bool _liveEvent = false;
  bool _liveChat = true;

  static const List<String> _stepTitles = <String>[
    'Basic Details',
    'Schedule & Location',
    'Media & Registration',
    'Preview & Publish',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _hydrateRoleDefaults();
      _loadDraft();
    });

    _autoSaveTimer = Timer.periodic(const Duration(seconds: 8), (_) {
      if (_hasUnsavedChanges && mounted) {
        _saveDraft(isAutoSave: true);
      }
    });
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    _draftSavedTimer?.cancel();

    _title.dispose();
    _description.dispose();
    _hashtags.dispose();
    _mentions.dispose();

    _address.dispose();
    _ward.dispose();
    _city.dispose();
    _state.dispose();

    _agendaPdf.dispose();
    _documents.dispose();
    _livestreamLink.dispose();
    _maxParticipants.dispose();

    _organizerName.dispose();
    _organizerPhone.dispose();
    _organizerEmail.dispose();
    _organizerWebsite.dispose();
    _socialLinks.dispose();

    _youtubeUrl.dispose();
    _facebookUrl.dispose();
    _customStream.dispose();
    super.dispose();
  }

  void _hydrateRoleDefaults() {
    final user = context.read<UserProvider>().appUser;
    _organizerName.text = user?.name.isNotEmpty == true ? user!.name : 'My Leader Organizer';
    _organizerPhone.text = user?.phone ?? '+91 00000 00000';
    _organizerEmail.text = user?.email ?? 'organizer@myleader.in';
    _organizerWebsite.text = 'www.myleader.in';
    _socialLinks.text = 'x.com/myleader • linkedin.com/company/myleader';
  }

  void _markChanged() {
    if (_hasUnsavedChanges) {
      return;
    }
    setState(() => _hasUnsavedChanges = true);
  }

  Future<void> _loadDraft() async {
    final draft = context.read<CommunityHubController>().getDraft(_draftKey);
    if (draft == null || !mounted) {
      return;
    }

    final Map<String, dynamic> d = draft.values;
    setState(() {
      _title.text = (d['title'] ?? '') as String;
      _description.text = (d['description'] ?? '') as String;
      _hashtags.text = (d['hashtags'] ?? '') as String;
      _mentions.text = (d['mentions'] ?? '') as String;

      _address.text = (d['address'] ?? '') as String;
      _ward.text = (d['ward'] ?? '') as String;
      _city.text = (d['city'] ?? '') as String;
      _state.text = (d['state'] ?? '') as String;

      _agendaPdf.text = (d['agendaPdf'] ?? '') as String;
      _documents.text = (d['documents'] ?? '') as String;
      _livestreamLink.text = (d['livestreamLink'] ?? '') as String;
      _maxParticipants.text = (d['maxParticipants'] ?? '200') as String;

      _organizerName.text = (d['organizerName'] ?? _organizerName.text) as String;
      _organizerPhone.text = (d['organizerPhone'] ?? _organizerPhone.text) as String;
      _organizerEmail.text = (d['organizerEmail'] ?? _organizerEmail.text) as String;
      _organizerWebsite.text = (d['organizerWebsite'] ?? _organizerWebsite.text) as String;
      _socialLinks.text = (d['socialLinks'] ?? _socialLinks.text) as String;

      _youtubeUrl.text = (d['youtubeUrl'] ?? '') as String;
      _facebookUrl.text = (d['facebookUrl'] ?? '') as String;
      _customStream.text = (d['customStream'] ?? '') as String;

      _bannerPath = d['bannerPath'] as String?;
      _photoAssets = (d['photoAssets'] ?? 0) as int;
      _videoAssets = (d['videoAssets'] ?? 0) as int;
      _docAssets = (d['docAssets'] ?? 0) as int;

      _category = EventCategory.values.firstWhere(
        (EventCategory item) => item.name == (d['category'] ?? EventCategory.local.name),
        orElse: () => EventCategory.local,
      );

      _visibility = (d['visibility'] ?? 'Public') as String;

      _startDate = _dateFromIso(d['startDate'] as String?);
      _endDate = _dateFromIso(d['endDate'] as String?);
      _registrationDeadline = _dateFromIso(d['registrationDeadline'] as String?);
      _startTime = _timeFromText(d['startTime'] as String?);
      _endTime = _timeFromText(d['endTime'] as String?);

      _googleMapsPicker = (d['googleMapsPicker'] ?? true) as bool;
      _currentLocation = (d['currentLocation'] ?? true) as bool;
      _dropPin = (d['dropPin'] ?? true) as bool;

      _unlimitedParticipants = (d['unlimitedParticipants'] ?? false) as bool;
      _registrationRequired = (d['registrationRequired'] ?? true) as bool;
      _liveEvent = (d['liveEvent'] ?? false) as bool;
      _liveChat = (d['liveChat'] ?? true) as bool;

      _step = ((d['step'] ?? 0) as int).clamp(0, _totalSteps - 1);
      _hasUnsavedChanges = false;
    });
  }

  DateTime? _dateFromIso(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    return DateTime.tryParse(value);
  }

  TimeOfDay? _timeFromText(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    final List<String> parts = value.split(':');
    if (parts.length != 2) {
      return null;
    }
    final int? hour = int.tryParse(parts.first);
    final int? minute = int.tryParse(parts.last);
    if (hour == null || minute == null) {
      return null;
    }
    return TimeOfDay(hour: hour, minute: minute);
  }

  Map<String, dynamic> _buildDraftPayload() {
    return <String, dynamic>{
      'title': _title.text.trim(),
      'description': _description.text.trim(),
      'hashtags': _hashtags.text.trim(),
      'mentions': _mentions.text.trim(),

      'address': _address.text.trim(),
      'ward': _ward.text.trim(),
      'city': _city.text.trim(),
      'state': _state.text.trim(),

      'agendaPdf': _agendaPdf.text.trim(),
      'documents': _documents.text.trim(),
      'livestreamLink': _livestreamLink.text.trim(),
      'maxParticipants': _maxParticipants.text.trim(),

      'organizerName': _organizerName.text.trim(),
      'organizerPhone': _organizerPhone.text.trim(),
      'organizerEmail': _organizerEmail.text.trim(),
      'organizerWebsite': _organizerWebsite.text.trim(),
      'socialLinks': _socialLinks.text.trim(),

      'youtubeUrl': _youtubeUrl.text.trim(),
      'facebookUrl': _facebookUrl.text.trim(),
      'customStream': _customStream.text.trim(),

      'bannerPath': _bannerPath,
      'photoAssets': _photoAssets,
      'videoAssets': _videoAssets,
      'docAssets': _docAssets,

      'category': _category.name,
      'visibility': _visibility,

      'startDate': _startDate?.toIso8601String(),
      'endDate': _endDate?.toIso8601String(),
      'registrationDeadline': _registrationDeadline?.toIso8601String(),
      'startTime': _startTime == null ? null : '${_startTime!.hour}:${_startTime!.minute}',
      'endTime': _endTime == null ? null : '${_endTime!.hour}:${_endTime!.minute}',

      'googleMapsPicker': _googleMapsPicker,
      'currentLocation': _currentLocation,
      'dropPin': _dropPin,

      'unlimitedParticipants': _unlimitedParticipants,
      'registrationRequired': _registrationRequired,
      'liveEvent': _liveEvent,
      'liveChat': _liveChat,

      'step': _step,
    };
  }

  Future<void> _saveDraft({bool isAutoSave = false}) async {
    if (!mounted) {
      return;
    }
    setState(() => _isSavingDraft = true);
    context.read<CommunityHubController>().saveDraft(_draftKey, _buildDraftPayload());

    await Future<void>.delayed(const Duration(milliseconds: 220));
    if (!mounted) {
      return;
    }

    _draftSavedTimer?.cancel();
    setState(() {
      _isSavingDraft = false;
      _hasUnsavedChanges = false;
      _showValidation = false;
      if (!isAutoSave) {
        _friendlyValidation = null;
      }
    });

    _draftSavedTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {});
      }
    });
  }

  String? _validateStep(int index) {
    switch (index) {
      case 0:
        if (_bannerPath == null || _bannerPath!.isEmpty) {
          return 'Please upload an event banner.';
        }
        if (_title.text.trim().isEmpty) {
          return 'Please enter an event title.';
        }
        if (_description.text.trim().isEmpty) {
          return 'Please enter an event description.';
        }
        return null;
      case 1:
        if (_startDate == null || _startTime == null) {
          return 'Please choose a start date and time.';
        }
        if (_endDate == null || _endTime == null) {
          return 'Please choose an end date and time.';
        }
        if (_address.text.trim().isEmpty) {
          return 'Please choose a location.';
        }
        return null;
      case 2:
        if (!_unlimitedParticipants &&
            (int.tryParse(_maxParticipants.text.trim()) == null ||
                int.parse(_maxParticipants.text.trim()) <= 0)) {
          return 'Please provide valid participant capacity.';
        }
        return null;
      default:
        if (_organizerName.text.trim().isEmpty) {
          return 'Please add organizer details.';
        }
        return null;
    }
  }

  bool _validateAllSteps() {
    for (int i = 0; i < _totalSteps; i++) {
      final String? error = _validateStep(i);
      if (error != null) {
        setState(() {
          _step = i;
          _friendlyValidation = error;
          _showValidation = true;
        });
        return false;
      }
    }
    return true;
  }

  Future<void> _pickBanner() async {
    final XFile? file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 78,
      maxHeight: 1800,
      maxWidth: 3200,
    );
    if (file == null || !mounted) {
      return;
    }
    setState(() {
      _bannerPath = file.path;
      _hasUnsavedChanges = true;
    });
  }

  Future<void> _pickPhotos() async {
    final List<XFile> files = await _picker.pickMultiImage(
      imageQuality: 80,
      maxHeight: 1400,
      maxWidth: 2200,
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _photoAssets += files.length;
      _hasUnsavedChanges = true;
    });
  }

  Future<void> _pickVideo() async {
    final XFile? file = await _picker.pickVideo(
      source: ImageSource.gallery,
      maxDuration: const Duration(minutes: 8),
    );
    if (file == null || !mounted) {
      return;
    }
    setState(() {
      _videoAssets += 1;
      _hasUnsavedChanges = true;
    });
  }

  Future<void> _pickDate({required bool start}) async {
    final DateTime initial =
        (start ? _startDate : _endDate) ?? DateTime.now().add(const Duration(days: 2));
    final DateTime? picked = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2035),
      initialDate: initial,
    );
    if (picked == null) {
      return;
    }
    setState(() {
      if (start) {
        _startDate = picked;
      } else {
        _endDate = picked;
      }
      _hasUnsavedChanges = true;
    });
  }

  Future<void> _pickTime({required bool start}) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: (start ? _startTime : _endTime) ?? const TimeOfDay(hour: 10, minute: 0),
    );
    if (picked == null) {
      return;
    }
    setState(() {
      if (start) {
        _startTime = picked;
      } else {
        _endTime = picked;
      }
      _hasUnsavedChanges = true;
    });
  }

  Future<void> _pickRegistrationDeadline() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2035),
      initialDate: _registrationDeadline ?? DateTime.now().add(const Duration(days: 1)),
    );
    if (picked == null) {
      return;
    }
    setState(() {
      _registrationDeadline = picked;
      _hasUnsavedChanges = true;
    });
  }

  void _nextStep() {
    final String? error = _validateStep(_step);
    if (error != null) {
      setState(() {
        _friendlyValidation = error;
        _showValidation = true;
      });
      return;
    }

    if (_step < _totalSteps - 1) {
      setState(() {
        _step += 1;
        _showValidation = false;
      });
    }
  }

  void _goToPreview() {
    final String? error = _validateStep(_step);
    if (error != null) {
      setState(() {
        _friendlyValidation = error;
        _showValidation = true;
      });
      return;
    }
    setState(() {
      _step = 3;
      _showValidation = false;
    });
  }

  Future<void> _publishEvent() async {
    if (!_validateAllSteps()) {
      return;
    }

    setState(() {
      _isPublishing = true;
      _showValidation = false;
      _friendlyValidation = null;
    });

    final DateTime eventDate = _startDate ?? DateTime.now().add(const Duration(days: 2));
    final String timeLabel = _startTime == null
        ? '10:00 AM'
        : _startTime!.format(context);

    context.read<CommunityHubController>().publishEvent(
          CommunityEventDraft(
            title: _title.text.trim(),
            description: _description.text.trim(),
            category: _category,
            date: eventDate,
            time: timeLabel,
            location: _address.text.trim(),
            organizer: _organizerName.text.trim(),
            isOnline: _liveEvent,
            registrationDeadline: _registrationDeadline,
          ),
        );

    await Future<void>.delayed(const Duration(milliseconds: 650));
    if (!mounted) {
      return;
    }

    context.read<CommunityHubController>().clearDraft(_draftKey);

    setState(() {
      _isPublishing = false;
      _showSuccess = true;
    });

    await Future<void>.delayed(const Duration(milliseconds: 1200));
    if (!mounted) {
      return;
    }
    Navigator.of(context).pushReplacementNamed('/events');
  }

  List<EventCategory> _categoryOptionsForRole(UserProvider provider) {
    final user = provider.appUser;
    if (user == null) {
      return <EventCategory>[EventCategory.local];
    }
    if (user.isLeader) {
      return EventCategory.values;
    }
    return <EventCategory>[EventCategory.local];
  }

  String _fmtDate(DateTime? date) {
    if (date == null) {
      return 'Select date';
    }
    return '${date.day}/${date.month}/${date.year}';
  }

  String _fmtTime(TimeOfDay? time) {
    if (time == null) {
      return 'Select time';
    }
    return time.format(context);
  }

  Widget _buildStepContent(UserProvider userProvider) {
    switch (_step) {
      case 0:
        return _buildStepBasicDetails(userProvider);
      case 1:
        return _buildStepScheduleLocation();
      case 2:
        return _buildStepMediaRegistration();
      default:
        return _buildStepPreviewPublish(userProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final UserProvider userProvider = context.watch<UserProvider>();

    return PopScope(
      canPop: !_hasUnsavedChanges,
      onPopInvokedWithResult: (bool didPop, dynamic _) {
        if (!didPop && _hasUnsavedChanges) {
          setState(() {
            _friendlyValidation = 'You have unsaved changes. Tap Save Draft before leaving.';
            _showValidation = true;
          });
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: <Widget>[
              Hero(
                tag: 'quick-action-Create Event',
                child: CircleAvatar(
                  backgroundColor: AppColors.primaryGold.withValues(alpha: 0.16),
                  child: Icon(Icons.event_available_rounded, color: AppColors.primaryGold),
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Create Event',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
        ),
        body: Stack(
          children: <Widget>[
            SafeArea(
              child: Column(
                children: <Widget>[
                  _WizardProgress(
                    currentStep: _step,
                    totalSteps: _totalSteps,
                    titles: _stepTitles,
                  ),
                  if (_showValidation && _friendlyValidation != null)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 260),
                      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colors.errorContainer,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: <Widget>[
                          Icon(Icons.info_rounded, color: colors.onErrorContainer),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _friendlyValidation!,
                              style: TextStyle(color: colors.onErrorContainer),
                            ),
                          ),
                        ],
                      ),
                    ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(
                        16,
                        10,
                        16,
                        MediaQuery.viewInsetsOf(context).bottom + 120,
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 280),
                        transitionBuilder: (Widget child, Animation<double> animation) {
                          final Animation<Offset> slide = Tween<Offset>(
                            begin: const Offset(0.08, 0),
                            end: Offset.zero,
                          ).animate(animation);
                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(position: slide, child: child),
                          );
                        },
                        child: KeyedSubtree(
                          key: ValueKey<int>(_step),
                          child: _buildStepContent(userProvider),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_showSuccess)
              IgnorePointer(
                child: Container(
                  color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.22),
                  alignment: Alignment.center,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0.65, end: 1),
                    duration: const Duration(milliseconds: 420),
                    curve: Curves.elasticOut,
                    builder: (context, value, _) {
                      return Transform.scale(
                        scale: value,
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 24),
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: colors.surface,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.16),
                                blurRadius: 24,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text('🎉', style: TextStyle(fontSize: 26)),
                              SizedBox(width: 10),
                              Text(
                                'Event Published Successfully',
                                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          child: Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            decoration: BoxDecoration(
              color: colors.surface,
              border: Border(top: BorderSide(color: AppColors.divider)),
            ),
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final bool compact = constraints.maxWidth < 560;
                if (compact) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Cancel'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _isSavingDraft ? null : () => _saveDraft(),
                              icon: _isSavingDraft
                                  ? const SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Icon(Icons.save_outlined),
                              label: const Text('Save Draft'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: FilledButton.tonal(
                              onPressed: _goToPreview,
                              child: const Text('Preview'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _GradientPublishButton(
                              onPressed: _isPublishing ? null : _publishEvent,
                              busy: _isPublishing,
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                }

                return Row(
                  children: <Widget>[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _isSavingDraft ? null : () => _saveDraft(),
                        icon: _isSavingDraft
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.save_outlined),
                        label: const Text('Save Draft'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: FilledButton.tonal(
                        onPressed: _goToPreview,
                        child: const Text('Preview'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _GradientPublishButton(
                        onPressed: _isPublishing ? null : _publishEvent,
                        busy: _isPublishing,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
        floatingActionButton: _step < _totalSteps - 1
            ? FloatingActionButton.extended(
                onPressed: _nextStep,
                icon: const Icon(Icons.arrow_forward_rounded),
                label: Text('Next: ${_stepTitles[_step + 1]}'),
              )
            : null,
      ),
    );
  }

  Widget _buildStepBasicDetails(UserProvider provider) {
    final List<EventCategory> allowed = _categoryOptionsForRole(provider);
    if (!allowed.contains(_category)) {
      _category = EventCategory.local;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const _SectionHeader(
          title: 'Step 1 - Basic Details',
          subtitle: 'Create the first impression with banner and story.',
        ),
        const SizedBox(height: 12),
        _PremiumCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Event Banner',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
              ),
              const SizedBox(height: 8),
              const Text('Recommended size: 1600 x 900 px (16:9)'),
              const SizedBox(height: 12),
              Hero(
                tag: 'event-banner-preview',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: Container(
                    height: 198,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: <Color>[
                          AppColors.primaryGold.withValues(alpha: 0.18),
                          AppColors.surfaceElevated,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: _bannerPath == null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(
                                Icons.image_outlined,
                                size: 48,
                                color: AppColors.primaryGold,
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Upload a premium event banner',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                            ],
                          )
                        : Image.asset(
                            _bannerPath!,
                            fit: BoxFit.cover,
                            errorBuilder: (BuildContext context, Object _, StackTrace? _) {
                              return const Center(child: Text('Banner selected'));
                            },
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  FilledButton.icon(
                    onPressed: _pickBanner,
                    icon: const Icon(Icons.upload_rounded),
                    label: Text(_bannerPath == null ? 'Upload Banner' : 'Replace Banner'),
                  ),
                  OutlinedButton.icon(
                    onPressed: _bannerPath == null ? null : _pickBanner,
                    icon: const Icon(Icons.preview_rounded),
                    label: const Text('Preview Banner'),
                  ),
                  OutlinedButton.icon(
                    onPressed: _bannerPath == null
                        ? null
                        : () {
                            setState(() {
                              _bannerPath = null;
                              _hasUnsavedChanges = true;
                            });
                          },
                    icon: const Icon(Icons.delete_outline_rounded),
                    label: const Text('Remove Banner'),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _PremiumCard(
          child: Column(
            children: <Widget>[
              _CounterField(
                controller: _title,
                label: 'Event Title',
                max: 120,
                onChanged: (_) => _markChanged(),
              ),
              const SizedBox(height: 10),
              _CounterField(
                controller: _description,
                label: 'Rich Description',
                max: 1200,
                maxLines: 6,
                onChanged: (_) => _markChanged(),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: allowed
                      .map(
                        (EventCategory item) => ChoiceChip(
                          selected: item == _category,
                          label: Text(item.label),
                          onSelected: (_) {
                            setState(() => _category = item);
                            _markChanged();
                          },
                        ),
                      )
                      .toList(growable: false),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: _hashtags,
                      onChanged: (_) => _markChanged(),
                      decoration: const InputDecoration(
                        labelText: 'Hashtags',
                        hintText: '#civic #publicService',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _mentions,
                      onChanged: (_) => _markChanged(),
                      decoration: const InputDecoration(
                        labelText: 'Mentions',
                        hintText: '@wardOfficer @leader',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  spacing: 8,
                  children: const <String>['😀', '🎯', '📍', '🤝', '🏛️']
                      .map(
                        (String emoji) => ActionChip(
                          label: Text(emoji),
                          onPressed: null,
                        ),
                      )
                      .toList(growable: false),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStepScheduleLocation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const _SectionHeader(
          title: 'Step 2 - Date, Time & Location',
          subtitle: 'Set schedule with map-ready civic location details.',
        ),
        const SizedBox(height: 12),
        _PremiumCard(
          child: Column(
            children: <Widget>[
              _DateTimeCard(
                title: 'Start',
                dateLabel: _fmtDate(_startDate),
                timeLabel: _fmtTime(_startTime),
                onDateTap: () => _pickDate(start: true),
                onTimeTap: () => _pickTime(start: true),
              ),
              const SizedBox(height: 10),
              _DateTimeCard(
                title: 'End',
                dateLabel: _fmtDate(_endDate),
                timeLabel: _fmtTime(_endTime),
                onDateTap: () => _pickDate(start: false),
                onTimeTap: () => _pickTime(start: false),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: _pickRegistrationDeadline,
                icon: const Icon(Icons.event_note_rounded),
                label: Text('Registration Deadline: ${_fmtDate(_registrationDeadline)}'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _PremiumCard(
          child: Column(
            children: <Widget>[
              TextField(
                controller: _address,
                onChanged: (_) => _markChanged(),
                decoration: const InputDecoration(
                  labelText: 'Location / Address',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: _ward,
                      onChanged: (_) => _markChanged(),
                      decoration: const InputDecoration(labelText: 'Ward', border: OutlineInputBorder()),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _city,
                      onChanged: (_) => _markChanged(),
                      decoration: const InputDecoration(labelText: 'City', border: OutlineInputBorder()),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _state,
                      onChanged: (_) => _markChanged(),
                      decoration: const InputDecoration(labelText: 'State', border: OutlineInputBorder()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                children: <Widget>[
                  FilterChip(
                    selected: _googleMapsPicker,
                    label: const Text('Google Maps Picker'),
                    onSelected: (bool value) {
                      setState(() => _googleMapsPicker = value);
                      _markChanged();
                    },
                  ),
                  FilterChip(
                    selected: _currentLocation,
                    label: const Text('Current Location'),
                    onSelected: (bool value) {
                      setState(() => _currentLocation = value);
                      _markChanged();
                    },
                  ),
                  FilterChip(
                    selected: _dropPin,
                    label: const Text('Drop Pin'),
                    onSelected: (bool value) {
                      setState(() => _dropPin = value);
                      _markChanged();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.divider),
                  gradient: LinearGradient(
                    colors: <Color>[
                      AppColors.surfaceElevated,
                      AppColors.primaryGold.withValues(alpha: 0.12),
                    ],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Icon(Icons.map_rounded, size: 42),
                    const SizedBox(height: 8),
                    Text(
                      _address.text.trim().isEmpty
                          ? 'Map preview appears after selecting location'
                          : 'Map preview: ${_address.text.trim()}',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStepMediaRegistration() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const _SectionHeader(
          title: 'Step 3 - Media & Registration',
          subtitle: 'Add rich assets and configure registration policy.',
        ),
        const SizedBox(height: 12),
        _PremiumCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text('Media Uploads', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  FilledButton.tonalIcon(
                    onPressed: _pickBanner,
                    icon: const Icon(Icons.image_rounded),
                    label: Text(_bannerPath == null ? 'Event Banner' : 'Banner Ready'),
                  ),
                  FilledButton.tonalIcon(
                    onPressed: _pickPhotos,
                    icon: const Icon(Icons.collections_rounded),
                    label: Text('Photos ($_photoAssets)'),
                  ),
                  FilledButton.tonalIcon(
                    onPressed: _pickVideo,
                    icon: const Icon(Icons.video_collection_rounded),
                    label: Text('Videos ($_videoAssets)'),
                  ),
                  FilledButton.tonalIcon(
                    onPressed: () {
                      setState(() {
                        _docAssets += 1;
                        _hasUnsavedChanges = true;
                      });
                    },
                    icon: const Icon(Icons.picture_as_pdf_rounded),
                    label: const Text('Agenda PDF'),
                  ),
                  FilledButton.tonalIcon(
                    onPressed: () {
                      setState(() {
                        _docAssets += 1;
                        _hasUnsavedChanges = true;
                      });
                    },
                    icon: const Icon(Icons.description_rounded),
                    label: Text('Documents ($_docAssets)'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _agendaPdf,
                onChanged: (_) => _markChanged(),
                decoration: const InputDecoration(
                  labelText: 'Agenda PDF Link (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _documents,
                onChanged: (_) => _markChanged(),
                decoration: const InputDecoration(
                  labelText: 'Supporting Documents Link',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _livestreamLink,
                onChanged: (_) => _markChanged(),
                decoration: const InputDecoration(
                  labelText: 'Livestream Link',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _PremiumCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text('Registration Settings', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
              const SizedBox(height: 10),
              SwitchListTile.adaptive(
                value: _unlimitedParticipants,
                onChanged: (bool value) {
                  setState(() => _unlimitedParticipants = value);
                  _markChanged();
                },
                title: const Text('Unlimited Participants'),
              ),
              if (!_unlimitedParticipants)
                TextField(
                  controller: _maxParticipants,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => _markChanged(),
                  decoration: const InputDecoration(
                    labelText: 'Maximum Participants',
                    border: OutlineInputBorder(),
                  ),
                ),
              const SizedBox(height: 8),
              SwitchListTile.adaptive(
                value: _registrationRequired,
                onChanged: (bool value) {
                  setState(() => _registrationRequired = value);
                  _markChanged();
                },
                title: const Text('Registration Required'),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _visibility,
                decoration: const InputDecoration(
                  labelText: 'Visibility',
                  border: OutlineInputBorder(),
                ),
                items: const <String>['Public', 'Followers', 'Invite Only']
                    .map((String v) => DropdownMenuItem<String>(value: v, child: Text(v)))
                    .toList(growable: false),
                onChanged: (String? value) {
                  if (value == null) {
                    return;
                  }
                  setState(() => _visibility = value);
                  _markChanged();
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStepPreviewPublish(UserProvider provider) {
    final bool verified = provider.appUser?.isVerifiedLeader ?? provider.appUser?.isLeader ?? false;

    final EventModel previewModel = EventModel(
      id: 'preview',
      title: _title.text.trim().isEmpty ? 'Your Event Title' : _title.text.trim(),
      description: _description.text.trim().isEmpty
          ? 'Your rich event description will appear here.'
          : _description.text.trim(),
      imageUrl: 'https://images.unsplash.com/photo-1511578314322-379afb476865?auto=format&fit=crop&w=1400&q=80',
      category: _category,
      date: _startDate ?? DateTime.now().add(const Duration(days: 7)),
      time: _fmtTime(_startTime) == 'Select time' ? '10:00 AM' : _fmtTime(_startTime),
      location: _address.text.trim().isEmpty ? 'Location not selected' : _address.text.trim(),
      organizer: _organizerName.text.trim().isEmpty ? 'Organizer' : _organizerName.text.trim(),
      interestedCount: _unlimitedParticipants ? 0 : (int.tryParse(_maxParticipants.text) ?? 0),
      status: EventStatus.upcoming,
      isFree: true,
      isOnline: _liveEvent,
      tags: <EventFilterTag>{EventFilterTag.leadership},
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const _SectionHeader(
          title: 'Step 4 - Organizer, Live Event, Preview',
          subtitle: 'Finalize organizer details and publish with confidence.',
        ),
        const SizedBox(height: 12),
        _PremiumCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text('Organizer Card', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
              const SizedBox(height: 10),
              Row(
                children: <Widget>[
                  Hero(
                    tag: 'organizer-photo-card',
                    child: CircleAvatar(
                      radius: 28,
                      backgroundColor: AppColors.primaryGold.withValues(alpha: 0.16),
                      child: Text(
                        _organizerName.text.isEmpty ? 'ML' : _organizerName.text[0].toUpperCase(),
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _organizerName,
                      onChanged: (_) => _markChanged(),
                      decoration: const InputDecoration(
                        labelText: 'Organizer Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (verified)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGold.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Icon(Icons.verified_rounded, size: 16),
                          SizedBox(width: 4),
                          Text('Verified', style: TextStyle(fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _organizerPhone,
                onChanged: (_) => _markChanged(),
                decoration: const InputDecoration(labelText: 'Phone', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _organizerEmail,
                onChanged: (_) => _markChanged(),
                decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _organizerWebsite,
                onChanged: (_) => _markChanged(),
                decoration: const InputDecoration(labelText: 'Website', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _socialLinks,
                onChanged: (_) => _markChanged(),
                decoration: const InputDecoration(labelText: 'Social Links', border: OutlineInputBorder()),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _PremiumCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text('Live Event', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
              SwitchListTile.adaptive(
                value: _liveEvent,
                onChanged: (bool value) {
                  setState(() => _liveEvent = value);
                  _markChanged();
                },
                title: const Text('Enable Live Event'),
              ),
              if (_liveEvent) ...<Widget>[
                TextField(
                  controller: _youtubeUrl,
                  onChanged: (_) => _markChanged(),
                  decoration: const InputDecoration(labelText: 'YouTube URL', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _facebookUrl,
                  onChanged: (_) => _markChanged(),
                  decoration: const InputDecoration(labelText: 'Facebook URL', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _customStream,
                  onChanged: (_) => _markChanged(),
                  decoration: const InputDecoration(labelText: 'Custom Stream', border: OutlineInputBorder()),
                ),
                SwitchListTile.adaptive(
                  value: _liveChat,
                  onChanged: (bool value) {
                    setState(() => _liveChat = value);
                    _markChanged();
                  },
                  title: const Text('Enable Live Chat'),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Event Preview',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
        ),
        const SizedBox(height: 8),
        EventCard(
          event: previewModel,
          index: 0,
          onViewDetails: () {},
          onShare: () {},
          onBookmark: () {},
          onOrganizerTap: () {},
        ),
        const SizedBox(height: 10),
        _PremiumCard(
          child: Row(
            children: <Widget>[
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.how_to_reg_rounded),
                  label: const Text('Register'),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                onPressed: () {},
                icon: const Icon(Icons.share_rounded),
              ),
              const SizedBox(width: 6),
              IconButton.filledTonal(
                onPressed: () {},
                icon: const Icon(Icons.bookmark_border_rounded),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _WizardProgress extends StatelessWidget {
  const _WizardProgress({
    required this.currentStep,
    required this.totalSteps,
    required this.titles,
  });

  final int currentStep;
  final int totalSteps;
  final List<String> titles;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Column(
        children: <Widget>[
          LinearProgressIndicator(
            value: (currentStep + 1) / totalSteps,
            borderRadius: BorderRadius.circular(999),
            minHeight: 8,
            color: AppColors.primaryGold,
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List<Widget>.generate(titles.length, (int index) {
                final bool active = index <= currentStep;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 260),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: active
                        ? AppColors.primaryGold.withValues(alpha: 0.16)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Text(
                    '${index + 1}. ${titles[index]}',
                    style: TextStyle(fontWeight: active ? FontWeight.w800 : FontWeight.w600),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
        const SizedBox(height: 4),
        Text(subtitle, style: TextStyle(color: AppColors.textMuted)),
      ],
    );
  }
}

class _PremiumCard extends StatelessWidget {
  const _PremiumCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.divider),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _DateTimeCard extends StatelessWidget {
  const _DateTimeCard({
    required this.title,
    required this.dateLabel,
    required this.timeLabel,
    required this.onDateTap,
    required this.onTimeTap,
  });

  final String title;
  final String dateLabel;
  final String timeLabel;
  final VoidCallback onDateTap;
  final VoidCallback onTimeTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onDateTap,
                  icon: const Icon(Icons.calendar_month_rounded),
                  label: Text(dateLabel),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onTimeTap,
                  icon: const Icon(Icons.schedule_rounded),
                  label: Text(timeLabel),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CounterField extends StatelessWidget {
  const _CounterField({
    required this.controller,
    required this.label,
    required this.max,
    required this.onChanged,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String label;
  final int max;
  final int maxLines;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final int count = controller.text.length;

    return TextField(
      controller: controller,
      maxLines: maxLines,
      maxLength: max,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        counterText: '$count/$max',
      ),
    );
  }
}

class _GradientPublishButton extends StatelessWidget {
  const _GradientPublishButton({
    required this.onPressed,
    required this.busy,
  });

  final VoidCallback? onPressed;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: const LinearGradient(
          colors: <Color>[Color(0xFFF5A623), Color(0xFFD4871A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          foregroundColor: Colors.black,
        ),
        child: busy
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Text('Publish Event'),
      ),
    );
  }
}
