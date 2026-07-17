import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/authority_profile.dart';
import '../models/issue_category.dart';
import '../models/submitted_issue.dart';
import '../services/authority_service.dart';
import '../services/issue_submission_service.dart';
import '../services/location_service.dart';
import '../services/media_picker_service.dart';
import '../utils/report_issue_constants.dart';
import '../utils/validators.dart';

class ReportIssueProvider extends ChangeNotifier {
  ReportIssueProvider({
    required this.mediaPickerService,
    required this.locationService,
    required this.submissionService,
    required this.authorityService,
  });

  final MediaPickerService mediaPickerService;
  final LocationService locationService;
  final IssueSubmissionService submissionService;
  final AuthorityService authorityService;

  final List<PickedMedia> _mediaItems = <PickedMedia>[];
  final List<AuthorityProfile> _authorities = <AuthorityProfile>[];
  final List<AuthorityProfile> _publicRepresentatives = <AuthorityProfile>[];
  final List<AuthorityProfile> _governmentAuthorities = <AuthorityProfile>[];
  final List<AuthorityProfile> _recommendedAuthorities = <AuthorityProfile>[];
  final List<AuthorityProfile> _selectedAuthorities = <AuthorityProfile>[];
  Timer? _draftDebounce;
  int _locationRequestToken = 0;
  bool _isDisposed = false;

  int _currentStep = 0;
  String? _selectedCategoryId;
  String _authoritySearchQuery = '';
  String _description = '';
  String _locationInput = '';
  double? _detectedLatitude;
  double? _detectedLongitude;
  Map<String, String> _addressComponents = <String, String>{};
  String? _locationPlaceId;
  DateTime? _locationTimestamp;
  bool _autoAddressLoaded = false;
  bool _isLoadingAuthorities = false;
  bool _isPickingMedia = false;
  bool _isSubmitting = false;
  bool _isLocating = false;
  bool _attemptedCategoryNext = false;
  bool _attemptedDescriptionNext = false;
  bool _attemptedLocationNext = false;
  bool _showLocationPermissionDialog = false;
  bool _submissionDone = false;
  bool _isGeneratingSuggestion = false;
  bool _draftRestored = false;
  String? _mediaError;
  String? _mediaWarning;
  String? _autoLocationText;
  String? _locationError;
  String? _submissionError;
  SubmittedIssue? _lastSubmittedIssue;

  List<IssueCategory> get categories => IssueCategoryCatalog.all;
  List<PickedMedia> get mediaItems =>
      List<PickedMedia>.unmodifiable(_mediaItems);
  List<AuthorityProfile> get authorities =>
      List<AuthorityProfile>.unmodifiable(_authorities);
  List<AuthorityProfile> get publicRepresentatives =>
      List<AuthorityProfile>.unmodifiable(_publicRepresentatives);
  List<AuthorityProfile> get governmentAuthorities =>
      List<AuthorityProfile>.unmodifiable(_governmentAuthorities);
  List<AuthorityProfile> get recommendedAuthorities =>
      List<AuthorityProfile>.unmodifiable(_recommendedAuthorities);
  List<AuthorityProfile> get selectedAuthorities =>
      List<AuthorityProfile>.unmodifiable(_selectedAuthorities);

  List<AuthorityProfile> get filteredPublicRepresentatives {
    final String query = _authoritySearchQuery.trim();
    if (query.isEmpty) {
      return List<AuthorityProfile>.unmodifiable(_publicRepresentatives);
    }
    return List<AuthorityProfile>.unmodifiable(
      _publicRepresentatives.where(
        (AuthorityProfile authority) => authority.matchesQuery(query),
      ),
    );
  }

  List<AuthorityProfile> get filteredGovernmentAuthorities {
    final String query = _authoritySearchQuery.trim();
    if (query.isEmpty) {
      return List<AuthorityProfile>.unmodifiable(_governmentAuthorities);
    }
    return List<AuthorityProfile>.unmodifiable(
      _governmentAuthorities.where(
        (AuthorityProfile authority) => authority.matchesQuery(query),
      ),
    );
  }

  int get currentStep => _currentStep;
  bool get isLastStep => _currentStep == 6;
  bool get canGoBackStep => _currentStep > 0;
  bool get isLoadingAuthorities => _isLoadingAuthorities;
  bool get isGeneratingSuggestion => _isGeneratingSuggestion;
  bool get draftRestored => _draftRestored;
  int get selectedAuthoritiesCount => _selectedAuthorities.length;

  String? get selectedCategoryId => _selectedCategoryId;
  String get authoritySearchQuery => _authoritySearchQuery;
  String get description => _description;
  String get locationInput => _locationInput;
  bool get isPickingMedia => _isPickingMedia;
  bool get isSubmitting => _isSubmitting;
  bool get isLocating => _isLocating;
  String? get mediaError => _mediaError;
  String? get mediaWarning => _mediaWarning;
  String? get autoLocationText => _autoLocationText;
  String get effectiveLocation => _locationInput.trim();
  double? get detectedLatitude => _detectedLatitude;
  double? get detectedLongitude => _detectedLongitude;
  Map<String, String> get addressComponents =>
      Map<String, String>.unmodifiable(_addressComponents);
  String? get locationPlaceId => _locationPlaceId;
  DateTime? get locationTimestamp => _locationTimestamp;
  bool get autoAddressLoaded => _autoAddressLoaded;
  bool get canEditLocationManually => _autoAddressLoaded;
  bool get hasResolvedLocation =>
      _detectedLatitude != null &&
      _detectedLongitude != null &&
      _autoAddressLoaded;
  String? get locationError => _locationError;
  bool get showLocationPermissionDialog => _showLocationPermissionDialog;
  String? get submissionError => _submissionError;
  SubmittedIssue? get lastSubmittedIssue => _lastSubmittedIssue;

  bool consumeLocationPermissionDialogRequest() {
    final bool value = _showLocationPermissionDialog;
    _showLocationPermissionDialog = false;
    return value;
  }

  int get descriptionLength => _description.characters.length;

  String? get categoryError => _attemptedCategoryNext
      ? ReportIssueValidators.validateCategory(_selectedCategoryId)
      : null;

  String? get authorityError {
    return null;
  }

  String? get descriptionError {
    if (_attemptedDescriptionNext || _description.isNotEmpty) {
      return ReportIssueValidators.validateDescription(_description);
    }
    return null;
  }

  String? get locationFieldError {
    if (_attemptedLocationNext || _locationInput.isNotEmpty) {
      return ReportIssueValidators.validateLocation(_locationInput);
    }
    return null;
  }

  bool get canProceedCurrentStep {
    if (_isPickingMedia || _isLocating || _isSubmitting) {
      return false;
    }

    switch (_currentStep) {
      case 0:
        return true;
      case 1:
        return ReportIssueValidators.validateCategory(_selectedCategoryId) ==
            null;
      case 2:
        return true;
      case 3:
        return ReportIssueValidators.validateDescription(_description) == null;
      case 4:
        return true;
      case 5:
        return ReportIssueValidators.validateLocation(_locationInput) == null;
      case 6:
        return !_submissionDone;
      default:
        return false;
    }
  }

  void selectCategory(String categoryId) {
    _submissionError = null;
    _selectedCategoryId = categoryId;
    _rebuildAuthoritySections();
    _saveDraftNow();
    notifyListeners();
  }

  Future<void> loadAuthoritiesIfNeeded() async {
    if (_isLoadingAuthorities || _authorities.isNotEmpty) {
      return;
    }
    _isLoadingAuthorities = true;
    notifyListeners();

    try {
      final List<AuthorityProfile> list = await authorityService
          .fetchAuthorities();
      _authorities
        ..clear()
        ..addAll(list);
      _rebuildAuthoritySections();
    } finally {
      _isLoadingAuthorities = false;
      notifyListeners();
    }
  }

  void updateAuthoritySearch(String value) {
    _authoritySearchQuery = value;
    notifyListeners();
  }

  bool isAuthoritySelected(String authorityId) {
    return _selectedAuthorities.any(
      (AuthorityProfile item) => item.id == authorityId,
    );
  }

  void toggleAuthority(AuthorityProfile authority) {
    final int existingIndex = _selectedAuthorities.indexWhere(
      (AuthorityProfile item) => item.id == authority.id,
    );
    if (existingIndex >= 0) {
      _selectedAuthorities.removeAt(existingIndex);
    } else {
      _selectedAuthorities.add(authority);
    }
    _submissionError = null;
    _saveDraftNow();
    notifyListeners();
  }

  void removeTaggedAuthority(String authorityId) {
    _selectedAuthorities.removeWhere(
      (AuthorityProfile item) => item.id == authorityId,
    );
    _saveDraftNow();
    notifyListeners();
  }

  void updateDescription(String value) {
    _submissionError = null;
    _description = value;
    _queueDraftSave();
    notifyListeners();
  }

  void updateLocationInput(String value) {
    _locationInput = value;
    if (_locationError != null) {
      _locationError = null;
    }
    _submissionError = null;
    _queueDraftSave();
    _rebuildAuthoritySections();
    notifyListeners();
  }

  Future<void> restoreDraft() async {
    if (_draftRestored) {
      return;
    }
    await loadAuthoritiesIfNeeded();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _selectedCategoryId = prefs.getString(_draftCategoryKey);
    _description = prefs.getString(_draftDescriptionKey) ?? _description;
    _locationInput = prefs.getString(_draftLocationKey) ?? _locationInput;
    _autoAddressLoaded = _locationInput.trim().isNotEmpty;

    final List<String> selectedIds =
        prefs.getStringList(_draftTaggedAuthoritiesKey) ?? <String>[];
    _selectedAuthorities
      ..clear()
      ..addAll(
        _authorities.where(
          (AuthorityProfile item) => selectedIds.contains(item.id),
        ),
      );
    _rebuildAuthoritySections();
    _draftRestored = true;
    notifyListeners();
  }

  Future<void> clearDraft() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_draftCategoryKey);
    await prefs.remove(_draftDescriptionKey);
    await prefs.remove(_draftLocationKey);
    await prefs.remove(_draftTaggedAuthoritiesKey);
  }

  Future<void> generateDescriptionSuggestion() async {
    if (_isGeneratingSuggestion) {
      return;
    }

    _isGeneratingSuggestion = true;
    notifyListeners();

    await Future<void>.delayed(const Duration(milliseconds: 380));

    final String categoryTitle = categories
        .where((IssueCategory item) => item.id == _selectedCategoryId)
        .map((IssueCategory item) => item.title)
        .firstWhere((String _) => true, orElse: () => 'Public service');

    final String location = _locationInput.trim().isEmpty
        ? 'near my area'
        : _locationInput.trim();

    _description =
        'I am reporting a $categoryTitle issue at $location. The issue is affecting daily public usage and requires timely action. Please assign the responsible department and update the status once inspection is completed.';
    _isGeneratingSuggestion = false;
    _queueDraftSave();
    notifyListeners();
  }

  Future<void> addFromCamera() {
    return _pickMedia(mediaPickerService.pickFromCamera);
  }

  Future<void> addFromGalleryImages() {
    return _pickMedia(mediaPickerService.pickImagesFromGallery);
  }

  Future<void> addFromGalleryVideo() {
    return _pickMedia(mediaPickerService.pickVideoFromGallery);
  }

  Future<void> detectLocation() async {
    if (_isDisposed) {
      return;
    }

    final int requestToken = ++_locationRequestToken;
    _isLocating = true;
    _locationError = null;
    _notifySafely();

    try {
      final LocationResult result = await locationService.getCurrentLocation();
      if (_isDisposed || requestToken != _locationRequestToken) {
        return;
      }
      _detectedLatitude = result.latitude;
      _detectedLongitude = result.longitude;
      _addressComponents = Map<String, String>.from(result.components);
      _locationPlaceId = result.placeId;
      _locationTimestamp = result.locationTimestamp;
      _autoAddressLoaded = true;
      _autoLocationText = result.formattedAddress;
      _locationInput = result.formattedAddress;
      _queueDraftSave();
      _rebuildAuthoritySections();
    } on LocationServiceFailure catch (error) {
      if (_isDisposed || requestToken != _locationRequestToken) {
        return;
      }
      _locationError = error.message;
      if (error.code == LocationFailureCode.permissionDenied ||
          error.code == LocationFailureCode.permissionDeniedForever) {
        _showLocationPermissionDialog = true;
      }
    } catch (_) {
      if (_isDisposed || requestToken != _locationRequestToken) {
        return;
      }
      _locationError =
          'Unable to detect your location. Please enter your address manually.';
    } finally {
      if (!_isDisposed && requestToken == _locationRequestToken) {
        _isLocating = false;
        _notifySafely();
      }
    }
  }

  Future<void> reverseGeocodeForCoordinates({
    required double latitude,
    required double longitude,
  }) async {
    if (_isDisposed) {
      return;
    }

    final int requestToken = ++_locationRequestToken;
    _isLocating = true;
    _locationError = null;
    _notifySafely();

    try {
      final LocationResult result = await locationService
          .reverseGeocodeCoordinates(latitude: latitude, longitude: longitude);
      if (_isDisposed || requestToken != _locationRequestToken) {
        return;
      }
      _detectedLatitude = result.latitude;
      _detectedLongitude = result.longitude;
      _addressComponents = Map<String, String>.from(result.components);
      _locationPlaceId = result.placeId;
      _locationTimestamp = result.locationTimestamp;
      _autoAddressLoaded = true;
      _autoLocationText = result.formattedAddress;
      _locationInput = result.formattedAddress;
      _queueDraftSave();
      _rebuildAuthoritySections();
    } on LocationServiceFailure catch (error) {
      if (_isDisposed || requestToken != _locationRequestToken) {
        return;
      }
      _locationError = error.message;
    } catch (_) {
      if (_isDisposed || requestToken != _locationRequestToken) {
        return;
      }
      _locationError = ReportIssueText.locationFetchFailed;
    } finally {
      if (!_isDisposed && requestToken == _locationRequestToken) {
        _isLocating = false;
        _notifySafely();
      }
    }
  }

  Future<void> searchAndResolveLocation(String query) async {
    final String q = query.trim();
    if (q.isEmpty) {
      return;
    }
    if (_isDisposed) {
      return;
    }

    final int requestToken = ++_locationRequestToken;
    _isLocating = true;
    _locationError = null;
    _notifySafely();

    try {
      final List<Location> locations = await locationFromAddress(q);
      if (locations.isEmpty) {
        throw const LocationServiceFailure('Unable to find this location.');
      }
      final Location first = locations.first;
      final LocationResult result = await locationService
          .reverseGeocodeCoordinates(
            latitude: first.latitude,
            longitude: first.longitude,
          );
      if (_isDisposed || requestToken != _locationRequestToken) {
        return;
      }
      _detectedLatitude = result.latitude;
      _detectedLongitude = result.longitude;
      _addressComponents = Map<String, String>.from(result.components);
      _locationPlaceId = result.placeId;
      _locationTimestamp = result.locationTimestamp;
      _autoAddressLoaded = true;
      _autoLocationText = result.formattedAddress;
      _locationInput = result.formattedAddress;
      _queueDraftSave();
      _rebuildAuthoritySections();
    } on LocationServiceFailure catch (error) {
      if (_isDisposed || requestToken != _locationRequestToken) {
        return;
      }
      _locationError = error.message;
    } catch (_) {
      if (_isDisposed || requestToken != _locationRequestToken) {
        return;
      }
      _locationError = 'Unable to search this location.';
    } finally {
      if (!_isDisposed && requestToken == _locationRequestToken) {
        _isLocating = false;
        _notifySafely();
      }
    }
  }

  void removeMediaAt(int index) {
    if (index < 0 || index >= _mediaItems.length) {
      return;
    }
    _mediaItems.removeAt(index);
    notifyListeners();
  }

  bool nextStep() {
    _submissionError = null;
    bool valid = false;
    switch (_currentStep) {
      case 0:
        valid = true;
        break;
      case 1:
        _attemptedCategoryNext = true;
        valid =
            ReportIssueValidators.validateCategory(_selectedCategoryId) == null;
        break;
      case 2:
        valid = true;
        break;
      case 3:
        _attemptedDescriptionNext = true;
        valid = ReportIssueValidators.validateDescription(_description) == null;
        break;
      case 4:
        valid = true;
        break;
      case 5:
        _attemptedLocationNext = true;
        valid = ReportIssueValidators.validateLocation(_locationInput) == null;
        break;
      case 6:
        valid = true;
        break;
      default:
        valid = false;
    }

    if (valid && _currentStep < 6) {
      _currentStep += 1;
    }

    notifyListeners();
    return valid;
  }

  void previousStep() {
    if (_currentStep == 0) {
      return;
    }
    _currentStep -= 1;
    notifyListeners();
  }

  void goToStep(int step) {
    final int clamped = step.clamp(0, 6);
    if (clamped == _currentStep) {
      return;
    }
    _currentStep = clamped;
    notifyListeners();
  }

  void startSubmit() {
    _isSubmitting = true;
    _submissionError = null;
    notifyListeners();
  }

  Future<SubmittedIssue> submitIssue({required String userId}) async {
    if (_isSubmitting) {
      throw const IssueSubmissionFailure('Submission already in progress.');
    }

    final IssueCategory? category = categories
        .where((IssueCategory item) => item.id == _selectedCategoryId)
        .cast<IssueCategory?>()
        .firstWhere((IssueCategory? item) => item != null, orElse: () => null);

    if (category == null) {
      throw const IssueSubmissionFailure('Issue category is required.');
    }

    startSubmit();
    try {
      final SubmittedIssue issue = await submissionService.submit(
        IssueSubmissionRequest(
          userId: userId,
          category: category,
          description: _description,
          locationText: _locationInput,
          latitude: _detectedLatitude,
          longitude: _detectedLongitude,
          formattedAddress: effectiveLocation,
          locationComponents: _addressComponents,
          locationPlaceId: _locationPlaceId,
          locationTimestamp: _locationTimestamp,
          mediaItems: _mediaItems,
          taggedAuthorities: _selectedAuthorities,
        ),
      );
      _submissionDone = true;
      _lastSubmittedIssue = issue;
      await clearDraft();
      return issue;
    } on IssueSubmissionFailure catch (error) {
      _submissionError = error.message;
      rethrow;
    } finally {
      completeSubmitCycle();
    }
  }

  void resetForm() {
    _currentStep = 0;
    _selectedCategoryId = null;
    _authoritySearchQuery = '';
    _description = '';
    _locationInput = '';
    _detectedLatitude = null;
    _detectedLongitude = null;
    _addressComponents = <String, String>{};
    _locationPlaceId = null;
    _locationTimestamp = null;
    _autoAddressLoaded = false;
    _isLoadingAuthorities = false;
    _isPickingMedia = false;
    _isSubmitting = false;
    _isLocating = false;
    _attemptedCategoryNext = false;
    _attemptedDescriptionNext = false;
    _attemptedLocationNext = false;
    _showLocationPermissionDialog = false;
    _submissionDone = false;
    _isGeneratingSuggestion = false;
    _draftRestored = false;
    _mediaError = null;
    _mediaWarning = null;
    _autoLocationText = null;
    _locationError = null;
    _submissionError = null;
    _lastSubmittedIssue = null;
    _mediaItems.clear();
    _selectedAuthorities.clear();
    _publicRepresentatives.clear();
    _governmentAuthorities.clear();
    _recommendedAuthorities.clear();
    clearDraft();
    notifyListeners();
  }

  void completeSubmitCycle() {
    if (_isSubmitting) {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<void> _pickMedia(
    Future<MediaPickerResult> Function() operation,
  ) async {
    _isPickingMedia = true;
    _mediaError = null;
    _mediaWarning = null;
    notifyListeners();

    try {
      final MediaPickerResult result = await operation();
      _mediaItems.addAll(result.items);
      _mediaWarning = result.warning;
      _queueDraftSave();
    } on MediaPickerFailure catch (error) {
      _mediaError = error.message;
    } finally {
      _isPickingMedia = false;
      notifyListeners();
    }
  }

  void _queueDraftSave() {
    _draftDebounce?.cancel();
    _draftDebounce = Timer(const Duration(milliseconds: 350), _saveDraftNow);
  }

  Future<void> _saveDraftNow() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (_selectedCategoryId == null || _selectedCategoryId!.isEmpty) {
      await prefs.remove(_draftCategoryKey);
    } else {
      await prefs.setString(_draftCategoryKey, _selectedCategoryId!);
    }
    await prefs.setString(_draftDescriptionKey, _description);
    await prefs.setString(_draftLocationKey, _locationInput);
    await prefs.setStringList(
      _draftTaggedAuthoritiesKey,
      _selectedAuthorities.map((AuthorityProfile item) => item.id).toList(),
    );
  }

  void _rebuildAuthoritySections() {
    _publicRepresentatives
      ..clear()
      ..addAll(authorityService.publicRepresentatives(_authorities));

    _governmentAuthorities
      ..clear()
      ..addAll(
        authorityService.governmentAuthoritiesForCategory(
          categoryId: _selectedCategoryId,
          authorities: _authorities,
        ),
      );

    _recommendedAuthorities
      ..clear()
      ..addAll(
        authorityService.recommendAuthorities(
          categoryId: _selectedCategoryId,
          locationText: _locationInput,
          authorities: <AuthorityProfile>[
            ..._governmentAuthorities,
            ..._publicRepresentatives,
          ],
        ),
      );
  }

  @override
  void dispose() {
    _isDisposed = true;
    _draftDebounce?.cancel();
    super.dispose();
  }

  void _notifySafely() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }
}

const String _draftCategoryKey = 'report_issue_draft_category';
const String _draftDescriptionKey = 'report_issue_draft_description';
const String _draftLocationKey = 'report_issue_draft_location';
const String _draftTaggedAuthoritiesKey =
    'report_issue_draft_tagged_authorities';
