import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../domain/models/community_hub_models.dart';
import '../../../state/community_hub_controller.dart';
import 'community_action_scaffold.dart';

class AskQuestionScreen extends StatefulWidget {
  const AskQuestionScreen({super.key});

  @override
  State<AskQuestionScreen> createState() => _AskQuestionScreenState();
}

class _AskQuestionScreenState extends State<AskQuestionScreen> {
  final TextEditingController _title = TextEditingController();
  final TextEditingController _question = TextEditingController();
  final TextEditingController _tags = TextEditingController();
  final TextEditingController _location = TextEditingController();
  String _category = 'Governance';
  bool _anonymous = false;
  bool _bestAnswer = true;
  bool _solvedStatus = false;

  @override
  void dispose() {
    _title.dispose();
    _question.dispose();
    _tags.dispose();
    _location.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final CommunityActionScaffoldState? scaffold =
        CommunityActionScaffold.maybeOf(context);

    return CommunityActionScaffold(
      actionKey: 'ask_question',
      title: 'Ask Question',
      subtitle: 'Q&A with category, tags, attachments and solved status',
      heroTag: 'quick-action-Ask Question',
      icon: Icons.help_center_rounded,
      collectValues: () => <String, dynamic>{
        'title': _title.text,
        'question': _question.text,
        'tags': _tags.text,
        'location': _location.text,
        'category': _category,
        'anonymous': _anonymous,
        'bestAnswer': _bestAnswer,
        'solvedStatus': _solvedStatus,
      },
      applyDraft: (Map<String, dynamic> draft) {
        setState(() {
          _title.text = (draft['title'] ?? '') as String;
          _question.text = (draft['question'] ?? '') as String;
          _tags.text = (draft['tags'] ?? '') as String;
          _location.text = (draft['location'] ?? '') as String;
          _category = (draft['category'] ?? 'Governance') as String;
          _anonymous = (draft['anonymous'] ?? false) as bool;
          _bestAnswer = (draft['bestAnswer'] ?? true) as bool;
          _solvedStatus = (draft['solvedStatus'] ?? false) as bool;
        });
      },
      validationBuilder: () {
        final List<String> errors = <String>[];
        if (_title.text.trim().isEmpty) {
          errors.add('Title is required');
        }
        if (_question.text.trim().isEmpty) {
          errors.add('Question is required');
        }
        return errors;
      },
      formBuilder: (BuildContext context) {
        return Column(
          children: <Widget>[
            CommunityTextField(
              controller: _title,
              label: 'Title',
              maxLength: 110,
              onChanged: (_) => scaffold?.markDirty(),
            ),
            const SizedBox(height: 8),
            CommunityTextField(
              controller: _question,
              label: 'Question',
              maxLength: 500,
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
              items: const <String>['Governance', 'Infrastructure', 'Health', 'Education']
                  .map((String value) => DropdownMenuItem<String>(value: value, child: Text(value)))
                  .toList(growable: false),
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
              controller: _tags,
              label: 'Tags',
              hintText: '#water #roads',
              onChanged: (_) => scaffold?.markDirty(),
            ),
            const SizedBox(height: 8),
            CommunityTextField(
              controller: _location,
              label: 'Location',
              onChanged: (_) => scaffold?.markDirty(),
            ),
            SwitchListTile.adaptive(
              value: _anonymous,
              title: const Text('Anonymous Mode'),
              onChanged: (bool value) {
                setState(() => _anonymous = value);
                scaffold?.markDirty();
              },
            ),
            SwitchListTile.adaptive(
              value: _bestAnswer,
              title: const Text('Enable Best Answer'),
              onChanged: (bool value) {
                setState(() => _bestAnswer = value);
                scaffold?.markDirty();
              },
            ),
            SwitchListTile.adaptive(
              value: _solvedStatus,
              title: const Text('Mark as Solved Status Ready'),
              onChanged: (bool value) {
                setState(() => _solvedStatus = value);
                scaffold?.markDirty();
              },
            ),
          ],
        );
      },
      previewBuilder: (BuildContext context, Map<String, dynamic> values) {
        return Card(
          child: ListTile(
            leading: const Icon(Icons.quiz_rounded),
            title: Text((values['title'] ?? '') as String),
            subtitle: Text((values['question'] ?? '') as String),
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
                title: (values['title'] ?? '') as String,
                description: (values['question'] ?? '') as String,
                type: CommunityContentType.question,
                targets: <CommunityTargetModule>{CommunityTargetModule.communityQuestions},
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
