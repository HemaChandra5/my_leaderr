import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../state/community_hub_controller.dart';

typedef FormCollector = Map<String, dynamic> Function();
typedef DraftApplier = void Function(Map<String, dynamic> draft);
typedef ValidationBuilder = List<String> Function();
typedef PreviewBuilder = Widget Function(
  BuildContext context,
  Map<String, dynamic> values,
);
typedef PublishHandler = Future<void> Function(
  BuildContext context,
  Map<String, dynamic> values,
);

class CommunityActionScaffold extends StatefulWidget {
  const CommunityActionScaffold({
    super.key,
    required this.actionKey,
    required this.title,
    required this.subtitle,
    required this.heroTag,
    required this.icon,
    required this.collectValues,
    required this.applyDraft,
    required this.validationBuilder,
    required this.formBuilder,
    required this.previewBuilder,
    required this.onPublish,
  });

  final String actionKey;
  final String title;
  final String subtitle;
  final String heroTag;
  final IconData icon;
  final FormCollector collectValues;
  final DraftApplier applyDraft;
  final ValidationBuilder validationBuilder;
  final WidgetBuilder formBuilder;
  final PreviewBuilder previewBuilder;
  final PublishHandler onPublish;

  static CommunityActionScaffoldState? maybeOf(BuildContext context) {
    return context.findAncestorStateOfType<CommunityActionScaffoldState>();
  }

  @override
  State<CommunityActionScaffold> createState() => CommunityActionScaffoldState();
}

class CommunityActionScaffoldState extends State<CommunityActionScaffold>
    with SingleTickerProviderStateMixin {
  Timer? _autoSaveTimer;
  bool _isSavingDraft = false;
  bool _isPublishing = false;
  bool _hasUnsavedChanges = false;
  bool _showSuccess = false;
  late final AnimationController _successController;

  @override
  void initState() {
    super.initState();
    _successController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final CommunityHubController controller = context
          .read<CommunityHubController>();
      final draft = controller.getDraft(widget.actionKey);
      if (draft != null) {
        widget.applyDraft(draft.values);
      }
    });

    _autoSaveTimer = Timer.periodic(const Duration(seconds: 12), (_) {
      if (_hasUnsavedChanges && mounted) {
        _saveDraft(isAutoSave: true);
      }
    });
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    _successController.dispose();
    super.dispose();
  }

  void markDirty() {
    if (_hasUnsavedChanges) {
      return;
    }
    setState(() => _hasUnsavedChanges = true);
  }

  Future<void> _saveDraft({bool isAutoSave = false}) async {
    final CommunityHubController controller = context.read<CommunityHubController>();
    setState(() => _isSavingDraft = true);
    await Future<void>.delayed(const Duration(milliseconds: 300));
    controller.saveDraft(widget.actionKey, widget.collectValues());
    if (!mounted) {
      return;
    }
    setState(() {
      _isSavingDraft = false;
      _hasUnsavedChanges = false;
    });
    if (!isAutoSave) {
      _showInfo('Draft saved');
    }
  }

  void _showInfo(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(message),
        ),
      );
  }

  void _showDiscardBanner() {
    ScaffoldMessenger.of(context)
      ..clearMaterialBanners()
      ..showMaterialBanner(
        MaterialBanner(
          content: const Text('You have unsaved changes.'),
          leading: const Icon(Icons.warning_amber_rounded),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).clearMaterialBanners();
              },
              child: const Text('Keep Editing'),
            ),
            FilledButton(
              onPressed: () {
                ScaffoldMessenger.of(context).clearMaterialBanners();
                Navigator.of(context).pop();
              },
              child: const Text('Discard'),
            ),
          ],
        ),
      );
  }

  void _handleCancel() {
    if (_hasUnsavedChanges) {
      _showDiscardBanner();
      return;
    }
    Navigator.of(context).pop();
  }

  void _openPreview() {
    final List<String> errors = widget.validationBuilder();
    if (errors.isNotEmpty) {
      _showInfo(errors.first);
      return;
    }

    final Map<String, dynamic> values = widget.collectValues();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CommunityActionPreviewPage(
          title: widget.title,
          icon: widget.icon,
          child: widget.previewBuilder(context, values),
        ),
      ),
    );
  }

  Future<void> _publish() async {
    final List<String> errors = widget.validationBuilder();
    if (errors.isNotEmpty) {
      _showInfo(errors.first);
      return;
    }

    setState(() => _isPublishing = true);
    await widget.onPublish(context, widget.collectValues());

    if (!mounted) {
      return;
    }

    context.read<CommunityHubController>().clearDraft(widget.actionKey);
    setState(() {
      _isPublishing = false;
      _hasUnsavedChanges = false;
      _showSuccess = true;
    });

    _successController.forward(from: 0);
    await Future<void>.delayed(const Duration(milliseconds: 1100));
    if (!mounted) {
      return;
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return PopScope(
      canPop: !_hasUnsavedChanges,
      onPopInvokedWithResult: (bool didPop, dynamic _) {
        if (!didPop && _hasUnsavedChanges) {
          _showDiscardBanner();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          titleSpacing: 0,
          title: Row(
            children: <Widget>[
              Hero(
                tag: widget.heroTag,
                child: CircleAvatar(
                  backgroundColor: AppColors.primaryGold.withValues(alpha: 0.16),
                  child: Icon(widget.icon, color: AppColors.primaryGold),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(widget.title, style: const TextStyle(fontWeight: FontWeight.w800)),
                    Text(
                      widget.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: _isSavingDraft ? null : () => _saveDraft(),
              child: _isSavingDraft
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save Draft'),
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: <Widget>[
              if (_isPublishing) const LinearProgressIndicator(minHeight: 2.5),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    16,
                    12,
                    16,
                    MediaQuery.viewInsetsOf(context).bottom + 100,
                  ),
                  child: widget.formBuilder(context),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: OutlinedButton(
                    onPressed: _handleCancel,
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.tonal(
                    onPressed: _isPublishing ? null : _openPreview,
                    child: const Text('Preview'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _isPublishing ? null : _publish,
                    icon: _isPublishing
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.publish_rounded),
                    label: const Text('Publish'),
                  ),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: IgnorePointer(
          ignoring: !_showSuccess,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 240),
            opacity: _showSuccess ? 1 : 0,
            child: Center(
              child: ScaleTransition(
                scale: CurvedAnimation(
                  parent: _successController,
                  curve: Curves.elasticOut,
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.divider),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 22,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(Icons.check_circle_rounded, color: Color(0xFF2E7D32)),
                      SizedBox(width: 10),
                      Text(
                        'Successfully Published',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }
}

class CommunityActionPreviewPage extends StatelessWidget {
  const CommunityActionPreviewPage({
    super.key,
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: <Widget>[
            Icon(icon),
            const SizedBox(width: 8),
            Expanded(child: Text('$title Preview')),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: child,
        ),
      ),
    );
  }
}

class CommunityTextField extends StatelessWidget {
  const CommunityTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.onChanged,
    this.maxLength,
    this.maxLines = 1,
    this.hintText,
  });

  final TextEditingController controller;
  final String label;
  final ValueChanged<String> onChanged;
  final int? maxLength;
  final int maxLines;
  final String? hintText;

  @override
  Widget build(BuildContext context) {
    final int count = controller.text.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        TextField(
          controller: controller,
          maxLength: maxLength,
          maxLines: maxLines,
          onChanged: onChanged,
          decoration: InputDecoration(
            labelText: label,
            hintText: hintText,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
        if (maxLength != null)
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '$count/$maxLength',
              style: TextStyle(color: AppColors.textMuted, fontSize: 12),
            ),
          ),
      ],
    );
  }
}
