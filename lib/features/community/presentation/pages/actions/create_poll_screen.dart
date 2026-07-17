import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../domain/models/community_hub_models.dart';
import '../../../state/community_hub_controller.dart';
import 'community_action_scaffold.dart';

class CreatePollScreen extends StatefulWidget {
  const CreatePollScreen({super.key});

  @override
  State<CreatePollScreen> createState() => _CreatePollScreenState();
}

class _CreatePollScreenState extends State<CreatePollScreen> {
  final TextEditingController _question = TextEditingController();
  final List<TextEditingController> _options = <TextEditingController>[
    TextEditingController(),
    TextEditingController(),
  ];
  bool _multipleChoice = false;
  bool _anonymous = false;
  String _expiry = '24 Hours';
  String _resultVisibility = 'After Vote';

  @override
  void dispose() {
    _question.dispose();
    for (final TextEditingController controller in _options) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addOption() {
    if (_options.length >= 6) {
      return;
    }
    setState(() => _options.add(TextEditingController()));
  }

  @override
  Widget build(BuildContext context) {
    final CommunityActionScaffoldState? scaffold =
        CommunityActionScaffold.maybeOf(context);

    return CommunityActionScaffold(
      actionKey: 'create_poll',
      title: 'Create Poll',
      subtitle: 'Single choice, multiple choice, anonymity and expiry',
      heroTag: 'quick-action-Create Poll',
      icon: Icons.poll_rounded,
      collectValues: () => <String, dynamic>{
        'question': _question.text,
        'options': _options.map((TextEditingController c) => c.text).toList(growable: false),
        'multipleChoice': _multipleChoice,
        'anonymous': _anonymous,
        'expiry': _expiry,
        'resultVisibility': _resultVisibility,
      },
      applyDraft: (Map<String, dynamic> draft) {
        setState(() {
          _question.text = (draft['question'] ?? '') as String;
          final List<String> optionValues = ((draft['options'] ?? <dynamic>[]) as List<dynamic>).cast<String>();
          if (optionValues.length >= 2) {
            for (final TextEditingController controller in _options) {
              controller.dispose();
            }
            _options
              ..clear()
              ..addAll(optionValues.map((String value) => TextEditingController(text: value)));
          }
          _multipleChoice = (draft['multipleChoice'] ?? false) as bool;
          _anonymous = (draft['anonymous'] ?? false) as bool;
          _expiry = (draft['expiry'] ?? '24 Hours') as String;
          _resultVisibility = (draft['resultVisibility'] ?? 'After Vote') as String;
        });
      },
      validationBuilder: () {
        final List<String> errors = <String>[];
        if (_question.text.trim().isEmpty) {
          errors.add('Poll question is required');
        }
        final int validOptions = _options.where((TextEditingController c) => c.text.trim().isNotEmpty).length;
        if (validOptions < 2) {
          errors.add('At least two options are required');
        }
        return errors;
      },
      formBuilder: (BuildContext context) {
        return Column(
          children: <Widget>[
            CommunityTextField(
              controller: _question,
              label: 'Question',
              maxLength: 140,
              maxLines: 3,
              onChanged: (_) => scaffold?.markDirty(),
            ),
            const SizedBox(height: 8),
            ..._options.asMap().entries.map(
              (MapEntry<int, TextEditingController> entry) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: CommunityTextField(
                  controller: entry.value,
                  label: 'Option ${entry.key + 1}',
                  onChanged: (_) => scaffold?.markDirty(),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: _addOption,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add Option'),
              ),
            ),
            SwitchListTile.adaptive(
              value: _multipleChoice,
              title: const Text('Multiple Choice'),
              onChanged: (bool value) {
                setState(() => _multipleChoice = value);
                scaffold?.markDirty();
              },
            ),
            SwitchListTile.adaptive(
              value: _anonymous,
              title: const Text('Anonymous Poll'),
              onChanged: (bool value) {
                setState(() => _anonymous = value);
                scaffold?.markDirty();
              },
            ),
            DropdownButtonFormField<String>(
              initialValue: _expiry,
              decoration: const InputDecoration(
                labelText: 'Poll Expiry',
                border: OutlineInputBorder(),
              ),
              items: const <String>['24 Hours', '3 Days', '7 Days']
                  .map((String value) => DropdownMenuItem<String>(value: value, child: Text(value)))
                  .toList(growable: false),
              onChanged: (String? value) {
                if (value == null) {
                  return;
                }
                setState(() => _expiry = value);
                scaffold?.markDirty();
              },
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _resultVisibility,
              decoration: const InputDecoration(
                labelText: 'Result Visibility',
                border: OutlineInputBorder(),
              ),
              items: const <String>['After Vote', 'After Poll Ends', 'Public']
                  .map((String value) => DropdownMenuItem<String>(value: value, child: Text(value)))
                  .toList(growable: false),
              onChanged: (String? value) {
                if (value == null) {
                  return;
                }
                setState(() => _resultVisibility = value);
                scaffold?.markDirty();
              },
            ),
          ],
        );
      },
      previewBuilder: (BuildContext context, Map<String, dynamic> values) {
        final List<dynamic> options = (values['options'] ?? <dynamic>[]) as List<dynamic>;
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text((values['question'] ?? '') as String, style: const TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                ...options.map((dynamic value) => ListTile(title: Text(value.toString()))),
              ],
            ),
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
                title: (values['question'] ?? '') as String,
                description: 'New poll published',
                type: CommunityContentType.poll,
                targets: <CommunityTargetModule>{
                  CommunityTargetModule.pollFeed,
                  CommunityTargetModule.communityFeed,
                },
                createdAt: DateTime.now(),
                authorName: 'You',
                metadata: values,
              ),
            );
      },
    );
  }
}
