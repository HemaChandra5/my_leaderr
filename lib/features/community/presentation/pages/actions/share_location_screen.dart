import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../domain/models/community_hub_models.dart';
import '../../../state/community_hub_controller.dart';
import 'community_action_scaffold.dart';

class ShareLocationScreen extends StatefulWidget {
  const ShareLocationScreen({super.key});

  @override
  State<ShareLocationScreen> createState() => _ShareLocationScreenState();
}

class _ShareLocationScreenState extends State<ShareLocationScreen> {
  final TextEditingController _address = TextEditingController();
  final TextEditingController _landmark = TextEditingController();
  final TextEditingController _description = TextEditingController();
  bool _currentLocation = true;
  bool _pinDrop = true;

  @override
  void dispose() {
    _address.dispose();
    _landmark.dispose();
    _description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final CommunityActionScaffoldState? scaffold =
        CommunityActionScaffold.maybeOf(context);

    return CommunityActionScaffold(
      actionKey: 'share_location',
      title: 'Share Location',
      subtitle: 'Google Maps-ready location card with pin drop details',
      heroTag: 'quick-action-Share Location',
      icon: Icons.location_on_rounded,
      collectValues: () => <String, dynamic>{
        'address': _address.text,
        'landmark': _landmark.text,
        'description': _description.text,
        'currentLocation': _currentLocation,
        'pinDrop': _pinDrop,
      },
      applyDraft: (Map<String, dynamic> draft) {
        setState(() {
          _address.text = (draft['address'] ?? '') as String;
          _landmark.text = (draft['landmark'] ?? '') as String;
          _description.text = (draft['description'] ?? '') as String;
          _currentLocation = (draft['currentLocation'] ?? true) as bool;
          _pinDrop = (draft['pinDrop'] ?? true) as bool;
        });
      },
      validationBuilder: () {
        if (_address.text.trim().isEmpty) {
          return <String>['Address is required'];
        }
        return <String>[];
      },
      formBuilder: (BuildContext context) {
        return Column(
          children: <Widget>[
            Container(
              width: double.infinity,
              height: 170,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Theme.of(context).dividerColor),
                gradient: const LinearGradient(
                  colors: <Color>[Color(0xFFE6F3EA), Color(0xFFDDEBF8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Center(
                child: Icon(Icons.map_rounded, size: 44),
              ),
            ),
            const SizedBox(height: 10),
            CommunityTextField(
              controller: _address,
              label: 'Address',
              onChanged: (_) => scaffold?.markDirty(),
            ),
            const SizedBox(height: 8),
            CommunityTextField(
              controller: _landmark,
              label: 'Nearby Landmark',
              onChanged: (_) => scaffold?.markDirty(),
            ),
            const SizedBox(height: 8),
            CommunityTextField(
              controller: _description,
              label: 'Description',
              maxLines: 3,
              maxLength: 240,
              onChanged: (_) => scaffold?.markDirty(),
            ),
            SwitchListTile.adaptive(
              value: _currentLocation,
              title: const Text('Use Current Location'),
              onChanged: (bool value) {
                setState(() => _currentLocation = value);
                scaffold?.markDirty();
              },
            ),
            SwitchListTile.adaptive(
              value: _pinDrop,
              title: const Text('Enable Pin Drop'),
              onChanged: (bool value) {
                setState(() => _pinDrop = value);
                scaffold?.markDirty();
              },
            ),
          ],
        );
      },
      previewBuilder: (BuildContext context, Map<String, dynamic> values) {
        return Card(
          child: ListTile(
            leading: const Icon(Icons.place_rounded),
            title: Text((values['address'] ?? '') as String),
            subtitle: Text('Landmark: ${(values['landmark'] ?? '') as String}'),
          ),
        );
      },
      onPublish: (BuildContext context, Map<String, dynamic> values) async {
        await Future<void>.delayed(const Duration(milliseconds: 650));
        if (!context.mounted) {
          return;
        }
        context.read<CommunityHubController>().publish(
              CommunityPublication(
                id: DateTime.now().microsecondsSinceEpoch.toString(),
                title: 'Location Shared',
                description: (values['description'] ?? '') as String,
                type: CommunityContentType.location,
                targets: <CommunityTargetModule>{CommunityTargetModule.communityFeed},
                createdAt: DateTime.now(),
                authorName: 'You',
                location: (values['address'] ?? '') as String,
                metadata: values,
              ),
            );
      },
    );
  }
}
