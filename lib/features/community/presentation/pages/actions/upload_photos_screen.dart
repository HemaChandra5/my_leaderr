import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../domain/models/community_hub_models.dart';
import '../../../state/community_hub_controller.dart';
import 'community_action_scaffold.dart';

class UploadPhotosScreen extends StatefulWidget {
  const UploadPhotosScreen({super.key});

  @override
  State<UploadPhotosScreen> createState() => _UploadPhotosScreenState();
}

class _UploadPhotosScreenState extends State<UploadPhotosScreen> {
  final TextEditingController _caption = TextEditingController();
  String _album = 'Community Updates';
  double _count = 3;
  bool _filters = true;
  bool _crop = true;
  bool _rotate = false;

  @override
  void dispose() {
    _caption.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final CommunityActionScaffoldState? scaffold =
        CommunityActionScaffold.maybeOf(context);

    return CommunityActionScaffold(
      actionKey: 'upload_photos',
      title: 'Upload Photos',
      subtitle: 'Single and multiple image upload with editing options',
      heroTag: 'quick-action-Upload Photos',
      icon: Icons.photo_library_rounded,
      collectValues: () => <String, dynamic>{
        'caption': _caption.text,
        'album': _album,
        'count': _count.round(),
        'filters': _filters,
        'crop': _crop,
        'rotate': _rotate,
      },
      applyDraft: (Map<String, dynamic> draft) {
        setState(() {
          _caption.text = (draft['caption'] ?? '') as String;
          _album = (draft['album'] ?? 'Community Updates') as String;
          _count = ((draft['count'] ?? 3) as num).toDouble();
          _filters = (draft['filters'] ?? true) as bool;
          _crop = (draft['crop'] ?? true) as bool;
          _rotate = (draft['rotate'] ?? false) as bool;
        });
      },
      validationBuilder: () {
        if (_caption.text.trim().isEmpty) {
          return <String>['Caption is required'];
        }
        return <String>[];
      },
      formBuilder: (BuildContext context) {
        return Column(
          children: <Widget>[
            CommunityTextField(
              controller: _caption,
              label: 'Caption',
              maxLength: 220,
              maxLines: 3,
              onChanged: (_) => scaffold?.markDirty(),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _album,
              decoration: const InputDecoration(
                labelText: 'Album',
                border: OutlineInputBorder(),
              ),
              items: const <String>[
                'Community Updates',
                'Ward Reports',
                'Volunteer Activities',
              ].map((String value) => DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  )).toList(growable: false),
              onChanged: (String? value) {
                if (value == null) {
                  return;
                }
                setState(() => _album = value);
                scaffold?.markDirty();
              },
            ),
            const SizedBox(height: 8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Number of Photos'),
              subtitle: Text('${_count.round()} selected'),
            ),
            Slider(
              value: _count,
              min: 1,
              max: 12,
              divisions: 11,
              label: '${_count.round()}',
              onChanged: (double value) {
                setState(() => _count = value);
                scaffold?.markDirty();
              },
            ),
            SwitchListTile.adaptive(
              value: _filters,
              title: const Text('Apply Filters'),
              onChanged: (bool value) {
                setState(() => _filters = value);
                scaffold?.markDirty();
              },
            ),
            SwitchListTile.adaptive(
              value: _crop,
              title: const Text('Crop Images'),
              onChanged: (bool value) {
                setState(() => _crop = value);
                scaffold?.markDirty();
              },
            ),
            SwitchListTile.adaptive(
              value: _rotate,
              title: const Text('Rotate Images'),
              onChanged: (bool value) {
                setState(() => _rotate = value);
                scaffold?.markDirty();
              },
            ),
          ],
        );
      },
      previewBuilder: (BuildContext context, Map<String, dynamic> values) {
        return Card(
          child: ListTile(
            leading: const Icon(Icons.collections_rounded),
            title: Text('Album: ${(values['album'] ?? '') as String}'),
            subtitle: Text('Caption: ${(values['caption'] ?? '') as String}'),
            trailing: Text('${values['count']} photos'),
          ),
        );
      },
      onPublish: (BuildContext context, Map<String, dynamic> values) async {
        await Future<void>.delayed(const Duration(milliseconds: 700));
        if (!context.mounted) {
          return;
        }
        context.read<CommunityHubController>().publish(
              CommunityPublication(
                id: DateTime.now().microsecondsSinceEpoch.toString(),
                title: 'Photo upload',
                description: (values['caption'] ?? '') as String,
                type: CommunityContentType.photos,
                targets: <CommunityTargetModule>{CommunityTargetModule.communityFeed},
                createdAt: DateTime.now(),
                authorName: 'You',
                metadata: values,
              ),
            );
      },
    );
  }
}
