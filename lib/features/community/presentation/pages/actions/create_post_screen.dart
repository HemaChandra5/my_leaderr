import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../domain/models/community_hub_models.dart';
import '../../../state/community_hub_controller.dart';
import 'community_action_scaffold.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _postController = TextEditingController();
  final TextEditingController _hashtagsController = TextEditingController();
  final TextEditingController _mentionsController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  String _audience = 'Public';
  final Set<String> _attachments = <String>{'Text'};

  @override
  void dispose() {
    _postController.dispose();
    _hashtagsController.dispose();
    _mentionsController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CommunityActionScaffold(
      actionKey: 'create_post',
      title: 'Create Post',
      subtitle: 'Civic updates, photos, videos, polls and mentions',
      heroTag: 'quick-action-Create Post',
      icon: Icons.edit_note_rounded,
      collectValues: () => <String, dynamic>{
        'post': _postController.text,
        'hashtags': _hashtagsController.text,
        'mentions': _mentionsController.text,
        'location': _locationController.text,
        'audience': _audience,
        'attachments': _attachments.toList(growable: false),
      },
      applyDraft: (Map<String, dynamic> draft) {
        setState(() {
          _postController.text = (draft['post'] ?? '') as String;
          _hashtagsController.text = (draft['hashtags'] ?? '') as String;
          _mentionsController.text = (draft['mentions'] ?? '') as String;
          _locationController.text = (draft['location'] ?? '') as String;
          _audience = (draft['audience'] ?? 'Public') as String;
          _attachments
            ..clear()
            ..addAll(((draft['attachments'] ?? <dynamic>[]) as List<dynamic>).cast<String>());
        });
      },
      validationBuilder: () {
        final List<String> errors = <String>[];
        if (_postController.text.trim().isEmpty) {
          errors.add('Post content is required');
        }
        if (_postController.text.trim().length < 5) {
          errors.add('Post content should have at least 5 characters');
        }
        return errors;
      },
      formBuilder: (BuildContext context) {
        final CommunityActionScaffoldState scaffold =
            CommunityActionScaffold.maybeOf(context)!;
        return Column(
          children: <Widget>[
            CommunityTextField(
              controller: _postController,
              label: 'Post Content',
              maxLength: 600,
              maxLines: 6,
              hintText: 'Share your update with the community...',
              onChanged: (_) => scaffold.markDirty(),
            ),
            const SizedBox(height: 12),
            _FeatureChipWrap(
              title: 'Attachment Types',
              values: const <String>[
                'Text',
                'Images',
                'Multiple Images',
                'Videos',
                'GIFs',
                'Poll Attachment',
                'Location',
                'Emoji Picker',
              ],
              selected: _attachments,
              onChanged: (String value) {
                setState(() {
                  if (_attachments.contains(value)) {
                    _attachments.remove(value);
                  } else {
                    _attachments.add(value);
                  }
                });
                scaffold.markDirty();
              },
            ),
            const SizedBox(height: 12),
            CommunityTextField(
              controller: _mentionsController,
              label: 'Mentions',
              hintText: '@wardOfficer @volunteerTeam',
              onChanged: (_) => scaffold.markDirty(),
            ),
            const SizedBox(height: 8),
            CommunityTextField(
              controller: _hashtagsController,
              label: 'Hashtags',
              hintText: '#CleanWard #WaterSafety',
              onChanged: (_) => scaffold.markDirty(),
            ),
            const SizedBox(height: 8),
            CommunityTextField(
              controller: _locationController,
              label: 'Location',
              hintText: 'Ward 94, Sector 3',
              onChanged: (_) => scaffold.markDirty(),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _audience,
              decoration: const InputDecoration(
                labelText: 'Audience',
                border: OutlineInputBorder(),
              ),
              items: const <String>['Public', 'Followers', 'Community']
                  .map((String value) => DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      ))
                  .toList(growable: false),
              onChanged: (String? value) {
                if (value == null) {
                  return;
                }
                setState(() => _audience = value);
                scaffold.markDirty();
              },
            ),
          ],
        );
      },
      previewBuilder: (BuildContext context, Map<String, dynamic> values) {
        return _PreviewCard(values: values);
      },
      onPublish: (BuildContext context, Map<String, dynamic> values) async {
        await Future<void>.delayed(const Duration(milliseconds: 700));
        if (!context.mounted) {
          return;
        }
        context.read<CommunityHubController>().publish(
              CommunityPublication(
                id: DateTime.now().microsecondsSinceEpoch.toString(),
                title: 'Post by Civic Member',
                description: (values['post'] as String).trim(),
                type: CommunityContentType.post,
                targets: <CommunityTargetModule>{CommunityTargetModule.communityFeed},
                createdAt: DateTime.now(),
                authorName: 'You',
                location: (values['location'] as String).trim(),
                tags: ((values['hashtags'] as String)
                        .split(' ')
                        .where((String t) => t.startsWith('#')))
                    .toList(growable: false),
                metadata: <String, dynamic>{
                  'audience': values['audience'],
                  'attachments': values['attachments'],
                  'mentions': values['mentions'],
                },
              ),
            );
      },
    );
  }
}

class _PreviewCard extends StatelessWidget {
  const _PreviewCard({required this.values});

  final Map<String, dynamic> values;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text('Post Preview', style: TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text((values['post'] ?? '') as String),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                _LabelChip(label: 'Audience: ${values['audience']}'),
                _LabelChip(label: 'Location: ${values['location'] ?? '-'}'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureChipWrap extends StatelessWidget {
  const _FeatureChipWrap({
    required this.title,
    required this.values,
    required this.selected,
    required this.onChanged,
  });

  final String title;
  final List<String> values;
  final Set<String> selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: values
              .map(
                (String value) => FilterChip(
                  selected: selected.contains(value),
                  label: Text(value),
                  onSelected: (_) => onChanged(value),
                ),
              )
              .toList(growable: false),
        ),
      ],
    );
  }
}

class _LabelChip extends StatelessWidget {
  const _LabelChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primaryGold.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }
}
