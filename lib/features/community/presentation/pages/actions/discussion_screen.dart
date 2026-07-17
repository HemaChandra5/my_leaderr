import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../domain/models/community_hub_models.dart';
import '../../../state/community_hub_controller.dart';
import 'community_action_scaffold.dart';

class DiscussionScreen extends StatefulWidget {
  const DiscussionScreen({super.key});

  @override
  State<DiscussionScreen> createState() => _DiscussionScreenState();
}

class _DiscussionScreenState extends State<DiscussionScreen> {
  final TextEditingController _title = TextEditingController();
  final TextEditingController _description = TextEditingController();
  final TextEditingController _inviteMembers = TextEditingController();
  String _category = 'Public Service';
  bool _isPublic = true;
  bool _moderator = true;
  bool _pinnedMessages = true;
  final Set<String> _attachments = <String>{'Images', 'Videos', 'Files'};

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _inviteMembers.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final CommunityActionScaffoldState? scaffold =
        CommunityActionScaffold.maybeOf(context);

    return CommunityActionScaffold(
      actionKey: 'discussion',
      title: 'Start Discussion',
      subtitle: 'Public/private threads with moderator and attachments',
      heroTag: 'quick-action-Start Discussion',
      icon: Icons.forum_rounded,
      collectValues: () => <String, dynamic>{
        'title': _title.text,
        'description': _description.text,
        'inviteMembers': _inviteMembers.text,
        'category': _category,
        'isPublic': _isPublic,
        'moderator': _moderator,
        'pinnedMessages': _pinnedMessages,
        'attachments': _attachments.toList(growable: false),
      },
      applyDraft: (Map<String, dynamic> draft) {
        setState(() {
          _title.text = (draft['title'] ?? '') as String;
          _description.text = (draft['description'] ?? '') as String;
          _inviteMembers.text = (draft['inviteMembers'] ?? '') as String;
          _category = (draft['category'] ?? 'Public Service') as String;
          _isPublic = (draft['isPublic'] ?? true) as bool;
          _moderator = (draft['moderator'] ?? true) as bool;
          _pinnedMessages = (draft['pinnedMessages'] ?? true) as bool;
          _attachments
            ..clear()
            ..addAll(((draft['attachments'] ?? <dynamic>[]) as List<dynamic>).cast<String>());
        });
      },
      validationBuilder: () {
        final List<String> errors = <String>[];
        if (_title.text.trim().isEmpty) {
          errors.add('Discussion title is required');
        }
        if (_description.text.trim().isEmpty) {
          errors.add('Discussion description is required');
        }
        return errors;
      },
      formBuilder: (BuildContext context) {
        return Column(
          children: <Widget>[
            CommunityTextField(
              controller: _title,
              label: 'Discussion Title',
              maxLength: 120,
              onChanged: (_) => scaffold?.markDirty(),
            ),
            const SizedBox(height: 8),
            CommunityTextField(
              controller: _description,
              label: 'Description',
              maxLength: 600,
              maxLines: 5,
              onChanged: (_) => scaffold?.markDirty(),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _category,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
              items: const <String>[
                'Public Service',
                'Infrastructure',
                'Environment',
                'Youth Engagement',
              ].map((String value) => DropdownMenuItem<String>(value: value, child: Text(value))).toList(growable: false),
              onChanged: (String? value) {
                if (value == null) {
                  return;
                }
                setState(() => _category = value);
                scaffold?.markDirty();
              },
            ),
            const SizedBox(height: 8),
            CommunityTextField(
              controller: _inviteMembers,
              label: 'Invite Members',
              hintText: 'name1, name2, name3',
              onChanged: (_) => scaffold?.markDirty(),
            ),
            SwitchListTile.adaptive(
              value: _isPublic,
              title: const Text('Public Discussion'),
              onChanged: (bool value) {
                setState(() => _isPublic = value);
                scaffold?.markDirty();
              },
            ),
            SwitchListTile.adaptive(
              value: _moderator,
              title: const Text('Assign Moderator'),
              onChanged: (bool value) {
                setState(() => _moderator = value);
                scaffold?.markDirty();
              },
            ),
            SwitchListTile.adaptive(
              value: _pinnedMessages,
              title: const Text('Pinned Messages'),
              onChanged: (bool value) {
                setState(() => _pinnedMessages = value);
                scaffold?.markDirty();
              },
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: 8,
                children: const <String>['Images', 'Videos', 'Files']
                    .map(
                      (String item) => Chip(label: Text(item)),
                    )
                    .toList(growable: false),
              ),
            ),
          ],
        );
      },
      previewBuilder: (BuildContext context, Map<String, dynamic> values) {
        return Card(
          child: ListTile(
            leading: const Icon(Icons.forum_rounded),
            title: Text((values['title'] ?? '') as String),
            subtitle: Text((values['description'] ?? '') as String),
            trailing: Text((values['isPublic'] as bool? ?? true) ? 'Public' : 'Private'),
          ),
        );
      },
      onPublish: (BuildContext context, Map<String, dynamic> values) async {
        await Future<void>.delayed(const Duration(milliseconds: 680));
        if (!context.mounted) {
          return;
        }
        context.read<CommunityHubController>().publish(
              CommunityPublication(
                id: DateTime.now().microsecondsSinceEpoch.toString(),
                title: (values['title'] ?? '') as String,
                description: (values['description'] ?? '') as String,
                type: CommunityContentType.discussion,
                targets: <CommunityTargetModule>{CommunityTargetModule.discussionFeed},
                createdAt: DateTime.now(),
                authorName: 'You',
                metadata: values,
              ),
            );
      },
    );
  }
}
