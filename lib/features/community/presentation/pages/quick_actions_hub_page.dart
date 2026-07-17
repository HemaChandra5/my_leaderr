import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../navigation/community_action_routes.dart';

class QuickActionsHubPage extends StatelessWidget {
  const QuickActionsHubPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community Hub Actions'),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Launch premium creation workflows',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Each action opens a dedicated Material 3 page with draft, preview, and publish.',
                style: TextStyle(color: AppColors.textMuted),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: GridView.builder(
                  itemCount: _actions.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    mainAxisExtent: 124,
                  ),
                  itemBuilder: (BuildContext context, int index) {
                    final _HubAction action = _actions[index];
                    return Hero(
                      tag: action.heroTag,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: () => Navigator.of(context).pushNamed(action.route),
                          child: Ink(
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: AppColors.divider),
                              boxShadow: <BoxShadow>[
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.06),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  CircleAvatar(
                                    backgroundColor: AppColors.primaryGold.withValues(alpha: 0.16),
                                    child: Icon(action.icon, color: AppColors.primaryGold),
                                  ),
                                  const Spacer(),
                                  Text(
                                    action.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontWeight: FontWeight.w800),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HubAction {
  const _HubAction({
    required this.title,
    required this.route,
    required this.icon,
    required this.heroTag,
  });

  final String title;
  final String route;
  final IconData icon;
  final String heroTag;
}

const List<_HubAction> _actions = <_HubAction>[
  _HubAction(
    title: 'Create Post',
    route: CommunityActionRoutes.createPost,
    icon: Icons.edit_note_rounded,
    heroTag: 'quick-action-Create Post',
  ),
  _HubAction(
    title: 'Upload Video',
    route: CommunityActionRoutes.uploadVideo,
    icon: Icons.videocam_rounded,
    heroTag: 'quick-action-Upload Video',
  ),
  _HubAction(
    title: 'Upload Photos',
    route: CommunityActionRoutes.uploadPhotos,
    icon: Icons.photo_library_rounded,
    heroTag: 'quick-action-Upload Photos',
  ),
  _HubAction(
    title: 'Create Poll',
    route: CommunityActionRoutes.createPoll,
    icon: Icons.poll_rounded,
    heroTag: 'quick-action-Create Poll',
  ),
  _HubAction(
    title: 'Ask Question',
    route: CommunityActionRoutes.askQuestion,
    icon: Icons.help_center_rounded,
    heroTag: 'quick-action-Ask Question',
  ),
  _HubAction(
    title: 'Create Event',
    route: CommunityActionRoutes.createEvent,
    icon: Icons.event_available_rounded,
    heroTag: 'quick-action-Create Event',
  ),
  _HubAction(
    title: 'Report Issue',
    route: '/track',
    icon: Icons.report_problem_rounded,
    heroTag: 'quick-action-Report Issue',
  ),
  _HubAction(
    title: 'Leader Announcement',
    route: CommunityActionRoutes.leaderAnnouncement,
    icon: Icons.campaign_rounded,
    heroTag: 'quick-action-Announcement (Leader)',
  ),
  _HubAction(
    title: 'Share Location',
    route: CommunityActionRoutes.shareLocation,
    icon: Icons.location_on_rounded,
    heroTag: 'quick-action-Share Location',
  ),
  _HubAction(
    title: 'Start Discussion',
    route: CommunityActionRoutes.discussion,
    icon: Icons.forum_rounded,
    heroTag: 'quick-action-Start Discussion',
  ),
];
