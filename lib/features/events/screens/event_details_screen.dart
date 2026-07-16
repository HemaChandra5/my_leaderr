import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../models/event_model.dart';

class EventDetailsScreen extends StatefulWidget {
  const EventDetailsScreen({super.key, required this.event});

  final EventModel event;

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  bool _saved = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Event Details'),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              setState(() => _saved = !_saved);
            },
            icon: Icon(
              _saved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
              color: AppColors.primaryGold,
            ),
          ),
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Share link copied')),
              );
            },
            icon: Icon(Icons.share_rounded, color: AppColors.textPrimary),
          ),
        ],
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: Hero(
              tag: 'event_banner_${widget.event.id}',
              child: Container(
                height: 240,
                margin: const EdgeInsets.fromLTRB(16, 8, 16, 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  image: DecorationImage(
                    image: NetworkImage(widget.event.imageUrl),
                    fit: BoxFit.cover,
                    onError: (_, _) {},
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: <Color>[
                        Colors.black.withValues(alpha: 0.05),
                        Colors.black.withValues(alpha: 0.72),
                      ],
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Spacer(),
                        Text(
                          widget.event.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${widget.event.location} • ${widget.event.time}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 30),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                <Widget>[
                  _sectionCard(
                    title: 'Event Information',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        _line('Organizer', widget.event.organizer),
                        _line('Date', '${widget.event.date.day}/${widget.event.date.month}/${widget.event.date.year}'),
                        _line('Type', widget.event.isOnline ? 'Online' : 'Offline'),
                        _line('Fee', widget.event.isFree ? 'Free' : 'Paid'),
                      ],
                    ),
                  ),
                  _sectionCard(
                    title: 'Description',
                    child: Text(
                      widget.event.description,
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 14,
                        height: 1.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  _sectionCard(
                    title: 'Location Map',
                    child: Container(
                      height: 140,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Map placeholder',
                        style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  _sectionCard(
                    title: 'Gallery',
                    child: SizedBox(
                      height: 92,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: 5,
                        separatorBuilder: (_, _) => const SizedBox(width: 8),
                        itemBuilder: (BuildContext context, int index) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: SizedBox(
                              width: 130,
                              child: Image.network(
                                widget.event.imageUrl,
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  _sectionCard(
                    title: 'Speakers',
                    child: Column(
                      children: const <Widget>[
                        ListTile(title: Text('Anita Verma'), subtitle: Text('Leadership Coach')),
                        Divider(height: 1),
                        ListTile(title: Text('Rahul Iyer'), subtitle: Text('Policy Strategist')),
                        Divider(height: 1),
                        ListTile(title: Text('Kiran Mehta'), subtitle: Text('Civic Innovation Lead')),
                      ],
                    ),
                  ),
                  _sectionCard(
                    title: 'Agenda',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const <Widget>[
                        Text('10:00 AM - Welcome and opening remarks'),
                        SizedBox(height: 8),
                        Text('11:00 AM - Leadership panel discussion'),
                        SizedBox(height: 8),
                        Text('12:00 PM - Interactive workshop'),
                        SizedBox(height: 8),
                        Text('1:00 PM - Networking and closing'),
                      ],
                    ),
                  ),
                  _sectionCard(
                    title: 'FAQs',
                    child: Column(
                      children: const <Widget>[
                        ExpansionTile(
                          title: Text('Do I need to register in advance?'),
                          children: [Padding(padding: EdgeInsets.all(12), child: Text('Yes, registration is recommended due to limited seating.'))],
                        ),
                        ExpansionTile(
                          title: Text('Will materials be shared after event?'),
                          children: [Padding(padding: EdgeInsets.all(12), child: Text('Yes, digital materials are shared with all registered attendees.'))],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Registration successful')),
              );
            },
            icon: const Icon(Icons.how_to_reg_rounded),
            label: const Text('Register Now'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionCard({required String title, required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  Widget _line(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 96,
            child: Text(
              title,
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
