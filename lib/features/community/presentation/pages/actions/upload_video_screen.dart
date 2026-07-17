import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../domain/models/community_hub_models.dart';
import '../../../state/community_hub_controller.dart';
import 'community_action_scaffold.dart';

class UploadVideoScreen extends StatefulWidget {
  const UploadVideoScreen({super.key});

  @override
  State<UploadVideoScreen> createState() => _UploadVideoScreenState();
}

class _UploadVideoScreenState extends State<UploadVideoScreen> {
  final TextEditingController _title = TextEditingController();
  final TextEditingController _description = TextEditingController();
  final TextEditingController _hashtags = TextEditingController();
  final TextEditingController _location = TextEditingController();

  bool _camera = true;
  bool _trim = true;
  bool _mute = false;
  bool _coverImage = true;
  bool _autoThumb = true;
  double _progress = 0.38;

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _hashtags.dispose();
    _location.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final CommunityActionScaffoldState? scaffold =
        CommunityActionScaffold.maybeOf(context);

    return CommunityActionScaffold(
      actionKey: 'upload_video',
      title: 'Upload Video',
      subtitle: 'Camera, trim, thumbnail, preview and publishing',
      heroTag: 'quick-action-Upload Video',
      icon: Icons.videocam_rounded,
      collectValues: () => <String, dynamic>{
        'title': _title.text,
        'description': _description.text,
        'hashtags': _hashtags.text,
        'location': _location.text,
        'camera': _camera,
        'trim': _trim,
        'mute': _mute,
        'coverImage': _coverImage,
        'autoThumb': _autoThumb,
        'progress': _progress,
      },
      applyDraft: (Map<String, dynamic> draft) {
        setState(() {
          _title.text = (draft['title'] ?? '') as String;
          _description.text = (draft['description'] ?? '') as String;
          _hashtags.text = (draft['hashtags'] ?? '') as String;
          _location.text = (draft['location'] ?? '') as String;
          _camera = (draft['camera'] ?? true) as bool;
          _trim = (draft['trim'] ?? true) as bool;
          _mute = (draft['mute'] ?? false) as bool;
          _coverImage = (draft['coverImage'] ?? true) as bool;
          _autoThumb = (draft['autoThumb'] ?? true) as bool;
          _progress = ((draft['progress'] ?? 0.38) as num).toDouble();
        });
      },
      validationBuilder: () {
        final List<String> errors = <String>[];
        if (_title.text.trim().isEmpty) {
          errors.add('Video title is required');
        }
        if (_description.text.trim().isEmpty) {
          errors.add('Description is required');
        }
        return errors;
      },
      formBuilder: (BuildContext context) {
        return Column(
          children: <Widget>[
            CommunityTextField(
              controller: _title,
              label: 'Video Title',
              maxLength: 100,
              onChanged: (_) => scaffold?.markDirty(),
            ),
            const SizedBox(height: 8),
            CommunityTextField(
              controller: _description,
              label: 'Description',
              maxLength: 400,
              maxLines: 4,
              onChanged: (_) => scaffold?.markDirty(),
            ),
            const SizedBox(height: 8),
            CommunityTextField(
              controller: _hashtags,
              label: 'Hashtags',
              hintText: '#civic #roadSafety',
              onChanged: (_) => scaffold?.markDirty(),
            ),
            const SizedBox(height: 8),
            CommunityTextField(
              controller: _location,
              label: 'Location',
              onChanged: (_) => scaffold?.markDirty(),
            ),
            const SizedBox(height: 10),
            SwitchListTile.adaptive(
              value: _camera,
              title: const Text('Use Camera Capture'),
              onChanged: (bool value) {
                setState(() => _camera = value);
                scaffold?.markDirty();
              },
            ),
            SwitchListTile.adaptive(
              value: _trim,
              title: const Text('Trim Video'),
              onChanged: (bool value) {
                setState(() => _trim = value);
                scaffold?.markDirty();
              },
            ),
            SwitchListTile.adaptive(
              value: _mute,
              title: const Text('Mute Video'),
              onChanged: (bool value) {
                setState(() => _mute = value);
                scaffold?.markDirty();
              },
            ),
            SwitchListTile.adaptive(
              value: _coverImage,
              title: const Text('Select Cover Image'),
              onChanged: (bool value) {
                setState(() => _coverImage = value);
                scaffold?.markDirty();
              },
            ),
            SwitchListTile.adaptive(
              value: _autoThumb,
              title: const Text('Auto-generate Thumbnail'),
              onChanged: (bool value) {
                setState(() => _autoThumb = value);
                scaffold?.markDirty();
              },
            ),
            const SizedBox(height: 6),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Upload Progress Simulation'),
              subtitle: LinearProgressIndicator(value: _progress),
            ),
            Slider(
              value: _progress,
              onChanged: (double value) {
                setState(() => _progress = value);
                scaffold?.markDirty();
              },
            ),
          ],
        );
      },
      previewBuilder: (BuildContext context, Map<String, dynamic> values) {
        return Card(
          child: ListTile(
            leading: const Icon(Icons.play_circle_fill_rounded),
            title: Text((values['title'] ?? '') as String),
            subtitle: Text((values['description'] ?? '') as String),
            trailing: Text('${(((values['progress'] ?? 0.0) as num).toDouble() * 100).round()}%'),
          ),
        );
      },
      onPublish: (BuildContext context, Map<String, dynamic> values) async {
        await Future<void>.delayed(const Duration(milliseconds: 800));
        if (!context.mounted) {
          return;
        }
        context.read<CommunityHubController>().publish(
              CommunityPublication(
                id: DateTime.now().microsecondsSinceEpoch.toString(),
                title: (values['title'] ?? 'Video') as String,
                description: (values['description'] ?? '') as String,
                type: CommunityContentType.video,
                targets: <CommunityTargetModule>{CommunityTargetModule.communityVideos},
                createdAt: DateTime.now(),
                authorName: 'You',
                location: (values['location'] ?? '') as String,
                metadata: values,
              ),
            );
      },
    );
  }
}
