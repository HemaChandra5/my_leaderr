import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../services/media_picker_service.dart';
import '../../utils/report_issue_constants.dart';

class MediaUploadWidget extends StatelessWidget {
  const MediaUploadWidget({
    super.key,
    required this.isLoading,
    required this.errorText,
    required this.warningText,
    required this.items,
    required this.onCameraTap,
    required this.onGalleryImagesTap,
    required this.onGalleryVideoTap,
    required this.onDeleteTap,
  });

  final bool isLoading;
  final String? errorText;
  final String? warningText;
  final List<PickedMedia> items;
  final VoidCallback onCameraTap;
  final VoidCallback onGalleryImagesTap;
  final VoidCallback onGalleryVideoTap;
  final ValueChanged<int> onDeleteTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: ReportIssueSemantics.uploadSection,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              const Text(
                ReportIssueText.mediaTitle,
                style: TextStyle(
                  color: ReportIssuePalette.whiteText,
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
              Row(
                children: <Widget>[
                  _IconUploadButton(
                    iconAssetPath: ReportIssueText.cameraIconAsset,
                    tooltip: ReportIssueText.camera,
                    onTap: isLoading ? null : onCameraTap,
                  ),
                  const SizedBox(width: ReportIssueSpacing.md),
                  _GalleryButton(
                    enabled: !isLoading,
                    onImagesTap: onGalleryImagesTap,
                    onVideoTap: onGalleryVideoTap,
                  ),
                ],
              ),
            ],
          ),
          if (isLoading) ...<Widget>[
            const SizedBox(height: ReportIssueSpacing.md),
            const LinearProgressIndicator(
              minHeight: 3,
              color: ReportIssuePalette.primaryGold,
              backgroundColor: ReportIssuePalette.border,
            ),
          ],
          if (errorText != null) ...<Widget>[
            const SizedBox(height: ReportIssueSpacing.md),
            Text(
              errorText!,
              style: const TextStyle(color: Colors.redAccent, fontSize: 12),
            ),
          ],
          if (warningText != null) ...<Widget>[
            const SizedBox(height: ReportIssueSpacing.sm),
            Text(
              warningText!,
              style: const TextStyle(color: Colors.orangeAccent, fontSize: 12),
            ),
          ],
          if (items.isNotEmpty) ...<Widget>[
            const SizedBox(height: ReportIssueSpacing.lg),
            _PreviewGrid(items: items, onDeleteTap: onDeleteTap),
          ],
        ],
      ),
    );
  }
}

class _IconUploadButton extends StatelessWidget {
  const _IconUploadButton({
    required this.iconAssetPath,
    required this.tooltip,
    required this.onTap,
  });

  final String iconAssetPath;
  final String tooltip;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bool enabled = onTap != null;

    return Tooltip(
      message: tooltip,
      child: SizedBox(
        width: 48,
        height: 48,
        child: OutlinedButton(
          onPressed: onTap,
          style: OutlinedButton.styleFrom(
            padding: EdgeInsets.zero,
            side: const BorderSide(color: ReportIssuePalette.border),
            backgroundColor: ReportIssuePalette.cardBackground,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: SvgPicture.asset(
            iconAssetPath,
            width: 18,
            height: 18,
            fit: BoxFit.contain,
            colorFilter: ColorFilter.mode(
              enabled
                  ? ReportIssuePalette.whiteText
                  : ReportIssuePalette.hintText,
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
    );
  }
}

class _GalleryButton extends StatelessWidget {
  const _GalleryButton({
    required this.enabled,
    required this.onImagesTap,
    required this.onVideoTap,
  });

  final bool enabled;
  final VoidCallback onImagesTap;
  final VoidCallback onVideoTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 48,
      child: PopupMenuButton<String>(
        enabled: enabled,
        tooltip: ReportIssueText.gallery,
        color: ReportIssuePalette.cardBackground,
        padding: EdgeInsets.zero,
        position: PopupMenuPosition.under,
        onSelected: (String value) {
          if (value == ReportIssueText.galleryImages) {
            onImagesTap();
            return;
          }
          onVideoTap();
        },
        itemBuilder: (BuildContext context) => const <PopupMenuEntry<String>>[
          PopupMenuItem<String>(
            value: ReportIssueText.galleryImages,
            child: Text(
              ReportIssueText.galleryImages,
              style: TextStyle(color: ReportIssuePalette.whiteText),
            ),
          ),
          PopupMenuItem<String>(
            value: ReportIssueText.galleryVideo,
            child: Text(
              ReportIssueText.galleryVideo,
              style: TextStyle(color: ReportIssuePalette.whiteText),
            ),
          ),
        ],
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: ReportIssuePalette.cardBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: ReportIssuePalette.border),
          ),
          alignment: Alignment.center,
          child: SvgPicture.asset(
            ReportIssueText.galleryIconAsset,
            width: 18,
            height: 18,
            fit: BoxFit.contain,
            colorFilter: ColorFilter.mode(
              enabled
                  ? ReportIssuePalette.whiteText
                  : ReportIssuePalette.hintText,
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
    );
  }
}

class _PreviewGrid extends StatelessWidget {
  const _PreviewGrid({required this.items, required this.onDeleteTap});

  final List<PickedMedia> items;
  final ValueChanged<int> onDeleteTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool compact = constraints.maxWidth < 420;
        final int crossAxisCount = compact ? 3 : 4;

        return GridView.builder(
          itemCount: items.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: ReportIssueSpacing.sm,
            mainAxisSpacing: ReportIssueSpacing.sm,
            childAspectRatio: 1,
          ),
          itemBuilder: (BuildContext context, int index) {
            final PickedMedia media = items[index];
            return _PreviewTile(
              media: media,
              onDelete: () => onDeleteTap(index),
            );
          },
        );
      },
    );
  }
}

class _PreviewTile extends StatelessWidget {
  const _PreviewTile({required this.media, required this.onDelete});

  final PickedMedia media;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final Widget child = media.type == PickedMediaType.image
        ? ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.file(File(media.file.path), fit: BoxFit.cover),
          )
        : Container(
            decoration: BoxDecoration(
              color: const Color(0xFF222222),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Icon(
                Icons.videocam_outlined,
                color: ReportIssuePalette.primaryGold,
              ),
            ),
          );

    return Stack(
      children: <Widget>[
        Positioned.fill(child: child),
        Positioned(
          top: 4,
          right: 4,
          child: SizedBox(
            width: 28,
            height: 28,
            child: DecoratedBox(
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.close, size: 14),
                color: Colors.white,
                padding: EdgeInsets.zero,
                tooltip: ReportIssueText.deleteMedia,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
