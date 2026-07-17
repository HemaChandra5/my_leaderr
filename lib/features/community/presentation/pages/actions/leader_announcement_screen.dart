import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../providers/user_provider.dart';
import '../../../domain/models/community_hub_models.dart';
import '../../../state/community_hub_controller.dart';
import 'community_action_scaffold.dart';

class LeaderAnnouncementScreen extends StatefulWidget {
  const LeaderAnnouncementScreen({super.key});

  @override
  State<LeaderAnnouncementScreen> createState() => _LeaderAnnouncementScreenState();
}

class _LeaderAnnouncementScreenState extends State<LeaderAnnouncementScreen> {
  final TextEditingController _title = TextEditingController();
  final TextEditingController _description = TextEditingController();
  String _priority = 'High';
  String _audience = 'Public';
  final TextEditingController _schedule = TextEditingController(text: 'Publish Now');
  bool _pinAnnouncement = true;

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _schedule.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isVerifiedLeader =
        context.select<UserProvider, bool>((UserProvider p) => p.appUser?.isVerifiedLeader ?? false);

    if (!isVerifiedLeader) {
      return Scaffold(
        appBar: AppBar(title: const Text('Leader Announcement')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              'This feature is available only for verified leaders.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      );
    }

    final CommunityActionScaffoldState? scaffold =
      CommunityActionScaffold.maybeOf(context);

    return CommunityActionScaffold(
      actionKey: 'leader_announcement',
      title: 'Leader Announcement',
      subtitle: 'Pinned announcements targeted by audience and priority',
      heroTag: 'quick-action-Announcement (Leader)',
      icon: Icons.campaign_rounded,
      collectValues: () => <String, dynamic>{
        'title': _title.text,
        'description': _description.text,
        'priority': _priority,
        'audience': _audience,
        'schedule': _schedule.text,
        'pinAnnouncement': _pinAnnouncement,
      },
      applyDraft: (Map<String, dynamic> draft) {
        setState(() {
          _title.text = (draft['title'] ?? '') as String;
          _description.text = (draft['description'] ?? '') as String;
          _priority = (draft['priority'] ?? 'High') as String;
          _audience = (draft['audience'] ?? 'Public') as String;
          _schedule.text = (draft['schedule'] ?? 'Publish Now') as String;
          _pinAnnouncement = (draft['pinAnnouncement'] ?? true) as bool;
        });
      },
      validationBuilder: () {
        final List<String> errors = <String>[];
        if (_title.text.trim().isEmpty) {
          errors.add('Announcement title is required');
        }
        if (_description.text.trim().isEmpty) {
          errors.add('Announcement description is required');
        }
        return errors;
      },
      formBuilder: (BuildContext context) {
        return Column(
          children: <Widget>[
            CommunityTextField(
              controller: _title,
              label: 'Title',
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
              initialValue: _priority,
              decoration: const InputDecoration(
                labelText: 'Priority',
                border: OutlineInputBorder(),
              ),
              items: const <String>['Critical', 'High', 'Normal']
                  .map((String value) => DropdownMenuItem<String>(value: value, child: Text(value)))
                  .toList(growable: false),
              onChanged: (String? value) {
                if (value == null) {
                  return;
                }
                setState(() => _priority = value);
                scaffold?.markDirty();
              },
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _audience,
              decoration: const InputDecoration(
                labelText: 'Target Audience',
                border: OutlineInputBorder(),
              ),
              items: const <String>['Public', 'Followers', 'Community', 'Ward Citizens']
                  .map((String value) => DropdownMenuItem<String>(value: value, child: Text(value)))
                  .toList(growable: false),
              onChanged: (String? value) {
                if (value == null) {
                  return;
                }
                setState(() => _audience = value);
                scaffold?.markDirty();
              },
            ),
            const SizedBox(height: 8),
            CommunityTextField(
              controller: _schedule,
              label: 'Schedule',
              onChanged: (_) => scaffold?.markDirty(),
            ),
            SwitchListTile.adaptive(
              value: _pinAnnouncement,
              title: const Text('Pin Announcement'),
              onChanged: (bool value) {
                setState(() => _pinAnnouncement = value);
                scaffold?.markDirty();
              },
            ),
          ],
        );
      },
      previewBuilder: (BuildContext context, Map<String, dynamic> values) {
        return Card(
          child: ListTile(
            leading: const Icon(Icons.push_pin_rounded),
            title: Text((values['title'] ?? '') as String),
            subtitle: Text((values['description'] ?? '') as String),
            trailing: Text((values['priority'] ?? '') as String),
          ),
        );
      },
      onPublish: (BuildContext context, Map<String, dynamic> values) async {
        await Future<void>.delayed(const Duration(milliseconds: 750));
        if (!context.mounted) {
          return;
        }
        context.read<CommunityHubController>().publish(
              CommunityPublication(
                id: DateTime.now().microsecondsSinceEpoch.toString(),
                title: (values['title'] ?? '') as String,
                description: (values['description'] ?? '') as String,
                type: CommunityContentType.announcement,
                targets: <CommunityTargetModule>{CommunityTargetModule.homeFeed},
                createdAt: DateTime.now(),
                authorName: 'Verified Leader',
                metadata: values,
              ),
            );
      },
    );
  }
}
