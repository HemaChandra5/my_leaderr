import '../models/event_model.dart';

class EventService {
  const EventService();

  Future<List<EventModel>> fetchEvents() async {
    await Future<void>.delayed(const Duration(milliseconds: 850));

    final List<String> imagePool = <String>[
      'https://images.unsplash.com/photo-1523580846011-d3a5bc25702b?auto=format&fit=crop&w=1400&q=80',
      'https://images.unsplash.com/photo-1511578314322-379afb476865?auto=format&fit=crop&w=1400&q=80',
      'https://images.unsplash.com/photo-1540317580384-e5d43867caa6?auto=format&fit=crop&w=1400&q=80',
      'https://images.unsplash.com/photo-1515187029135-18ee286d815b?auto=format&fit=crop&w=1400&q=80',
      'https://images.unsplash.com/photo-1464375117522-1311dd6a989c?auto=format&fit=crop&w=1400&q=80',
      'https://images.unsplash.com/photo-1475721027785-f74eccf877e2?auto=format&fit=crop&w=1400&q=80',
      'https://images.unsplash.com/photo-1489515217757-5fd1be406fef?auto=format&fit=crop&w=1400&q=80',
      'https://images.unsplash.com/photo-1517048676732-d65bc937f952?auto=format&fit=crop&w=1400&q=80',
      'https://images.unsplash.com/photo-1521737604893-d14cc237f11d?auto=format&fit=crop&w=1400&q=80',
      'https://images.unsplash.com/photo-1552664730-d307ca884978?auto=format&fit=crop&w=1400&q=80',
      'https://images.unsplash.com/photo-1531058020387-3be344556be6?auto=format&fit=crop&w=1400&q=80',
      'https://images.unsplash.com/photo-1504384308090-c894fdcc538d?auto=format&fit=crop&w=1400&q=80',
    ];

    final DateTime now = DateTime.now();

    List<EventModel> buildCategory({
      required EventCategory category,
      required List<String> titles,
      required List<String> organizers,
      required List<String> locations,
      required int offsetDays,
      required Set<EventFilterTag> fixedTags,
    }) {
      return List<EventModel>.generate(10, (int index) {
        final DateTime date = now.add(Duration(days: offsetDays + index));
        final bool isFree = index.isEven;
        final bool isOnline = index % 3 == 0;
        final EventStatus status = index == 0
            ? EventStatus.live
            : (index < 7 ? EventStatus.upcoming : EventStatus.completed);

        final Set<EventFilterTag> tags = <EventFilterTag>{...fixedTags};
        tags.add(isFree ? EventFilterTag.free : EventFilterTag.paid);
        tags.add(isOnline ? EventFilterTag.online : EventFilterTag.offline);

        if (index % 2 == 0) {
          tags.add(EventFilterTag.training);
        }
        if (index % 3 == 0) {
          tags.add(EventFilterTag.workshop);
        }
        if (index % 5 == 0) {
          tags.add(EventFilterTag.seminar);
        }

        return EventModel(
          id: '${category.name}_$index',
          title: titles[index],
          description:
              '${titles[index]} brings civic leaders, volunteers, and domain experts together to collaborate on practical action plans and measurable outcomes for communities.',
          imageUrl: imagePool[(index + offsetDays) % imagePool.length],
          category: category,
          date: date,
          time: index.isEven ? '10:00 AM - 12:30 PM' : '3:00 PM - 6:00 PM',
          location: locations[index],
          organizer: organizers[index],
          interestedCount: 120 + (index * 47) + (offsetDays * 3),
          status: status,
          isFree: isFree,
          isOnline: isOnline,
          tags: tags,
        );
      });
    }

    final List<EventModel> local = buildCategory(
      category: EventCategory.local,
      offsetDays: 1,
      fixedTags: <EventFilterTag>{EventFilterTag.leadership},
      titles: const <String>[
        'Ward Leadership Meetup',
        'Local Civic Action Circle',
        'Neighborhood Policy Dialogue',
        'Community Leaders Connect',
        'Grassroots Innovation Hour',
        'Citizen Voice Roundtable',
        'Town Hall Strategy Session',
        'Volunteer Leadership Sprint',
        'Public Service Bootcamp',
        'Ward Problem Solving Forum',
      ],
      organizers: const <String>[
        'My Leader Hyderabad Chapter',
        'Citizens Collective Forum',
        'Ward Development Council',
        'Local Impact Foundation',
        'Urban Futures Lab',
        'People First Network',
        'Leadership Guild',
        'Community Growth Alliance',
        'Service Leaders Circle',
        'Local Vision Council',
      ],
      locations: const <String>[
        'Ameerpet Community Hall, Hyderabad',
        'Madhapur Convention Center, Hyderabad',
        'Banjara Hills Club House, Hyderabad',
        'Kukatpally Civic Center, Hyderabad',
        'Secunderabad Innovation Hub, Hyderabad',
        'Gachibowli Municipal Center, Hyderabad',
        'Begumpet Knowledge Hall, Hyderabad',
        'Nallagandla Public Forum, Hyderabad',
        'Kompally Leadership Arena, Hyderabad',
        'Miyapur Governance Hub, Hyderabad',
      ],
    );

    final List<EventModel> state = buildCategory(
      category: EventCategory.state,
      offsetDays: 4,
      fixedTags: <EventFilterTag>{EventFilterTag.career},
      titles: const <String>[
        'State Policy Leadership Summit',
        'District Officers Networking Day',
        'Statewide Governance Dialogue',
        'Public Sector Excellence Expo',
        'Leadership Capability Conclave',
        'State Transformation Workshop',
        'Chief Coordinators Forum',
        'Regional Governance Masterclass',
        'State Innovation Assembly',
        'People Centric Policy Meetup',
      ],
      organizers: const <String>[
        'State Governance Academy',
        'Telangana Policy Forum',
        'Civil Services Leadership Board',
        'Public Affairs Institute',
        'State Development Mission',
        'Leaders of Tomorrow Council',
        'State Talent Accelerator',
        'Administrative Excellence Hub',
        'Policy Design Network',
        'State Public Leadership Alliance',
      ],
      locations: const <String>[
        'Ravindra Bharathi, Hyderabad',
        'Vijayawada Convention Center, AP',
        'Visakhapatnam Public Hall, AP',
        'Warangal Knowledge Center, Telangana',
        'Nizamabad Leadership Hall, Telangana',
        'Khammam Development Center, Telangana',
        'Karimnagar Public Auditorium, Telangana',
        'Nalgonda Civic Plaza, Telangana',
        'Mahabubnagar Learning Hub, Telangana',
        'Tirupati Leadership Arena, AP',
      ],
    );

    final List<EventModel> national = buildCategory(
      category: EventCategory.national,
      offsetDays: 8,
      fixedTags: <EventFilterTag>{EventFilterTag.leadership},
      titles: const <String>[
        'National Leaders Forum',
        'India Civic Futures Conference',
        'Policy Impact National Summit',
        'Digital Governance India Meet',
        'National Leadership Exchange',
        'Public Innovation Grand Meetup',
        'National Social Leadership Day',
        'India Development Strategy Summit',
        'Nationwide Civic Collaboration Expo',
        'Future of Leadership Conclave',
      ],
      organizers: const <String>[
        'National Governance Council',
        'India Public Leadership Institute',
        'Civic Tech India',
        'Policy Futures Foundation',
        'National Affairs Forum',
        'Leadership India Network',
        'United Public Leaders Association',
        'Future India Governance Board',
        'National Reform Hub',
        'India Leadership Ecosystem',
      ],
      locations: const <String>[
        'Bharat Mandapam, New Delhi',
        'Jio World Convention Center, Mumbai',
        'BIEC Grounds, Bengaluru',
        'Science City Convention Hall, Kolkata',
        'Chennai Trade Center, Chennai',
        'Jaipur International Center, Jaipur',
        'Bhopal Policy Pavilion, Bhopal',
        'Guwahati Leadership Center, Guwahati',
        'Lucknow Global Hall, Lucknow',
        'Pune Innovation Plaza, Pune',
      ],
    );

    return <EventModel>[...local, ...state, ...national];
  }
}
