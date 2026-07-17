import 'package:flutter/material.dart';

class ReportIssuePalette {
  static const Color background = Color(0xFF0B0B0B);
  static const Color cardBackground = Color(0xFF111111);
  static const Color border = Color(0xFF2D2D2D);
  static const Color primaryGold = Color(0xFFF4B63C);
  static const Color whiteText = Color(0xFFFFFFFF);
  static const Color secondaryText = Color(0xFF8A8A8A);
  static const Color hintText = Color(0xFF6E6E6E);
  static const Color inactiveStep = Color(0xFF1A1A1A);
  static const Color inactiveStepBorder = Color(0xFF3A3A3A);
}

class ReportIssueSpacing {
  static const double xs = 6;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double section = 28;
}

class ReportIssueRadius {
  static const double card = 14;
  static const double field = 14;
  static const double button = 14;
  static const double pill = 999;
}

class ReportIssueText {
  static const String appBarTitle = 'Report an Issue';
  static const String stepCategory = 'Category';
  static const String stepDetails = 'Details';
  static const String stepLocation = 'Location';
  static const String stepReview = 'Review';

  static const String categoryTitle = 'Select Category';
  static const String detailsTitle = 'Add Details';
  static const String detailsHint = 'Describe the issue in detail...';
  static const String mediaTitle = 'Upload Photo / Video';
  static const String locationTitle = 'Location';
  static const String manualLocationLabel = 'Enter Location Manually';
  static const String manualLocationHint = 'Type area, street, landmark...';
  static const String autoLocationButton = 'Select Location Automatically';
  static const String locationSelectedPrefix = 'Location selected:';
  static const String reviewTitle = 'Review Issue';
  static const String reviewCategory = 'Category';
  static const String reviewDescription = 'Description';
  static const String reviewLocation = 'Location';
  static const String reviewMediaCount = 'Media Attachments';
  static const String notProvided = 'Not provided';
  static const String camera = 'Camera';
  static const String gallery = 'Gallery';
  static const String galleryImages = 'Gallery Images';
  static const String galleryVideo = 'Gallery Video';
  static const String next = 'Next';
  static const String submit = 'Submit';

  static const String categoryRequired = 'Please select an issue category.';
  static const String descriptionRequired = 'Please describe the issue.';
  static const String descriptionTooLong =
      'Description cannot exceed 500 characters.';
  static const String locationRequired = 'Please provide a location.';

  static const String pickerPermissionDenied =
      'Media permission denied. Please enable permission in settings.';
  static const String pickerFailed = 'Unable to pick media. Please try again.';
  static const String compressionFailed =
      'Image optimization failed. Original image retained.';
  static const String goBack = 'Go back';
  static const String deleteMedia = 'Delete media';
  static const String locationFetchFailed =
      'Unable to fetch location. Please try again.';

  static const String cameraIconAsset = 'assets/images/report_issue/camera.svg';
  static const String galleryIconAsset =
      'assets/images/report_issue/gallery.svg';
}

class ReportIssueSemantics {
  static const String progressStepper = 'Issue report progress stepper';
  static const String categoryGrid = 'Issue categories grid';
  static const String descriptionField = 'Issue description input field';
  static const String uploadSection = 'Media upload section';
}

class ReportIssueRoutes {
  static const String trackStatus = '/track/status';
}
